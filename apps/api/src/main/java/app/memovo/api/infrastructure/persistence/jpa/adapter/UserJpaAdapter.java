package app.memovo.api.infrastructure.persistence.jpa.adapter;

import app.memovo.api.domain.model.User;
import app.memovo.api.domain.port.UserRepository;
import app.memovo.api.infrastructure.persistence.jpa.entity.UserJpaEntity;
import app.memovo.api.infrastructure.persistence.jpa.mapper.UserPersistenceMapper;
import app.memovo.api.infrastructure.persistence.jpa.repository.SpringDataUserRepository;
import org.springframework.stereotype.Component;
import java.util.Optional;

@Component
public class UserJpaAdapter implements UserRepository {

    private final SpringDataUserRepository springRepository;
    private final UserPersistenceMapper mapper;

    public UserJpaAdapter(SpringDataUserRepository springRepository, UserPersistenceMapper mapper) {
        this.springRepository = springRepository;
        this.mapper = mapper;
    }

    @Override
    public User save(User user) {
        UserJpaEntity entity = mapper.toEntity(user);
        UserJpaEntity savedEntity = springRepository.save(entity);
        return mapper.toDomain(savedEntity);
    }

    @Override
    public Optional<User> findById(String id) {
        return springRepository.findById(id).map(mapper::toDomain);
    }

    @Override
    public void deleteById(String id) {
        springRepository.deleteById(id);
    }
}
