from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class ChatSessionBase(BaseModel):
    userId: str = Field(..., description="The ID of the user who owns this session.")
    title: str = Field(..., description="The title of the chat session.")
    lastMessage: Optional[str] = Field(
        None, description="The content of the last message in this session."
    )
    updatedAt: datetime = Field(default_factory=datetime.now)


class ChatSessionCreate(ChatSessionBase):
    id: str = Field(..., description="Unique identifier for the chat session.")


class ChatSessionUpdate(BaseModel):
    title: Optional[str] = None
    lastMessage: Optional[str] = None
    updatedAt: Optional[datetime] = None


class ChatSessionResponse(ChatSessionBase):
    id: str
