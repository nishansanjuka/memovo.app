from pydantic import BaseModel, Field
from typing import Optional


class ChatRequest(BaseModel):
    # Request model for context-aware chat
    userId: str = Field(..., description="The ID of the user")
    chatId: Optional[str] = Field(None, description="The ID of the chat session")
    prompt: str = Field(..., description="The user's message/prompt")


class ChatResponseChunk(BaseModel):
    # Model for individual chunks in the streaming response
    type: str = Field(..., description="'status' or 'chunk'")
    status: Optional[str] = Field(None, description="Status code for status type")
    message: Optional[str] = Field(None, description="Status message")
    content: Optional[str] = Field(
        None, description="Partial text content for chunk type"
    )
