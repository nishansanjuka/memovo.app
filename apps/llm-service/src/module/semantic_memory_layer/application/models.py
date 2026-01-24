from pydantic import BaseModel, Field
from typing import Any, Dict


class CreateSemanticMemoryRequest(BaseModel):
    # Request model for creating a semantic memory
    userId: str = Field(..., description="The ID of the user")
    content: str = Field(..., description="The content to be processed")
    metadata: Dict[str, Any] = Field(
        default_factory=dict, description="Additional metadata"
    )


class SemanticSearchRequest(BaseModel):
    # Request model for searching semantic memory
    userId: str = Field(..., description="The ID of the user")
    prompt: str = Field(..., description="The search prompt")
    threshold: float = Field(default=0.8, description="Relevance score threshold")
