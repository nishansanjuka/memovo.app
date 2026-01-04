package app.memovo.api.security;

/**
 * Represents an authenticated Clerk user exposed to controllers via
 *
 * @CurrentUser.
 */
public class ClerkUser {

    private final String id;
    private final String email;

    public ClerkUser(String id, String email) {
        this.id = id;
        this.email = email;
    }

    public String getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }
}
