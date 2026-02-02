#!/bin/bash
# =============================================================================
# MEMOVO.APP - Google Cloud Run Deployment Script
# =============================================================================
# This script deploys all services to Google Cloud Run
# =============================================================================

set -e

# Configuration
PROJECT_ID="${GCP_PROJECT_ID}"
REGION="${GCP_REGION:-us-central1}"
ARTIFACT_REGISTRY="${ARTIFACT_REGISTRY}"
BUILD_TAG="${BUILD_TAG:-latest}"

# Service configurations (name:port:memory:cpu:min-instances:max-instances:health-path)
SERVICES=(
    "api:8080:2Gi:2:1:10:/actuator/health"
    "gateway-service:3000:1Gi:1:1:10:/gateway/health"
    "web-app:3010:1Gi:1:1:20:/"
    "llm-service:7000:2Gi:2:1:5:/healthcheck"
    "docs:4173:512Mi:1:0:5:/"
)

echo "🚀 Starting deployment to Google Cloud Run"
echo "Project: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "Build Tag: ${BUILD_TAG}"
echo "=========================================="

# Function to deploy a single service
deploy_service() {
    local service_config="$1"
    IFS=':' read -r name port memory cpu min_instances max_instances health_path <<< "$service_config"
    
    local image="${ARTIFACT_REGISTRY}/${name}:${BUILD_TAG}"
    
    echo ""
    echo "📦 Deploying ${name}..."
    echo "   Image: ${image}"
    echo "   Port: ${port}"
    echo "   Memory: ${memory}"
    echo "   CPU: ${cpu}"
    echo "   Health Path: ${health_path}"
    
    gcloud run deploy "${name}" \
        --image="${image}" \
        --platform=managed \
        --region="${REGION}" \
        --port="${port}" \
        --memory="${memory}" \
        --cpu="${cpu}" \
        --min-instances="${min_instances}" \
        --max-instances="${max_instances}" \
        --allow-unauthenticated \
        --set-env-vars="BUILD_TAG=${BUILD_TAG},NODE_ENV=production,ENVIRONMENT=production" \
        --labels="app=memovo,service=${name},version=${BUILD_TAG}" \
        --quiet
    
    # Get the service URL
    local url=$(gcloud run services describe "${name}" \
        --platform=managed \
        --region="${REGION}" \
        --format='value(status.url)')
    
    echo "   ✅ Deployed successfully!"
    echo "   URL: ${url}"
}

# Deploy all services
for service_config in "${SERVICES[@]}"; do
    deploy_service "${service_config}"
done

echo ""
echo "=========================================="
echo "✅ All services deployed successfully!"
echo "=========================================="

# Output all service URLs
echo ""
echo "📋 Service URLs:"
for service_config in "${SERVICES[@]}"; do
    IFS=':' read -r name _ <<< "$service_config"
    url=$(gcloud run services describe "${name}" \
        --platform=managed \
        --region="${REGION}" \
        --format='value(status.url)')
    echo "   ${name}: ${url}"
done
