package app.memovo.api.controller.mapper;

import org.springframework.stereotype.Component;

import app.memovo.api.controller.dto.JournalRequest;
import app.memovo.api.controller.dto.JournalUpdateRequest;
import app.memovo.api.controller.dto.JournalResponse;
import app.memovo.api.domain.model.Journal;

@Component
public class JournalControllerMapper {

    public Journal toDomain(JournalRequest request) {
        if (request == null) return null;
        
        Journal journal = new Journal();
        journal.setTitle(request.title());
        journal.setContent(request.content());
        journal.setUserId(request.userId());
        return journal;
    }

    public Journal toDomain(JournalUpdateRequest request) {
        if (request == null) return null;

        Journal journal = new Journal();
        journal.setTitle(request.title());
        journal.setContent(request.content());
        journal.setUserId(request.userId());
        return journal;
    }

    public JournalResponse toResponse(Journal domain) {
        if (domain == null) return null;
        
        return new JournalResponse(
            domain.getId(),
            domain.getUserId(),
            domain.getTitle(),
            domain.getContent(),
            domain.getCreatedAt()
        );
    }
}