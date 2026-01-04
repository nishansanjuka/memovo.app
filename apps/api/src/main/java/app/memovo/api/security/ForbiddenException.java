package app.memovo.api.security;

/**
 * Exception thrown when access is forbidden (403 Forbidden)
 */
public class ForbiddenException extends RuntimeException {
    public ForbiddenException(String message) {
        super(message);
    }

    public ForbiddenException(String message, Throwable cause) {
        super(message, cause);
    }
}
