package app.memovo.api.controller;

import app.memovo.api.security.ClerkUser;
import app.memovo.api.security.CurrentUser;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * Example protected controller demonstrating @CurrentUser usage
 * All endpoints under /api/v1/** are protected by Clerk authentication
 */
@RestController
@RequestMapping("/api/v1")
public class UserController {

    @GetMapping("/profile")
    public ResponseEntity<Map<String, Object>> getProfile(@CurrentUser ClerkUser user) {
        Map<String, Object> response = new HashMap<>();
        response.put("userId", user.getUserId());
        response.put("email", user.getEmail());
        response.put("claims", user.getClaims());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/protected")
    public ResponseEntity<Map<String, String>> protectedEndpoint(@CurrentUser ClerkUser user) {
        Map<String, String> response = new HashMap<>();
        response.put("message", "This is a protected endpoint");
        response.put("userId", user.getUserId());
        
        return ResponseEntity.ok(response);
    }
}
