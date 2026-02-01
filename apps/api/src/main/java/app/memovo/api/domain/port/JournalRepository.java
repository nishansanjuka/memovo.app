package app.memovo.api.domain.port;

import java.util.Optional;

import app.memovo.api.domain.model.Journal;

public interface JournalRepository {
    // 1. Must return 'Journal', not 'User'
    Journal save(Journal journal);

    // 2. Must return 'Optional<Journal>'
    Optional<Journal> findById(String id);

    // 3. Delete method
    void deleteById(String id);

    boolean existsById(String id);
}