from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from .docs import CREATE_SEMANTIC_MEMORY_DOCS, SEARCH_SEMANTIC_MEMORY_DOCS
from ..application.models import CreateSemanticMemoryRequest, SemanticSearchRequest
from ..application.service import SemanticMemoryService

router = APIRouter(prefix="/semantic-memory", tags=["Semantic Memory"])


@router.post("", **CREATE_SEMANTIC_MEMORY_DOCS)
async def create_semantic_memory(
    request: CreateSemanticMemoryRequest,
    service: SemanticMemoryService = Depends(SemanticMemoryService),
):
    # Endpoint to create a semantic memory from content.
    # Returns a real-time stream of status updates via StreamWriter.
    stream = service.create_semantic_memory_stream(request)
    return StreamingResponse(
        aiter(stream),
    )


@router.post("/search", **SEARCH_SEMANTIC_MEMORY_DOCS)
async def search_semantic_memory(
    request: SemanticSearchRequest,
    service: SemanticMemoryService = Depends(SemanticMemoryService),
):
    # Endpoint to search semantic memory for relevant context.
    return await service.search_semantic_memory(request)
