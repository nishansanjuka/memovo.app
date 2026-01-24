import pytest
import json
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from src.main import app
from src.module.semantic_memory_layer.application.service import SemanticMemoryService

# Mock Gemini/Google AI classes before they are imported/instantiated
mock_genai = MagicMock()
patch("langchain_google_genai.ChatGoogleGenerativeAI", return_value=mock_genai).start()
patch(
    "langchain_google_genai.GoogleGenerativeAIEmbeddings", return_value=MagicMock()
).start()
patch("langchain_pinecone.PineconeVectorStore", return_value=MagicMock()).start()

client = TestClient(app)


@pytest.fixture
def mock_semantic_service():
    # Mock the semantic memory service
    service = MagicMock(spec=SemanticMemoryService)

    # Setup mock methods
    def mock_create_stream(request):
        async def mock_iter():
            yield (
                json.dumps({"status": "summarizing", "message": "msg"}).encode("utf-8")
                + b"\n"
            )
            yield (
                json.dumps({"status": "chunking", "message": "msg"}).encode("utf-8")
                + b"\n"
            )
            yield (
                json.dumps({"status": "storing", "message": "msg"}).encode("utf-8")
                + b"\n"
            )
            yield (
                json.dumps({"status": "completed", "message": "msg"}).encode("utf-8")
                + b"\n"
            )

        return mock_iter()

    service.create_semantic_memory_stream = mock_create_stream

    # Override the dependency
    app.dependency_overrides[SemanticMemoryService] = lambda: service
    yield service
    # Clean up
    app.dependency_overrides.clear()


def test_create_semantic_memory_success(mock_semantic_service):
    # Test successful creation of semantic memory
    payload = {
        "userId": "user123",
        "content": "This is some long content to summarize.",
        "metadata": {"source": "web"},
    }
    response = client.post("/semantic-memory", json=payload)
    assert response.status_code == 200

    # Parse the stream of JSON lines
    lines = response.text.strip().split("\n")
    statuses = [json.loads(line)["status"] for line in lines]

    assert "summarizing" in statuses
    assert "chunking" in statuses
    assert "storing" in statuses
    assert "completed" in statuses


def test_create_semantic_memory_failure(mock_semantic_service):
    # Test failure during processing
    def mock_fail_stream(request):
        async def mock_iter():
            yield (
                json.dumps({"status": "summarizing", "message": "msg"}).encode("utf-8")
                + b"\n"
            )
            yield (
                json.dumps(
                    {"status": "failed", "message": "Error occurred: Model failed"}
                ).encode("utf-8")
                + b"\n"
            )

        return mock_iter()

    mock_semantic_service.create_semantic_memory_stream = mock_fail_stream

    payload = {"userId": "user123", "content": "Content causing error", "metadata": {}}
    response = client.post("/semantic-memory", json=payload)
    assert response.status_code == 200

    lines = response.text.strip().split("\n")
    statuses = [json.loads(line)["status"] for line in lines]

    assert "summarizing" in statuses
    assert "failed" in statuses
    assert any("Model failed" in line for line in lines)


def test_search_semantic_memory_success(mock_semantic_service):
    # Test successful semantic search
    async def mock_search(request):
        results = [
            {"content": "High score", "score": 0.9},
            {"content": "Low score", "score": 0.5},
        ]
        return [r for r in results if r["score"] >= request.threshold]

    mock_semantic_service.search_semantic_memory = mock_search

    # Test default threshold (0.8)
    payload = {"userId": "user123", "prompt": "test"}
    response = client.post("/semantic-memory/search", json=payload)
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["content"] == "High score"

    # Test custom threshold (0.4)
    payload = {"userId": "user123", "prompt": "test", "threshold": 0.4}
    response = client.post("/semantic-memory/search", json=payload)
    assert response.status_code == 200
    assert len(response.json()) == 2


def test_create_semantic_memory_invalid_input(mock_semantic_service):
    # Test invalid input validation
    payload = {
        "userId": "user123",
        # missing content
    }
    response = client.post("/semantic-memory", json=payload)
    assert response.status_code == 422
