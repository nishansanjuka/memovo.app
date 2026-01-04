package app.memovo.api.domain;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

class HealthStatusTest {

    @Test
    void constructor_shouldSetStatus() {
        HealthStatus healthStatus = new HealthStatus("OK");

        assertThat(healthStatus.getStatus()).isEqualTo("OK");
    }

    @Test
    void getStatus_shouldReturnCorrectValue() {
        HealthStatus healthStatus = new HealthStatus("DEGRADED");

        assertThat(healthStatus.getStatus()).isEqualTo("DEGRADED");
    }
}
