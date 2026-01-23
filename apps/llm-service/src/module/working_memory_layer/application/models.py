from pydantic import BaseModel, Field
from typing import Optional


class WorkingMemoryBase(BaseModel):
    chat: str = Field(..., description="The chat content associated with this memory.")


class WorkingMemoryCreate(WorkingMemoryBase):
    id: str = Field(..., description="Unique identifier for the memory record.")


class WorkingMemoryUpdate(BaseModel):
    chat: Optional[str] = None


class WorkingMemoryResponse(WorkingMemoryBase):
    id: str
