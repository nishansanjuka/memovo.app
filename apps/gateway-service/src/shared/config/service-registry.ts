import type { BaseConfig } from '../env';

/**
 * Supported backend service types
 */
export type ServiceType = 'api' | 'llm';

/**
 * Service configuration definition
 */
export interface ServiceConfig {
  /** Base URL for the service */
  baseUrl: string;
  /** Path to OpenAPI spec endpoint */
  openApiPath?: string;
  /** Route prefix for this service in gateway */
  gatewayPrefix: string;
  /** Whether to strip the gateway prefix when forwarding */
  stripPrefix: boolean;
  /** Description for documentation */
  description: string;
  /** Default timeout in milliseconds */
  timeout?: number;
  /** Whether this service supports streaming */
  supportsStreaming?: boolean;
}

/**
 * Route mapping configuration
 */
export interface RouteMapping {
  /** Gateway route pattern (e.g., '/api/v1/**') */
  pattern: string;
  /** Target service */
  service: ServiceType;
  /** Whether authentication is required */
  requiresAuth: boolean;
  /** HTTP methods allowed (empty = all) */
  methods?: string[];
  /** Whether to stream responses */
  stream?: boolean;
}

/**
 * Service Registry - Central configuration for all backend services
 */
export class ServiceRegistry {
  private readonly services: Map<ServiceType, ServiceConfig>;
  private readonly routes: RouteMapping[];

  constructor(private readonly baseConfig: BaseConfig) {
    this.services = this.initializeServices();
    this.routes = this.initializeRoutes();
  }

  /**
   * Initialize service configurations from environment
   */
  private initializeServices(): Map<ServiceType, ServiceConfig> {
    return new Map<ServiceType, ServiceConfig>([
      [
        'api',
        {
          baseUrl: this.baseConfig.apiUrl,
          openApiPath: '/api-docs',
          gatewayPrefix: '/api/v1',
          stripPrefix: false,
          description: 'Main API Service (Spring Boot)',
          timeout: 30000,
        },
      ],
      [
        'llm',
        {
          baseUrl: this.baseConfig.llmServiceUrl,
          openApiPath: '/api-json',
          gatewayPrefix: '/llm',
          stripPrefix: true,
          description: 'LLM Service (FastAPI)',
          timeout: 120000, // Longer timeout for LLM operations
          supportsStreaming: true,
        },
      ],
    ]);
  }

  /**
   * Initialize route mappings
   */
  private initializeRoutes(): RouteMapping[] {
    return [
      // Health endpoints - no auth required
      {
        pattern: '/health',
        service: 'api',
        requiresAuth: false,
      },
      {
        pattern: '/llm/healthcheck',
        service: 'llm',
        requiresAuth: false,
      },

      // API Service routes
      {
        pattern: '/api/v1/users',
        service: 'api',
        requiresAuth: true,
      },
      {
        pattern: '/api/v1/users/:id',
        service: 'api',
        requiresAuth: true,
      },
      {
        pattern: '/api/v1/journals',
        service: 'api',
        requiresAuth: true,
      },
      {
        pattern: '/api/v1/journals/:journalId',
        service: 'api',
        requiresAuth: true,
      },

      // LLM Service routes
      {
        pattern: '/llm/chat',
        service: 'llm',
        requiresAuth: true,
        methods: ['POST'],
        stream: true,
      },
      {
        pattern: '/llm/working-memory',
        service: 'llm',
        requiresAuth: true,
      },
      {
        pattern: '/llm/working-memory/:id',
        service: 'llm',
        requiresAuth: true,
      },
      {
        pattern: '/llm/episodic-memory',
        service: 'llm',
        requiresAuth: true,
      },
      {
        pattern: '/llm/episodic-memory/:id',
        service: 'llm',
        requiresAuth: true,
      },
      {
        pattern: '/llm/semantic-memory',
        service: 'llm',
        requiresAuth: true,
      },
      {
        pattern: '/llm/semantic-memory/:id',
        service: 'llm',
        requiresAuth: true,
      },
    ];
  }

  /**
   * Get service configuration by type
   */
  getServiceConfig(service: ServiceType): ServiceConfig {
    const config = this.services.get(service);
    if (!config) {
      throw new Error(`Unknown service: ${service}`);
    }
    return config;
  }

  /**
   * Get service base URL
   */
  getServiceUrl(service: ServiceType): string {
    return this.getServiceConfig(service).baseUrl;
  }

  /**
   * Get OpenAPI spec path for a service
   */
  getOpenApiPath(service: ServiceType): string | undefined {
    return this.getServiceConfig(service).openApiPath;
  }

  /**
   * Get all registered services
   */
  getAllServices(): Map<ServiceType, ServiceConfig> {
    return this.services;
  }

  /**
   * Get all route mappings
   */
  getRoutes(): RouteMapping[] {
    return this.routes;
  }

  /**
   * Find route mapping for a given path
   */
  findRoute(path: string, method: string): RouteMapping | undefined {
    return this.routes.find((route) => {
      // Simple pattern matching (could be enhanced with path-to-regexp)
      const patternRegex = this.patternToRegex(route.pattern);
      const pathMatches = patternRegex.test(path);

      const methodMatches =
        !route.methods ||
        route.methods.length === 0 ||
        route.methods.includes(method.toUpperCase());

      return pathMatches && methodMatches;
    });
  }

  /**
   * Convert route pattern to regex
   */
  private patternToRegex(pattern: string): RegExp {
    const regexPattern = pattern
      .replace(/\*\*/g, '.*')
      .replace(/:\w+/g, '[^/]+')
      .replace(/\//g, '\\/');
    return new RegExp(`^${regexPattern}$`);
  }

  /**
   * Determine service from path
   */
  getServiceFromPath(path: string): ServiceType | null {
    if (path.startsWith('/api/v1') || path === '/health') {
      return 'api';
    }
    if (path.startsWith('/llm')) {
      return 'llm';
    }
    return null;
  }

  /**
   * Get the prefix to strip when forwarding to a service
   */
  getStripPrefix(service: ServiceType): string | undefined {
    const config = this.getServiceConfig(service);
    return config.stripPrefix ? config.gatewayPrefix : undefined;
  }
}

/**
 * Gateway route prefixes (for documentation and module configuration)
 */
export const GATEWAY_ROUTES = {
  API_V1: '/api/v1',
  LLM: '/llm',
  WEBHOOKS: '/api/webhooks',
  HEALTH: '/health',
} as const;

/**
 * Public routes that don't require authentication
 */
export const PUBLIC_ROUTES = [
  '/health',
  '/api-json',
  '/llm/healthcheck',
] as const;

/**
 * Check if a path is a public route
 */
export function isPublicRoute(path: string): boolean {
  return PUBLIC_ROUTES.some(
    (route) => path === route || path.startsWith(`${route}?`),
  );
}
