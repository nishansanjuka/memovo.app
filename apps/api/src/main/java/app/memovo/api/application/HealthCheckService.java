package app.memovo.api.application;

import app.memovo.api.domain.HealthStatus;
import app.memovo.api.infrastructure.MockHealthRepository;

public class HealthCheckService {
    private final MockHealthRepository repository;

    public HealthCheckService(MockHealthRepository repository) {
        this.repository = repository;
    }

    public HealthStatus getHealthStatus() {
        return repository.fetchHealthStatus();
    }
}
