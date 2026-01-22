package app.memovo.api.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import app.memovo.api.application.JournalService;
import app.memovo.api.controller.dto.JournalRequest;
import app.memovo.api.controller.dto.JournalResponse;
import app.memovo.api.controller.mapper.JournalControllerMapper;
import app.memovo.api.domain.model.Journal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/journals")
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
    public ResponseEntity<JournalResponse> createJournal(
    
            @Valid @RequestBody JournalRequest request) {

        
        Journal journalDomain = mapper.toDomain(request);



        Journal createdJournal = journalService.createJournal(journalDomain);

        
        JournalResponse response = mapper.toResponse(createdJournal);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}