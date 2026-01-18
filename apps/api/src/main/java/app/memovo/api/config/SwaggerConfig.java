package app.memovo.api.config;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.servers.Server;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;

/**
 * Swagger/OpenAPI configuration for interactive API documentation
 */
@Configuration
@OpenAPIDefinition(
        info = @Info(
                title = "Memovo API",
                version = "1.0.0",
                description = "Interactive REST API documentation for Memovo with Clerk JWT authentication. Use Bearer tokens issued by Clerk to access all /api/v1/** routes. The local server at http://localhost:8080 is intended for development; https://api.memovo.app targets production. Endpoints expose health checks, authenticated user profile retrieval, and protected examples to validate JWT handling. Each operation documents required security, response schemas, and expected behavior to aid testing and integration.",
                contact = @Contact(name = "Memovo Support", email = "support@memovo.app")
        ),
        servers = {
            @Server(url = "http://localhost:8080", description = "Local Development"),
            @Server(url = "https://api.memovo.app", description = "Production")
        }
)
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .servers(List.of(
                        new io.swagger.v3.oas.models.servers.Server().url("http://localhost:8080").description("Local Development"),
                        new io.swagger.v3.oas.models.servers.Server().url("https://api.memovo.app").description("Production")
                ))
                // Allow either Bearer or x-api-key for all endpoints
                .addSecurityItem(new SecurityRequirement().addList("BearerAuth").addList("XApiKeyAuth"))
                .components(new Components()
                        .addSecuritySchemes("BearerAuth",
                                new SecurityScheme()
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("Clerk JWT token. All /api/v1/** endpoints require authentication."))
                        .addSecuritySchemes("XApiKeyAuth",
                                new SecurityScheme()
                                        .type(SecurityScheme.Type.APIKEY)
                                        .in(SecurityScheme.In.HEADER)
                                        .name("x-api-key")
                                        .description("API Key header. All /api/v1/** endpoints accept either Clerk JWT or x-api-key."))
                );
    }
}
