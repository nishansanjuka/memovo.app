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
public class SpotifyAdapter implements ExternalContentPort {

    private final RestTemplate restTemplate;
    private static final String API_URL = "https://api.spotify.com/v1/me/player/recently-played?limit=5";

    public SpotifyAdapter(RestTemplate restTemplate) {
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
                    Map<String, Object> track = (Map<String, Object>) item.get("track");
                    String id = (String) track.get("id");
                    String title = (String) track.get("name");
                    
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> artists = (List<Map<String, Object>>) track.get("artists");
                    String artistName = artists != null && !artists.isEmpty() ? (String) artists.get(0).get("name") : "Unknown";
                    
                    @SuppressWarnings("unchecked")
                    Map<String, Object> album = (Map<String, Object>) track.get("album");
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> images = (List<Map<String, Object>>) album.get("images");
                    String thumbnailUrl = images != null && !images.isEmpty() ? (String) images.get(0).get("url") : "";

                    @SuppressWarnings("unchecked")
                    Map<String, String> externalUrls = (Map<String, String>) track.get("external_urls");

                    contentList.add(new ExternalContent(
                        id, title, artistName, thumbnailUrl,
                        externalUrls != null ? externalUrls.get("spotify") : "",
                        ExternalPlatform.SPOTIFY
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
        return ExternalPlatform.SPOTIFY;
    }
}
