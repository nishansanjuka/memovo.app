#!/bin/bash
# =============================================================================
# MEMOVO.APP - Build Validation Script
# =============================================================================
# Validates that all builds completed successfully
# =============================================================================

set -e

echo "🔍 Validating build artifacts..."

# Check Node.js builds
check_node_build() {
    local service=$1
    local build_dir=$2
    
    if [ -d "apps/${service}/${build_dir}" ]; then
        echo "  ✅ ${service}: ${build_dir}/ exists"
        return 0
    else
        echo "  ❌ ${service}: ${build_dir}/ NOT FOUND"
        return 1
    fi
}

# Check Java build
check_java_build() {
    if [ -f "apps/api/target/api-0.0.1-SNAPSHOT.jar" ]; then
        echo "  ✅ api: JAR file exists"
        return 0
    else
        echo "  ❌ api: JAR file NOT FOUND"
        return 1
    fi
}

# Validation results
FAILED=0

echo ""
echo "Node.js Services:"
check_node_build "gateway-service" "dist" || FAILED=$((FAILED + 1))
check_node_build "web-app" ".next" || FAILED=$((FAILED + 1))
check_node_build "docs" "dist" || FAILED=$((FAILED + 1))

echo ""
echo "Java Services:"
check_java_build || FAILED=$((FAILED + 1))

echo ""
if [ $FAILED -gt 0 ]; then
    echo "❌ Build validation FAILED! ${FAILED} service(s) missing artifacts."
    exit 1
else
    echo "✅ Build validation PASSED! All artifacts present."
    exit 0
fi
