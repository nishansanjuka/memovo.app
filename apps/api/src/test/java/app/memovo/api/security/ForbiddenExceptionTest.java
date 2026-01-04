package app.memovo.api.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import org.junit.jupiter.api.Test;

class ForbiddenExceptionTest {

    @Test
    void constructor_shouldSetMessage() {
        ForbiddenException exception = new ForbiddenException("Access denied");

        assertThat(exception.getMessage()).isEqualTo("Access denied");
    }

    @Test
    void exception_shouldBeThrowable() {
        assertThatThrownBy(() -> {
            throw new ForbiddenException("Insufficient permissions");
        })
        .isInstanceOf(ForbiddenException.class)
        .hasMessage("Insufficient permissions");
    }
}
