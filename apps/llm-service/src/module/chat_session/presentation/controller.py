from fastapi import APIRouter, HTTPException, status, Header
from ..application.models import (
    ChatSessionCreate,
    ChatSessionUpdate,
    ChatSessionResponse,
)
from ..application.service import chat_session_service
from typing import List, Optional

router = APIRouter(prefix="/sessions", tags=["Chat Sessions"])


@router.post("/", response_model=str, status_code=status.HTTP_201_CREATED)
async def create_session(payload: ChatSessionCreate):
    return await chat_session_service.create_session(payload)


@router.get("/{session_id}", response_model=ChatSessionResponse)
async def get_session(session_id: str):
    session = await chat_session_service.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return session


@router.patch("/{session_id}", response_model=bool)
async def update_session(session_id: str, payload: ChatSessionUpdate):
    return await chat_session_service.update_session(session_id, payload)


@router.delete("/{session_id}", response_model=bool)
async def delete_session(session_id: str):
    return await chat_session_service.delete_session(session_id)


@router.get("/user/{user_id}", response_model=List[ChatSessionResponse])
async def list_user_sessions(user_id: str, x_user_id: Optional[str] = Header(None)):
    final_user_id = x_user_id if user_id == "me" else user_id
    if not final_user_id:
        raise HTTPException(status_code=401, detail="User ID not provided")
    return await chat_session_service.list_user_sessions(final_user_id)
