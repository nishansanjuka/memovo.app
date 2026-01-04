package app.memovo.api.exception;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.context.request.WebRequest;

import app.memovo.api.security.ForbiddenException;
import app.memovo.api.security.UnauthorizedException;

class GlobalExceptionHandlerTest {

    private GlobalExceptionHandler handler;
    private WebRequest webRequest;

    @BeforeEach
    @SuppressWarnings("unused")
    void setUp() {
        handler = new GlobalExceptionHandler();
        webRequest = mock(WebRequest.class);
        when(webRequest.getDescription(false)).thenReturn("uri=/api/v1/test");
    }

    @Test
    void handleUnauthorizedException_shouldReturn401() {
        UnauthorizedException exception = new UnauthorizedException("Invalid token");

        ResponseEntity<Object> response = handler.handleUnauthorizedException(exception, webRequest);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        assertThat(response.getBody()).isInstanceOf(java.util.Map.class);
        @SuppressWarnings("unchecked")
        java.util.Map<String, Object> body = (java.util.Map<String, Object>) response.getBody();
        assertThat(body).containsEntry("error", "Unauthorized");
        assertThat(body).containsEntry("message", "Invalid token");
        assertThat(body).containsEntry("status", 401);
        assertThat(body).containsEntry("path", "/api/v1/test");
    }

    @Test
    void handleForbiddenException_shouldReturn403() {
        ForbiddenException exception = new ForbiddenException("Access denied");

        ResponseEntity<Object> response = handler.handleForbiddenException(exception, webRequest);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
        assertThat(response.getBody()).isInstanceOf(java.util.Map.class);
        @SuppressWarnings("unchecked")
        java.util.Map<String, Object> body = (java.util.Map<String, Object>) response.getBody();
        assertThat(body).containsEntry("error", "Forbidden");
        assertThat(body).containsEntry("message", "Access denied");
        assertThat(body).containsEntry("status", 403);
        assertThat(body).containsEntry("path", "/api/v1/test");
    }

    @Test
    void handleNotFoundException_shouldReturn404() {
        org.springframework.web.servlet.NoHandlerFoundException exception = 
            new org.springframework.web.servlet.NoHandlerFoundException("GET", "/api/v1/unknown", null);

        ResponseEntity<Object> response = handler.handleNotFoundException(exception, webRequest);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(response.getBody()).isInstanceOf(java.util.Map.class);
        @SuppressWarnings("unchecked")
        java.util.Map<String, Object> body = (java.util.Map<String, Object>) response.getBody();
        assertThat(body).containsEntry("error", "Not Found");
        assertThat(body).containsEntry("status", 404);
        assertThat(body).containsEntry("path", "/api/v1/test");
    }
}
