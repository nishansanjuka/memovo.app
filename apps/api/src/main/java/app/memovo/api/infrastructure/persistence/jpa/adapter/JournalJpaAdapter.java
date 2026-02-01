package app.memovo.api.infrastructure.persistence.jpa.adapter;

import app.memovo.api.domain.model.Journal;
import app.memovo.api.domain.port.JournalRepository;
import app.memovo.api.infrastructure.persistence.jpa.entity.JournalJpaEntity;
import app.memovo.api.infrastructure.persistence.jpa.mapper.JournalPersistenceMapper;
import app.memovo.api.infrastructure.persistence.jpa.repository.SpringDataJournalRepository;
import org.springframework.stereotype.Component;
import java.util.Optional;

@Component
public class JournalJpaAdapter implements JournalRepository {

    private final SpringDataJournalRepository springRepository;
    private final app.memovo.api.infrastructure.persistence.jpa.repository.SpringDataUserRepository userRepository;
    private final JournalPersistenceMapper mapper;

    public JournalJpaAdapter(SpringDataJournalRepository springRepository, 
                             app.memovo.api.infrastructure.persistence.jpa.repository.SpringDataUserRepository userRepository,
                             JournalPersistenceMapper mapper) {
        this.springRepository = springRepository;
        this.userRepository = userRepository;
        this.mapper = mapper;
    }

    @Override
    public Journal save(Journal journal) {
        JournalJpaEntity entity = mapper.toEntity(journal);
        if (journal.getUserId() != null) {
            entity.setUser(userRepository.getReferenceById(journal.getUserId()));
        }
        JournalJpaEntity savedEntity = springRepository.save(entity);
        return mapper.toDomain(savedEntity);
    }

    @Override
    public Optional<Journal> findById(String id) {
        return springRepository.findById(id).map(mapper::toDomain);
    }

    @Override
    public void deleteById(String id) {
        springRepository.deleteById(id);
    }

    @Override
    public boolean existsById(String id) {
        return springRepository.existsById(id);
    }
}