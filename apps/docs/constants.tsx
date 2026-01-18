import { DocPage } from "./types.ts";

export const DOCS: DocPage[] = [
  // ============================================================
  // GENERAL — PLATFORM
  // ============================================================
  {
    id: "platform-overview",
    title: "Platform Overview",
    type: "markdown",
    group: "General",
    content: `
# Memovo Platform Overview

Memovo is a cloud-native, microservices-based platform designed for scalability,
security, and AI-driven capabilities.

---

## High-Level Architecture

\`\`\`mermaid
graph TD
    Client((Web / Mobile))
        --> Gateway[NestJS Gateway]

    Gateway --> API[Spring Boot API]
    Gateway --> LLM[Python LLM Service]
    Gateway --> Mobile[Flutter App]
\`\`\`

---

## Core Principles

- API-first architecture
- Centralized authentication
- Stateless microservices
- Horizontal scalability
- OpenAPI-driven development
`,
  },

  // ============================================================
  // GENERAL — SERVICES
  // ============================================================
  {
    id: "api-service-intro",
    title: "API Service",
    type: "markdown",
    group: "General",
    content: `
# API Service — Spring Boot

**Location:** \`apps/api\`

The API service is the system's primary business engine.

### Responsibilities
- Domain logic
- Database access
- Transaction management
- Event publishing

### Technology
- Java 21
- Spring Boot 4
- Hibernate / JPA
- PostgreSQL

### Security
- JWT validation via Clerk
- Role-based access control

### Exposed Through
- Gateway → \`/api/v1/**\`
`,
  },

  {
    id: "gateway-service-intro",
    title: "Gateway Service",
    type: "markdown",
    group: "General",
    content: `
# Gateway Service — NestJS

**Location:** \`apps/gateway-service\`

The gateway is the only public-facing backend service.

### Responsibilities
- JWT authentication
- API aggregation
- Request transformation
- Rate limiting
- Caching

### Technology
- NestJS
- TypeScript
- Express
- Zod validation

### Routes
- \`/api/v1/**\`
- \`/api/webhooks/**\`
`,
  },

  {
    id: "llm-service-intro",
    title: "LLM Service",
    type: "markdown",
    group: "General",
    content: `
# LLM Service — FastAPI

**Location:** \`apps/llm-service\`

Provides AI and machine learning capabilities.

### Responsibilities
- Prompt execution
- Vector embeddings
- Semantic search
- Tool orchestration

### Technology
- Python 3.10+
- FastAPI
- OpenAI / Local LLMs
- Async workers

### Communication
- Internal HTTP via gateway
`,
  },

  {
    id: "mobile-app-intro",
    title: "Mobile Application",
    type: "markdown",
    group: "General",
    content: `
# Mobile Application

**Location:** \`apps/mobile\`

Cross-platform mobile client.

### Features
- iOS and Android support
- Offline-first sync
- Secure token storage
- Push notifications

### Technology
- Flutter
- Riverpod
- REST APIs
`,
  },

  // ============================================================
  // API REFERENCES — SCALAR
  // ============================================================
  {
    id: "memovo-api",
    title: "Memovo API",
    type: "api",
    group: "Api references",
    specUrl:
      import.meta.env.VITE_MEMOVO_API_URL ?? "http://localhost:8080/api-docs",
  },

  {
    id: "LLM-service-api",
    title: "LLM Service API",
    type: "api",
    group: "Api references",
    specUrl:
      "https://raw.githubusercontent.com/scalar/scalar/main/packages/api-reference/src/fixtures/openapi.json",
  },

  // ============================================================
  // GATEWAY SERVICE API
  // ============================================================
  {
    id: "gateway-service-api",
    title: "Gateway Service API",
    type: "api",
    group: "Gateway",
    specUrl:
      import.meta.env.VITE_GATEWAY_API_URL ?? "http://localhost:4000/api-json",
  },
];
