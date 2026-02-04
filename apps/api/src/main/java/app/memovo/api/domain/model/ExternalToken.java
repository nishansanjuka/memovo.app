package app.memovo.api.domain.model;

import java.time.LocalDateTime;

public record ExternalToken(
    String userId,
    ExternalPlatform platform,
    String accessToken,
    String refreshToken,
    LocalDateTime expiresAt
) {
    public boolean isExpired() {
        return expiresAt != null && expiresAt.isBefore(LocalDateTime.now());
    }
}
