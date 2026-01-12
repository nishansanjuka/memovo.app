package app.memovo.api.domain.port;

import app.memovo.api.domain.HealthStatus;

/**
 * Domain-level port for health repository. Placed under `domain.port` to
 * express that this is a domain-facing interface that infrastructure adapters
 * implement.
 */
public interface HealthRepository {
    HealthStatus fetchHealthStatus();
}
