# =============================================================================
# MEMOVO Web App - Next.js Dockerfile
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
COPY apps/web-app/package.json ./apps/web-app/
COPY packages/types/package.json ./packages/types/
COPY packages/eslint-config/package.json ./packages/eslint-config/
COPY packages/typescript-config/package.json ./packages/typescript-config/
COPY packages/utils/package.json ./packages/utils/

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
COPY --from=deps /app/apps/web-app/node_modules ./apps/web-app/node_modules
COPY --from=deps /app/packages ./packages

# Copy source code
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY apps/web-app ./apps/web-app
COPY packages ./packages

# Set Next.js telemetry
ENV NEXT_TELEMETRY_DISABLED=1

# Build using Turborepo
RUN pnpm turbo run build --filter=web-app

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
LABEL service="web-app"

# Install curl for health checks
RUN apk add --no-cache curl

# Create non-root user
RUN addgroup -g 1001 -S memovo && adduser -S memovo -u 1001 -G memovo

WORKDIR /app

# Set environment
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3010

# Copy Next.js standalone output
COPY --from=builder --chown=memovo:memovo /app/apps/web-app/.next/standalone ./
COPY --from=builder --chown=memovo:memovo /app/apps/web-app/.next/static ./apps/web-app/.next/static
COPY --from=builder --chown=memovo:memovo /app/apps/web-app/public ./apps/web-app/public

# Switch to non-root user
USER memovo

# Expose port
EXPOSE 3010

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3010/api/health || exit 1

# Start application
CMD ["node", "apps/web-app/server.js"]
