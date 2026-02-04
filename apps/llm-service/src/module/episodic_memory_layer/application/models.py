from pydantic import BaseModel, Field
from typing import Optional, Any


class EpisodicMemoryBase(BaseModel):
    snapshot: Any = Field(
        ...,
        description="The snapshot content associated with this memory. Can be string, object, array, etc.",
    )
    userId: str = Field(..., description="The ID of the user who owns this memory.")


class EpisodicMemoryCreate(EpisodicMemoryBase):
    id: str = Field(..., description="Unique identifier for the memory record.")


class EpisodicMemoryUpdate(BaseModel):
    snapshot: Optional[Any] = None
    userId: Optional[str] = None


class EpisodicMemoryResponse(EpisodicMemoryBase):
    id: str
