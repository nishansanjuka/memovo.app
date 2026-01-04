package app.memovo.api.controller.docs;

import app.memovo.api.controller.dto.HealthCheckResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;

/**
 * OpenAPI documentation definitions for Health endpoints
 */
public class HealthApiDocs {

    public static final String HEALTH_CHECK_SUMMARY = "Health check with authenticated user context";
    
    public static final String HEALTH_CHECK_DESCRIPTION = 
        "Returns application health status along with the authenticated user's id, email, and status " +
        "extracted from the Clerk JWT token. This endpoint verifies both system availability and " +
        "successful JWT authentication. Useful for authenticated readiness probes and monitoring systems " +
        "that need to confirm user context is being properly parsed from tokens.";

    @Operation(
        summary = HEALTH_CHECK_SUMMARY,
        description = HEALTH_CHECK_DESCRIPTION,
        security = {@SecurityRequirement(name = "BearerAuth")},
        responses = {
            @ApiResponse(
                responseCode = "200",
                description = "Health status returned successfully with authenticated user context",
                content = @Content(schema = @Schema(implementation = HealthCheckResponse.class))
            ),
            @ApiResponse(
                responseCode = "401",
                description = "Missing, invalid, or expired JWT token in Authorization header",
                content = @Content
            ),
            @ApiResponse(
                responseCode = "500",
                description = "Internal server error occurred during health check",
                content = @Content
            )
        }
    )
    public @interface HealthCheckOperation {}
}
