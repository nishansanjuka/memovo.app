package app.memovo.api.security;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.clerk.backend_api.helpers.security.VerifyToken;
import com.clerk.backend_api.helpers.security.models.TokenVerificationException;
import com.clerk.backend_api.helpers.security.models.VerifyTokenOptions;
import com.clerk.backend_api.models.errors.ClerkErrors;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Filter to authenticate requests using Clerk JWT tokens Applies to all
 * requests under /api/v1/**
 */
@Component
public class ClerkAuthenticationFilter implements Filter {

    @Value("${clerk.secret.key:}")
    private String clerkSecretKey;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        if (clerkSecretKey == null || clerkSecretKey.isEmpty()) {
            throw new ServletException("Clerk secret key is not configured. Please set clerk.secret.key in application.properties");
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getRequestURI();

        // Only apply authentication to /api/v1/** paths
        if (!path.startsWith("/api/v1/")) {
            chain.doFilter(request, response);
            return;
        }

        try {
            // Extract token from Authorization header
            String authHeader = httpRequest.getHeader("Authorization");
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                sendUnauthorizedError(httpResponse, "Missing or invalid Authorization header");
                return;
            }

            String token = authHeader.substring(7); // Remove "Bearer " prefix

            // Verify token with Clerk using the new security helper
            VerifyTokenOptions options = VerifyTokenOptions.Builder.withSecretKey(clerkSecretKey)
                    .build();

            com.clerk.backend_api.helpers.security.models.TokenVerificationResponse<?> verifyResponse = VerifyToken.verifyToken(token, options);

            // The payload is actually a JWT Claims object
            Object payload = verifyResponse.payload();

            if (payload == null) {
                throw new ServletException("Token verification returned null payload");
            }

            if (!(payload instanceof io.jsonwebtoken.Claims)) {
                throw new ServletException("Unexpected payload type: " + payload.getClass().getName());
            }

            io.jsonwebtoken.Claims claims = (io.jsonwebtoken.Claims) payload;

            // Store claims in request attributes for later retrieval
            httpRequest.setAttribute("clerk.claims", claims);

            chain.doFilter(request, response);

        } catch (ClerkErrors e) {
            sendUnauthorizedError(httpResponse, "Token verification failed: " + e.getMessage());
        } catch (TokenVerificationException | ServletException | IOException | InterruptedException e) {
            sendUnauthorizedError(httpResponse, "Authentication error: " + e.getMessage());
        }
    }

    private void sendUnauthorizedError(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.getWriter().write(String.format("{\"error\": \"Unauthorized\", \"message\": \"%s\"}", message));
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
