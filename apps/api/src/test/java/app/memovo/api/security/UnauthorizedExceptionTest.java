package app.memovo.api.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import org.junit.jupiter.api.Test;

class UnauthorizedExceptionTest {

    @Test
    void constructor_shouldSetMessage() {
        UnauthorizedException exception = new UnauthorizedException("Invalid credentials");

        assertThat(exception.getMessage()).isEqualTo("Invalid credentials");
    }

    @Test
    void exception_shouldBeThrowable() {
        assertThatThrownBy(() -> {
            throw new UnauthorizedException("Token expired");
        })
        .isInstanceOf(UnauthorizedException.class)
        .hasMessage("Token expired");
    }
}
