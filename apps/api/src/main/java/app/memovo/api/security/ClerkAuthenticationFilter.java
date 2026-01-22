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
 * Filter to authenticate requests using Clerk JWT tokens
 * Applies to all requests under /api/v1/**
 */
@Component
public class ClerkAuthenticationFilter implements Filter {

    @Value("${clerk.secret.key:}")
    private String clerkSecretKey;

    @Value("${api.key:}")
    private String apiKey;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        if (clerkSecretKey == null || clerkSecretKey.isEmpty()) {
            throw new ServletException(
                "Clerk secret key is not configured. Please set clerk.secret.key"
            );
        }
    }

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getRequestURI();

        // Public endpoint
        if ("/api/webhooks/clerk".equals(path)) {
            executeSafely(chain, request, response);
            return;
        }

        // API key auth
        String apiKeyHeader = httpRequest.getHeader("x-api-key");
        if (apiKeyHeader != null
                && !apiKeyHeader.isEmpty()
                && apiKey != null
                && apiKey.equals(apiKeyHeader)) {

            executeSafely(chain, request, response);
            return;
        }

        // Clerk auth
        String authHeader = httpRequest.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            sendUnauthorizedError(httpResponse, "Missing Authorization header");
            return;
        }

        String token = authHeader.substring(7);

        try {
            VerifyTokenOptions options =
                    VerifyTokenOptions.Builder
                            .withSecretKey(clerkSecretKey)
                            .build();

            var verifyResponse = VerifyToken.verifyToken(token, options);

            Object payload = verifyResponse.payload();

            if (!(payload instanceof io.jsonwebtoken.Claims)) {
                throw new ServletException("Invalid token payload");
            }

            httpRequest.setAttribute("clerk.claims", payload);

        } catch (ClerkErrors |
                 TokenVerificationException |
                 InterruptedException e) {

            sendUnauthorizedError(httpResponse, "Invalid or expired token");
            return;
        }

        // Execute request safely and return real exception messages without stack trace
        executeSafely(chain, request, response);
    }

    /**
     * Executes filter chain and returns exception message without stack trace
     */
    private void executeSafely(
            FilterChain chain,
            ServletRequest request,
            ServletResponse response)
            throws IOException {

        HttpServletResponse httpResponse = (HttpServletResponse) response;

        try {
            chain.doFilter(request, response);
        } catch (Exception ex) {

            if (!httpResponse.isCommitted()) {
                httpResponse.resetBuffer();
            }

            httpResponse.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            httpResponse.setContentType("application/json");

            String message = ex.getMessage() != null ? ex.getMessage() : "Internal server error";

            httpResponse.getWriter().write(
                String.format(
                    "{\"status\":500,\"error\":\"Internal Server Error\",\"message\":\"%s\"}",
                    message.replace("\"", "\\\"") // escape quotes
                )
            );
        }
    }

    private void sendUnauthorizedError(HttpServletResponse response, String message)
            throws IOException {

        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.getWriter().write(
            String.format(
                "{\"error\":\"Unauthorized\",\"message\":\"%s\"}",
                message.replace("\"", "\\\"")
            )
        );
    }

    @Override
    public void destroy() {
    }
}
