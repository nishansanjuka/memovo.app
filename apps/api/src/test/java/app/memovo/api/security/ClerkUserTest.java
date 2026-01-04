package app.memovo.api.security;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

class ClerkUserTest {

    @Test
    void constructor_shouldSetAllFields() {
        ClerkUser user = new ClerkUser("user_123", "test@example.com");

        assertThat(user.getId()).isEqualTo("user_123");
        assertThat(user.getEmail()).isEqualTo("test@example.com");
    }

    @Test
    void getters_shouldReturnCorrectValues() {
        ClerkUser user = new ClerkUser("user_456", "admin@example.com");

        assertThat(user.getId()).isEqualTo("user_456");
        assertThat(user.getEmail()).isEqualTo("admin@example.com");
    }
}
