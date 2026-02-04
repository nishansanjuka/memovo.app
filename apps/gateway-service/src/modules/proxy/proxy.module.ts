import {
  MiddlewareConsumer,
  Module,
  NestModule,
  RequestMethod,
} from '@nestjs/common';
import { UsersProxyController } from './controllers/users-proxy.controller';
import { JournalsProxyController } from './controllers/journals-proxy.controller';
import { LlmProxyController } from './controllers/llm-proxy.controller';
import { HealthProxyController } from './controllers/health-proxy.controller';
import { ExternalProxyController } from './controllers/external-proxy.controller';
import { ProxyService } from '../../shared/services/proxy.service';
import { ConfigService } from '../../shared/services/config.service';
import { AuthMiddleware } from '../../shared/middleware/auth.middleware';
import { PUBLIC_ROUTES } from '../../shared/config/service-registry';

@Module({
  controllers: [
    UsersProxyController,
    JournalsProxyController,
    LlmProxyController,
    HealthProxyController,
    ExternalProxyController,
  ],
  providers: [ProxyService, ConfigService],
  exports: [ProxyService],
})
export class ProxyModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    // Apply auth middleware to all proxy routes except public ones
    consumer
      .apply(AuthMiddleware)
      .exclude(
        // Health check endpoints
        { path: 'health', method: RequestMethod.GET },
        { path: 'health/all', method: RequestMethod.GET },
        { path: 'llm/healthcheck', method: RequestMethod.GET },
        { path: 'gateway/health', method: RequestMethod.GET },
        // OpenAPI spec endpoints
        { path: 'api-json', method: RequestMethod.GET },
        { path: 'api/v1/external-auth/callback/*', method: RequestMethod.GET },
      )
      .forRoutes(
        { path: 'api/v1/*', method: RequestMethod.ALL },
        { path: 'llm/*', method: RequestMethod.ALL },
      );
  }
}
