import { Controller, Post } from '@nestjs/common';
import { ApiExcludeController } from '@nestjs/swagger';
import { ClerkWebhookUseCase } from '../application/webhooks.handle.use-case';
import { CatchEntityErrors } from '../../../shared/decorators/exception.catcher';
import { ClerkEvent } from '../../../shared/decorators/auth.decorator';
import { type WebhookEvent } from '@clerk/express';

@ApiExcludeController()
@Controller('api/webhooks')
export class ClerkWebhookController {
  constructor(private readonly webhookUseCase: ClerkWebhookUseCase) { }

  @Post('clerk')
  @CatchEntityErrors()
  async handleWebhook(@ClerkEvent() event: WebhookEvent) {
    return await this.webhookUseCase.handleWebhook(event);
  }
}
