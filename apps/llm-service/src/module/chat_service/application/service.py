import json
import asyncio
import uuid
from datetime import datetime, timedelta
from typing import List, Any, Dict, Optional
from langchain_google_genai import ChatGoogleGenerativeAI
from src.shared.config import settings
from src.module.episodic_memory_layer.application.service import episodic_memory_service
from src.module.semantic_memory_layer.application.service import SemanticMemoryService
from src.module.semantic_memory_layer.application.models import SemanticSearchRequest
from src.module.working_memory_layer.application.service import working_memory_service
from src.module.working_memory_layer.application.models import WorkingMemoryCreate
from .models import ChatRequest
from .prompts import SYSTEM_PROMPT
from src.module.episodic_memory_layer.application.models import EpisodicMemoryCreate


class ChatStreamWriter:
    # A stream writer for the chat service that handles status updates, response chunks, and data updates.

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

    async def write_data(self, key: str, value: Any):
        # Push structured data (like updated working memory) to the stream.
        data = json.dumps({"type": "data", "key": key, "value": value}) + "\n"
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
    # Orchestrates context-aware chat by integrating episodic, semantic, and working memory.

    def __init__(self):
        self.llm = ChatGoogleGenerativeAI(
            # Using flash lite for speed and cost efficiency
            model="gemini-2.5-flash-lite",
            google_api_key=settings.GOOGLE_API_KEY,
            temperature=0.7,
        )
        self.semantic_service = SemanticMemoryService()

    def chat_stream(self, request: ChatRequest) -> ChatStreamWriter:
        # Returns the stream object immediately and processes in background.
        stream = ChatStreamWriter()
        asyncio.create_task(self._process_chat(request, stream))
        return stream

    async def _process_chat(self, request: ChatRequest, stream: ChatStreamWriter):
        # Background task for chat orchestration.
        try:
            # 1. Retrieve Working Memory (Chat History)
            await stream.write_status(
                "retrieving_working", "Retrieving chat history..."
            )
            user_working_mem = await working_memory_service.get_user_memory(
                request.userId
            )

            # Send initial working memory to client
            serializable_initial = [m.model_dump() for m in user_working_mem]
            await stream.write_data("working_memory", serializable_initial)

            # Sort working memory by timestamp to ensure correct order
            sorted_mem = (
                sorted(user_working_mem, key=lambda x: x.chat.get("timestamp", ""))
                if user_working_mem
                else []
            )

            history_context = ""
            if sorted_mem:
                history_context = "Recent Chat History:\n"
                for mem in sorted_mem:
                    chat_data = mem.chat
                    role = chat_data.get("role", "unknown")
                    content = chat_data.get("content", "")
                    history_context += f"{role.capitalize()}: {content}\n"

            # 2. Retrieve Episodic Memory (Last 7 Days)
            await stream.write_status(
                "retrieving_episodic", "Fetching memories from the last 7 days..."
            )
            seven_days_ago = (datetime.now() - timedelta(days=7)).isoformat()
            recent_memories = await episodic_memory_service.get_recent_memories(
                request.userId, seven_days_ago
            )

            relevant_memories = []
            if recent_memories:
                # 3. Analyze Relevance
                await stream.write_status(
                    "analyzing_relevance",
                    f"Analyzing {len(recent_memories)} memories...",
                )
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
                await self._update_memory_metrics(relevant_memories)
                for m in relevant_memories:
                    content = (
                        m.snapshot.get("summary", "")
                        if isinstance(m.snapshot, dict)
                        else str(m.snapshot)
                    )
                    context_docs.append(content)
            else:
                # 4. Semantic Fallback
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

                    # Create a new episodic snapshot based on the semantic results and prompt
                    await stream.write_status(
                        "creating_snapshot",
                        "Creating new episodic snapshot for this topic...",
                    )
                    new_snapshot = await self._generate_and_save_snapshot(
                        request.userId, request.prompt, semantic_results
                    )
                    if new_snapshot:
                        # Add the new snapshot to context as well
                        context_docs.append(new_snapshot.get("summary", ""))
                else:
                    await stream.write_status(
                        "no_context", "No relevant context found in memory layers."
                    )

            # 5. Save User Message to Working Memory
            user_msg_id = str(uuid.uuid4())
            await working_memory_service.create_memory(
                WorkingMemoryCreate(
                    id=user_msg_id,
                    userid=request.userId,
                    chat={
                        "role": "user",
                        "content": request.prompt,
                        "timestamp": datetime.now().isoformat(),
                    },
                )
            )

            # 6. Chat Orchestration
            await stream.write_status("generating_response", "Synthesizing response...")

            context_str = "\n".join([f"- {doc}" for doc in context_docs])

            final_prompt = (
                f"{SYSTEM_PROMPT}\n\n"
                f"CONTEXT FROM MEMORIES:\n{context_str}\n\n"
                f"CHAT HISTORY:\n{history_context}\n\n"
                f"USER PROMPT: {request.prompt}\n\n"
                "RESPONSE:"
            )

            # 7. Streaming Delivery and accumulation
            full_response = ""
            async for chunk in self.llm.astream(final_prompt):
                content = chunk.content
                full_response += content
                await stream.write_chunk(content)

            # 8. Save Agent Message to Working Memory
            agent_msg_id = str(uuid.uuid4())
            await working_memory_service.create_memory(
                WorkingMemoryCreate(
                    id=agent_msg_id,
                    userid=request.userId,
                    chat={
                        "role": "agent",
                        "content": full_response,
                        "timestamp": datetime.now().isoformat(),
                    },
                )
            )

            # 9. Return latest working memory
            updated_working_mem = await working_memory_service.get_user_memory(
                request.userId
            )
            # Serialize for transport
            serializable_mem = [m.model_dump() for m in updated_working_mem]
            await stream.write_data("working_memory", serializable_mem)

            await stream.write_status("completed", "Response finished.")

        except Exception as e:
            await stream.write_status("failed", f"Error: {str(e)}")
        finally:
            await stream.close()

    async def _update_memory_metrics(self, memories: List[Any]):
        for m in memories:
            try:
                if isinstance(m.snapshot, dict):
                    current_score = m.snapshot.get("importance_score", 0)
                    new_snapshot = {
                        **m.snapshot,
                        "importance_score": min(10, current_score + 1),
                    }
                    await episodic_memory_service.update_memory(
                        m.id, {"snapshot": new_snapshot}
                    )
            except Exception:
                pass

    async def _generate_and_save_snapshot(
        self, user_id: str, prompt: str, semantic_results: List[Dict[str, Any]]
    ) -> Optional[Dict[str, Any]]:
        # Generates a new episodic snapshot from semantic context and user prompt.
        try:
            semantic_context = "\n".join([r["content"] for r in semantic_results])

            gen_prompt = (
                "Based on the user's prompt and the related long-term memories provided, "
                "create a structured episodic memory snapshot.\n\n"
                f"User Prompt: {prompt}\n"
                f"Related Context: {semantic_context}\n\n"
                "Return a JSON object with: summary, entities (list), emotion_label, importance_score (1-10), and timestamp (ISO format)."
            )

            response = await self.llm.ainvoke(gen_prompt)
            # Find JSON block in response
            content = response.content
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            elif "```" in content:
                content = content.split("```")[1].split("```")[0].strip()

            snapshot = json.loads(content)

            # Save to episodic memory layer
            memory_id = f"epi_{uuid.uuid4().hex[:8]}"
            await episodic_memory_service.create_memory(
                EpisodicMemoryCreate(id=memory_id, userid=user_id, snapshot=snapshot)
            )
            return snapshot
        except Exception:
            return None


chat_service = ChatService()
