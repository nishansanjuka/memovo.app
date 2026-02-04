package app.memovo.api.domain.port;

import app.memovo.api.domain.model.ExternalContent;
import app.memovo.api.domain.model.ExternalPlatform;
import java.util.List;

public interface ExternalContentPort {
    List<ExternalContent> getRecentTopContent(String accessToken);
    ExternalPlatform getPlatform();
}
