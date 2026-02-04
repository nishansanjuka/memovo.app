from fastapi import APIRouter
from ..application.models import WellbeingInsightRequest, WellbeingInsightResponse
from ..application.service import wellbeing_service

router = APIRouter(prefix="/wellbeing", tags=["wellbeing"])


@router.post("/insights", response_model=WellbeingInsightResponse)
async def get_insights(request: WellbeingInsightRequest):
    return await wellbeing_service.get_daily_insights(
        request.userId, request.currentUsage, request.externalContent
    )
