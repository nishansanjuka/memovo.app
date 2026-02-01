package app.memovo.api.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import app.memovo.api.application.JournalService;
import app.memovo.api.controller.dto.JournalRequest;
import app.memovo.api.controller.dto.JournalResponse;
import app.memovo.api.controller.dto.JournalUpdateRequest;
import app.memovo.api.controller.mapper.JournalControllerMapper;
import app.memovo.api.domain.model.Journal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/journals")
@Tag(name = "Journals", description = "Operations related to user journals")
public class JournalController {

    private final JournalService journalService;
    private final JournalControllerMapper mapper;

    public JournalController(JournalService journalService, JournalControllerMapper mapper) {
        this.journalService = journalService;
        this.mapper = mapper;
    }

    @PostMapping
    @Operation(summary = "Create a new journal entry for a specific user")
    public ResponseEntity<JournalResponse> createJournal(@Valid @RequestBody JournalRequest request) {

        Journal journalDomain = mapper.toDomain(request);

        Journal createdJournal = journalService.createJournal(journalDomain);

        JournalResponse response = mapper.toResponse(createdJournal);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    @Operation(summary = "Get all journal entries for a user")
    public ResponseEntity<List<JournalResponse>> getJournals(@RequestParam String userId) {
        List<Journal> journals = journalService.getJournalsByUserId(userId);
        List<JournalResponse> responses = journals.stream()
            .map(mapper::toResponse)
            .toList();
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/{journalId}")
    @Operation(summary = "Get a journal entry by ID with userId validation")
    public ResponseEntity<JournalResponse> getJournal(
            @PathVariable String journalId,
            @RequestParam String userId) {

        Journal journal = journalService.getJournalById(journalId, userId);

        JournalResponse response = mapper.toResponse(journal);

        return ResponseEntity.ok(response);
    }

    @PutMapping("/{journalId}")
    @Operation(summary = "Update an existing journal entry for a specific user")
    public ResponseEntity<JournalResponse> updateJournal(
            @RequestBody JournalUpdateRequest request,
            @PathVariable String journalId) {

        Journal journalDomain = mapper.toDomain(request);

        Journal updatedJournal = journalService.updateJournal(journalId, journalDomain);

        JournalResponse response = mapper.toResponse(updatedJournal);

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{journalId}")
    @Operation(summary = "Delete a journal entry")
    public ResponseEntity<Void> deleteJournal(@PathVariable String journalId) {
        journalService.deleteJournal(journalId);
        return ResponseEntity.noContent().build();
    }
}