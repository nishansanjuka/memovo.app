/* eslint-disable @typescript-eslint/no-redundant-type-constituents */
/// <reference types="@clerk/express/env" />

import { AuthObject, WebhookEvent } from '@clerk/express';

declare global {
  namespace Express {
    interface Request {
      /** Clerk auth object populated by clerkMiddleware */
      auth?: AuthObject;
      /** User authentication state from Clerk middleware */
      user: ReturnType<typeof import('@clerk/express').getAuth>;
      /** Clerk webhook event populated by webhook middleware */
      clerkEvent: WebhookEvent | null;
    }
  }
}

export type AuthUserObject = ReturnType<
  typeof import('@clerk/express').getAuth
>;

export {};
