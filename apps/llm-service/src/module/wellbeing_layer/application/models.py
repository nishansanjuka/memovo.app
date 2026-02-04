from pydantic import BaseModel
from typing import List, Dict, Any


class AppUsage(BaseModel):
    appName: str
    durationMinutes: int
    category: str  # Social, Productivity, Entertainment, etc.


class DailyUsage(BaseModel):
    userId: str
    date: str  # YYYY-MM-DD
    usage: List[AppUsage]
    totalScreenTime: int


class WellbeingInsightRequest(BaseModel):
    userId: str
    currentUsage: List[AppUsage]


class WellbeingInsightResponse(BaseModel):
    insight: str
    suggestions: List[str]
    moodAnalysis: str
    usageStats: Dict[str, Any]
