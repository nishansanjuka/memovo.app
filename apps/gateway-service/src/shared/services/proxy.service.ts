import { Injectable, Logger, HttpStatus } from '@nestjs/common';
import { Request, Response } from 'express';
import { ConfigService } from './config.service';
import { ServiceType, ServiceRegistry } from '../config/service-registry';

export interface ProxyOptions {
  service: ServiceType;
  stripPrefix?: string;
  additionalHeaders?: Record<string, string>;
  stream?: boolean;
  timeout?: number;
  /** Whether to inject authenticated user ID into body/query params. Default: true */
  injectUserId?: boolean;
}

export interface ProxyResult {
  status: number;
  headers: Record<string, string>;
  body: unknown;
}

/** Fields that should be replaced with authenticated user ID for security */
const USER_ID_FIELDS = ['userId', 'user_id', 'userid'] as const;

@Injectable()
export class ProxyService {
  private readonly logger = new Logger(ProxyService.name);
  private readonly serviceRegistry: ServiceRegistry;

  constructor(private readonly configService: ConfigService) {
    const baseConfig = this.configService.get('base');
    this.serviceRegistry = new ServiceRegistry(baseConfig);
  }

  async proxyRequest(
    req: Request,
    res: Response,
    options: ProxyOptions,
  ): Promise<void> {
    const service = options.service;
    const stripPrefix = options.stripPrefix;
    const additionalHeaders = options.additionalHeaders || {};
    const stream = options.stream || false;
    const timeout = options.timeout || 30000;
    const injectUserId = options.injectUserId !== false; // Default true

    // Get authenticated user ID
    const authenticatedUserId = req.user?.userId;

    // Build URL with potentially injected userId in query params
    const targetUrl = this.buildTargetUrl(
      req,
      service,
      stripPrefix,
      injectUserId ? authenticatedUserId : undefined,
    );
    const headers = this.buildHeaders(req, additionalHeaders);

    this.logger.debug(
      `Proxying ${req.method} ${req.originalUrl} -> ${targetUrl}`,
    );

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      const fetchOptions: RequestInit = {
        method: req.method,
        headers,
        signal: controller.signal,
      };

      if (!['GET', 'HEAD'].includes(req.method) && req.body) {
        // Inject userId into body if needed
        const rawBody = req.body as Record<string, unknown>;
        const body = injectUserId
          ? this.injectUserIdIntoBody(rawBody, authenticatedUserId)
          : rawBody;
        fetchOptions.body = JSON.stringify(body);
      }

      const response = await fetch(targetUrl, fetchOptions);
      clearTimeout(timeoutId);

      this.copyResponseHeaders(response, res);

      if (stream) {
        await this.streamResponse(response, res);
      } else {
        await this.sendResponse(response, res);
      }
    } catch (error) {
      this.handleProxyError(error, res, targetUrl);
    }
  }

  /**
   * Injects the authenticated user ID into request body if it contains userId fields.
   * This ensures users can't spoof other user IDs in requests.
   */
  private injectUserIdIntoBody(
    body: Record<string, unknown>,
    authenticatedUserId: string | null | undefined,
  ): Record<string, unknown> {
    if (!authenticatedUserId || !body || typeof body !== 'object') {
      return body;
    }

    const modifiedBody = { ...body };
    let injected = false;

    for (const field of USER_ID_FIELDS) {
      if (field in modifiedBody) {
        modifiedBody[field] = authenticatedUserId;
        injected = true;
      }
    }

    if (injected) {
      this.logger.debug(
        `Injected authenticated userId into request body: ${authenticatedUserId}`,
      );
    }

    return modifiedBody;
  }

  /**
   * Builds the target URL, injecting authenticated userId into path and query params.
   * - Replaces path params like /users/:id with authenticated user's ID
   * - Replaces any existing userId query param with the authenticated user's ID
   * - Adds userId as query param for GET requests to user-specific endpoints
   */
  private buildTargetUrl(
    req: Request,
    service: ServiceType,
    stripPrefix?: string,
    authenticatedUserId?: string | null,
  ): string {
    const baseUrl = this.serviceRegistry.getServiceUrl(service);
    let path = req.originalUrl;

    if (stripPrefix && path.startsWith(stripPrefix)) {
      path = path.substring(stripPrefix.length) || '/';
    }

    // Inject userId into path and query params if user is authenticated
    if (authenticatedUserId) {
      const url = new URL(path, 'http://placeholder');
      let modified = false;

      // Replace path parameter for /users/:id endpoint
      // Pattern: /api/v1/users/{someId} -> /api/v1/users/{authenticatedUserId}
      const usersPathMatch = url.pathname.match(
        /^(\/api\/v1\/users\/)([^/]+)(\/.*)?$/,
      );
      if (usersPathMatch) {
        const [, prefix, , suffix = ''] = usersPathMatch;
        url.pathname = `${prefix}${authenticatedUserId}${suffix}`;
        modified = true;
        this.logger.debug(`Replaced userId in path: ${url.pathname}`);
      }

      // Replace any existing userId fields in query params
      for (const field of USER_ID_FIELDS) {
        if (url.searchParams.has(field)) {
          url.searchParams.set(field, authenticatedUserId);
          modified = true;
        }
      }

      // For GET requests, add userId if not present but endpoint likely needs it
      // Check if this is a user-specific endpoint (journals, memory, etc.)
      if (req.method === 'GET' && !modified) {
        const userEndpoints = [
          '/journals',
          '/working-memory',
          '/episodic-memory',
          '/semantic-memory',
        ];
        const needsUserId = userEndpoints.some((ep) =>
          url.pathname.includes(ep),
        );

        if (needsUserId) {
          url.searchParams.set('userId', authenticatedUserId);
          modified = true;
        }
      }

      if (modified) {
        this.logger.debug(
          `Injected authenticated userId into query params: ${authenticatedUserId}`,
        );
        path = url.pathname + url.search;
      }
    }

    return `${baseUrl}${path}`;
  }

  private buildHeaders(
    req: Request,
    additionalHeaders: Record<string, string>,
  ): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      Accept: req.headers.accept || 'application/json',
    };

    if (req.headers.authorization) {
      headers['Authorization'] = req.headers.authorization;
    }

    const apiKey = this.configService.get('base').apiKey;
    if (apiKey) {
      headers['x-api-key'] = apiKey;
    }

    if (req.user?.userId) {
      headers['x-user-id'] = req.user.userId;
    }

    const traceHeaders = [
      'x-request-id',
      'x-correlation-id',
      'x-trace-id',
      'x-span-id',
    ];
    for (const header of traceHeaders) {
      const value = req.headers[header];
      if (typeof value === 'string') {
        headers[header] = value;
      }
    }

    Object.assign(headers, additionalHeaders);

    return headers;
  }

  private copyResponseHeaders(
    response: globalThis.Response,
    res: Response,
  ): void {
    const headersToSkip = new Set([
      'content-encoding',
      'content-length',
      'transfer-encoding',
      'connection',
    ]);

    response.headers.forEach((value, key) => {
      if (!headersToSkip.has(key.toLowerCase())) {
        res.setHeader(key, value);
      }
    });
  }

  private async streamResponse(
    response: globalThis.Response,
    res: Response,
  ): Promise<void> {
    res.status(response.status);

    if (!response.body) {
      res.end();
      return;
    }

    const reader = response.body.getReader();

    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        res.write(value);
      }
      res.end();
    } catch (error) {
      this.logger.error('Stream error:', error);
      if (!res.headersSent) {
        res.status(502).json({ error: 'Stream interrupted' });
      }
    }
  }

  private async sendResponse(
    response: globalThis.Response,
    res: Response,
  ): Promise<void> {
    res.status(response.status);

    const contentType = response.headers.get('content-type') || '';

    if (contentType.includes('application/json')) {
      try {
        const json = (await response.json()) as unknown;
        res.json(json);
      } catch {
        res.end();
      }
    } else {
      const text = await response.text();
      res.send(text);
    }
  }

  private handleProxyError(
    error: unknown,
    res: Response,
    targetUrl: string,
  ): void {
    this.logger.error(`Proxy error for ${targetUrl}:`, error);

    if (error instanceof Error) {
      if (error.name === 'AbortError') {
        res.status(HttpStatus.GATEWAY_TIMEOUT).json({
          statusCode: HttpStatus.GATEWAY_TIMEOUT,
          message: 'Request timeout',
          error: 'Gateway Timeout',
        });
        return;
      }

      if (error.message.includes('ECONNREFUSED')) {
        res.status(HttpStatus.SERVICE_UNAVAILABLE).json({
          statusCode: HttpStatus.SERVICE_UNAVAILABLE,
          message: 'Service unavailable',
          error: 'Service Unavailable',
        });
        return;
      }
    }

    res.status(HttpStatus.BAD_GATEWAY).json({
      statusCode: HttpStatus.BAD_GATEWAY,
      message: 'Failed to connect to upstream service',
      error: 'Bad Gateway',
    });
  }

  async fetchOpenApiSpec(
    service: ServiceType,
  ): Promise<Record<string, unknown> | null> {
    const specPath = this.serviceRegistry.getOpenApiPath(service);
    if (!specPath) {
      return null;
    }

    const baseUrl = this.serviceRegistry.getServiceUrl(service);
    const url = `${baseUrl}${specPath}`;

    try {
      const response = await fetch(url, {
        headers: {
          Accept: 'application/json',
          'x-api-key': this.configService.get('base').apiKey,
        },
      });

      if (!response.ok) {
        this.logger.warn(
          `Failed to fetch OpenAPI spec from ${url}: ${response.status}`,
        );
        return null;
      }

      return (await response.json()) as Record<string, unknown>;
    } catch (error) {
      this.logger.error(`Error fetching OpenAPI spec from ${url}:`, error);
      return null;
    }
  }
}
