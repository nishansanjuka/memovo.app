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
    public  Journal updateJournal(String userId, Journal journalUpdates) { 
        Journal existingJournal = journalRepository.findById(journalUpdates.getId())
            .orElseThrow(() -> new NoSuchElementException("Journal not found with id: " + journalUpdates.getId()));

        if (!existingJournal.getUserId().equals(userId)) {
            throw new SecurityException("User " + userId + " is not authorized to update this journal.");
        }

        existingJournal.setTitle(journalUpdates.getTitle());
        existingJournal.setContent(journalUpdates.getContent());
        
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