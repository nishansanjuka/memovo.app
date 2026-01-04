# Memovo

A modern full-stack application built with a microservices architecture, featuring Spring Boot API, NestJS Gateway, Python LLM service, and Flutter mobile app.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Apps & Services](#apps--services)
- [Development](#development)
- [Building](#building)
- [Testing](#testing)
- [Deployment](#deployment)

## 🎯 Overview

Memovo is a comprehensive application platform designed with:

- **Microservices Architecture** - Independent, scalable services
- **Modern Tech Stack** - Spring Boot, NestJS, Python, Flutter
- **API-First Design** - OpenAPI documentation and Swagger UI
- **Cloud-Ready** - Containerized with health checks and monitoring
- **Mobile-First** - Cross-platform Flutter mobile application

## 🏗️ Architecture

```
memovo.app/
├── apps/
│   ├── api/              # Spring Boot REST API (Java 21)
│   ├── gateway-service/  # NestJS API Gateway (TypeScript)
│   ├── llm-service/      # LLM Integration Service (Python)
│   └── mobile/           # Flutter Mobile App (Dart)
└── packages/
    ├── eslint-config/    # Shared ESLint configurations
    └── typescript-config/# Shared TypeScript configurations
```

### Service Communication

```
Mobile App (Flutter)
    ↓
Gateway Service (NestJS) ← API Gateway & Router
    ↓
├→ API Service (Spring Boot) ← Core Business Logic
└→ LLM Service (Python)      ← AI/ML Processing
```

## 🔧 Prerequisites

### Required

- **Node.js** 18+ (for workspace management)
- **pnpm** 8+ (package manager)
- **Java** 21+ (for API service)
- **Maven** 3.6+ (for API service)
- **Python** 3.10+ (for LLM service)
- **Flutter** 3.0+ (for mobile app)

### Recommended

- **Docker** (for containerization)
- **Kubernetes** (for orchestration)
- **Postman** (for API testing)

## 🚀 Getting Started

### 1. Clone Repository

```bash
git clone <repository-url>
cd memovo.app
```

### 2. Install Dependencies

```bash
# Install workspace dependencies
pnpm install
```

### 3. Configure Environment

Each service has its own `.env` file. See individual service READMEs for details:

- [API Service Configuration](apps/api/README.md#configuration)
- Gateway Service Configuration
- LLM Service Configuration
- Mobile App Configuration

### 4. Start Development

**Start all services:**

```bash
turbo dev
```

**Start specific service:**

```bash
pnpm --filter api dev
pnpm --filter gateway-service dev
pnpm --filter llm-service dev
pnpm --filter mobile dev
```

## 📦 Apps & Services

### 🔷 API Service (Spring Boot)

**Location:** `apps/api/`

**Tech Stack:** Java 21, Spring Boot 4, Maven

**Features:**

- Clerk JWT authentication
- OpenAPI 3.0 documentation
- Automated Postman sync
- Health check endpoints
- Comprehensive unit tests

**Quick Start:**

```bash
cd apps/api
pnpm install
pnpm dev  # Runs on http://localhost:8080
```

**Documentation:** [apps/api/README.md](apps/api/README.md)

**Key Endpoints:**

- `GET /health` - Health check (public)
- `GET /api/v1/profile` - User profile (protected)
- `GET /swagger-ui.html` - API documentation

---

### 🔶 Gateway Service (NestJS)

**Location:** `apps/gateway-service/`

**Tech Stack:** TypeScript, NestJS, Express

**Features:**

- API routing and aggregation
- Request/response transformation
- Rate limiting and throttling
- Authentication middleware

**Quick Start:**

```bash
cd apps/gateway-service
pnpm install
pnpm dev  # Runs on http://localhost:3000
```

---

### 🔸 LLM Service (Python)

**Location:** `apps/llm-service/`

**Tech Stack:** Python 3.10+, FastAPI

**Features:**

- LLM integration
- AI/ML processing
- Async request handling
- Vector embeddings

**Quick Start:**

```bash
cd apps/llm-service
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

---

### 📱 Mobile App (Flutter)

**Location:** `apps/mobile/`

**Tech Stack:** Dart, Flutter

**Features:**

- Cross-platform (iOS & Android)
- Material Design UI
- State management
- Offline support

**Quick Start:**

```bash
cd apps/mobile
flutter pub get
flutter run
```

## 🛠️ Development

### Workspace Commands

**Development:**

```bash
# Start all services
turbo dev

# Start specific service
turbo dev --filter=api
turbo dev --filter=gateway-service
```

**Building:**

```bash
# Build all services
turbo build

# Build specific service
turbo build --filter=api
```

**Testing:**

```bash
# Test all services
turbo test

# Test specific service
turbo test --filter=api
```

### Code Quality

**Linting:**

```bash
turbo lint
```

**Formatting:**

```bash
turbo format
```

## 🏗️ Building

### Build All Services

```bash
pnpm build
```

### Build Individual Services

**API Service:**

```bash
cd apps/api
pnpm build              # With tests
pnpm build:skip-tests   # Skip tests
```

**Gateway Service:**

```bash
cd apps/gateway-service
pnpm build
```

**Mobile App:**

```bash
cd apps/mobile
flutter build apk       # Android
flutter build ios       # iOS
```

### Build Outputs

- **API:** `apps/api/target/api-0.0.1-SNAPSHOT.jar`
- **Gateway:** `apps/gateway-service/dist/`
- **Mobile:** `apps/mobile/build/`

## 🧪 Testing

### Run All Tests

```bash
pnpm test
```

### Service-Specific Tests

**API Service:**

```bash
cd apps/api
pnpm test              # Full output
pnpm test:quiet        # Summary only
```

**Gateway Service:**

```bash
cd apps/gateway-service
pnpm test
pnpm test:e2e
```

### Test Coverage

View test coverage reports in each service's directory:

- API: `apps/api/target/surefire-reports/`
- Gateway: `apps/gateway-service/coverage/`

## 🚀 Deployment

### Docker

Each service includes Dockerfile for containerization:

```bash
# Build API image
docker build -t memovo-api ./apps/api

# Build Gateway image
docker build -t memovo-gateway ./apps/gateway-service

# Build LLM Service image
docker build -t memovo-llm ./apps/llm-service
```

### Kubernetes

Health check configuration example:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Environment Variables

Each service requires specific environment variables. See individual service READMEs:

- [API Environment Variables](apps/api/README.md#environment-variables)
- Gateway Environment Variables
- LLM Service Environment Variables

## 📚 Documentation

### API Documentation

- **Swagger UI:** http://localhost:8080/swagger-ui.html
- **OpenAPI Spec:** http://localhost:8080/api-docs
- **Postman Collection:** Auto-synced (see [API README](apps/api/README.md#postman-integration))

### Service READMEs

- [API Service](apps/api/README.md) - Complete API documentation
- [Gateway Service](apps/gateway-service/README.md)
- [LLM Service](apps/llm-service/README.md)
- [Mobile App](apps/mobile/README.md)

## 🔧 Troubleshooting

### Common Issues

**1. Port conflicts**

- API: Default 8080 (change in `application.properties`)
- Gateway: Default 3000 (change in `.env`)

**2. Build failures**

```bash
# Clean and rebuild
cd apps/api
pnpm clean
pnpm build
```

**3. Dependency issues**

```bash
# Reinstall all dependencies
pnpm install --force
```

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Write/update tests
4. Update documentation
5. Submit a pull request

## 📄 License

Copyright © 2026 Memovo Team

## 📞 Support

- **API Issues:** Check [API README](apps/api/README.md)
- **Gateway Issues:** Check Gateway service logs
- **Mobile Issues:** Check Flutter diagnostics

---

**Built with** ❤️ **using Spring Boot, NestJS, Python, and Flutter**
