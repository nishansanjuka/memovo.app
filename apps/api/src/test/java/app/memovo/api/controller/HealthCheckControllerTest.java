package app.memovo.api.controller;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;

import app.memovo.api.application.HealthCheckService;
import app.memovo.api.controller.dto.HealthCheckResponse;
import app.memovo.api.domain.HealthStatus;

@ExtendWith(MockitoExtension.class)
class HealthCheckControllerTest {

    @Mock
    private HealthCheckService service;

    @InjectMocks
    private HealthCheckController controller;

    @Test
    void healthcheck_shouldReturnOkStatus() {
        HealthStatus healthStatus = new HealthStatus("OK");
        when(service.getHealthStatus()).thenReturn(healthStatus);

        HealthCheckResponse response = controller.healthcheck();

        assertThat(response.status()).isEqualTo("OK");
    }

    @Test
    void healthcheck_shouldReturnServiceStatus() {
        HealthStatus degradedStatus = new HealthStatus("DEGRADED");
        when(service.getHealthStatus()).thenReturn(degradedStatus);

        HealthCheckResponse response = controller.healthcheck();

        assertThat(response.status()).isEqualTo("DEGRADED");
    }
}
