from src.shared import mongodb_adapter
from typing import Optional, List, Dict, Any


class EpisodicMemoryRepository:
    def __init__(self):
        self.collection_name = "episodic_memories"

    def _get_collection(self):
        db = mongodb_adapter.get_db()
        return db[self.collection_name]

    async def create(self, data: Dict[str, Any]) -> str:
        doc = {**data, "_id": data["id"]}
        del doc["id"]
        await self._get_collection().insert_one(doc)
        return data["id"]

    async def get_by_id(self, memory_id: str) -> Optional[Dict[str, Any]]:
        doc = await self._get_collection().find_one({"_id": memory_id})
        if doc:
            doc["id"] = doc["_id"]
            return doc
        return None

    async def update(self, memory_id: str, data: Dict[str, Any]) -> bool:
        result = await self._get_collection().update_one(
            {"_id": memory_id}, {"$set": data}
        )
        return result.modified_count > 0

    async def delete(self, memory_id: str) -> bool:
        result = await self._get_collection().delete_one({"_id": memory_id})
        return result.deleted_count > 0

    async def find_by_ids(self, memory_ids: List[str]) -> List[Dict[str, Any]]:
        cursor = self._get_collection().find({"_id": {"$in": memory_ids}})
        results = []
        async for doc in cursor:
            doc["id"] = doc["_id"]
            results.append(doc)
        return results


episodic_memory_repository = EpisodicMemoryRepository()
