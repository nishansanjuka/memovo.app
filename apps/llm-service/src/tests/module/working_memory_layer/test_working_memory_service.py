import pytest
from unittest.mock import patch, AsyncMock
from src.module.working_memory_layer.application.service import WorkingMemoryService
from src.module.working_memory_layer.application.models import (
    WorkingMemoryCreate,
    WorkingMemoryUpdate,
)


@pytest.fixture
def mock_repo():
    with patch(
        "src.module.working_memory_layer.application.service.working_memory_repository",
        new_callable=AsyncMock,
    ) as mock:
        yield mock


@pytest.mark.asyncio
async def test_create_memory_success(mock_repo):
    service = WorkingMemoryService()
    chat_data = {"text": "hello", "metadata": {"source": "web"}}
    payload = WorkingMemoryCreate(id="mem_1", chat=chat_data, userid="user_123")
    mock_repo.create.return_value = "mem_1"

    result = await service.create_memory(payload)
    assert result == "mem_1"
    mock_repo.create.assert_called_once_with(
        {"id": "mem_1", "chat": chat_data, "userid": "user_123"}
    )


@pytest.mark.asyncio
async def test_get_memory_not_found(mock_repo):
    service = WorkingMemoryService()
    mock_repo.get_by_id.return_value = None

    result = await service.get_memory("non_existent")
    assert result is None


@pytest.mark.asyncio
async def test_update_memory_no_changes(mock_repo):
    service = WorkingMemoryService()
    payload = WorkingMemoryUpdate()  # No fields set

    result = await service.update_memory("mem_1", payload)
    assert result is False
    mock_repo.update.assert_not_called()


@pytest.mark.asyncio
async def test_delete_memory_non_existent(mock_repo):
    service = WorkingMemoryService()
    mock_repo.delete.return_value = False

    result = await service.delete_memory("mem_1")
    assert result is False
    mock_repo.delete.assert_called_once_with("mem_1")


@pytest.mark.asyncio
async def test_list_memories_by_ids(mock_repo):
    service = WorkingMemoryService()
    ids = ["id1", "id2"]
    mock_repo.find_by_ids.return_value = [
        {"id": "id1", "chat": "chat 1", "userid": "u1"},
        {"id": "id2", "chat": "chat 2", "userid": "u1"},
    ]

    results = await service.list_memories_by_ids(ids)
    assert len(results) == 2
    assert results[0].id == "id1"
    assert results[0].userid == "u1"
    assert results[1].id == "id2"
    mock_repo.find_by_ids.assert_called_once_with(ids)
