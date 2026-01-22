package app.memovo.api.infrastructure.persistence.jpa.mapper;

import org.springframework.stereotype.Component;

import app.memovo.api.domain.model.Journal;
import app.memovo.api.infrastructure.persistence.jpa.entity.JournalJpaEntity;

@Component
public class JournalPersistenceMapper {

    public Journal toDomain(JournalJpaEntity entity) {
        if (entity == null) return null;
        return new Journal(
            entity.getId(),
            entity.getUserId(),
            entity.getTitle(),
            entity.getContent(),
            entity.getCreatedAt()
        );
    }

    public JournalJpaEntity toEntity(Journal domain) {
        if (domain == null) return null;
        JournalJpaEntity entity = new JournalJpaEntity();
        entity.setId(domain.getId());
        entity.setUserId(domain.getUserId());
        entity.setTitle(domain.getTitle());
        entity.setContent(domain.getContent());
        entity.setCreatedAt(domain.getCreatedAt());
        return entity;
    }
}