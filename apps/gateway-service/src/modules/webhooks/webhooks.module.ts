import {
  MiddlewareConsumer,
  Module,
  NestModule,
  RequestMethod,
} from '@nestjs/common';
import { WebhookSignatureMiddleware } from '../../shared/middleware/webhooks.middleware';
import { ClerkWebhookService } from './infrastructure/webhook.service';
import { ClerkWebhookController } from './presentation/webhooks.controller';
import { ClerkWebhookUseCase } from './application/webhooks.handle.use-case';
import { ConfigService } from '../../shared/services/config.service';

@Module({
  imports: [],
  controllers: [ClerkWebhookController],
  providers: [ConfigService, ClerkWebhookService, ClerkWebhookUseCase],
})
export class WebhooksModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(WebhookSignatureMiddleware).forRoutes({
      path: '/api/webhooks/clerk',
      method: RequestMethod.ALL,
    });
  }
}
