package app.memovo.api.application;

import app.memovo.api.domain.model.ExternalPlatform;
import app.memovo.api.domain.model.ExternalToken;
import java.util.Optional;

public interface ExternalAuthService {
    void storeToken(ExternalToken token);
    Optional<ExternalToken> getToken(String userId, ExternalPlatform platform);
    String refreshAccessToken(String userId, ExternalPlatform platform);
}
