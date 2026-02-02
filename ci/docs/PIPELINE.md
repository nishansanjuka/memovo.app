# =============================================================================

# MEMOVO.APP - CI/CD Pipeline Documentation

# =============================================================================

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Pipeline Stages](#pipeline-stages)
4. [Environment Variables & Secrets](#environment-variables--secrets)
5. [Jenkins Setup](#jenkins-setup)
6. [Docker Compose Deployment](#docker-compose-deployment)
7. [Adding New Languages/Build Steps](#adding-new-languagesbuild-steps)
8. [Troubleshooting](#troubleshooting)

---

## Overview

The memovo.app CI/CD pipeline uses **Jenkins** with **Turborepo** for efficient monorepo builds. The pipeline supports:

- **Pull Request Builds**: Lint, type-check, build, and test all services
- **Main Branch Deployments**: Build Docker images and deploy to Google Cloud Run

### Supported Languages/Frameworks

| Service           | Language    | Framework       | Build Tool       |
| ----------------- | ----------- | --------------- | ---------------- |
| `api`             | Java 21     | Spring Boot 4.x | Maven            |
| `gateway-service` | TypeScript  | NestJS          | pnpm + Turborepo |
| `web-app`         | TypeScript  | Next.js         | pnpm + Turborepo |
| `docs`            | TypeScript  | Vite + React    | pnpm + Turborepo |
| `llm-service`     | Python 3.12 | FastAPI         | pip              |
| `mobile`          | Dart        | Flutter         | flutter          |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        GitHub Repository                              │
│                         memovo.app                                    │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
                            │ Webhook
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         Jenkins Server                                │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                      Jenkinsfile                                │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │  │
│  │  │  Lint   │ │  Type   │ │  Build  │ │  Test   │ │ Deploy  │ │  │
│  │  │         │ │  Check  │ │         │ │         │ │         │ │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ │  │
│  └───────────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
                            │ docker compose build & push
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│              Google Artifact Registry                                 │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │   api   │ │ gateway │ │ web-app │ │   llm   │ │  docs   │       │
│  │  :tag   │ │  :tag   │ │  :tag   │ │  :tag   │ │  :tag   │       │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
                            │ gcloud run deploy
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Google Cloud Run                                   │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │   api   │ │ gateway │ │ web-app │ │   llm   │ │  docs   │       │
│  │ Service │ │ Service │ │ Service │ │ Service │ │ Service │       │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Pipeline Stages

### PR Pipeline (Validation)

| Stage                 | Description                | Parallel |
| --------------------- | -------------------------- | -------- |
| **Environment Setup** | Install pnpm, dependencies | No       |
| **Code Quality**      | Lint all languages         | Yes      |
| **Type Checking**     | TypeScript, Python mypy    | Yes      |
| **Build**             | Build all services         | Yes      |
| **Unit Tests**        | Run unit tests             | Yes      |
| **Integration Tests** | Run e2e tests              | No       |

### Main Branch Pipeline (Deployment)

| Stage                   | Description                | Parallel |
| ----------------------- | -------------------------- | -------- |
| **Environment Setup**   | Install pnpm, dependencies | No       |
| **Code Quality**        | Lint all languages         | Yes      |
| **Type Checking**       | TypeScript, Python mypy    | Yes      |
| **Build**               | Build all services         | Yes      |
| **Unit Tests**          | Run unit tests             | Yes      |
| **Build Docker Images** | docker compose build       | No       |
| **Push Docker Images**  | docker compose push        | No       |
| **Deploy to Cloud Run** | gcloud run deploy          | No       |

---

## Environment Variables & Secrets

### Jenkins Credentials (Required)

Configure these in Jenkins > Manage Jenkins > Credentials:

| Credential ID             | Type        | Description                             |
| ------------------------- | ----------- | --------------------------------------- |
| `gcp-project-id`          | Secret text | Google Cloud Project ID                 |
| `gcp-service-account-key` | Secret file | GCP Service Account JSON key            |
| `turbo-team`              | Secret text | Turborepo team name (optional)          |
| `turbo-token`             | Secret text | Turborepo remote cache token (optional) |

### GCP Service Account Permissions

The service account needs these roles:

```
- roles/artifactregistry.writer     # Push images to Artifact Registry
- roles/run.admin                   # Deploy to Cloud Run
- roles/iam.serviceAccountUser      # Act as service account
```

### Environment Variables Set in Pipeline

| Variable            | Description                    |
| ------------------- | ------------------------------ |
| `BUILD_TAG`         | Git commit SHA (first 8 chars) |
| `ARTIFACT_REGISTRY` | Full Artifact Registry path    |
| `GCP_REGION`        | Default: us-central1           |
| `NODE_ENV`          | production (for deployments)   |
| `PNPM_HOME`         | pnpm store directory           |

### Application Environment Variables

Each service may require additional environment variables. Set these in Cloud Run:

**API Service (Java)**

```
SPRING_PROFILES_ACTIVE=production
DATABASE_URL=<your-database-url>
CLERK_SECRET_KEY=<clerk-secret>
```

**Gateway Service (NestJS)**

```
NODE_ENV=production
CLERK_PUBLISHABLE_KEY=<clerk-key>
CLERK_SECRET_KEY=<clerk-secret>
```

**LLM Service (Python)**

```
ENVIRONMENT=production
GOOGLE_API_KEY=<google-ai-key>
PINECONE_API_KEY=<pinecone-key>
MONGODB_URI=<mongodb-uri>
```

---

## Jenkins Setup

### 1. Install Required Plugins

```
- Pipeline
- Git
- GitHub Branch Source
- Docker Pipeline
- Credentials Binding
- Pipeline: Stage View
- Timestamper
- AnsiColor
```

### 2. Configure Tools

Go to **Manage Jenkins > Global Tool Configuration**:

**NodeJS**

- Name: `Node-20`
- Version: `20.x`
- Install automatically: Yes

**Maven**

- Name: `Maven-3.9`
- Version: `3.9.x`
- Install automatically: Yes

**JDK**

- Name: `JDK-21`
- Install automatically: Yes (AdoptOpenJDK 21)

### 3. Configure GitHub Webhook

1. In GitHub repo settings > Webhooks > Add webhook
2. Payload URL: `https://<jenkins-url>/github-webhook/`
3. Content type: `application/json`
4. Events: `Pull requests`, `Pushes`

### 4. Create Multibranch Pipeline

1. New Item > Multibranch Pipeline
2. Name: `memovo-app`
3. Branch Sources > GitHub
4. Repository: `your-org/memovo.app`
5. Behaviors:
   - Discover branches
   - Discover pull requests from origin
6. Build Configuration > Jenkinsfile
7. Scan Multibranch Pipeline Triggers: Periodically (1 hour)

### 5. Configure Shared Library (Optional)

For reusable pipeline functions, configure a shared library:

```groovy
@Library('memovo-pipeline-lib') _
```

---

## Docker Compose Deployment

### Build All Images

```bash
# Set environment variables
export ARTIFACT_REGISTRY=us-central1-docker.pkg.dev/your-project/memovo
export BUILD_TAG=$(git rev-parse --short HEAD)
export GIT_COMMIT=$(git rev-parse HEAD)

# Build all images
docker compose -f docker-compose.deploy.yml build
```

### Push All Images

```bash
# Authenticate with GCP
gcloud auth configure-docker us-central1-docker.pkg.dev

# Push all images
docker compose -f docker-compose.deploy.yml push
```

### Run Locally (Testing)

```bash
# Build and run all services
docker compose -f docker-compose.deploy.yml up --build

# Run specific service
docker compose -f docker-compose.deploy.yml up api
```

---

## Adding New Languages/Build Steps

### Adding a New Node.js Service

1. **Create Dockerfile** in `apps/<service>/Dockerfile`:

```dockerfile
# Copy the gateway-service Dockerfile pattern
FROM node:20-alpine AS deps
# ... (follow existing pattern)
```

2. **Add to docker-compose.deploy.yml**:

```yaml
new-service:
  image: ${ARTIFACT_REGISTRY:-memovo}/new-service:${BUILD_TAG:-latest}
  build:
    <<: *common-build
    dockerfile: ./apps/new-service/Dockerfile
  ports:
    - "PORT:PORT"
```

3. **Add to Jenkinsfile** build stage:

```groovy
stage('Build - New Service') {
    steps {
        sh 'pnpm turbo run build --filter=new-service'
    }
}
```

4. **Add to deploy script** (`ci/scripts/deploy-cloud-run.sh`):

```bash
SERVICES=(
    # ... existing services
    "new-service:PORT:1Gi:1:1:10"
)
```

### Adding a New Python Service

1. **Create Dockerfile** (copy from llm-service):

```dockerfile
FROM python:3.12-slim AS builder
# ... (follow existing pattern)
```

2. **Add lint step to Jenkinsfile**:

```groovy
stage('Lint - New Python Service') {
    steps {
        dir('apps/new-python-service') {
            sh 'python -m ruff check src/'
        }
    }
}
```

3. **Add test step**:

```groovy
stage('Test - New Python Service') {
    steps {
        dir('apps/new-python-service') {
            sh 'python -m pytest src/tests/'
        }
    }
}
```

### Adding a New Java Service

1. **Create Dockerfile** (copy from api):

```dockerfile
FROM eclipse-temurin:21-jdk AS builder
# ... (follow existing pattern)
```

2. **Add build step to Jenkinsfile**:

```groovy
stage('Build - New Java Service') {
    steps {
        dir('apps/new-java-service') {
            sh './mvnw clean package -DskipTests'
        }
    }
}
```

### Extending Turborepo

Add new tasks to `turbo.json`:

```json
{
  "tasks": {
    "new-task": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    }
  }
}
```

---

## Troubleshooting

### Common Issues

#### Build Fails: "pnpm not found"

```bash
# Ensure corepack is enabled
corepack enable
corepack prepare pnpm@9.0.0 --activate
```

#### Docker Build Fails: "COPY failed"

Check that all files exist in the build context. The Dockerfile paths are relative to the repository root.

#### Cloud Run Deploy Fails: "Permission denied"

Verify the service account has the required roles:

```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SA_EMAIL" \
  --role="roles/run.admin"
```

#### Turborepo Cache Not Working

1. Verify credentials are set:

```bash
echo $TURBO_TOKEN
echo $TURBO_TEAM
```

2. Check Turborepo configuration in `turbo.json`

#### Tests Timeout

Increase test timeout in Jenkins stage:

```groovy
timeout(time: 30, unit: 'MINUTES') {
    sh 'pnpm test'
}
```

### Viewing Logs

**Jenkins Build Logs**:

- Click on the build number
- Click "Console Output"

**Cloud Run Logs**:

```bash
gcloud run services logs read SERVICE_NAME --region=REGION
```

**Docker Container Logs**:

```bash
docker compose -f docker-compose.deploy.yml logs SERVICE_NAME
```

---

## Quick Reference

### Pipeline Triggers

| Event             | Pipeline        | Stages                       |
| ----------------- | --------------- | ---------------------------- |
| PR opened/updated | PR Pipeline     | Lint → Build → Test          |
| Push to main      | Deploy Pipeline | Lint → Build → Test → Deploy |

### Key Files

| File                             | Purpose                   |
| -------------------------------- | ------------------------- |
| `Jenkinsfile`                    | Main pipeline definition  |
| `docker-compose.deploy.yml`      | Production Docker Compose |
| `apps/*/Dockerfile`              | Per-service Dockerfiles   |
| `ci/scripts/deploy-cloud-run.sh` | Cloud Run deployment      |
| `turbo.json`                     | Turborepo configuration   |

### Useful Commands

```bash
# Run full CI locally (lint + build + test)
pnpm turbo run lint build test

# Build specific service
pnpm turbo run build --filter=gateway-service

# Build Docker images locally
docker compose -f docker-compose.deploy.yml build

# View Turborepo cache status
pnpm turbo run build --dry-run
```

---

## Support

For issues with the CI/CD pipeline:

1. Check Jenkins build logs
2. Review this documentation
3. Check the `#devops` channel
4. Create a GitHub issue with the `ci/cd` label
