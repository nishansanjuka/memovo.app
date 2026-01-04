package app.memovo.api.controller.docs;

import app.memovo.api.controller.dto.ProtectedResponse;
import app.memovo.api.controller.dto.UserProfileResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;

/**
 * OpenAPI documentation definitions for User endpoints
 */
public class UserApiDocs {

    public static final String GET_PROFILE_SUMMARY = "Get authenticated user profile";
    
    public static final String GET_PROFILE_DESCRIPTION = 
        "Retrieves the authenticated user's profile information including unique identifier, email address, " +
        "and current account status. All data is extracted from the verified Clerk JWT token claims. " +
        "This endpoint is essential for client applications to obtain the current user's basic information " +
        "after successful authentication. The response provides minimal user context without additional database lookups.";

    public static final String PROTECTED_ENDPOINT_SUMMARY = "Protected endpoint example";
    
    public static final String PROTECTED_ENDPOINT_DESCRIPTION = 
        "Demonstrates a protected route that requires valid Clerk JWT authentication. Returns a success message " +
        "along with the authenticated user's id to confirm the authentication middleware is working correctly. " +
        "This endpoint serves as a reference implementation for developers building additional protected routes " +
        "and validates that the @CurrentUser annotation properly injects authenticated user context into controller methods.";

    @Operation(
        summary = GET_PROFILE_SUMMARY,
        description = GET_PROFILE_DESCRIPTION,
        security = {@SecurityRequirement(name = "BearerAuth")},
        responses = {
            @ApiResponse(
                responseCode = "200",
                description = "User profile retrieved successfully",
                content = @Content(schema = @Schema(implementation = UserProfileResponse.class))
            ),
            @ApiResponse(
                responseCode = "401",
                description = "Missing, invalid, or expired JWT token in Authorization header",
                content = @Content
            ),
            @ApiResponse(
                responseCode = "500",
                description = "Internal server error occurred while retrieving profile",
                content = @Content
            )
        }
    )
    public @interface GetProfileOperation {}

    @Operation(
        summary = PROTECTED_ENDPOINT_SUMMARY,
        description = PROTECTED_ENDPOINT_DESCRIPTION,
        security = {@SecurityRequirement(name = "BearerAuth")},
        responses = {
            @ApiResponse(
                responseCode = "200",
                description = "Protected endpoint accessed successfully",
                content = @Content(schema = @Schema(implementation = ProtectedResponse.class))
            ),
            @ApiResponse(
                responseCode = "401",
                description = "Missing, invalid, or expired JWT token in Authorization header",
                content = @Content
            ),
            @ApiResponse(
                responseCode = "500",
                description = "Internal server error occurred",
                content = @Content
            )
        }
    )
    public @interface ProtectedEndpointOperation {}
}
