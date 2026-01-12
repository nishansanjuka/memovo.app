package app.memovo.api.controller.mapper;

import app.memovo.api.controller.dto.HealthCheckResponse;
import app.memovo.api.domain.HealthStatus;

/**
 * Simple mapper to convert domain `HealthStatus` to controller DTOs.
 */
public final class HealthMapper {
    private HealthMapper() {}

    public static HealthCheckResponse toDto(HealthStatus status) {
        if (status == null) return new HealthCheckResponse(null, null, null);
        // userId and email are not available in this context — leave null for now
        return new HealthCheckResponse(status.getStatus(), null, null);
    }
}
