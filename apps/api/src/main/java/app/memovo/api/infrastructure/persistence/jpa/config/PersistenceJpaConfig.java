package app.memovo.api.infrastructure.persistence.jpa.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * Explicit JPA Configuration
 * 
 * While Spring Boot performs auto-configuration, this class provides explicit
 * boundaries for JPA repositories, improving readability and 
 * making the infrastructure layer explicit.
 */
@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(basePackages = "app.memovo.api.infrastructure.persistence.jpa.repository")
public class PersistenceJpaConfig {
    // Explicit configuration for JPA infrastructure
}
