package app.memovo.api.controller.dto;

/**
 * Response payload for health check endpoint.
 */
public record HealthCheckResponse(String status, String userId, String email) {

}
