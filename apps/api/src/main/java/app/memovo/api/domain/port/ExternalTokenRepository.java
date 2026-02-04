package app.memovo.api.domain.port;

import app.memovo.api.domain.model.ExternalPlatform;
import app.memovo.api.domain.model.ExternalToken;
import java.util.Optional;

public interface ExternalTokenRepository {
    void save(ExternalToken token);
    Optional<ExternalToken> findByUserIdAndPlatform(String userId, ExternalPlatform platform);
    void deleteByUserIdAndPlatform(String userId, ExternalPlatform platform);
}
