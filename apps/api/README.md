# Memovo API

A Spring Boot REST API service with Clerk JWT authentication, comprehensive OpenAPI documentation, and automated Postman collection synchronization.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [API Documentation](#api-documentation)
- [Authentication](#authentication)
- [API Endpoints](#api-endpoints)
- [Testing](#testing)
- [Postman Integration](#postman-integration)
- [Development](#development)
- [Project Structure](#project-structure)

## ✨ Features

- **JWT Authentication** with Clerk
- **OpenAPI 3.0** documentation with Swagger UI
- **Automated Postman Sync** for collections and environments
- **Health Check Endpoint** for monitoring
- **Custom User Decorator** (`@CurrentUser`) for authentication context
- **Comprehensive Unit Tests** with JUnit 5 and Mockito
- **Global Exception Handling**

## 🔧 Prerequisites

- Java 21 or higher
- Maven 3.6+
- Node.js 18+ (for Postman sync scripts)
- pnpm (recommended) or npm
- Clerk account for authentication

## 🚀 Getting Started

### 1. Clone and Navigate

```bash
cd apps/api
```

### 2. Install Dependencies

```bash
pnpm install
```

### 3. Configure Environment

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Clerk Configuration
CLERK_SECRET_KEY=sk_test_your_clerk_secret_key_here
CLERK_TEST_USER_ID=user_test_user_id_here

# Postman Configuration
POSTMAN_API_KEY=your_postman_api_key_here
POSTMAN_COLLECTION_ID=your_collection_id_here
POSTMAN_ENVIRONMENT_ID=your_environment_id_here
POSTMAN_WORKSPACE_ID=your_workspace_id_here
```

### 4. Run the Application

**Using Maven:**
```bash
./mvnw spring-boot:run
```

**Using pnpm:**
```bash
pnpm run dev
```

The application will start on `http://localhost:8080`

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `CLERK_SECRET_KEY` | Your Clerk secret key for JWT verification | Yes |
| `CLERK_TEST_USER_ID` | Test user ID for development/testing | No |
| `POSTMAN_API_KEY` | Postman API key for collection sync | No* |
| `POSTMAN_COLLECTION_ID` | ID of your Postman collection | No* |
| `POSTMAN_ENVIRONMENT_ID` | ID of your Postman environment | No* |
| `POSTMAN_WORKSPACE_ID` | ID of your Postman workspace | No* |

*Required only if you want to use Postman sync features

### Application Properties

Key configuration in `src/main/resources/application.properties`:

```properties
server.port=8080
server.tomcat.max-http-request-header-size=32KB

# Clerk Configuration
clerk.secret-key=${CLERK_SECRET_KEY}
```

## 📚 API Documentation

### Swagger UI (Interactive)

Access the interactive API documentation:

```
http://localhost:8080/swagger-ui.html
```

### OpenAPI JSON

Download the OpenAPI specification:

```
http://localhost:8080/api-docs
```

The documentation includes:
- Detailed endpoint descriptions
- Request/response schemas
- Authentication requirements
- Example payloads
- Response codes and error handling

## 🔐 Authentication

This API uses **Clerk JWT Authentication** for protected endpoints.

### How It Works

1. **Client** obtains a JWT token from Clerk
2. **Client** includes token in `Authorization` header: `Bearer <token>`
3. **API** verifies token using Clerk's public key
4. **API** extracts user claims and makes available via `@CurrentUser`

### Protected vs Public Endpoints

**Public Endpoints** (no authentication required):
- `GET /health` - Health check

**Protected Endpoints** (requires JWT token):
- `GET /api/v1/profile` - Get current user profile
- `GET /api/v1/protected` - Example protected endpoint

### Using @CurrentUser Decorator

In your controllers, inject the authenticated user:

```java
@GetMapping("/profile")
public ResponseEntity<UserProfileResponse> getProfile(
    @CurrentUser @Parameter(hidden = true) ClerkUser user
) {
    // user.getId() - Clerk user ID
    // user.getEmail() - User email
    return ResponseEntity.ok(new UserProfileResponse(user.getId(), user.getEmail()));
}
```

## 🌐 API Endpoints

### Health Check

**Endpoint:** `GET /health`

**Description:** Public health check endpoint for monitoring, load balancers, and Kubernetes probes.

**Authentication:** None required

**Response:**
```json
{
  "status": "OK"
}
```

**Example:**
```bash
curl http://localhost:8080/health
```

---

### Get User Profile

**Endpoint:** `GET /api/v1/profile`

**Description:** Retrieves the profile of the currently authenticated user.

**Authentication:** Required (JWT Bearer token)

**Response:**
```json
{
  "userId": "user_2abc123xyz",
  "email": "user@example.com"
}
```

**Example:**
```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:8080/api/v1/profile
```

---

### Protected Endpoint

**Endpoint:** `GET /api/v1/protected`

**Description:** Example protected endpoint demonstrating authentication.

**Authentication:** Required (JWT Bearer token)

**Response:**
```json
{
  "message": "This is a protected resource",
  "userId": "user_2abc123xyz"
}
```

## 🧪 Testing

### Run All Tests

```bash
# Using Maven
./mvnw test

# Using pnpm
pnpm test

# Quiet mode (summary only)
./mvnw test -q
```

### Test Coverage

The project includes comprehensive tests:

- **Unit Tests** - All components except application layer
- **Integration Tests** - Full Spring context for services
- **Test Classes:**
  - `ApiApplicationTests` - Application context loading
  - `HealthCheckControllerTest` - Controller logic
  - `UserControllerTest` - User endpoints
  - `HealthCheckServiceIntegrationTest` - Service integration
  - `ClerkUserTest` - Domain model
  - `CurrentUserArgumentResolverTest` - Authentication resolution
  - `GlobalExceptionHandlerTest` - Error handling
  - `MockHealthRepositoryTest` - Repository behavior
  - Exception tests (Unauthorized, Forbidden)

### Test Results

After running tests, view detailed reports:

```
target/surefire-reports/
```

## 📮 Postman Integration

This project includes automated Postman collection and environment synchronization.

### Initial Setup

1. **Get Postman API Key:**
   - Go to [Postman Account Settings](https://web.postman.co/settings/me/api-keys)
   - Generate a new API key
   - Add to `.env` as `POSTMAN_API_KEY`

2. **Get Collection/Environment IDs:**
   - Create a collection in Postman
   - Get IDs from collection/environment URLs
   - Add to `.env`

### Sync Commands

**Sync Collection Only:**
```bash
pnpm run sync:postman
```

**Sync Environment Only:**
```bash
pnpm run sync:postman:env
```

**Sync Both:**
```bash
pnpm run sync:postman:all
```

### How It Works

1. **Collection Sync:**
   - Reads OpenAPI spec from `http://localhost:8080/api-docs`
   - Converts to Postman collection format
   - Patches with custom scripts and variables
   - Uploads to Postman via API

2. **Environment Sync:**
   - Reads environment template from `scripts/postman-env-dev.json`
   - Injects variables from `.env`
   - Uploads to Postman via API

3. **Pre-request Scripts:**
   - Automatically included in all requests
   - Located in `scripts/pre-request.js`
   - Handles authentication token injection

### Manual Sync

If automated sync fails, manually import:

1. Download OpenAPI spec: `http://localhost:8080/api-docs`
2. Import to Postman: `Import > Link > Paste URL`
3. Configure environment variables manually

## 🛠️ Development

### Project Structure

```
apps/api/
├── src/
│   ├── main/
│   │   ├── java/app/memovo/api/
│   │   │   ├── ApiApplication.java          # Main application
│   │   │   ├── application/                 # Service layer
│   │   │   │   └── HealthCheckService.java
│   │   │   ├── config/                      # Configuration
│   │   │   │   ├── SwaggerConfig.java       # OpenAPI config
│   │   │   │   └── WebConfig.java           # Web/CORS config
│   │   │   ├── controller/                  # REST controllers
│   │   │   │   ├── HealthCheckController.java
│   │   │   │   ├── UserController.java
│   │   │   │   └── docs/                    # API documentation
│   │   │   │       ├── HealthApiDocs.java
│   │   │   │       └── UserApiDocs.java
│   │   │   ├── domain/                      # Domain models
│   │   │   │   ├── HealthStatus.java
│   │   │   │   └── response/                # Response DTOs
│   │   │   ├── exception/                   # Exception handling
│   │   │   │   └── GlobalExceptionHandler.java
│   │   │   ├── infrastructure/              # Infrastructure layer
│   │   │   │   └── MockHealthRepository.java
│   │   │   └── security/                    # Security & auth
│   │   │       ├── ClerkAuthenticationFilter.java
│   │   │       ├── ClerkUser.java
│   │   │       ├── CurrentUser.java         # Custom annotation
│   │   │       ├── CurrentUserArgumentResolver.java
│   │   │       ├── ForbiddenException.java
│   │   │       └── UnauthorizedException.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/app/memovo/api/            # Test files
├── scripts/                                 # Postman sync scripts
│   ├── sync-collection.ps1
│   ├── sync-environment.ps1
│   ├── patch-postman.mjs
│   └── pre-request.js
├── .env                                     # Environment variables
├── .env.example                            # Environment template
├── pom.xml                                  # Maven dependencies
├── package.json                             # Node scripts
└── README.md                                # This file
```

### Architecture Layers

1. **Controller** - REST endpoints and HTTP handling
2. **Application** - Business logic and services
3. **Domain** - Core domain models and DTOs
4. **Infrastructure** - External integrations and repositories
5. **Security** - Authentication and authorization

### Adding New Endpoints

1. **Create Response DTO** in `domain/response/`
2. **Add Documentation Annotation** in `controller/docs/`
3. **Implement Controller Method** with `@Operation` reference
4. **Write Tests** in corresponding test class
5. **Sync Postman** to update collection

### Code Style

- Use Java 21 features (records, pattern matching)
- Follow Spring Boot best practices
- Document all public APIs with JavaDoc
- Write tests for all new features
- Use meaningful variable and method names

## 🔍 Monitoring & Health Checks

### Health Endpoint

The `/health` endpoint is designed for:

- **Load Balancers** - Traffic routing decisions
- **Kubernetes** - Liveness and readiness probes
- **Monitoring Systems** - Uptime tracking
- **CI/CD Pipelines** - Deployment verification

### Kubernetes Example

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

## 🐛 Troubleshooting

### Common Issues

**1. Port 8080 already in use**
```bash
# Change port in application.properties
server.port=8081
```

**2. Clerk authentication fails**
- Verify `CLERK_SECRET_KEY` in `.env`
- Check token expiration
- Ensure token format: `Bearer <token>`

**3. Postman sync fails**
- Verify API key is valid
- Check collection/environment IDs
- Ensure server is running during sync

**4. Tests fail**
- Run `./mvnw clean test` to rebuild
- Check test reports in `target/surefire-reports/`

## 📄 License

Copyright © 2026 Memovo Team

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Write/update tests
4. Update documentation
5. Submit a pull request

## 📞 Support

For issues or questions:
- Check [Swagger UI](http://localhost:8080/swagger-ui.html) for API details
- Review test cases for usage examples
- Check application logs for error details

---

**Built with** ❤️ **using Spring Boot, Clerk, and OpenAPI**
