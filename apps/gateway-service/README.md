# Memovo Gateway Service

This is the main API gateway for the Memovo platform. It handles authentication, request routing, aggregation, rate limiting, and exposes public endpoints for all backend microservices.

## Features

- JWT authentication via Clerk
- Passthrough proxy to backend services (API, LLM)
- OpenAPI spec aggregation from all services
- Request transformation and header injection
- Streaming support for LLM responses
- Rate limiting and caching
- Webhook handling

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Clients                              │
│              (Web App, Mobile App, External)                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Gateway Service                           │
│                    (NestJS, Port 4000)                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Auth Middleware (Clerk JWT Validation)              │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ /api/v1  │  │   /llm   │  │ /webhooks│  │  /health │   │
│  │  Proxy   │  │  Proxy   │  │  Handler │  │  Checks  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
        │                │
        ▼                ▼
┌─────────────┐  ┌─────────────┐
│ API Service │  │ LLM Service │
│ Spring Boot │  │   FastAPI   │
│ Port 8080   │  │  Port 8000  │
└─────────────┘  └─────────────┘
```

## Main Modules

- **Proxy**: Passthrough proxy controllers for API and LLM services
  - `ApiProxyController` - Forwards `/api/v1/**` to Spring Boot API
  - `LlmProxyController` - Forwards `/llm/**` to FastAPI LLM service (with streaming support)
  - `HealthProxyController` - Aggregated health checks
- **Webhooks**: Handles Clerk webhooks for user sync
- **Shared**: Common decorators, middleware, services, and configuration

## Routes

| Route Pattern         | Target Service | Auth Required | Description                       |
| --------------------- | -------------- | ------------- | --------------------------------- |
| `/api/v1/**`          | API Service    | Yes           | Business logic, CRUD operations   |
| `/llm/**`             | LLM Service    | Yes           | AI/ML endpoints, chat (streaming) |
| `/api/webhooks/clerk` | Gateway        | Webhook Auth  | Clerk webhook handler             |
| `/health`             | API Service    | No            | API service health check          |
| `/llm/healthcheck`    | LLM Service    | No            | LLM service health check          |
| `/gateway/health`     | Gateway        | No            | Gateway health check              |
| `/api-json`           | Gateway        | No            | Aggregated OpenAPI spec           |

## Setup

1. Install dependencies:

   ```bash
   pnpm install
   ```

2. Configure environment variables in `.env`:

   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

3. Run the service:
   ```bash
   pnpm dev
   ```

## Environment Variables

| Variable                       | Description                                | Example                 |
| ------------------------------ | ------------------------------------------ | ----------------------- |
| `PORT`                         | Gateway server port                        | `4000`                  |
| `BASE_API_URL`                 | Spring Boot API service URL                | `http://localhost:8080` |
| `LLM_SERVICE_URL`              | FastAPI LLM service URL                    | `http://localhost:8000` |
| `API_KEY`                      | Internal API key for service communication | `your-api-key`          |
| `CLERK_WEBHOOK_SIGNING_SECRET` | Clerk webhook signing secret               | `whsec_...`             |
| `NODE_ENV`                     | Environment mode                           | `development`           |

## API Documentation

- **Aggregated OpenAPI Spec**: `/api-json` - Combines specs from all services
- **Gateway-only Spec**: `/api-json/gateway` - Gateway endpoints only
- **Swagger UI**: Use with tools like Scalar or Swagger UI

The gateway aggregates OpenAPI documentation from:

- API Service (`/api-docs`)
- LLM Service (`/api-json`)

## Authentication

### JWT (Clerk)

Most endpoints require a valid Clerk JWT token in the Authorization header:

```http
Authorization: Bearer <clerk-jwt-token>
```

The gateway validates the token and injects `x-user-id` header when forwarding requests.

### Webhook Authentication

Clerk webhooks use Svix signature verification with headers:

- `svix-id`
- `svix-timestamp`
- `svix-signature`

## Decorators

### `@User()`

Extracts the authenticated user from the request:

```typescript
@Get('profile')
getProfile(@User() user: AuthUserObject) {
  return { userId: user.userId };
}
```

### `@Auth()`

Extracts the full Clerk auth object:

```typescript
@Get('session')
getSession(@Auth() auth: AuthObject) {
  return { sessionId: auth.sessionId };
}
```

## Folder Structure

```
src/
├── main.ts                    # Entry point, OpenAPI aggregation
├── app.module.ts              # Root module
├── modules/
│   ├── proxy/                 # Passthrough proxy module
│   │   ├── proxy.module.ts
│   │   └── controllers/
│   │       ├── api-proxy.controller.ts
│   │       ├── llm-proxy.controller.ts
│   │       └── health-proxy.controller.ts
│   └── webhooks/              # Webhook handling
│       ├── webhooks.module.ts
│       ├── webhooks.config.ts
│       ├── presentation/
│       ├── application/
│       └── infrastructure/
└── shared/
    ├── config.ts              # Configuration aggregation
    ├── env.ts                 # Environment validation (Zod)
    ├── config/
    │   └── service-registry.ts  # Service URL mapping
    ├── middleware/
    │   ├── auth.middleware.ts    # Clerk JWT validation
    │   └── webhooks.middleware.ts
    ├── services/
    │   ├── config.service.ts
    │   └── proxy.service.ts      # HTTP proxy logic
    └── decorators/
        └── auth.decorator.ts     # @User, @Auth, @ClerkEvent
```

## Contributing

1. Follow the existing code style
2. Add tests for new functionality
3. Update documentation as needed

PRs and issues welcome! See the code comments for extension points and module guidelines.
