package app.memovo.api.controller.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDateTime;

public record JournalResponse(
    @Schema(description = "Unique identifier of the journal entry", example = "journal_abc123")
    String id,

    @Schema(description = "ID of the user who owns this journal", example = "user_123")
    String userId,

    @Schema(description = "The title of the journal entry", example = "My First Day")
    String title,

    @Schema(description = "The content of the journal entry", example = "Today was a great day...")
    String content,

    @Schema(description = "Timestamp when the entry was created")
    LocalDateTime createdAt
) {}