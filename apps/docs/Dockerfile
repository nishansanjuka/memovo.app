# =============================================================================
# MEMOVO Docs Portal - Vite React Dockerfile
# =============================================================================
# Multi-stage build for optimized production image
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
COPY apps/docs/package.json ./apps/docs/

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
COPY --from=deps /app/apps/docs/node_modules ./apps/docs/node_modules

# Copy source code
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY apps/docs ./apps/docs

# Build using Turborepo
RUN pnpm turbo run build --filter=devdocs-portal

# -----------------------------------------------------------------------------
# Stage 3: Production (using nginx for static files)
# -----------------------------------------------------------------------------
FROM nginx:alpine AS runner

# Build arguments
ARG BUILD_TAG=latest
ARG GIT_COMMIT=unknown

# Labels
LABEL maintainer="memovo.app team"
LABEL version="${BUILD_TAG}"
LABEL commit="${GIT_COMMIT}"
LABEL service="docs"

# Copy custom nginx config
COPY apps/docs/nginx.conf /etc/nginx/conf.d/default.conf

# Copy built files from builder
COPY --from=builder /app/apps/docs/dist /usr/share/nginx/html

# Expose port
EXPOSE 4173

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:4173 || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
