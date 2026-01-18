# Memovo Gateway Service

This is the main API gateway for the Memovo platform. It handles authentication, request routing, aggregation, rate limiting, and exposes public endpoints for all backend microservices.

## Features

- JWT authentication via Clerk
- API aggregation and transformation
- Rate limiting and caching
- Webhook handling
- Modular architecture (NestJS)

## Main Modules

- **Auth**: Centralized authentication and user context
- **Webhooks**: Handles Clerk webhooks and other integrations
- **API Proxy**: Forwards requests to internal microservices (Spring Boot API, LLM Service, etc.)
  // ...existing code...
- **Shared**: Common decorators, middleware, and utilities

## Setup

1. Install dependencies:
   ```bash
   pnpm install
   # or
   npm install
   ```
2. Configure environment variables in `.env` (see `.env.example` for reference)
3. Run the service:
   ```bash
   pnpm dev
   # or
   npm run start:dev
   ```

## API Documentation

- Swagger/OpenAPI available at `/api-json`
- Webhook endpoint: `/api/webhooks/clerk`

## Folder Structure

- `src/modules/auth` — Authentication logic
- `src/modules/webhooks` — Webhook controller, DTOs, constants
- API documentation is generated from controllers and served at `/api-json`
- `src/shared` — Common decorators, middleware, services
- `src/main.ts` — Entry point

## Contributing

PRs and issues welcome! See the code comments for extension points and module guidelines.
