from pydantic import BaseModel, Field
from typing import Optional, Any


class WorkingMemoryBase(BaseModel):
    chat: Any = Field(
        ...,
        description="The chat content associated with this memory. Can be string, object, array, etc.",
    )
    userid: str = Field(..., description="The ID of the user who owns this memory.")


class WorkingMemoryCreate(WorkingMemoryBase):
    id: str = Field(..., description="Unique identifier for the memory record.")


class WorkingMemoryUpdate(BaseModel):
    chat: Optional[Any] = None
    userid: Optional[str] = None


class WorkingMemoryResponse(WorkingMemoryBase):
    id: str
