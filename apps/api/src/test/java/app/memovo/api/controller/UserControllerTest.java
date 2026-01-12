package app.memovo.api.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import app.memovo.api.application.UserService;
import app.memovo.api.controller.dto.UserRequest;
import app.memovo.api.controller.dto.UserResponse;
import app.memovo.api.domain.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;
import java.util.Optional;

@ExtendWith(MockitoExtension.class)
class UserControllerTest {

    @Mock
    private UserService userService;

    @InjectMocks
    private UserController userController;

    private User testUser;
    private UserRequest testRequest;

    @BeforeEach
    void setUp() {
        testUser = new User("user_123", "John", "Doe", "john.doe@example.com", LocalDateTime.now(), LocalDateTime.now());
        testRequest = new UserRequest("user_123", "John", "Doe", "john.doe@example.com");
    }

    @Test
    void createUser_shouldReturnCreatedUser() {
        when(userService.createUser(any(User.class))).thenReturn(testUser);

        ResponseEntity<UserResponse> response = userController.createUser(testRequest);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().id()).isEqualTo(testUser.getId());
        verify(userService).createUser(any(User.class));
    }

    @Test
    void getUser_shouldReturnUser() {
        when(userService.getUserById("user_123")).thenReturn(Optional.of(testUser));

        ResponseEntity<UserResponse> response = userController.getUser("user_123");

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().id()).isEqualTo("user_123");
    }

    @Test
    void updateUser_shouldReturnUpdatedUser() {
        when(userService.updateUser(eq("user_123"), any(User.class))).thenReturn(testUser);

        ResponseEntity<UserResponse> response = userController.updateUser("user_123", testRequest);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        verify(userService).updateUser(eq("user_123"), any(User.class));
    }

    @Test
    void deleteUser_shouldReturnNoContent() {
        userController.deleteUser("user_123");

        verify(userService).deleteUser("user_123");
    }
}
