package app.memovo.api.controller;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import app.memovo.api.controller.dto.HealthCheckResponse;
import app.memovo.api.controller.mapper.HealthMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;

/**
 * Health Check API
 *
 * Provides public system health status endpoint for monitoring and readiness
 * probes. This endpoint is NOT protected - accessible without authentication.
 *
 * @author Memovo Team
 * @version 0.0.1
 * @since 0.0.1
 */
@RestController
@RequestMapping("/health")
@Tag(name = "Health", description = "Public health and readiness endpoints (no authentication required)")
public class HealthCheckController {

    private final app.memovo.api.application.HealthCheckService service;

    public HealthCheckController(app.memovo.api.application.HealthCheckService service) {
        this.service = service;
    }

    /**
     * Health Check
     *
     * Returns the current health status of the application. Useful for load
     * balancers, Kubernetes readiness probes, and monitoring systems. This
     * endpoint is public and does not require authentication.
     *
     * @return Map containing the health status (e.g., {"status": "OK"})
     * @apiNote Public endpoint - no authentication required
     * @author Memovo Team
     * @since 0.0.1
     */
    @Operation(
            summary = "Public health check",
            description = "Returns application health status without requiring authentication. Suitable for load balancers, Kubernetes probes, and monitoring systems that cannot provide JWT tokens.",
            responses = {
                @ApiResponse(responseCode = "200", description = "Health status returned",
                        content = @Content(schema = @Schema(implementation = Map.class))),
                @ApiResponse(responseCode = "500", description = "Server error", content = @Content)
            }
    )
    @GetMapping
    public HealthCheckResponse healthcheck() {
        app.memovo.api.domain.HealthStatus status = service.getHealthStatus();
        return HealthMapper.toDto(status);
    }
}
