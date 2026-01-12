package app.memovo.api.controller.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record UserRequest(
    @Schema(description = "User's unique identifier", example = "user_123")
    @NotBlank String id,
    
    @Schema(description = "User's first name", example = "John")
    @NotBlank String firstName,
    
    @Schema(description = "User's last name", example = "Doe")
    String lastName,
    
    @Schema(description = "User's email address", example = "john.doe@example.com")
    @NotBlank @Email String email
) {}
