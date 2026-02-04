package app.memovo.api.application;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
public class LlmServiceImpl implements LlmService {

    private final RestTemplate restTemplate;

    @Value("${llm.service.url:http://localhost:7000}")
    private String llmServiceUrl;

    @Value("${api.key:}")
    private String apiKey;

    public LlmServiceImpl(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Override
    @Async
    public void createSemanticMemory(String userId, String content, Map<String, Object> metadata) {
        System.out.println("DEBUG: [LlmService] Starting background task for user: " + userId);
        String url = llmServiceUrl + "/semantic-memory";

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            if (!apiKey.isEmpty()) {
                headers.set("x-api-key", apiKey);
            }

            Map<String, Object> body = new HashMap<>();
            body.put("userId", userId);
            body.put("content", content);
            body.put("metadata", metadata != null ? metadata : new HashMap<>());

            // Since semantic-memory returns a stream of status updates,
            // we use a request callback that doesn't try to buffer the whole thing.
            restTemplate.execute(url, org.springframework.http.HttpMethod.POST, 
                request -> {
                    request.getHeaders().addAll(headers);
                    // Use existing converter to write body
                    restTemplate.getMessageConverters().stream()
                        .filter(c -> c.canWrite(body.getClass(), MediaType.APPLICATION_JSON))
                        .findFirst()
                        .ifPresent(c -> {
                            try {
                                ((org.springframework.http.converter.HttpMessageConverter<Object>)c)
                                    .write(body, MediaType.APPLICATION_JSON, request);
                            } catch (Exception e) {
                                throw new RuntimeException(e);
                            }
                        });
                }, 
                response -> {
                    System.out.println("DEBUG: [LlmService] Connection established. Status: " + response.getStatusCode());
                    // We don't need to read the stream content here, just initiating is enough
                    return null;
                }
            );

            System.out.println("DEBUG: [LlmService] Task completed for user: " + userId);
        } catch (Exception e) {
            System.err.println("ERROR: [LlmService] Failed to create semantic memory: " + e.getMessage());
        }
    }
}
