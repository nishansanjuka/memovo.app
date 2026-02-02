import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule, OpenAPIObject } from '@nestjs/swagger';
import * as express from 'express';
import { baseConfig } from './shared/env';
import { Logger } from '@nestjs/common';

const logger = new Logger('Bootstrap');

/**
 * Fetch OpenAPI spec from a backend service
 */
async function fetchOpenApiSpec(
  serviceUrl: string,
  specPath: string,
  apiKey: string,
): Promise<OpenAPIObject | null> {
  try {
    const response = await fetch(`${serviceUrl}${specPath}`, {
      headers: {
        Accept: 'application/json',
        'x-api-key': apiKey,
      },
    });

    if (!response.ok) {
      logger.warn(
        `Failed to fetch OpenAPI spec from ${serviceUrl}${specPath}: ${response.status}`,
      );
      return null;
    }

    return (await response.json()) as OpenAPIObject;
  } catch (error) {
    logger.warn(
      `Error fetching OpenAPI spec from ${serviceUrl}${specPath}:`,
      error,
    );
    return null;
  }
}

/**
 * Transform paths from a backend service spec to include gateway prefix
 */
function transformPaths(
  paths: OpenAPIObject['paths'],
  prefix: string,
): OpenAPIObject['paths'] {
  if (!paths) return {};

  const transformed: OpenAPIObject['paths'] = {};

  for (const [path, operations] of Object.entries(paths)) {
    // Apply prefix transformation for LLM service
    const newPath = prefix ? `${prefix}${path}` : path;
    transformed[newPath] = operations;
  }

  return transformed;
}

/**
 * Merge OpenAPI specs from multiple services into a single spec
 * Note: We don't merge API service paths/tags since the gateway defines its own
 * documented proxy endpoints. We only merge schemas for reference.
 * LLM service paths are merged with /llm prefix.
 */
function mergeOpenApiSpecs(
  baseSpec: OpenAPIObject,
  apiSpec: OpenAPIObject | null,
  llmSpec: OpenAPIObject | null,
): OpenAPIObject {
  const mergedSpec: OpenAPIObject = {
    ...baseSpec,
    paths: { ...baseSpec.paths },
    components: {
      ...baseSpec.components,
      schemas: { ...baseSpec.components?.schemas },
    },
  };

  // Merge API service spec - only schemas, not paths/tags
  // (Gateway has its own documented proxy endpoints under "API Service" tag)
  if (apiSpec) {
    // Merge schemas for reference
    if (apiSpec.components?.schemas) {
      mergedSpec.components = {
        ...mergedSpec.components,
        schemas: {
          ...mergedSpec.components?.schemas,
          ...apiSpec.components.schemas,
        },
      };
    }
    // Don't merge paths or tags - gateway defines its own
  }

  // Merge LLM service spec - only schemas, not paths/tags
  // (Gateway has its own documented proxy endpoints under "LLM Service" tag)
  if (llmSpec) {
    // Merge schemas with LLM prefix to avoid conflicts
    if (llmSpec.components?.schemas) {
      const llmSchemas = Object.fromEntries(
        Object.entries(llmSpec.components.schemas).map(([name, schema]) => [
          `LLM_${name}`,
          schema,
        ]),
      );
      mergedSpec.components = {
        ...mergedSpec.components,
        schemas: {
          ...mergedSpec.components?.schemas,
          ...llmSchemas,
        },
      };
    }
    // Don't merge paths or tags - gateway defines its own
  }

  return mergedSpec;
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({ origin: '*', credentials: true });

  // Get config
  const config = baseConfig();

  // Build base Gateway OpenAPI spec
  const gatewayDocConfig = new DocumentBuilder()
    .setTitle('Memovo Gateway Service API')
    .setDescription(
      'OpenAPI documentation for the Memovo Gateway Service.\n\n' +
        '## Overview\n' +
        'This gateway aggregates documentation from all backend microservices:\n' +
        '- **API Service** (`/api/v1/**`) - Spring Boot business logic\n' +
        '- **LLM Service** (`/llm/**`) - FastAPI AI/ML capabilities\n\n' +
        '## Authentication\n' +
        '- Most routes require a Bearer token (JWT) in the Authorization header.\n' +
        '- The Clerk webhook route (/api/webhooks/clerk) uses a custom webhook authentication scheme, requiring the following headers:\n' +
        '    - svix-id: Unique Svix webhook event ID\n' +
        '    - svix-timestamp: Timestamp of the Svix webhook event\n' +
        '    - svix-signature: Signature for verifying the Svix webhook event\n' +
        '\nRefer to each route for specific requirements.',
    )
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        in: 'header',
      },
      'Authorization',
    )
    .addApiKey(
      {
        type: 'apiKey',
        in: 'header',
        name: 'svix-signature',
        description:
          'Svix webhook signature. Also requires svix-id and svix-timestamp headers.',
      },
      'webhook',
    )
    .addServer(process.env.API_URL || 'http://localhost:4000')
    .build();

  const gatewayDocument = SwaggerModule.createDocument(app, gatewayDocConfig, {
    deepScanRoutes: true,
  });

  // Cache for merged spec
  let cachedMergedSpec: OpenAPIObject | null = null;
  let lastFetchTime = 0;
  const CACHE_TTL = 60000; // 1 minute cache

  // Expose the OpenAPI JSON with aggregated specs from backend services
  app
    .getHttpAdapter()
    .get('/api-json', async (req: express.Request, res: express.Response) => {
      const now = Date.now();

      // Return cached spec if still valid
      if (cachedMergedSpec && now - lastFetchTime < CACHE_TTL) {
        res.json(cachedMergedSpec);
        return;
      }

      try {
        // Fetch specs from backend services in parallel
        const [apiSpec, llmSpec] = await Promise.all([
          fetchOpenApiSpec(config.apiUrl, '/api-docs', config.apiKey),
          fetchOpenApiSpec(config.llmServiceUrl, '/api-json', config.apiKey),
        ]);

        // Merge all specs
        cachedMergedSpec = mergeOpenApiSpecs(gatewayDocument, apiSpec, llmSpec);
        lastFetchTime = now;

        res.json(cachedMergedSpec);
      } catch (error) {
        logger.error('Error generating merged OpenAPI spec:', error);
        // Return gateway-only spec as fallback
        res.json(gatewayDocument);
      }
    });

  // Individual service specs (for debugging)
  app
    .getHttpAdapter()
    .get('/api-json/gateway', (req: express.Request, res: express.Response) => {
      res.json(gatewayDocument);
    });

  await app.listen(process.env.PORT ?? 4000);
  logger.log(`Gateway service running on port ${process.env.PORT ?? 4000}`);
}

bootstrap();
