import { UserJSON, UserWebhookEvent } from '@clerk/express';
import { forwardReq, logDebug } from '@memovo.app/utils';
import { Injectable } from '@nestjs/common';
import { WEBHOOKS_ROUTES } from '../webhooks.config';
import { UserRequest } from '@memovo.app/types';
import { baseConfig } from '../../../shared/env';
import { BadRequestException } from '@nestjs/common';

@Injectable()
export class ClerkWebhookService {
  constructor() { }

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
      logDebug(err.errors);
      throw new BadRequestException(JSON.stringify(err.errors));
    }
  }
}
