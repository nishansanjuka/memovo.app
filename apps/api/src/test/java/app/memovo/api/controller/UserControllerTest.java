package app.memovo.api.controller;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import app.memovo.api.controller.dto.ProtectedResponse;
import app.memovo.api.controller.dto.UserProfileResponse;
import app.memovo.api.security.ClerkUser;

@ExtendWith(MockitoExtension.class)
class UserControllerTest {

    @InjectMocks
    private UserController controller;

    private ClerkUser testUser;

    @BeforeEach
    @SuppressWarnings("unused")
    void setUp() {
        testUser = new ClerkUser("user_123", "test@example.com");
    }

    @Test
    void getProfile_shouldReturnUserProfile() {
        ResponseEntity<UserProfileResponse> response = controller.getProfile(testUser);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().id()).isEqualTo("user_123");
        assertThat(response.getBody().email()).isEqualTo("test@example.com");
    }

    @Test
    void protectedEndpoint_shouldReturnMessageWithUserId() {
        ResponseEntity<ProtectedResponse> response = controller.protectedEndpoint(testUser);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("This is a protected endpoint");
        assertThat(response.getBody().userId()).isEqualTo("user_123");
    }
}
