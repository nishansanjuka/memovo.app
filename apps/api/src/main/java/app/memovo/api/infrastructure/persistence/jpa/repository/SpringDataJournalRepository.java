package app.memovo.api.infrastructure.persistence.jpa.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import app.memovo.api.infrastructure.persistence.jpa.entity.JournalJpaEntity;

@Repository
public interface SpringDataJournalRepository extends JpaRepository<JournalJpaEntity, String> {
    java.util.List<JournalJpaEntity> findByUserId(String userId);
}