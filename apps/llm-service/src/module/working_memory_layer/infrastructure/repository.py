from src.shared import mongodb_adapter
from typing import Optional, List, Dict, Any
import logging

logger = logging.getLogger(__name__)


class WorkingMemoryRepository:
    def __init__(self):
        self.collection_name = "working_memories"

    def _get_collection(self):
        db = mongodb_adapter.get_db()
        return db[self.collection_name]

    async def create(self, data: Dict[str, Any]) -> str:
        # Use provided id as _id in MongoDB
        doc = {**data, "_id": data["id"]}
        del doc["id"]
        print(
            f"DEBUG: Saving to working_memories: {doc['_id']} for session {doc.get('chatId')}"
        )
        try:
            await self._get_collection().insert_one(doc)
            print(f"DEBUG: Successfully saved {doc['_id']}")
        except Exception as e:
            print(f"DEBUG: Failed to save to working_memories: {str(e)}")
            raise
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

    async def find_by_user(self, user_id: str) -> List[Dict[str, Any]]:
        cursor = self._get_collection().find({"userId": user_id})
        results = []
        async for doc in cursor:
            doc["id"] = doc["_id"]
            results.append(doc)
        return results

    async def find_by_session(self, user_id: str, chat_id: str) -> List[Dict[str, Any]]:
        cursor = self._get_collection().find({"userId": user_id, "chatId": chat_id})
        results = []
        async for doc in cursor:
            doc["id"] = doc["_id"]
            results.append(doc)
        return results

    async def delete_by_session(self, user_id: str, chat_id: str) -> bool:
        result = await self._get_collection().delete_many(
            {"userId": user_id, "chatId": chat_id}
        )
        return result.deleted_count > 0


working_memory_repository = WorkingMemoryRepository()
