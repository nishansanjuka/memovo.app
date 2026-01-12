package app.memovo.api.infrastructure.persistence.jpa.repository;

import app.memovo.api.infrastructure.persistence.jpa.entity.UserJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpringDataUserRepository extends JpaRepository<UserJpaEntity, String> {
}
