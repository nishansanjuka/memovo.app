import json
import asyncio
from datetime import datetime, timedelta
from typing import List, Any
from langchain_google_genai import ChatGoogleGenerativeAI
from src.shared.config import settings
from src.module.episodic_memory_layer.application.service import episodic_memory_service
from src.module.semantic_memory_layer.application.service import SemanticMemoryService
from src.module.semantic_memory_layer.application.models import SemanticSearchRequest
from .models import ChatRequest


class ChatStreamWriter:
    # A stream writer for the chat service that handles status updates and response chunks.

    def __init__(self):
        self._queue: asyncio.Queue = asyncio.Queue()

    async def write_status(self, status: str, message: str):
        # Push a status update to the stream.
        data = (
            json.dumps({"type": "status", "status": status, "message": message}) + "\n"
        )
        await self._queue.put(data.encode("utf-8"))

    async def write_chunk(self, content: str):
        # Push a text chunk to the stream.
        data = json.dumps({"type": "chunk", "content": content}) + "\n"
        await self._queue.put(data.encode("utf-8"))

    async def close(self):
        # Signal the end of the stream.
        await self._queue.put(None)

    async def __aiter__(self):
        # Async iterator to yield chunks for StreamingResponse.
        while True:
            chunk = await self._queue.get()
            if chunk is None:
                break
            yield chunk


class ChatService:
    # Orchestrates context-aware chat by integrating episodic and semantic memory.

    def __init__(self):
        self.llm = ChatGoogleGenerativeAI(
            model="gemini-2.5-flash-lite",
            google_api_key=settings.GOOGLE_API_KEY,
            temperature=0.7,
        )
        self.semantic_service = SemanticMemoryService()

    def chat_stream(self, request: ChatRequest) -> ChatStreamWriter:
        # returns the stream object immediately and processes in background.
        stream = ChatStreamWriter()
        asyncio.create_task(self._process_chat(request, stream))
        return stream

    async def _process_chat(self, request: ChatRequest, stream: ChatStreamWriter):
        # Background task for chat orchestration.
        try:
            # 1. Retrieve Episodic Memory (Last 7 Days)
            await stream.write_status(
                "retrieving_episodic", "Fetching memories from the last 7 days..."
            )
            seven_days_ago = (datetime.now() - timedelta(days=7)).isoformat()
            recent_memories = await episodic_memory_service.get_recent_memories(
                request.userId, seven_days_ago
            )

            relevant_memories = []
            if recent_memories:
                # 2. Analyze Relevance
                await stream.write_status(
                    "analyzing_relevance",
                    f"Analyzing {len(recent_memories)} memories...",
                )
                # Extract summaries for analysis
                memory_summaries = []
                for m in recent_memories:
                    content = (
                        m.snapshot.get("summary", "N/A")
                        if isinstance(m.snapshot, dict)
                        else str(m.snapshot)
                    )
                    memory_summaries.append(f"ID: {m.id}, Content: {content}")

                analysis_prompt = (
                    f"User Prompt: '{request.prompt}'\n\n"
                    f"Recent Memories:\n" + "\n".join(memory_summaries) + "\n\n"
                    "Determine which Memory IDs are directly relevant to the user prompt. "
                    "Return a comma-separated list of IDs only, or 'None'."
                )

                analysis_response = await self.llm.ainvoke(analysis_prompt)
                relevant_ids_text = analysis_response.content.strip()

                if relevant_ids_text.lower() != "none":
                    relevant_ids = [id.strip() for id in relevant_ids_text.split(",")]
                    relevant_memories = [
                        m for m in recent_memories if m.id in relevant_ids
                    ]

            context_docs = []
            if relevant_memories:
                await stream.write_status(
                    "enhancing_context",
                    f"Found {len(relevant_memories)} relevant episodic memories.",
                )
                # 3. Update Metrics (Importance/Confidence)
                await self._update_memory_metrics(relevant_memories)
                for m in relevant_memories:
                    content = (
                        m.snapshot.get("summary", "")
                        if isinstance(m.snapshot, dict)
                        else str(m.snapshot)
                    )
                    context_docs.append(content)
            else:
                # 5. Semantic Fallback
                await stream.write_status(
                    "semantic_fallback",
                    "No recent episodic relevance. Searching long-term memory...",
                )
                semantic_results = await self.semantic_service.search_semantic_memory(
                    SemanticSearchRequest(
                        userId=request.userId, prompt=request.prompt, threshold=0.7
                    )
                )
                if isinstance(semantic_results, list) and semantic_results:
                    for res in semantic_results:
                        context_docs.append(res["content"])
                else:
                    await stream.write_status(
                        "no_context", "No relevant context found in memory layers."
                    )

            # 4. Chat Orchestration
            await stream.write_status("generating_response", "Synthesizing response...")

            context_str = "\n".join([f"- {doc}" for doc in context_docs])
            final_prompt = (
                "You are an AI assistant for the Memovo app. Use the provided context to inform your answer. "
                "If the context is irrelevant, answer based on your general knowledge but focus on the user's needs.\n\n"
                f"Context:\n{context_str}\n\n"
                f"User Prompt: {request.prompt}\n\n"
                "Response:"
            )

            # 6. Streaming Delivery
            async for chunk in self.llm.astream(final_prompt):
                await stream.write_chunk(chunk.content)

            await stream.write_status("completed", "Response finished.")

        except Exception as e:
            await stream.write_status("failed", f"Error: {str(e)}")
        finally:
            await stream.close()

    async def _update_memory_metrics(self, memories: List[Any]):
        # Update importance_score for used memories
        for m in memories:
            try:
                if isinstance(m.snapshot, dict):
                    current_score = m.snapshot.get("importance_score", 0)
                    # Increment importance if used in chat context
                    new_snapshot = {
                        **m.snapshot,
                        "importance_score": min(10, current_score + 1),
                    }
                    await episodic_memory_service.update_memory(
                        m.id, {"snapshot": new_snapshot}
                    )
            except Exception:
                pass  # Silent fail for metric updates to avoid blocking chat


chat_service = ChatService()
