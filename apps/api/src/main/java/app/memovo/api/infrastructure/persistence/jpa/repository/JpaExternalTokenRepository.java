package app.memovo.api.infrastructure.persistence.jpa.repository;

import app.memovo.api.domain.model.ExternalPlatform;
import app.memovo.api.infrastructure.persistence.jpa.entity.ExternalTokenJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface JpaExternalTokenRepository extends JpaRepository<ExternalTokenJpaEntity, Long> {
    Optional<ExternalTokenJpaEntity> findByUserIdAndPlatform(String userId, ExternalPlatform platform);
    void deleteByUserIdAndPlatform(String userId, ExternalPlatform platform);
}
