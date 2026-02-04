from fastapi import APIRouter, Depends, Header
from fastapi.responses import StreamingResponse
from typing import Optional
from .docs import CREATE_SEMANTIC_MEMORY_DOCS, SEARCH_SEMANTIC_MEMORY_DOCS
from ..application.models import CreateSemanticMemoryRequest, SemanticSearchRequest
from ..application.service import SemanticMemoryService

router = APIRouter(prefix="/semantic-memory", tags=["Semantic Memory"])


@router.post("", **CREATE_SEMANTIC_MEMORY_DOCS)
async def create_semantic_memory(
    request: CreateSemanticMemoryRequest,
    x_user_id: Optional[str] = Header(None),
    service: SemanticMemoryService = Depends(SemanticMemoryService),
):
    # Fallback to header if userId is 'me'
    if request.userId == "me" and x_user_id:
        request.userId = x_user_id

    # Endpoint to create a semantic memory from content.
    # Returns a real-time stream of status updates via StreamWriter.
    stream = service.create_semantic_memory_stream(request)
    return StreamingResponse(
        aiter(stream),
    )


@router.post("/search", **SEARCH_SEMANTIC_MEMORY_DOCS)
async def search_semantic_memory(
    request: SemanticSearchRequest,
    x_user_id: Optional[str] = Header(None),
    service: SemanticMemoryService = Depends(SemanticMemoryService),
):
    # Fallback to header if userId is 'me'
    if request.userId == "me" and x_user_id:
        request.userId = x_user_id

    print(f"DEBUG: Searching semantic memory for user: {request.userId}")
    return await service.search_semantic_memory(request)
