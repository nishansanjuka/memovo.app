package app.memovo.api.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.NoSuchElementException;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import app.memovo.api.domain.model.Journal;
import app.memovo.api.domain.port.JournalRepository;

@ExtendWith(MockitoExtension.class)
class JournalServiceImplTest {

    @Mock
    private JournalRepository journalRepository;

    @InjectMocks
    private JournalServiceImpl journalService;

    private Journal existingJournal;

    @BeforeEach
    void setUp() {
        existingJournal = new Journal();
        existingJournal.setId("journal_123");
        existingJournal.setTitle("Old Title");
        existingJournal.setContent("Old Content");
        existingJournal.setUserId("user_123");
    }

    @Test
    void updateJournal_shouldUpdateOnlyProvidedFields() {
        // Arrange
        Journal updates = new Journal();
        updates.setTitle("New Title");

        when(journalRepository.findById("journal_123")).thenReturn(Optional.of(existingJournal));
        when(journalRepository.save(any(Journal.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        Journal result = journalService.updateJournal("journal_123", updates);

        // Assert
        assertThat(result.getTitle()).isEqualTo("New Title");
        assertThat(result.getContent()).isEqualTo("Old Content");
        assertThat(result.getUserId()).isEqualTo("user_123");
    }

    @Test
    void updateJournal_shouldUpdateAllFields_whenAllProvided() {
        // Arrange
        Journal updates = new Journal();
        updates.setTitle("New Title");
        updates.setContent("New Content");
        updates.setUserId("new_user");

        when(journalRepository.findById("journal_123")).thenReturn(Optional.of(existingJournal));
        when(journalRepository.save(any(Journal.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        Journal result = journalService.updateJournal("journal_123", updates);

        // Assert
        assertThat(result.getTitle()).isEqualTo("New Title");
        assertThat(result.getContent()).isEqualTo("New Content");
        assertThat(result.getUserId()).isEqualTo("new_user");
    }

    @Test
    void updateJournal_shouldThrowException_whenNotFound() {
        // Arrange
        when(journalRepository.findById("non_existent")).thenReturn(Optional.empty());

        // Act & Assert
        assertThatThrownBy(() -> journalService.updateJournal("non_existent", new Journal()))
            .isInstanceOf(NoSuchElementException.class);
    }

    @Test
    void deleteJournal_shouldDelete_whenExists() {
        // Arrange
        when(journalRepository.existsById("journal_123")).thenReturn(true);

        // Act
        journalService.deleteJournal("journal_123");

        // Assert
        verify(journalRepository).deleteById("journal_123");
    }

    @Test
    void deleteJournal_shouldThrowException_whenNotFound() {
        // Arrange
        when(journalRepository.existsById("non_existent")).thenReturn(false);

        // Act & Assert
        assertThatThrownBy(() -> journalService.deleteJournal("non_existent"))
            .isInstanceOf(NoSuchElementException.class);
    }
}
