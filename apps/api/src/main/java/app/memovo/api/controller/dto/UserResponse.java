package app.memovo.api.controller.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDateTime;

public record UserResponse(
    @Schema(description = "User's unique identifier", example = "user_123")
    String id,
    
    @Schema(description = "User's first name", example = "John")
    String firstName,
    
    @Schema(description = "User's last name", example = "Doe")
    String lastName,
    
    @Schema(description = "User's email address", example = "john.doe@example.com")
    String email,
    
    @Schema(description = "Timestamp when the user was created")
    LocalDateTime createdAt,
    
    @Schema(description = "Timestamp when the user was last updated")
    LocalDateTime updatedAt
) {}
