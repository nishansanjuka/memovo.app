import json
from datetime import datetime, timedelta
from typing import List
from langchain_google_genai import ChatGoogleGenerativeAI
from src.shared.config import settings
from src.module.episodic_memory_layer.application.service import episodic_memory_service
from .models import WellbeingInsightResponse, AppUsage


class WellbeingService:
    def __init__(self):
        # Use gemini-2.5-flash-lite for cost-efficient insights
        self.llm = ChatGoogleGenerativeAI(
            model="gemini-2.5-flash-lite",
            google_api_key=settings.GOOGLE_API_KEY,
            temperature=0.7,
        )

    async def get_daily_insights(
        self, user_id: str, current_usage: List[AppUsage]
    ) -> WellbeingInsightResponse:
        try:
            # 1. Get recent memories for mood tracking (last 3 days)
            three_days_ago = (datetime.now() - timedelta(days=3)).isoformat()
            memories = await episodic_memory_service.get_recent_memories(
                user_id, three_days_ago
            )

            # Extract moods and summaries
            mood_context = ""
            for mem in memories:
                snapshot = mem.snapshot
                if isinstance(snapshot, dict):
                    mood = snapshot.get("emotion_label", "neutral")
                    summary = snapshot.get("summary", "")
                    mood_context += f"- Mood: {mood}, Context: {summary[:100]}...\n"

            # 2. Format usage context
            usage_context = "\n".join(
                [
                    f"- {app.appName} ({app.category}): {app.durationMinutes} mins"
                    for app in current_usage
                ]
            )
            total_time = sum(app.durationMinutes for app in current_usage)

            # 3. LLM Analysis
            prompt = f"""
            As a Digital Wellbeing Assistant, analyze the user's digital life and recent mood.
            
            RECENT MOOD CONTEXT:
            {mood_context if mood_context else "No recent mood data available."}
            
            TODAY'S APP USAGE:
            {usage_context}
            Total Screen Time: {total_time} minutes
            
            TASK:
            1. Analyze the correlation between their mood and digital usage.
            2. Provide 1 insightful observation.
            3. Provide 3 actionable suggestions (e.g., "Go for a walk", "Limit Social Media", "Try a quick meditation").
            
            Return the result in JSON format:
            {{
                "insight": "...",
                "moodAnalysis": "...",
                "suggestions": ["...", "...", "..."]
            }}
            """

            response = await self.llm.ainvoke(prompt)
            content = response.content

            # Parse JSON from response
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            elif "```" in content:
                content = content.split("```")[1].split("```")[0].strip()

            data = json.loads(content)

            return WellbeingInsightResponse(
                insight=data.get("insight", "Your digital usage seems balanced."),
                moodAnalysis=data.get(
                    "moodAnalysis", "Your mood appears stable based on recent logs."
                ),
                suggestions=data.get(
                    "suggestions",
                    [
                        "Take a 5-minute break",
                        "Practice mindfulness",
                        "Stretch your body",
                    ],
                ),
                usageStats={
                    "totalMinutes": total_time,
                    "topApp": max(
                        current_usage, key=lambda x: x.durationMinutes
                    ).appName
                    if current_usage
                    else "None",
                },
            )
        except Exception as e:
            print(f"Error in WellbeingService: {str(e)}")
            return WellbeingInsightResponse(
                insight="Start your day with a clear mind.",
                moodAnalysis="We're still learning about your moods.",
                suggestions=[
                    "Take a deep breath",
                    "Set your intentions for the day",
                    "Drink a glass of water",
                ],
                usageStats={"totalMinutes": 0, "topApp": "None"},
            )


wellbeing_service = WellbeingService()
