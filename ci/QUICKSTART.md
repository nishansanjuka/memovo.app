# =============================================================================

# MEMOVO.APP - Quick Start Guide

# =============================================================================

## Prerequisites

- Jenkins server with Docker support
- Google Cloud Platform account with Cloud Run enabled
- GitHub repository access

## Quick Setup Steps

### 1. Configure Jenkins Credentials

Add the following credentials in Jenkins (Manage Jenkins > Credentials):

| ID                        | Type        | Description                |
| ------------------------- | ----------- | -------------------------- |
| `gcp-project-id`          | Secret text | Your GCP Project ID        |
| `gcp-service-account-key` | Secret file | GCP Service Account JSON   |
| `turbo-team`              | Secret text | Turborepo team (optional)  |
| `turbo-token`             | Secret text | Turborepo token (optional) |

### 2. Configure Jenkins Tools

Install these tools in Jenkins (Manage Jenkins > Global Tool Configuration):

- **NodeJS**: Name `Node-20`, Version 20.x
- **Maven**: Name `Maven-3.9`, Version 3.9.x
- **JDK**: Name `JDK-21`, Version 21

### 3. Create GCP Resources

```bash
# Create Artifact Registry repository
gcloud artifacts repositories create memovo \
  --repository-format=docker \
  --location=us-central1

# Create Service Account
gcloud iam service-accounts create jenkins-deploy \
  --display-name="Jenkins Deployment"

# Grant permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:jenkins-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:jenkins-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# Download key
gcloud iam service-accounts keys create jenkins-key.json \
  --iam-account=jenkins-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### 4. Create Jenkins Pipeline

1. New Item > Multibranch Pipeline
2. Name: `memovo-app`
3. Branch Source: GitHub
4. Repository URL: Your repo
5. Build Configuration: Jenkinsfile

### 5. Configure GitHub Webhook

Add webhook in GitHub repo settings:

- URL: `https://your-jenkins/github-webhook/`
- Events: Pull requests, Pushes

## File Structure

```
ci/
├── docs/
│   └── PIPELINE.md      # Full documentation
├── env/
│   └── ci.env.example   # CI environment variables
└── scripts/
    ├── deploy-cloud-run.sh   # Cloud Run deployment
    ├── health-check.sh       # Post-deploy health checks
    └── validate-builds.sh    # Build validation

Jenkinsfile                    # Main pipeline
docker-compose.deploy.yml      # Deployment compose file
.dockerignore                  # Docker build exclusions

apps/
├── api/Dockerfile
├── gateway-service/Dockerfile
├── web-app/Dockerfile
├── llm-service/Dockerfile
└── docs/Dockerfile
```

## Verify Setup

After configuring, push a test commit and verify:

1. ✅ Jenkins triggers on push
2. ✅ All stages complete successfully
3. ✅ PR builds run lint/test stages
4. ✅ Main branch deploys to Cloud Run

For detailed information, see [ci/docs/PIPELINE.md](docs/PIPELINE.md).
