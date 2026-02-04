from src.shared import mongodb_adapter
from typing import Optional, List, Dict, Any
from datetime import datetime


class ChatSessionRepository:
    def __init__(self):
        self.collection_name = "chat_sessions"

    def _get_collection(self):
        db = mongodb_adapter.get_db()
        return db[self.collection_name]

    async def create(self, data: Dict[str, Any]) -> str:
        doc = {**data, "_id": data["id"]}
        if isinstance(doc.get("updatedAt"), datetime):
            doc["updatedAt"] = doc["updatedAt"].isoformat()
        del doc["id"]
        await self._get_collection().insert_one(doc)
        return data["id"]

    async def get_by_id(self, session_id: str) -> Optional[Dict[str, Any]]:
        doc = await self._get_collection().find_one({"_id": session_id})
        if doc:
            doc["id"] = doc["_id"]
            return doc
        return None

    async def update(self, session_id: str, data: Dict[str, Any]) -> bool:
        if isinstance(data.get("updatedAt"), datetime):
            data["updatedAt"] = data["updatedAt"].isoformat()

        print(f"DEBUG: MongoDB Update query for {session_id}: {data}")
        result = await self._get_collection().update_one(
            {"_id": session_id}, {"$set": data}
        )
        print(
            f"DEBUG: MongoDB modified count for {session_id}: {result.modified_count}"
        )
        return result.modified_count > 0

    async def delete(self, session_id: str) -> bool:
        result = await self._get_collection().delete_one({"_id": session_id})
        return result.deleted_count > 0

    async def find_by_user(self, user_id: str) -> List[Dict[str, Any]]:
        cursor = self._get_collection().find({"userId": user_id}).sort("updatedAt", -1)
        results = []
        async for doc in cursor:
            doc["id"] = doc["_id"]
            results.append(doc)
        return results


chat_session_repository = ChatSessionRepository()
