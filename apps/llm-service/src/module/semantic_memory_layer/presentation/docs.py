CREATE_SEMANTIC_MEMORY_DOCS = {
    "summary": "Create Semantic Memory",
    "description": "Process content by summarizing, chunking, and storing it in a vector database (Pinecone).",
    "responses": {
        200: {
            "description": "A stream of status updates during the processing.",
            "content": {"application/octet-stream": {}},
        }
    },
}

SEARCH_SEMANTIC_MEMORY_DOCS = {
    "summary": "Search Semantic Memory",
    "description": "Perform a semantic search on the user's stored memories and return relevant context as a string.",
    "responses": {
        200: {
            "description": "A string containing the relevant context.",
        }
    },
}
