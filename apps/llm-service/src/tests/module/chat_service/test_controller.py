import pytest
import json
from unittest.mock import MagicMock
from fastapi.testclient import TestClient
from src.main import app
from src.module.chat_service.application.service import ChatService
from src.module.chat_service.presentation.controller import get_chat_service

client = TestClient(app)


@pytest.fixture
def mock_chat_service():
    service = MagicMock(spec=ChatService)

    def mock_chat_stream(request):
        async def mock_iter():
            # Initial working memory
            yield (
                json.dumps(
                    {"type": "data", "key": "working_memory", "value": []}
                ).encode("utf-8")
                + b"\n"
            )
            yield (
                json.dumps(
                    {
                        "type": "status",
                        "status": "retrieving_episodic",
                        "message": "msg",
                    }
                ).encode("utf-8")
                + b"\n"
            )
            yield (
                json.dumps({"type": "chunk", "content": "Hello world"}).encode("utf-8")
                + b"\n"
            )
            # Final working memory
            yield (
                json.dumps(
                    {
                        "type": "data",
                        "key": "working_memory",
                        "value": [{"role": "user", "content": "Hi"}],
                    }
                ).encode("utf-8")
                + b"\n"
            )
            yield (
                json.dumps(
                    {"type": "status", "status": "completed", "message": "msg"}
                ).encode("utf-8")
                + b"\n"
            )

        return mock_iter()

    service.chat_stream = mock_chat_stream
    app.dependency_overrides[get_chat_service] = lambda: service
    yield service
    app.dependency_overrides.clear()


def test_chat_endpoint_success(mock_chat_service):
    payload = {"userId": "user123", "prompt": "Hi"}
    response = client.post("/chat", json=payload)

    assert response.status_code == 200
    lines = response.text.strip().split("\n")
    data = [json.loads(line) for line in lines]

    assert data[0]["type"] == "data"
    assert data[0]["key"] == "working_memory"
    assert data[1]["status"] == "retrieving_episodic"
    assert data[2]["content"] == "Hello world"
    assert data[3]["type"] == "data"
    assert data[4]["status"] == "completed"


def test_chat_invalid_input():
    app.dependency_overrides.clear()
    payload = {"userId": "user123"}  # missing prompt
    response = client.post("/chat", json=payload)
    assert response.status_code == 422
