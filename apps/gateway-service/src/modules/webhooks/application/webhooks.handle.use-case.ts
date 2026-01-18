import { Injectable } from '@nestjs/common';
import { WebhookEvent } from '@clerk/express';
import { logDebug } from '@memovo.app/utils';
import { ClerkWebhookService } from '../infrastructure/webhook.service';

@Injectable()
export class ClerkWebhookUseCase {
  constructor(private readonly webhookService: ClerkWebhookService) {}

  async handleWebhook(event: WebhookEvent) {
    logDebug('Received webhook event:', event.type);

    switch (event.type) {
      case 'user.created':
        // as business owner, I want to create a corresponding user in my system when a new user is created in Clerk
        return await this.webhookService.handleUserCreated(event);
      case 'user.updated':
        // as business owner, I want to update a corresponding user in my system when a user is updated in Clerk
        await this.webhookService.handleUserUpdated(event);
        break;
      case 'user.deleted':
        // as business owner, I want to update the corresponding business in my system when a user is deleted in Clerk
        // await this.webhookService.handleOrganizationUpdated(event);
        break;
      default:
        logDebug('Unhandled webhook event type:', event.type);
        break;
    }
    return { received: true };
  }
}
