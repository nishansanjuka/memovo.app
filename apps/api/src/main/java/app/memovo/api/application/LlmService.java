package app.memovo.api.application;

import java.util.Map;

public interface LlmService {
    void createSemanticMemory(String userId, String content, Map<String, Object> metadata);
}
