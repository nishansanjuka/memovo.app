package app.memovo.api.infrastructure.persistence.jpa.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "journals")
public class JournalJpaEntity {

    @Id
    @Column(name = "entry_id") 
    private String id;

    @Column(name = "user_id", nullable = false) 
    private String userId;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT") 
    private String content;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public JournalJpaEntity() {}

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}