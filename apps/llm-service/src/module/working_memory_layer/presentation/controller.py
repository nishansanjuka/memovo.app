from fastapi import APIRouter, HTTPException, Query, status
from .docs import WorkingMemoryDocs
from ..application.models import (
    WorkingMemoryCreate,
    WorkingMemoryUpdate,
    WorkingMemoryResponse,
)
from ..application.service import working_memory_service
from typing import List

router = APIRouter(prefix="/working-memory", tags=["Working Memory"])


@router.post(
    "/",
    response_model=str,
    status_code=status.HTTP_201_CREATED,
    **WorkingMemoryDocs.CREATE_MEMORY,
)
async def create_memory(payload: WorkingMemoryCreate):
    try:
        return await working_memory_service.create_memory(payload)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create memory: {str(e)}",
        )


@router.get(
    "/{memory_id}", response_model=WorkingMemoryResponse, **WorkingMemoryDocs.GET_MEMORY
)
async def get_memory(memory_id: str):
    memory = await working_memory_service.get_memory(memory_id)
    if not memory:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found"
        )
    return memory


@router.patch("/{memory_id}", response_model=bool, **WorkingMemoryDocs.UPDATE_MEMORY)
async def update_memory(memory_id: str, payload: WorkingMemoryUpdate):
    updated = await working_memory_service.update_memory(memory_id, payload)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Memory not found or no changes made",
        )
    return updated


@router.delete("/{memory_id}", response_model=bool, **WorkingMemoryDocs.DELETE_MEMORY)
async def delete_memory(memory_id: str):
    deleted = await working_memory_service.delete_memory(memory_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found"
        )
    return deleted


@router.get(
    "/", response_model=List[WorkingMemoryResponse], **WorkingMemoryDocs.LIST_BY_IDS
)
async def list_memories_by_ids(ids: List[str] = Query(...)):
    return await working_memory_service.list_memories_by_ids(ids)


@router.get("/user/{user_id}", response_model=List[WorkingMemoryResponse])
async def get_user_history(user_id: str):
    return await working_memory_service.get_user_memory(user_id)


@router.get(
    "/user/{user_id}/session/{chat_id}", response_model=List[WorkingMemoryResponse]
)
async def get_session_history(user_id: str, chat_id: str):
    return await working_memory_service.get_session_memory(user_id, chat_id)


@router.delete("/user/{user_id}/session/{chat_id}", response_model=bool)
async def delete_session_history(user_id: str, chat_id: str):
    return await working_memory_service.delete_session_memory(user_id, chat_id)
