package app.memovo.api.controller;

import app.memovo.api.application.ExternalAuthService;
import app.memovo.api.domain.model.ExternalPlatform;
import app.memovo.api.domain.model.ExternalToken;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/external-auth")
@Tag(name = "External Auth", description = "OAuth flow handlers for YouTube and Spotify")
public class ExternalAuthController {

    private final ExternalAuthService authService;
    private final RestTemplate restTemplate;

    @Value("${spotify.client-id:}")
    private String spotifyClientId;

    @Value("${spotify.client-secret:}")
    private String spotifyClientSecret;

    @Value("${youtube.client-id:}")
    private String youtubeClientId;

    @Value("${youtube.client-secret:}")
    private String youtubeClientSecret;

    @Value("${app.gateway-url:http://localhost:3000}")
    private String gatewayUrl;

    public ExternalAuthController(ExternalAuthService authService, RestTemplate restTemplate) {
        this.authService = authService;
        this.restTemplate = restTemplate;
    }

    @GetMapping("/authorize/{platform}")
    @Operation(summary = "Initiate OAuth flow")
    public void authorize(
        @PathVariable ExternalPlatform platform,
        @RequestParam String userId,
        HttpServletResponse response
    ) throws IOException {
        String url;
        String redirectUri = gatewayUrl + "/api/v1/external-auth/callback/" + platform.name().toLowerCase();
        
        if (platform == ExternalPlatform.SPOTIFY) {
            url = String.format("https://accounts.spotify.com/authorize?client_id=%s&response_type=code&redirect_uri=%s&scope=user-read-recently-played&state=%s",
                spotifyClientId, redirectUri, userId);
        } else {
            url = String.format("https://accounts.google.com/o/oauth2/v2/auth?client_id=%s&response_type=code&redirect_uri=%s&scope=https://www.googleapis.com/auth/youtube.readonly&state=%s&access_type=offline&prompt=consent",
                youtubeClientId, redirectUri, userId);
        }
        
        response.sendRedirect(url);
    }

    @GetMapping("/callback/{platform}")
    @Operation(summary = "OAuth callback handler")
    public void callback(
        @PathVariable ExternalPlatform platform,
        @RequestParam String code,
        @RequestParam String state, // State contains the userId
        HttpServletResponse response
    ) throws IOException {
        String tokenUrl = platform == ExternalPlatform.SPOTIFY ? "https://accounts.spotify.com/api/token" : "https://oauth2.googleapis.com/token";
        String redirectUri = gatewayUrl + "/api/v1/external-auth/callback/" + platform.name().toLowerCase();
        
        String clientId = platform == ExternalPlatform.SPOTIFY ? spotifyClientId : youtubeClientId;
        String clientSecret = platform == ExternalPlatform.SPOTIFY ? spotifyClientSecret : youtubeClientSecret;

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        
        String body = String.format("grant_type=authorization_code&code=%s&redirect_uri=%s&client_id=%s&client_secret=%s",
            code, redirectUri, clientId, clientSecret);
        
        HttpEntity<String> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map<String, Object>> responseEntity = restTemplate.exchange(
                tokenUrl,
                HttpMethod.POST,
                entity,
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );
            Map<String, Object> data = responseEntity.getBody();
            if (data == null) throw new RuntimeException("No token data received");
            
            String accessToken = (String) data.get("access_token");
            String refreshToken = (String) data.get("refresh_token");
            Integer expiresIn = (Integer) data.get("expires_in");
            
            ExternalToken token = new ExternalToken(
                state, platform, accessToken, refreshToken,
                LocalDateTime.now().plusSeconds(expiresIn != null ? expiresIn : 3600)
            );
            
            authService.storeToken(token);
            
            // Redirect back to mobile app success page
            response.sendRedirect(gatewayUrl + "/auth-success.html");
        } catch (Exception e) {
            response.sendRedirect(gatewayUrl + "/auth-error.html");
        }
    }
}
