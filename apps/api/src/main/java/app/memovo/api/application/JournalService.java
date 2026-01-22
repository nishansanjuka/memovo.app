package app.memovo.api.application;

import java.util.List;
import java.util.Optional;

import app.memovo.api.domain.model.Journal;

public interface JournalService {
    // We explicitly require userId here to ensure ownership is set
    Journal createJournal(String userId, Journal journal); 
    
    Optional<Journal> getJournalById(String id);
    
    // Helpful method to get all journals belonging to a specific user
    List<Journal> getJournalsByUserId(String userId); 
    
    void deleteJournal(String id);
}
