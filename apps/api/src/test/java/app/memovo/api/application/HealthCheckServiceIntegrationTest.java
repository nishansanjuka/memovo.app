package app.memovo.api.application;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import app.memovo.api.domain.HealthStatus;
import app.memovo.api.infrastructure.MockHealthRepository;

@SpringBootTest
class HealthCheckServiceIntegrationTest {

    @Autowired
    private HealthCheckService service;

    @Test
    void getHealthStatus_shouldReturnHealthFromRepository() {
        HealthStatus status = service.getHealthStatus();

        assertThat(status).isNotNull();
        assertThat(status.getStatus()).isEqualTo("OK");
    }

    @Test
    void getHealthStatus_shouldIntegrateWithMockRepository() {
        MockHealthRepository repository = new MockHealthRepository();
        HealthCheckService testService = new HealthCheckService(repository);

        HealthStatus status = testService.getHealthStatus();

        assertThat(status).isNotNull();
        assertThat(status.getStatus()).isEqualTo("OK");
    }
}
