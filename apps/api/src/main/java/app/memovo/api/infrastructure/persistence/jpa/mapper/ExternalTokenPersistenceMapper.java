package app.memovo.api.infrastructure.persistence.jpa.mapper;

import app.memovo.api.domain.model.ExternalToken;
import app.memovo.api.infrastructure.persistence.jpa.entity.ExternalTokenJpaEntity;
import org.springframework.stereotype.Component;

@Component
public class ExternalTokenPersistenceMapper {

    public ExternalToken toDomain(ExternalTokenJpaEntity entity) {
        if (entity == null) return null;
        return new ExternalToken(
            entity.getUserId(),
            entity.getPlatform(),
            entity.getAccessToken(),
            entity.getRefreshToken(),
            entity.getExpiresAt()
        );
    }

    public ExternalTokenJpaEntity toJpaEntity(ExternalToken domain) {
        if (domain == null) return null;
        ExternalTokenJpaEntity entity = new ExternalTokenJpaEntity();
        entity.setUserId(domain.userId());
        entity.setPlatform(domain.platform());
        entity.setAccessToken(domain.accessToken());
        entity.setRefreshToken(domain.refreshToken());
        entity.setExpiresAt(domain.expiresAt());
        return entity;
    }
}
