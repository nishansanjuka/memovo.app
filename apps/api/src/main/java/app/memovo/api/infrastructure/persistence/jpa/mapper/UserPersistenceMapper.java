package app.memovo.api.infrastructure.persistence.jpa.mapper;

import app.memovo.api.domain.model.User;
import app.memovo.api.infrastructure.persistence.jpa.entity.UserJpaEntity;
import org.springframework.stereotype.Component;

@Component
public class UserPersistenceMapper {

    public User toDomain(UserJpaEntity entity) {
        if (entity == null) return null;
        return new User(
            entity.getId(),
            entity.getFirstName(),
            entity.getLastName(),
            entity.getEmail(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }

    public UserJpaEntity toEntity(User domain) {
        if (domain == null) return null;
        UserJpaEntity entity = new UserJpaEntity();
        entity.setId(domain.getId());
        entity.setFirstName(domain.getFirstName());
        entity.setLastName(domain.getLastName());
        entity.setEmail(domain.getEmail());
        entity.setCreatedAt(domain.getCreatedAt());
        entity.setUpdatedAt(domain.getUpdatedAt());
        return entity;
    }
}
