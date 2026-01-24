from .models import WorkingMemoryCreate, WorkingMemoryUpdate, WorkingMemoryResponse
from ..infrastructure.repository import working_memory_repository
from typing import List, Optional


class WorkingMemoryService:
    async def create_memory(self, payload: WorkingMemoryCreate) -> str:
        return await working_memory_repository.create(payload.model_dump())

    async def get_memory(self, memory_id: str) -> Optional[WorkingMemoryResponse]:
        data = await working_memory_repository.get_by_id(memory_id)
        if data:
            return WorkingMemoryResponse(**data)
        return None

    async def update_memory(self, memory_id: str, payload: WorkingMemoryUpdate) -> bool:
        update_data = payload.model_dump(exclude_unset=True)
        if not update_data:
            return False
        return await working_memory_repository.update(memory_id, update_data)

    async def delete_memory(self, memory_id: str) -> bool:
        return await working_memory_repository.delete(memory_id)

    async def list_memories_by_ids(
        self, memory_ids: List[str]
    ) -> List[WorkingMemoryResponse]:
        data_list = await working_memory_repository.find_by_ids(memory_ids)
        return [WorkingMemoryResponse(**data) for data in data_list]

    async def get_user_memory(self, user_id: str) -> List[WorkingMemoryResponse]:
        data_list = await working_memory_repository.find_by_user(user_id)
        return [WorkingMemoryResponse(**data) for data in data_list]


working_memory_service = WorkingMemoryService()
