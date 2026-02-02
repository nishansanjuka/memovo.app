# =============================================================================
# MEMOVO API - Java Spring Boot Dockerfile
# =============================================================================
# Multi-stage build for optimized production image
# =============================================================================

ARG JAVA_VERSION=21

# -----------------------------------------------------------------------------
# Stage 1: Build
# -----------------------------------------------------------------------------
FROM eclipse-temurin:${JAVA_VERSION}-jdk AS builder

WORKDIR /app

# Copy Maven wrapper and pom.xml first for better caching
COPY apps/api/mvnw apps/api/mvnw.cmd ./
COPY apps/api/.mvn ./.mvn
COPY apps/api/pom.xml ./

# Make mvnw executable
RUN chmod +x ./mvnw

# Download dependencies (cached layer)
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY apps/api/src ./src

# Build the application
RUN ./mvnw clean package -DskipTests -B

# Extract layers for better Docker caching
RUN java -Djarmode=layertools -jar target/*.jar extract

# -----------------------------------------------------------------------------
# Stage 2: Runtime
# -----------------------------------------------------------------------------
FROM eclipse-temurin:${JAVA_VERSION}-jre AS runtime

# Build arguments
ARG BUILD_TAG=latest
ARG GIT_COMMIT=unknown

# Labels
LABEL maintainer="memovo.app team"
LABEL version="${BUILD_TAG}"
LABEL commit="${GIT_COMMIT}"
LABEL service="api"

# Create non-root user for security
RUN groupadd -r memovo && useradd -r -g memovo memovo

WORKDIR /app

# Copy layers from builder
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./

# Change ownership
RUN chown -R memovo:memovo /app

# Switch to non-root user
USER memovo

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Set JVM options for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Start application
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} org.springframework.boot.loader.launch.JarLauncher"]
