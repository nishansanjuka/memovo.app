package app.memovo.api.application;

import java.util.List;
import java.util.Optional;

import app.memovo.api.domain.model.Journal;

public interface JournalService {
    
    Journal createJournal( Journal journal); 

    Journal updateJournal( String userId, Journal journalUpdates);
    
    Optional<Journal> getJournalById(String id);
    
    List<Journal> getJournalsByUserId(String userId); 
    
    void deleteJournal(String id);

    
}
