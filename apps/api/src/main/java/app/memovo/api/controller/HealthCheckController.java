package app.memovo.api.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthCheckController {
    private final app.memovo.api.application.HealthCheckService service;

    public HealthCheckController() {
        // Manual wiring for demo; use DI in real projects
        this.service = new app.memovo.api.application.HealthCheckService(new app.memovo.api.infrastructure.MockHealthRepository());
    }

    @GetMapping("/healthcheck")
    public java.util.Map<String, String> healthcheck() {
        app.memovo.api.domain.HealthStatus status = service.getHealthStatus();
        return java.util.Collections.singletonMap("status", status.getStatus());
    }
}
