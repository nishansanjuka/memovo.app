from fastapi import APIRouter, Header
from typing import Optional
from ..application.models import WellbeingInsightRequest, WellbeingInsightResponse
from ..application.service import wellbeing_service

router = APIRouter(prefix="/wellbeing", tags=["wellbeing"])


@router.post("/insights", response_model=WellbeingInsightResponse)
async def get_insights(
    request: WellbeingInsightRequest, x_user_id: Optional[str] = Header(None)
):
    # Fallback to header if userId is 'me'
    if request.userId == "me" and x_user_id:
        request.userId = x_user_id

    return await wellbeing_service.get_daily_insights(
        request.userId, request.currentUsage, request.externalContent
    )
