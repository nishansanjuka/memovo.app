package app.memovo.api.controller.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

public record JournalRequest(
    @Schema(description = "The title of the journal entry", example = "My First Day")
    @NotBlank String title,

    @Schema(description = "The main content of the journal entry", example = "Today was a great day...")
    @NotBlank String content,

    @Schema(description = "ID of the user who owns this journal", example = "e4567-e89b-12d3-a456-426614174000")
    @NotBlank String userId
) {}


