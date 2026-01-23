from typing import Dict, Any


class EpisodicMemoryDocs:
    CREATE_MEMORY: Dict[str, Any] = {
        "summary": "Create a new episodic memory",
        "description": "Store a snapshot memory record with a unique identifier and user ID. Snapshot content can be any JSON-serializable object.",
        "responses": {
            201: {"description": "Memory created successfully"},
            400: {"description": "Validation error or failed to create memory"},
        },
    }

    GET_MEMORY: Dict[str, Any] = {
        "summary": "Retrieve a specific episodic memory",
        "description": "Fetch an episodic memory record by its unique ID.",
        "responses": {
            200: {"description": "Memory retrieved successfully"},
            404: {"description": "Memory not found"},
        },
    }

    UPDATE_MEMORY: Dict[str, Any] = {
        "summary": "Update an existing episodic memory",
        "description": "Update the snapshot content of an episodic memory record.",
        "responses": {
            200: {"description": "Memory updated successfully"},
            404: {"description": "Memory not found"},
        },
    }

    DELETE_MEMORY: Dict[str, Any] = {
        "summary": "Delete an episodic memory",
        "description": "Permanently remove an episodic memory record by ID.",
        "responses": {
            200: {"description": "Memory deleted successfully"},
            404: {"description": "Memory not found"},
        },
    }

    LIST_BY_IDS: Dict[str, Any] = {
        "summary": "List episodic memories by a set of IDs",
        "description": "Retrieve multiple episodic memory records using a list of unique identifiers.",
        "responses": {200: {"description": "List of memories retrieved successfully"}},
    }
