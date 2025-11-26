package app.memovo.api.infrastructure;

import app.memovo.api.domain.HealthStatus;

public class MockHealthRepository {
    public HealthStatus fetchHealthStatus() {
        // Simulate fetching health status from infrastructure
        return new HealthStatus("ok");
    }
}
