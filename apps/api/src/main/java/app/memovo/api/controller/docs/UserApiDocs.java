package app.memovo.api.controller.docs;

import app.memovo.api.controller.dto.UserResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;

/**
 * OpenAPI documentation definitions for User CRUD endpoints
 */
public class UserApiDocs {

    public static final String CREATE_USER_SUMMARY = "Create a new user";
    public static final String CREATE_USER_DESCRIPTION = "Creates a new user in the system with the provided information.";

    public static final String GET_USER_SUMMARY = "Get user by ID";
    public static final String GET_USER_DESCRIPTION = "Retrieves a user's details by their unique identifier.";

    public static final String UPDATE_USER_SUMMARY = "Update an existing user";
    public static final String UPDATE_USER_DESCRIPTION = "Updates the information of an existing user.";

    public static final String DELETE_USER_SUMMARY = "Delete a user";
    public static final String DELETE_USER_DESCRIPTION = "Permanently deletes a user from the system.";

    @Operation(
        summary = CREATE_USER_SUMMARY,
        description = CREATE_USER_DESCRIPTION,
        security = {@SecurityRequirement(name = "BearerAuth")},
        responses = {
            @ApiResponse(responseCode = "201", description = "User created successfully",
                content = @Content(schema = @Schema(implementation = UserResponse.class))),
            @ApiResponse(responseCode = "400", description = "Invalid input data", content = @Content),
            @ApiResponse(responseCode = "401", description = "Unauthorized", content = @Content)
        }
    )
    public @interface CreateUserOperation {}

    @Operation(
        summary = GET_USER_SUMMARY,
        description = GET_USER_DESCRIPTION,
        security = {@SecurityRequirement(name = "BearerAuth")},
        responses = {
            @ApiResponse(responseCode = "200", description = "User found",
                content = @Content(schema = @Schema(implementation = UserResponse.class))),
            @ApiResponse(responseCode = "404", description = "User not found", content = @Content),
            @ApiResponse(responseCode = "401", description = "Unauthorized", content = @Content)
        }
    )
    public @interface GetUserOperation {}

    @Operation(
        summary = UPDATE_USER_SUMMARY,
        description = UPDATE_USER_DESCRIPTION,
        security = {@SecurityRequirement(name = "BearerAuth")},
        responses = {
            @ApiResponse(responseCode = "200", description = "User updated successfully",
                content = @Content(schema = @Schema(implementation = UserResponse.class))),
            @ApiResponse(responseCode = "404", description = "User not found", content = @Content),
            @ApiResponse(responseCode = "400", description = "Invalid input data", content = @Content),
            @ApiResponse(responseCode = "401", description = "Unauthorized", content = @Content)
        }
    )
    public @interface UpdateUserOperation {}

    @Operation(
        summary = DELETE_USER_SUMMARY,
        description = DELETE_USER_DESCRIPTION,
        security = {@SecurityRequirement(name = "BearerAuth")},
        responses = {
            @ApiResponse(responseCode = "204", description = "User deleted successfully", content = @Content),
            @ApiResponse(responseCode = "404", description = "User not found", content = @Content),
            @ApiResponse(responseCode = "401", description = "Unauthorized", content = @Content)
        }
    )
    public @interface DeleteUserOperation {}
}
