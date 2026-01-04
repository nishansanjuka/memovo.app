package app.memovo.api.infrastructure;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import app.memovo.api.domain.HealthStatus;

class MockHealthRepositoryTest {

    private MockHealthRepository repository;

    @BeforeEach
    @SuppressWarnings("unused")
    void setUp() {
        repository = new MockHealthRepository();
    }

    @Test
    void fetchHealthStatus_shouldReturnOkStatus() {
        HealthStatus status = repository.fetchHealthStatus();

        assertThat(status).isNotNull();
        assertThat(status.getStatus()).isEqualTo("OK");
    }
}
