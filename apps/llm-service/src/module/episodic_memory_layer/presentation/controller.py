from fastapi import APIRouter, HTTPException, Query, status
from .docs import EpisodicMemoryDocs
from ..application.models import (
    EpisodicMemoryCreate,
    EpisodicMemoryUpdate,
    EpisodicMemoryResponse,
)
from ..application.service import episodic_memory_service
from typing import List

router = APIRouter(prefix="/episodic-memory", tags=["Episodic Memory"])


@router.post(
    "/",
    response_model=str,
    status_code=status.HTTP_201_CREATED,
    **EpisodicMemoryDocs.CREATE_MEMORY,
)
async def create_memory(payload: EpisodicMemoryCreate):
    try:
        return await episodic_memory_service.create_memory(payload)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create memory: {str(e)}",
        )


@router.get(
    "/{memory_id}",
    response_model=EpisodicMemoryResponse,
    **EpisodicMemoryDocs.GET_MEMORY,
)
async def get_memory(memory_id: str):
    memory = await episodic_memory_service.get_memory(memory_id)
    if not memory:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found"
        )
    return memory


@router.patch("/{memory_id}", response_model=bool, **EpisodicMemoryDocs.UPDATE_MEMORY)
async def update_memory(memory_id: str, payload: EpisodicMemoryUpdate):
    updated = await episodic_memory_service.update_memory(memory_id, payload)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Memory not found or no changes made",
        )
    return updated


@router.delete("/{memory_id}", response_model=bool, **EpisodicMemoryDocs.DELETE_MEMORY)
async def delete_memory(memory_id: str):
    deleted = await episodic_memory_service.delete_memory(memory_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found"
        )
    return deleted


@router.get(
    "/", response_model=List[EpisodicMemoryResponse], **EpisodicMemoryDocs.LIST_BY_IDS
)
async def list_memories_by_ids(ids: List[str] = Query(...)):
    return await episodic_memory_service.list_memories_by_ids(ids)
