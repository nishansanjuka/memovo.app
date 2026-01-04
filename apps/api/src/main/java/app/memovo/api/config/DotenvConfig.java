package app.memovo.api.config;

import java.util.HashMap;
import java.util.Map;

import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import io.github.cdimascio.dotenv.Dotenv;
import io.github.cdimascio.dotenv.DotenvException;

/**
 * Loads environment variables from .env file for development In production, use
 * actual environment variables
 */
public class DotenvConfig implements ApplicationContextInitializer<ConfigurableApplicationContext> {

    @Override
    public void initialize(ConfigurableApplicationContext applicationContext) {
        try {
            // Load .env file if it exists
            Dotenv dotenv = Dotenv.configure()
                    .directory("./")
                    .ignoreIfMissing()
                    .load();

            ConfigurableEnvironment environment = applicationContext.getEnvironment();
            Map<String, Object> dotenvProperties = new HashMap<>();

            // Add all .env entries to Spring environment
            dotenv.entries().forEach(entry -> {
                dotenvProperties.put(entry.getKey(), entry.getValue());
            });

            environment.getPropertySources()
                    .addFirst(new MapPropertySource("dotenvProperties", dotenvProperties));

        } catch (DotenvException e) {
            // If .env file doesn't exist or can't be loaded, continue with system env variables
            System.out.println("No .env file found, using system environment variables");
        }
    }
}
