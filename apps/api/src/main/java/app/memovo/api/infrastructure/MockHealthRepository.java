package app.memovo.api.infrastructure;

import org.springframework.stereotype.Component;

import app.memovo.api.domain.HealthStatus;

@Component
public class MockHealthRepository {
    public HealthStatus fetchHealthStatus() {
        // Simulate fetching health status from infrastructure
        return new HealthStatus("OK");
    }
}
