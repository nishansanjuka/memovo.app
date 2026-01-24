CHAT_DOCS = {
    "summary": "Context-Aware Chat",
    "description": (
        "Provides a streaming chat interface. It automatically retrieves episodic memory from the last 7 days "
        "and analyzes relevance. If no episodic relevance is found, it falls back to semantic memory search."
    ),
    "responses": {
        200: {
            "description": "Stream of status updates and chat chunks (NDJSON-like bytes)",
            "content": {
                "application/octet-stream": {
                    "schema": {
                        "type": "string",
                        "example": '{"type": "status", "status": "retrieving_episodic", "message": "..."}\\n{"type": "chunk", "content": "..."}',
                    }
                }
            },
        }
    },
}
