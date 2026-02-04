package app.memovo.api.controller;

import app.memovo.api.application.ExternalContentService;
import app.memovo.api.domain.model.ExternalContent;
import app.memovo.api.domain.model.ExternalPlatform;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/external-content")
@Tag(name = "External Content", description = "Endpoints for fetching content from YouTube and Spotify")
public class ExternalContentController {

    private final ExternalContentService contentService;

    public ExternalContentController(ExternalContentService contentService) {
        this.contentService = contentService;
    }

    @GetMapping("/{platform}")
    @Operation(summary = "Get recent activities/top played content", description = "Returns top 5 recently played tracks or activities")
    public List<ExternalContent> getRecentContent(
        @Parameter(description = "User ID (injected by gateway)") @RequestParam String userId,
        @PathVariable ExternalPlatform platform
    ) {
        return contentService.getRecentContent(userId, platform);
    }
}
