package app.memovo.api.config;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import app.memovo.api.security.ClerkAuthenticationFilter;
import app.memovo.api.security.CurrentUserArgumentResolver;
import org.springframework.web.servlet.config.annotation.CorsRegistry;

/**
 * Web MVC configuration for Clerk authentication and static resources
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private CurrentUserArgumentResolver currentUserArgumentResolver;

    @Autowired
    private ClerkAuthenticationFilter clerkAuthenticationFilter;

    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
        resolvers.add(currentUserArgumentResolver);
    }

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
    }

    /**
     * Register the Clerk authentication filter to intercept /api/v1/** requests
     * Swagger UI and API docs are automatically excluded from authentication
     */
    @Bean
    public FilterRegistrationBean<ClerkAuthenticationFilter> clerkFilter() {
        FilterRegistrationBean<ClerkAuthenticationFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(clerkAuthenticationFilter);
        registrationBean.addUrlPatterns("/api/v1/*");
        registrationBean.setOrder(1); // High priority
        return registrationBean;
    }
}
