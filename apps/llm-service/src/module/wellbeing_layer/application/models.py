from pydantic import BaseModel
from typing import List, Dict, Any, Optional


class AppUsage(BaseModel):
    appName: str
    durationMinutes: int
    category: str  # Social, Productivity, Entertainment, etc.


class ExternalContent(BaseModel):
    id: str
    title: str
    artistOrChannel: str
    thumbnailUrl: Optional[str] = None
    externalUrl: Optional[str] = None
    platform: str  # YOUTUBE, SPOTIFY


class DailyUsage(BaseModel):
    userId: str
    date: str  # YYYY-MM-DD
    usage: List[AppUsage]
    totalScreenTime: int


class WellbeingInsightRequest(BaseModel):
    userId: str
    currentUsage: List[AppUsage]
    externalContent: Optional[List[ExternalContent]] = None


class WellbeingInsightResponse(BaseModel):
    insight: str
    suggestions: List[str]
    moodAnalysis: str
    usageStats: Dict[str, Any]
