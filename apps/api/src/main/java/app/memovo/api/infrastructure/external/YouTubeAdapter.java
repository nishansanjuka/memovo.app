package app.memovo.api.infrastructure.external;

import app.memovo.api.domain.model.ExternalContent;
import app.memovo.api.domain.model.ExternalPlatform;
import app.memovo.api.domain.port.ExternalContentPort;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Component
public class YouTubeAdapter implements ExternalContentPort {

    private final RestTemplate restTemplate;
    private static final String API_URL = "https://www.googleapis.com/youtube/v3/activities?mine=true&part=snippet&maxResults=5";

    public YouTubeAdapter(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Override
    public List<ExternalContent> getRecentTopContent(String accessToken) {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        try {
            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                API_URL,
                HttpMethod.GET,
                entity,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );
            Map<String, Object> body = response.getBody();
            if (body == null) return List.of();
            
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> items = (List<Map<String, Object>>) body.get("items");
            
            List<ExternalContent> contentList = new ArrayList<>();
            if (items != null) {
                for (Map<String, Object> item : items) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> snippet = (Map<String, Object>) item.get("snippet");
                    String id = (String) item.get("id");
                    String title = (String) snippet.get("title");
                    String channel = (String) snippet.get("channelTitle");
                    
                    @SuppressWarnings("unchecked")
                    Map<String, Object> thumbnails = (Map<String, Object>) snippet.get("thumbnails");
                    String thumbnailUrl = "";
                    if (thumbnails != null && thumbnails.get("default") != null) {
                        @SuppressWarnings("unchecked")
                        Map<String, Object> defaultThumb = (Map<String, Object>) thumbnails.get("default");
                        thumbnailUrl = (String) defaultThumb.get("url");
                    }

                    contentList.add(new ExternalContent(
                        id, title, channel, thumbnailUrl,
                        "https://www.youtube.com/watch?v=" + id,
                        ExternalPlatform.YOUTUBE
                    ));
                }
            }
            return contentList;
        } catch (Exception e) {
            return List.of();
        }
    }

    @Override
    public ExternalPlatform getPlatform() {
        return ExternalPlatform.YOUTUBE;
    }
}
