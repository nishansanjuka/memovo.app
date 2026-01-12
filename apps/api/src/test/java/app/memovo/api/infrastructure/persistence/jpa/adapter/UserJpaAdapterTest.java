package app.memovo.api.infrastructure.persistence.jpa.adapter;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

import app.memovo.api.domain.model.User;
import app.memovo.api.infrastructure.persistence.jpa.entity.UserJpaEntity;
import app.memovo.api.infrastructure.persistence.jpa.mapper.UserPersistenceMapper;
import app.memovo.api.infrastructure.persistence.jpa.repository.SpringDataUserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;

@ExtendWith(MockitoExtension.class)
class UserJpaAdapterTest {

    @Mock
    private SpringDataUserRepository springRepository;

    @Mock
    private UserPersistenceMapper mapper;

    @InjectMocks
    private UserJpaAdapter userJpaAdapter;

    private User testUser;
    private UserJpaEntity testEntity;

    @BeforeEach
    void setUp() {
        testUser = new User("user_123", "John", "Doe", "john.doe@example.com", LocalDateTime.now(), LocalDateTime.now());
        testEntity = new UserJpaEntity();
        testEntity.setId("user_123");
    }

    @Test
    void save_shouldSaveAndReturnDomain() {
        when(mapper.toEntity(testUser)).thenReturn(testEntity);
        when(springRepository.save(testEntity)).thenReturn(testEntity);
        when(mapper.toDomain(testEntity)).thenReturn(testUser);

        User savedUser = userJpaAdapter.save(testUser);

        assertThat(savedUser).isEqualTo(testUser);
        verify(springRepository).save(testEntity);
    }

    @Test
    void findById_shouldReturnOptionalDomain() {
        when(springRepository.findById("user_123")).thenReturn(Optional.of(testEntity));
        when(mapper.toDomain(testEntity)).thenReturn(testUser);

        Optional<User> result = userJpaAdapter.findById("user_123");

        assertThat(result).isPresent().contains(testUser);
    }

    @Test
    void deleteById_shouldCallRepository() {
        userJpaAdapter.deleteById("user_123");

        verify(springRepository).deleteById("user_123");
    }
}
