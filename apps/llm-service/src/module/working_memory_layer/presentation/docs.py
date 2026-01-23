from typing import Dict, Any


class WorkingMemoryDocs:
    CREATE_MEMORY: Dict[str, Any] = {
        "summary": "Create a new working memory",
        "description": "Store a chat memory record with a unique identifier and user ID. Chat content can be any JSON-serializable object.",
        "responses": {
            201: {"description": "Memory created successfully"},
            400: {"description": "Validation error or failed to create memory"},
        },
    }

    GET_MEMORY: Dict[str, Any] = {
        "summary": "Retrieve a specific working memory",
        "description": "Fetch a working memory record by its unique ID.",
        "responses": {
            200: {"description": "Memory retrieved successfully"},
            404: {"description": "Memory not found"},
        },
    }

    UPDATE_MEMORY: Dict[str, Any] = {
        "summary": "Update an existing working memory",
        "description": "Update the chat content of a working memory record.",
        "responses": {
            200: {"description": "Memory updated successfully"},
            404: {"description": "Memory not found"},
        },
    }

    DELETE_MEMORY: Dict[str, Any] = {
        "summary": "Delete a working memory",
        "description": "Permanently remove a working memory record by ID.",
        "responses": {
            200: {"description": "Memory deleted successfully"},
            404: {"description": "Memory not found"},
        },
    }

    LIST_BY_IDS: Dict[str, Any] = {
        "summary": "List working memories by a set of IDs",
        "description": "Retrieve multiple working memory records using a list of unique identifiers.",
        "responses": {200: {"description": "List of memories retrieved successfully"}},
    }
