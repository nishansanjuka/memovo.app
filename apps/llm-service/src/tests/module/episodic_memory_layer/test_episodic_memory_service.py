import pytest
from unittest.mock import patch, AsyncMock
from src.module.episodic_memory_layer.application.service import EpisodicMemoryService
from src.module.episodic_memory_layer.application.models import (
    EpisodicMemoryCreate,
    EpisodicMemoryUpdate,
)


@pytest.fixture
def mock_repo():
    with patch(
        "src.module.episodic_memory_layer.application.service.episodic_memory_repository",
        new_callable=AsyncMock,
    ) as mock:
        yield mock


@pytest.mark.asyncio
async def test_create_memory_success(mock_repo):
    service = EpisodicMemoryService()
    snapshot_data = {"event": "therapy_session", "notes": "client felt better"}
    payload = EpisodicMemoryCreate(
        id="epi_1", snapshot=snapshot_data, userid="user_456"
    )
    mock_repo.create.return_value = "epi_1"

    result = await service.create_memory(payload)
    assert result == "epi_1"
    mock_repo.create.assert_called_once_with(
        {"id": "epi_1", "snapshot": snapshot_data, "userid": "user_456"}
    )


@pytest.mark.asyncio
async def test_get_memory_not_found(mock_repo):
    service = EpisodicMemoryService()
    mock_repo.get_by_id.return_value = None

    result = await service.get_memory("non_existent")
    assert result is None


@pytest.mark.asyncio
async def test_update_memory_no_changes(mock_repo):
    service = EpisodicMemoryService()
    payload = EpisodicMemoryUpdate()  # No fields set

    result = await service.update_memory("epi_1", payload)
    assert result is False
    mock_repo.update.assert_not_called()


@pytest.mark.asyncio
async def test_delete_memory_non_existent(mock_repo):
    service = EpisodicMemoryService()
    mock_repo.delete.return_value = False

    result = await service.delete_memory("epi_1")
    assert result is False
    mock_repo.delete.assert_called_once_with("epi_1")


@pytest.mark.asyncio
async def test_list_memories_by_ids(mock_repo):
    service = EpisodicMemoryService()
    ids = ["id1", "id2"]
    mock_repo.find_by_ids.return_value = [
        {"id": "id1", "snapshot": "chat 1", "userid": "u2"},
        {"id": "id2", "snapshot": "chat 2", "userid": "u2"},
    ]

    results = await service.list_memories_by_ids(ids)
    assert len(results) == 2
    assert results[0].id == "id1"
    assert results[0].userid == "u2"
    assert results[1].id == "id2"
    mock_repo.find_by_ids.assert_called_once_with(ids)


@pytest.mark.asyncio
async def test_get_recent_memories(mock_repo):
    service = EpisodicMemoryService()
    user_id = "user_123"
    start_date = "2026-01-17T00:00:00"
    mock_repo.find_by_user_and_date_range.return_value = [
        {"id": "id1", "snapshot": {"summary": "recent"}, "userid": user_id}
    ]

    results = await service.get_recent_memories(user_id, start_date)
    assert len(results) == 1
    assert results[0].userid == user_id
    mock_repo.find_by_user_and_date_range.assert_called_once_with(user_id, start_date)
