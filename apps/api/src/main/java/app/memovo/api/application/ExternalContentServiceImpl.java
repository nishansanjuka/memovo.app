package app.memovo.api.application;

import app.memovo.api.domain.model.ExternalContent;
import app.memovo.api.domain.model.ExternalPlatform;
import app.memovo.api.domain.model.ExternalToken;
import app.memovo.api.domain.port.ExternalContentPort;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ExternalContentServiceImpl implements ExternalContentService {

    private final ExternalAuthService authService;
    private final List<ExternalContentPort> contentPorts;

    public ExternalContentServiceImpl(ExternalAuthService authService, List<ExternalContentPort> contentPorts) {
        this.authService = authService;
        this.contentPorts = contentPorts;
    }

    @Override
    public List<ExternalContent> getRecentContent(String userId, ExternalPlatform platform) {
        Optional<ExternalToken> tokenOpt = authService.getToken(userId, platform);
        if (tokenOpt.isEmpty()) {
            return List.of();
        }

        ExternalToken token = tokenOpt.get();
        String accessToken = token.accessToken();
        
        if (token.isExpired()) {
            accessToken = authService.refreshAccessToken(userId, platform);
            if (accessToken == null) return List.of();
        }

        String finalAccessToken = accessToken;
        return contentPorts.stream()
            .filter(port -> port.getPlatform() == platform)
            .findFirst()
            .map(port -> port.getRecentTopContent(finalAccessToken))
            .orElse(List.of());
    }
}
