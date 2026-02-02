# =============================================================================
# MEMOVO LLM Service - Python FastAPI Dockerfile
# =============================================================================
# Multi-stage build for optimized production image
# =============================================================================

ARG PYTHON_VERSION=3.12

# -----------------------------------------------------------------------------
# Stage 1: Builder
# -----------------------------------------------------------------------------
FROM python:${PYTHON_VERSION}-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy and install requirements
COPY apps/llm-service/requirements.txt ./
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# -----------------------------------------------------------------------------
# Stage 2: Production
# -----------------------------------------------------------------------------
FROM python:${PYTHON_VERSION}-slim AS runner

# Build arguments
ARG BUILD_TAG=latest
ARG GIT_COMMIT=unknown

# Labels
LABEL maintainer="memovo.app team"
LABEL version="${BUILD_TAG}"
LABEL commit="${GIT_COMMIT}"
LABEL service="llm-service"

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user
RUN groupadd -r memovo && useradd -r -g memovo memovo

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code
COPY --chown=memovo:memovo apps/llm-service/src ./src

# Switch to non-root user
USER memovo

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV ENVIRONMENT=production
ENV PORT=7000

# Expose port
EXPOSE 7000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:7000/healthcheck || exit 1

# Start application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "7000"]
