import { UserJSON, UserWebhookEvent } from '@clerk/express';
import { forwardReq } from '@memovo.app/utils';
import { Injectable } from '@nestjs/common';
import { WEBHOOKS_ROUTES } from '../webhooks.config';
import { UserRequest } from '@memovo.app/types';

@Injectable()
export class ClerkWebhookService {
  constructor() {}

  async handleUserCreated(event: UserWebhookEvent) {
    const userData = event.data as UserJSON;

    console.log(userData);

    const res = await forwardReq(WEBHOOKS_ROUTES.UserCreated, 'POST', {
      id: userData.id,
      firstName: userData.first_name,
      lastName: userData.last_name,
      email:
        userData.email_addresses.length > 0
          ? userData.email_addresses[0].email_address
          : 'abc@gmail.com',
    } as UserRequest);

    console.log(res);

    return res;
  }
}
