package app.memovo.api.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import app.memovo.api.domain.model.User;
import app.memovo.api.domain.port.UserRepository;
import app.memovo.api.exception.UserNotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;

@ExtendWith(MockitoExtension.class)
class UserServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserServiceImpl userService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User("user_123", "John", "Doe", "john.doe@example.com", null, null);
    }

    @Test
    void createUser_shouldSaveUserWithTimestamps() {
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        User createdUser = userService.createUser(testUser);

        assertThat(createdUser).isNotNull();
        assertThat(testUser.getCreatedAt()).isNotNull();
        assertThat(testUser.getUpdatedAt()).isNotNull();
        verify(userRepository).save(testUser);
    }

    @Test
    void updateUser_shouldUpdateExistingUser() {
        User existingUser = new User("user_123", "Old", "Name", "old@example.com", LocalDateTime.now(), LocalDateTime.now());
        when(userRepository.findById("user_123")).thenReturn(Optional.of(existingUser));
        when(userRepository.save(any(User.class))).thenReturn(existingUser);

        User updatedUser = userService.updateUser("user_123", testUser);

        assertThat(updatedUser.getFirstName()).isEqualTo("John");
        assertThat(updatedUser.getLastName()).isEqualTo("Doe");
        verify(userRepository).save(existingUser);
    }

    @Test
    void updateUser_shouldThrowExceptionWhenUserNotFound() {
        when(userRepository.findById("user_nonexistent")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.updateUser("user_nonexistent", testUser))
                .isInstanceOf(UserNotFoundException.class);
    }

    @Test
    void getUserById_shouldReturnUser() {
        when(userRepository.findById("user_123")).thenReturn(Optional.of(testUser));

        Optional<User> result = userService.getUserById("user_123");

        assertThat(result).isPresent();
        assertThat(result.get().getId()).isEqualTo("user_123");
    }

    @Test
    void deleteUser_shouldDeleteWhenUserExists() {
        when(userRepository.findById("user_123")).thenReturn(Optional.of(testUser));

        userService.deleteUser("user_123");

        verify(userRepository).deleteById("user_123");
    }

    @Test
    void deleteUser_shouldThrowExceptionWhenUserNotFound() {
        when(userRepository.findById("user_nonexistent")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.deleteUser("user_nonexistent"))
                .isInstanceOf(UserNotFoundException.class);
    }
}
