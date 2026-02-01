package app.memovo.api.application;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.UUID;
 
import org.springframework.stereotype.Service;

import app.memovo.api.domain.model.Journal;
import app.memovo.api.domain.port.JournalRepository; 

@Service
public class JournalServiceImpl implements JournalService {

    private final JournalRepository journalRepository;

    public JournalServiceImpl(JournalRepository journalRepository) {
        this.journalRepository = journalRepository;
    }

    @Override
    public Journal createJournal( Journal journal) {
        
        
        if (journal.getId() == null) {
            journal.setId(UUID.randomUUID().toString());
        }
        journal.setCreatedAt(LocalDateTime.now());
        
        return journalRepository.save(journal);
    }

    @Override
    public Journal updateJournal(String journalId, Journal journalUpdates) { 
        Journal existingJournal = journalRepository.findById(journalId)
            .orElseThrow(() -> new NoSuchElementException("Journal not found with id: " + journalId));

        if (journalUpdates.getTitle() != null) {
            existingJournal.setTitle(journalUpdates.getTitle());
        }
        if (journalUpdates.getContent() != null) {
            existingJournal.setContent(journalUpdates.getContent());
        }
        if (journalUpdates.getUserId() != null) {
            existingJournal.setUserId(journalUpdates.getUserId());
        }
        
        return journalRepository.save(existingJournal);
    }
    

    @Override
    public Optional<Journal> getJournalById(String id) {
        return journalRepository.findById(id);
    }

    @Override
    public List<Journal> getJournalsByUserId(String userId) {
        return Collections.emptyList(); 
    }

    @Override
    public void deleteJournal(String id) {
        journalRepository.deleteById(id);
    }
}