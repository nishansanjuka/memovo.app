import { UserDeletedJSON, UserJSON, UserWebhookEvent } from '@clerk/express';
import { forwardReq, logDebug } from '@memovo.app/utils';
import { Injectable } from '@nestjs/common';
import { WEBHOOKS_ROUTES } from '../webhooks.config';
import { UserRequest } from '@memovo.app/types';
import { baseConfig } from '../../../shared/env';
import { BadRequestException } from '@nestjs/common';

@Injectable()
export class ClerkWebhookService {
  constructor() {}

  async handleUserCreated(event: UserWebhookEvent) {
    const userData = event.data as UserJSON;
    const res = await forwardReq(
      WEBHOOKS_ROUTES.UserCreated,
      'POST',
      baseConfig().apiKey,
      {
        id: userData.id,
        firstName: userData.first_name,
        lastName: userData.last_name,
        email:
          userData.email_addresses.length > 0
            ? userData.email_addresses[0].email_address
            : `${userData.id}@memovo.app`,
      } as UserRequest,
    );

    if (res.ok) {
      logDebug(
        'Successfully handled user.created webhook for user ID:',
        userData.id,
      );
      return { success: true };
    } else {
      logDebug(
        'Failed to handle user.created webhook for user ID:',
        userData.id,
      );
      const err = (await res.json()) as { message: string; errors: Array<any> };
      logDebug(err);
      throw new BadRequestException(JSON.stringify(err.errors));
    }
  }

  async handleUserUpdated(event: UserWebhookEvent) {
    const userData = event.data as UserJSON;
    const res = await forwardReq(
      WEBHOOKS_ROUTES.UserUpdated.replace('{id}', userData.id),
      'PUT',
      baseConfig().apiKey,
      {
        id: userData.id,
        firstName: userData.first_name,
        lastName: userData.last_name,
        email:
          userData.email_addresses.length > 0
            ? userData.email_addresses[0].email_address
            : undefined,
      } as UserRequest,
    );

    if (res.ok) {
      logDebug(
        'Successfully handled user.updated webhook for user ID:',
        userData.id,
      );
      return { success: true };
    } else {
      logDebug(
        'Failed to handle user.updated webhook for user ID:',
        userData.id,
      );
      const err = (await res.json()) as { message: string; errors: Array<any> };
      logDebug(err);
      throw new BadRequestException(JSON.stringify(err.errors));
    }
  }

  async handleUserDeleted(event: UserWebhookEvent) {
    const userData = event.data as UserDeletedJSON;

    if (!userData.id) {
      logDebug('User ID is missing in user.deleted webhook event');
      throw new BadRequestException('User ID is missing in webhook event');
    }

    const res = await forwardReq(
      WEBHOOKS_ROUTES.UserDeleted.replace('{id}', userData.id),
      'DELETE',
      baseConfig().apiKey,
    );

    if (res.ok) {
      logDebug(
        'Successfully handled user.deleted webhook for user ID:',
        userData.id,
      );
      return { success: true };
    } else {
      logDebug(
        'Failed to handle user.deleted webhook for user ID:',
        userData.id,
      );
      const err = (await res.json()) as { message: string; errors: Array<any> };
      logDebug(err);
      throw new BadRequestException(JSON.stringify(err.errors));
    }
  }
}
