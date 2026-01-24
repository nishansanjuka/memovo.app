from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from .docs import CHAT_DOCS
from ..application.models import ChatRequest
from ..application.service import ChatService, chat_service


def get_chat_service() -> ChatService:
    return chat_service


router = APIRouter(prefix="/chat", tags=["Chat"])


@router.post(
    "",
    **CHAT_DOCS,
)
async def chat_endpoint(
    request: ChatRequest, service: ChatService = Depends(get_chat_service)
):
    # Context-aware chat endpoint with episodic and semantic memory integration.
    # Streams status updates and response chunks back to the client.
    stream = service.chat_stream(request)
    return StreamingResponse(
        aiter(stream),
        media_type="application/octet-stream",
        headers={
            "X-Accel-Buffering": "no",
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
        },
    )
