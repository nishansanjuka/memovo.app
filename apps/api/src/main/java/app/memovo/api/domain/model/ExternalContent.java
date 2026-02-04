package app.memovo.api.domain.model;

public record ExternalContent(
    String id,
    String title,
    String artistOrChannel,
    String thumbnailUrl,
    String externalUrl,
    ExternalPlatform platform
) {
}
