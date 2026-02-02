# =============================================================================
# MEMOVO Gateway Service - NestJS Dockerfile
# =============================================================================
# Multi-stage build using Turborepo for optimized monorepo builds
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Dependencies
# -----------------------------------------------------------------------------
FROM node:20-alpine AS deps

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

WORKDIR /app

# Copy root package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Copy all package.json files for workspace
COPY apps/gateway-service/package.json ./apps/gateway-service/
COPY packages/types/package.json ./packages/types/
COPY packages/eslint-config/package.json ./packages/eslint-config/
COPY packages/typescript-config/package.json ./packages/typescript-config/

# Install dependencies
RUN pnpm install --frozen-lockfile

# -----------------------------------------------------------------------------
# Stage 2: Builder
# -----------------------------------------------------------------------------
FROM node:20-alpine AS builder

# Build arguments
ARG BUILD_TAG=latest
ARG GIT_COMMIT=unknown

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/apps/gateway-service/node_modules ./apps/gateway-service/node_modules
COPY --from=deps /app/packages ./packages

# Copy source code
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY apps/gateway-service ./apps/gateway-service
COPY packages ./packages

# Build using Turborepo
RUN pnpm turbo run build --filter=gateway-service

# -----------------------------------------------------------------------------
# Stage 3: Production
# -----------------------------------------------------------------------------
FROM node:20-alpine AS runner

# Build arguments
ARG BUILD_TAG=latest
ARG GIT_COMMIT=unknown

# Labels
LABEL maintainer="memovo.app team"
LABEL version="${BUILD_TAG}"
LABEL commit="${GIT_COMMIT}"
LABEL service="gateway-service"

# Install curl for health checks and dumb-init for proper signal handling
RUN apk add --no-cache curl dumb-init

# Create non-root user
RUN addgroup -g 1001 -S memovo && adduser -S memovo -u 1001 -G memovo

WORKDIR /app

# Copy built application
COPY --from=builder --chown=memovo:memovo /app/apps/gateway-service/dist ./dist
COPY --from=builder --chown=memovo:memovo /app/apps/gateway-service/node_modules ./node_modules
COPY --from=builder --chown=memovo:memovo /app/apps/gateway-service/package.json ./

# Switch to non-root user
USER memovo

# Expose port
EXPOSE 3000

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:3000/gateway/health || exit 1

# Start application with dumb-init
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/main.js"]
