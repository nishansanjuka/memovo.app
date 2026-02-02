import {
  Controller,
  Get,
  Req,
  Res,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { ProxyService } from '../../../shared/services/proxy.service';

/**
 * Health Controller
 * Provides health check endpoints for all services
 */
@ApiTags('Health')
@Controller()
export class HealthProxyController {
  constructor(private readonly proxyService: ProxyService) {}

  // ============================================
  // Gateway Health
  // ============================================

  @Get('gateway/health')
  @ApiOperation({
    summary: 'Gateway Health Check',
    description: 'Returns health status of the gateway service itself.',
  })
  @ApiResponse({
    status: 200,
    description: 'Gateway is healthy',
    schema: {
      type: 'object',
      properties: {
        status: { type: 'string', example: 'ok' },
        service: { type: 'string', example: 'gateway' },
        timestamp: { type: 'string', example: '2026-02-02T12:00:00.000Z' },
      },
    },
  })
  @HttpCode(HttpStatus.OK)
  gatewayHealth(): { status: string; service: string; timestamp: string } {
    return {
      status: 'ok',
      service: 'gateway',
      timestamp: new Date().toISOString(),
    };
  }

  // ============================================
  // API Service Health (Spring Boot)
  // ============================================

  @Get('health')
  @ApiOperation({
    summary: 'API Service Health Check',
    description:
      'Returns health status from the Spring Boot API service. Useful for load balancers and monitoring.',
  })
  @ApiResponse({
    status: 200,
    description: 'API service is healthy',
    schema: {
      type: 'object',
      properties: {
        status: { type: 'string', example: 'UP' },
        database: { type: 'string', example: 'UP' },
      },
    },
  })
  @ApiResponse({ status: 502, description: 'API service unavailable' })
  @HttpCode(HttpStatus.OK)
  async apiHealth(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'api',
      timeout: 5000,
    });
  }

  // ============================================
  // Aggregated Health (All Services)
  // ============================================

  @Get('health/all')
  @ApiOperation({
    summary: 'Aggregated Health Check',
    description:
      'Returns health status of all backend services (Gateway, API, LLM). Useful for comprehensive monitoring.',
  })
  @ApiResponse({
    status: 200,
    description: 'All services health status',
    schema: {
      type: 'object',
      properties: {
        status: { type: 'string', example: 'ok' },
        timestamp: { type: 'string', example: '2026-02-02T12:00:00.000Z' },
        services: {
          type: 'object',
          properties: {
            gateway: {
              type: 'object',
              properties: {
                status: { type: 'string', example: 'ok' },
              },
            },
            api: {
              type: 'object',
              properties: {
                status: { type: 'string', example: 'ok' },
                latency: { type: 'number', example: 45 },
              },
            },
            llm: {
              type: 'object',
              properties: {
                status: { type: 'string', example: 'ok' },
                latency: { type: 'number', example: 120 },
              },
            },
          },
        },
      },
    },
  })
  @HttpCode(HttpStatus.OK)
  async aggregatedHealth(): Promise<{
    status: string;
    timestamp: string;
    services: {
      gateway: { status: string };
      api: { status: string; latency?: number; error?: string };
      llm: { status: string; latency?: number; error?: string };
    };
  }> {
    const timestamp = new Date().toISOString();
    const services: {
      gateway: { status: string };
      api: { status: string; latency?: number; error?: string };
      llm: { status: string; latency?: number; error?: string };
    } = {
      gateway: { status: 'ok' },
      api: { status: 'unknown' },
      llm: { status: 'unknown' },
    };

    // Check API service
    try {
      const apiStart = Date.now();
      const apiResponse = await fetch(
        `${process.env.API_SERVICE_URL || 'http://localhost:8080'}/health`,
        { signal: AbortSignal.timeout(5000) },
      );
      services.api.latency = Date.now() - apiStart;
      services.api.status = apiResponse.ok ? 'ok' : 'unhealthy';
    } catch (error) {
      services.api.status = 'unavailable';
      services.api.error =
        error instanceof Error ? error.message : 'Unknown error';
    }

    // Check LLM service
    try {
      const llmStart = Date.now();
      const llmResponse = await fetch(
        `${process.env.LLM_SERVICE_URL || 'http://localhost:8000'}/healthcheck`,
        { signal: AbortSignal.timeout(5000) },
      );
      services.llm.latency = Date.now() - llmStart;
      services.llm.status = llmResponse.ok ? 'ok' : 'unhealthy';
    } catch (error) {
      services.llm.status = 'unavailable';
      services.llm.error =
        error instanceof Error ? error.message : 'Unknown error';
    }

    // Determine overall status
    const allOk = services.api.status === 'ok' && services.llm.status === 'ok';
    const status = allOk ? 'ok' : 'degraded';

    return { status, timestamp, services };
  }
}
