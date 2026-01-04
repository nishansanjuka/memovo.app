package app.memovo.api.application;

import org.springframework.stereotype.Service;

import app.memovo.api.domain.HealthStatus;
import app.memovo.api.infrastructure.MockHealthRepository;

@Service
public class HealthCheckService {
    private final MockHealthRepository repository;

    public HealthCheckService(MockHealthRepository repository) {
        this.repository = repository;
    }

    public HealthStatus getHealthStatus() {
        return repository.fetchHealthStatus();
    }
}
