package app.memovo.api.application;

import java.util.List;

import app.memovo.api.domain.model.Journal;

public interface JournalService {
    
    Journal createJournal( Journal journal); 

    Journal updateJournal(String journalId, Journal journalUpdates);
    
    Journal getJournalById(String journalId, String userId);
    
    List<Journal> getJournalsByUserId(String userId); 
    
    void deleteJournal(String id);

    
}
