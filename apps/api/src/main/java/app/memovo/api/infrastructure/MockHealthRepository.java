package app.memovo.api.infrastructure;

import org.springframework.stereotype.Component;

import app.memovo.api.domain.HealthStatus;
import app.memovo.api.domain.port.HealthRepository;

@Component
public class MockHealthRepository implements HealthRepository {
    @Override
    public HealthStatus fetchHealthStatus() {
        // Simulate fetching health status from infrastructure
        return new HealthStatus("OK");
    }
}
