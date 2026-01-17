import { UserJSON, UserWebhookEvent } from '@clerk/express';
import { Injectable } from '@nestjs/common';

@Injectable()
export class ClerkWebhookService {
  constructor() {}

  async handleUserCreated(event: UserWebhookEvent) {
    const userData = event.data as UserJSON;

    return await new Promise((resolve) => {
      console.log('Handling user.created webhook for user:', userData);
      // Implement your logic to create a corresponding user in your system here
      resolve(true);
    });
  }
}
