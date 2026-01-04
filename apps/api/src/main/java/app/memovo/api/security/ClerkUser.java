package app.memovo.api.security;

import java.util.Map;

/**
 * Represents an authenticated Clerk user
 */
public class ClerkUser {
    private final String userId;
    private final String email;
    private final Map<String, Object> claims;

    public ClerkUser(String userId, String email, Map<String, Object> claims) {
        this.userId = userId;
        this.email = email;
        this.claims = claims;
    }

    public String getUserId() {
        return userId;
    }

    public String getEmail() {
        return email;
    }

    public Map<String, Object> getClaims() {
        return claims;
    }

    public Object getClaim(String key) {
        return claims != null ? claims.get(key) : null;
    }
}
