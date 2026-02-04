package app.memovo.api.application;

import app.memovo.api.domain.model.ExternalPlatform;
import app.memovo.api.domain.model.ExternalToken;
import app.memovo.api.domain.port.ExternalTokenRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

@Service
public class ExternalAuthServiceImpl implements ExternalAuthService {

    private final ExternalTokenRepository tokenRepository;
    private final RestTemplate restTemplate;

    @Value("${spotify.client-id:}")
    private String spotifyClientId;

    @Value("${spotify.client-secret:}")
    private String spotifyClientSecret;

    @Value("${youtube.client-id:}")
    private String youtubeClientId;

    @Value("${youtube.client-secret:}")
    private String youtubeClientSecret;

    public ExternalAuthServiceImpl(ExternalTokenRepository tokenRepository, RestTemplate restTemplate) {
        this.tokenRepository = tokenRepository;
        this.restTemplate = restTemplate;
    }

    @Override
    public void storeToken(ExternalToken token) {
        tokenRepository.save(token);
    }

    @Override
    public Optional<ExternalToken> getToken(String userId, ExternalPlatform platform) {
        return tokenRepository.findByUserIdAndPlatform(userId, platform);
    }

    @Override
    public String refreshAccessToken(String userId, ExternalPlatform platform) {
        Optional<ExternalToken> tokenOpt = getToken(userId, platform);
        if (tokenOpt.isEmpty() || tokenOpt.get().refreshToken() == null) {
            return null;
        }

        ExternalToken token = tokenOpt.get();
        String clientId = platform == ExternalPlatform.SPOTIFY ? spotifyClientId : youtubeClientId;
        String clientSecret = platform == ExternalPlatform.SPOTIFY ? spotifyClientSecret : youtubeClientSecret;
        String refreshUrl = platform == ExternalPlatform.SPOTIFY ? "https://accounts.spotify.com/api/token" : "https://oauth2.googleapis.com/token";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        
        String body = String.format("grant_type=refresh_token&refresh_token=%s&client_id=%s&client_secret=%s",
            token.refreshToken(), clientId, clientSecret);
        
        HttpEntity<String> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                refreshUrl,
                HttpMethod.POST,
                entity,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );
            Map<String, Object> data = response.getBody();
            if (data == null) return null;
            
            String newAccessToken = (String) data.get("access_token");
            Integer expiresIn = (Integer) data.get("expires_in");
            
            ExternalToken updatedToken = new ExternalToken(
                userId, platform, newAccessToken, token.refreshToken(),
                LocalDateTime.now().plusSeconds(expiresIn != null ? expiresIn : 3600)
            );
            
            storeToken(updatedToken);
            return newAccessToken;
        } catch (Exception e) {
            return null;
        }
    }
}
