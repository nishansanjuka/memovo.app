import {
  Injectable,
  NestMiddleware,
  UnauthorizedException,
} from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';
import { clerkMiddleware, getAuth } from '@clerk/express';
import 'dotenv/config';

/**
 * Authentication middleware using Clerk.
 * Validates JWT tokens and populates request with user information.
 */
@Injectable()
export class AuthMiddleware implements NestMiddleware {
  private clerk = clerkMiddleware();

  use(req: Request, res: Response, next: NextFunction) {
    this.clerk(req, res, (err?: unknown) => {
      if (err) return next(err);

      // Get auth state from the request
      const auth = getAuth(req);
      req.user = auth;

      // Check if user is authenticated
      if (!auth.userId) {
        throw new UnauthorizedException('Unauthorized');
      }

      next();
    });
  }
}

/**
 * Optional authentication middleware - doesn't throw if user is not authenticated.
 * Use for routes that support both authenticated and anonymous access.
 */
@Injectable()
export class OptionalAuthMiddleware implements NestMiddleware {
  private clerk = clerkMiddleware();

  use(req: Request, res: Response, next: NextFunction) {
    this.clerk(req, res, (err?: unknown) => {
      if (err) return next(err);

      // Get auth state from the request (may be null/undefined for anonymous)
      const auth = getAuth(req);
      req.user = auth;

      next();
    });
  }
}

export default AuthMiddleware;
