from .models import ChatSessionCreate, ChatSessionUpdate, ChatSessionResponse
from ..infrastructure.repository import chat_session_repository
from src.module.working_memory_layer.application.service import (
    working_memory_service,
)
from typing import List, Optional
from datetime import datetime


class ChatSessionService:
    async def create_session(self, payload: ChatSessionCreate) -> str:
        return await chat_session_repository.create(payload.model_dump())

    async def get_session(self, session_id: str) -> Optional[ChatSessionResponse]:
        data = await chat_session_repository.get_by_id(session_id)
        if data:
            return ChatSessionResponse(**data)
        return None

    async def update_session(self, session_id: str, payload: ChatSessionUpdate) -> bool:
        update_data = payload.model_dump(exclude_unset=True)
        if not update_data:
            return False
        return await chat_session_repository.update(session_id, update_data)

    async def delete_session(self, session_id: str) -> bool:
        session = await self.get_session(session_id)
        if session:
            await working_memory_service.delete_session_memory(
                session.userId, session_id
            )
        return await chat_session_repository.delete(session_id)

    async def list_user_sessions(self, user_id: str) -> List[ChatSessionResponse]:
        data_list = await chat_session_repository.find_by_user(user_id)
        return [ChatSessionResponse(**data) for data in data_list]

    async def ensure_session(
        self,
        user_id: str,
        session_id: str,
        title: str = "New Chat",
        last_message: str = None,
    ):
        # Check if session exists, create if not
        exists = await self.get_session(session_id)
        if not exists:
            await self.create_session(
                ChatSessionCreate(
                    id=session_id,
                    userId=user_id,
                    title=title,
                    lastMessage=last_message,
                    updatedAt=datetime.now(),
                )
            )
        else:
            # If title is default, update it with the provided one
            if exists.title.strip().lower() == "new chat":
                await self.update_session(
                    session_id,
                    ChatSessionUpdate(
                        title=title, lastMessage=last_message, updatedAt=datetime.now()
                    ),
                )


chat_session_service = ChatSessionService()
