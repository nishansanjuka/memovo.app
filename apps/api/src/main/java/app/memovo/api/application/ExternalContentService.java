package app.memovo.api.application;

import app.memovo.api.domain.model.ExternalContent;
import app.memovo.api.domain.model.ExternalPlatform;
import java.util.List;

public interface ExternalContentService {
    List<ExternalContent> getRecentContent(String userId, ExternalPlatform platform);
}
