#!/bin/bash
# =============================================================================
# MEMOVO.APP - Health Check Script
# =============================================================================
# Verifies all deployed services are healthy
# =============================================================================

set -e

PROJECT_ID="${GCP_PROJECT_ID}"
REGION="${GCP_REGION:-us-central1}"

SERVICES=("api" "gateway-service" "web-app" "llm-service" "docs")

echo "🏥 Running health checks for deployed services..."
echo ""

FAILED=0

for service in "${SERVICES[@]}"; do
    url=$(gcloud run services describe "${service}" \
        --platform=managed \
        --region="${REGION}" \
        --format='value(status.url)' 2>/dev/null || echo "")
    
    if [ -z "$url" ]; then
        echo "  ⚠️  ${service}: Service not found"
        FAILED=$((FAILED + 1))
        continue
    fi
    
    # Check health endpoint
    health_url="${url}/health"
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${health_url}" 2>/dev/null || echo "000")
    
    if [ "$status" = "200" ]; then
        echo "  ✅ ${service}: Healthy (${url})"
    else
        echo "  ❌ ${service}: Unhealthy (HTTP ${status})"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
if [ $FAILED -gt 0 ]; then
    echo "❌ Health check FAILED! ${FAILED} service(s) unhealthy."
    exit 1
else
    echo "✅ All services are healthy!"
    exit 0
fi
