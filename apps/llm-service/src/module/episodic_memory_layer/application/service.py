from .models import EpisodicMemoryCreate, EpisodicMemoryUpdate, EpisodicMemoryResponse
from ..infrastructure.repository import episodic_memory_repository
from typing import List, Optional


class EpisodicMemoryService:
    async def create_memory(self, payload: EpisodicMemoryCreate) -> str:
        return await episodic_memory_repository.create(payload.model_dump())

    async def get_memory(self, memory_id: str) -> Optional[EpisodicMemoryResponse]:
        data = await episodic_memory_repository.get_by_id(memory_id)
        if data:
            return EpisodicMemoryResponse(**data)
        return None

    async def update_memory(
        self, memory_id: str, payload: EpisodicMemoryUpdate
    ) -> bool:
        update_data = payload.model_dump(exclude_unset=True)
        if not update_data:
            return False
        return await episodic_memory_repository.update(memory_id, update_data)

    async def delete_memory(self, memory_id: str) -> bool:
        return await episodic_memory_repository.delete(memory_id)

    async def list_memories_by_ids(
        self, memory_ids: List[str]
    ) -> List[EpisodicMemoryResponse]:
        data_list = await episodic_memory_repository.find_by_ids(memory_ids)
        return [EpisodicMemoryResponse(**data) for data in data_list]

    async def get_recent_memories(
        self, user_id: str, start_date: str
    ) -> List[EpisodicMemoryResponse]:
        data_list = await episodic_memory_repository.find_by_user_and_date_range(
            user_id, start_date
        )
        return [EpisodicMemoryResponse(**data) for data in data_list]


episodic_memory_service = EpisodicMemoryService()
