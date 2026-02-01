package app.memovo.api.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import app.memovo.api.application.JournalService;
import app.memovo.api.controller.dto.JournalResponse;
import app.memovo.api.controller.dto.JournalUpdateRequest;
import app.memovo.api.controller.mapper.JournalControllerMapper;
import app.memovo.api.domain.model.Journal;

@ExtendWith(MockitoExtension.class)
class JournalControllerTest {

    @Mock
    private JournalService journalService;

    @Mock
    private JournalControllerMapper mapper;

    @InjectMocks
    private JournalController journalController;

    @Test
    void getJournal_shouldReturnOk() {
        // Arrange
        String journalId = "journal_123";
        String userId = "user_123";
        Journal journal = new Journal();
        journal.setId(journalId);
        JournalResponse responseDto = new JournalResponse(journalId, userId, "Title", "Content", null);

        when(journalService.getJournalById(journalId, userId)).thenReturn(journal);
        when(mapper.toResponse(journal)).thenReturn(responseDto);

        // Act
        ResponseEntity<JournalResponse> response = journalController.getJournal(journalId, userId);

        // Assert
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        verify(journalService).getJournalById(journalId, userId);
    }

    @Test
    void updateJournal_shouldReturnOk_withPartialUpdate() {
        // Arrange
        String journalId = "journal_123";
        JournalUpdateRequest request = new JournalUpdateRequest("Updated Title", null, null);
        Journal journalDomain = new Journal();
        journalDomain.setTitle("Updated Title");
        
        Journal updatedJournal = new Journal();
        updatedJournal.setId(journalId);
        updatedJournal.setTitle("Updated Title");
        updatedJournal.setContent("Original Content");
        
        JournalResponse responseDto = new JournalResponse(journalId, "user_1", "Updated Title", "Original Content", null);

        when(mapper.toDomain(request)).thenReturn(journalDomain);
        when(journalService.updateJournal(eq(journalId), any(Journal.class))).thenReturn(updatedJournal);
        when(mapper.toResponse(updatedJournal)).thenReturn(responseDto);

        // Act
        ResponseEntity<JournalResponse> response = journalController.updateJournal(request, journalId);

        // Assert
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().title()).isEqualTo("Updated Title");
        verify(journalService).updateJournal(eq(journalId), any(Journal.class));
    }

    @Test
    void deleteJournal_shouldReturnNoContent() {
        // Arrange
        String journalId = "journal_123";

        // Act
        ResponseEntity<Void> response = journalController.deleteJournal(journalId);

        // Assert
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);
        verify(journalService).deleteJournal(journalId);
    }
}
