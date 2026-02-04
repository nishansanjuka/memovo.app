package app.memovo.api.infrastructure.persistence.jpa.adapter;

import app.memovo.api.domain.model.ExternalPlatform;
import app.memovo.api.domain.model.ExternalToken;
import app.memovo.api.domain.port.ExternalTokenRepository;
import app.memovo.api.infrastructure.persistence.jpa.entity.ExternalTokenJpaEntity;
import app.memovo.api.infrastructure.persistence.jpa.mapper.ExternalTokenPersistenceMapper;
import app.memovo.api.infrastructure.persistence.jpa.repository.JpaExternalTokenRepository;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Component
@Transactional
public class ExternalTokenPersistenceAdapter implements ExternalTokenRepository {

    private final JpaExternalTokenRepository jpaRepository;
    private final ExternalTokenPersistenceMapper mapper;

    public ExternalTokenPersistenceAdapter(
        JpaExternalTokenRepository jpaRepository,
        ExternalTokenPersistenceMapper mapper
    ) {
        this.jpaRepository = jpaRepository;
        this.mapper = mapper;
    }

    @Override
    public void save(ExternalToken token) {
        Optional<ExternalTokenJpaEntity> existing = jpaRepository.findByUserIdAndPlatform(token.userId(), token.platform());
        
        ExternalTokenJpaEntity entity;
        if (existing.isPresent()) {
            entity = existing.get();
            entity.setAccessToken(token.accessToken());
            entity.setRefreshToken(token.refreshToken());
            entity.setExpiresAt(token.expiresAt());
        } else {
            entity = mapper.toJpaEntity(token);
        }
        
        jpaRepository.save(entity);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ExternalToken> findByUserIdAndPlatform(String userId, ExternalPlatform platform) {
        return jpaRepository.findByUserIdAndPlatform(userId, platform)
            .map(mapper::toDomain);
    }

    @Override
    public void deleteByUserIdAndPlatform(String userId, ExternalPlatform platform) {
        jpaRepository.deleteByUserIdAndPlatform(userId, platform);
    }
}
