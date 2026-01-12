package app.memovo.api.application;

import org.springframework.stereotype.Service;

import app.memovo.api.domain.HealthStatus;
import app.memovo.api.domain.port.HealthRepository;

@Service
public class HealthCheckService {
    private final HealthRepository repository;

    public HealthCheckService(HealthRepository repository) {
        this.repository = repository;
    }

    public HealthStatus getHealthStatus() {
        return repository.fetchHealthStatus();
    }
}
