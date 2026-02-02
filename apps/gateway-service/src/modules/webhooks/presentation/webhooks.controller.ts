import { Controller, Post } from '@nestjs/common';
import { ClerkWebhookUseCase } from '../application/webhooks.handle.use-case';
import { ClerkWebhookDto } from '../dto/clerk-webhook.dto';
import { CatchEntityErrors } from '../../../shared/decorators/exception.catcher';
import { ClerkEvent } from '../../../shared/decorators/auth.decorator';
import { type WebhookEvent } from '@clerk/express';

import {
  ApiOperation,
  ApiTags,
  ApiBody,
  ApiResponse,
  ApiSecurity,
} from '@nestjs/swagger';
import { WEBHOOK_API_OPERATIONS } from '../constants/api-operations';

@ApiTags('API Service - Webhooks')
@ApiSecurity('webhook')
@Controller('api/webhooks')
export class ClerkWebhookController {
  constructor(private readonly webhookUseCase: ClerkWebhookUseCase) {}

  @Post('clerk')
  @ApiBody({
    type: ClerkWebhookDto,
    ...WEBHOOK_API_OPERATIONS.CLERK.apiBody,
  })
  @ApiResponse({
    status: 201,
    description: 'Webhook processed successfully',
  })
  @CatchEntityErrors()
  @ApiOperation({
    operationId: WEBHOOK_API_OPERATIONS.CLERK.operationId,
    description: WEBHOOK_API_OPERATIONS.CLERK.description,
  })
  async handleWebhook(@ClerkEvent() event: WebhookEvent) {
    return await this.webhookUseCase.handleWebhook(event);
  }
}
