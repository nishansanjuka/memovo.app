import json
import asyncio
import uuid
from datetime import datetime, timedelta
from typing import Any, Dict, Optional
from langchain_google_genai import ChatGoogleGenerativeAI
from src.shared.config import settings
from src.module.episodic_memory_layer.application.service import episodic_memory_service
from src.module.semantic_memory_layer.application.service import SemanticMemoryService
from src.module.semantic_memory_layer.application.models import SemanticSearchRequest
from src.module.working_memory_layer.application.service import working_memory_service
from src.module.working_memory_layer.application.models import (
    WorkingMemoryCreate,
    WorkingMemoryResponse,
)
from src.module.chat_session.application.service import chat_session_service
from .models import ChatRequest
from .prompts import SYSTEM_PROMPT
from src.module.episodic_memory_layer.application.models import EpisodicMemoryCreate


class ChatStreamWriter:
    def __init__(self):
        self._queue: asyncio.Queue = asyncio.Queue()

    async def write_status(self, status: str, message: str):
        data = (
            json.dumps({"type": "status", "status": status, "message": message}) + "\n"
        )
        await self._queue.put(data.encode("utf-8"))

    async def write_chunk(self, content: str):
        data = json.dumps({"type": "chunk", "content": content}) + "\n"
        await self._queue.put(data.encode("utf-8"))

    async def write_data(self, key: str, value: Any):
        data = json.dumps({"type": "data", "key": key, "value": value}) + "\n"
        await self._queue.put(data.encode("utf-8"))

    async def close(self):
        await self._queue.put(None)

    async def __aiter__(self):
        while True:
            chunk = await self._queue.get()
            if chunk is None:
                break
            yield chunk


class ChatService:
    def __init__(self):
        # Using gemini-2.5-flash as the official model.
        self.llm = ChatGoogleGenerativeAI(
            model="gemini-2.5-flash",
            google_api_key=settings.GOOGLE_API_KEY,
            temperature=0.7,
        )
        self.semantic_service = SemanticMemoryService()

    def chat_stream(self, request: ChatRequest) -> ChatStreamWriter:
        stream = ChatStreamWriter()
        asyncio.create_task(self._process_chat(request, stream))
        return stream

    async def _process_chat(self, request: ChatRequest, stream: ChatStreamWriter):
        try:
            print(
                f"DEBUG: Processing chat for user {request.userId}, session {request.chatId}"
            )

            # 1. IMMEDIATE PERSISTENCE (GOD MODE)
            # Persist session and user message FIRST so history is always correct.
            if request.chatId:
                words = request.prompt.strip().split()
                instant_title = " ".join(words[:4])
                if len(instant_title) > 30:
                    instant_title = instant_title[:27] + "..."

                await chat_session_service.ensure_session(
                    user_id=request.userId,
                    session_id=request.chatId,
                    title=instant_title,
                    last_message=request.prompt[:100],
                )

                await working_memory_service.create_memory(
                    WorkingMemoryCreate(
                        id=str(uuid.uuid4()),
                        userId=request.userId,
                        chatId=request.chatId,
                        chat={
                            "role": "user",
                            "content": request.prompt,
                            "timestamp": datetime.now().isoformat(),
                        },
                    )
                )

            # 2. STATUS START & HISTORY SYNC
            await stream.write_status(
                "retrieving_working", "Retrieving chat history..."
            )

            # Pull existing history
            user_working_mem = await (
                working_memory_service.get_session_memory(
                    request.userId, request.chatId
                )
                if request.chatId
                else working_memory_service.get_user_memory(request.userId)
            )

            # ENSURE current message is in history (prevents race condition with MongoDB indexing)
            # Find if current message is already in retrieved set (unlikely due to timing)
            prompt_in_history = any(
                m.chat.get("content") == request.prompt and m.chat.get("role") == "user"
                for m in user_working_mem
            )

            if not prompt_in_history and request.chatId:
                # We know we just saved it, but if get_session_memory missed it, we manually add it for this stream
                # This ensures the LLM sees it and the client's 'data' event contains it
                current_msg_mem = WorkingMemoryResponse(
                    id="current_user_msg",
                    userId=request.userId,
                    chatId=request.chatId,
                    chat={
                        "role": "user",
                        "content": request.prompt,
                        "timestamp": datetime.now().isoformat(),
                    },
                )
                user_working_mem.append(current_msg_mem)

            # Send initial state to client once (Prevents flickering during stream)
            await stream.write_data(
                "working_memory", [m.model_dump() for m in user_working_mem]
            )

            # Prepare history context for LLM
            history_context = ""
            sorted_mem = sorted(
                user_working_mem, key=lambda x: x.chat.get("timestamp", "")
            )
            for mem in sorted_mem:
                role = mem.chat.get("role", "").capitalize()
                content = mem.chat.get("content", "")
                history_context += f"{role}: {content}\n"

            # Background: AI Title Upgrade (Non-blocking)
            if request.chatId:
                asyncio.create_task(self._upgrade_title(request.chatId, request.prompt))

            # 3. Context Retrieval (Episodic & Semantic)
            context_docs = []
            relevant_memories = []
            try:
                await stream.write_status(
                    "retrieving_episodic", "Fetching memories from the last 7 days..."
                )
                seven_days_ago = (datetime.now() - timedelta(days=7)).isoformat()
                recent_memories = await episodic_memory_service.get_recent_memories(
                    request.userId, seven_days_ago
                )

                if recent_memories:
                    await stream.write_status(
                        "analyzing_relevance",
                        f"Analyzing {len(recent_memories)} memories...",
                    )
                    try:
                        memory_summaries = [
                            f"ID: {m.id}, Content: {m.snapshot.get('summary', str(m.snapshot))[:100]}"
                            for m in recent_memories
                        ]
                        analysis_prompt = f"Relevant IDs for '{request.prompt[:100]}'? {','.join(memory_summaries)}. Return IDs or 'None'."
                        analysis_response = await self.llm.ainvoke(analysis_prompt)
                        relevant_ids_text = analysis_response.content.strip()
                        if relevant_ids_text.lower() != "none":
                            relevant_ids = [
                                id.strip() for id in relevant_ids_text.split(",")
                            ]
                            relevant_memories = [
                                m for m in recent_memories if m.id in relevant_ids
                            ]
                    except Exception:
                        pass

                if relevant_memories:
                    context_docs = [
                        m.snapshot.get("summary", "")
                        if isinstance(m.snapshot, dict)
                        else str(m.snapshot)
                        for m in relevant_memories
                    ]
                else:
                    await stream.write_status(
                        "semantic_fallback", "Searching long-term memory..."
                    )
                    semantic_results = (
                        await self.semantic_service.search_semantic_memory(
                            SemanticSearchRequest(
                                userId=request.userId,
                                prompt=request.prompt,
                                threshold=0.7,
                            )
                        )
                    )
                    context_docs = (
                        [res["content"] for res in semantic_results]
                        if semantic_results
                        else []
                    )
            except Exception:
                pass

            # 4. Response Synthesis
            await stream.write_status("generating_response", "Synthesizing response...")
            context_str = "\n".join([f"- {doc}" for doc in context_docs])
            final_prompt = f"{SYSTEM_PROMPT}\n\nCONTEXT:\n{context_str}\n\nHISTORY:\n{history_context}\n\nUSER PROMPT: {request.prompt}\n\nRESPONSE:"

            full_response = ""
            async for chunk in self.llm.astream(final_prompt):
                if chunk.content:
                    full_response += chunk.content
                    await stream.write_chunk(chunk.content)

            # 5. Save Agent Response
            if full_response and full_response.strip():
                print(f"DEBUG: Saving agent response for session {request.chatId}")
                agent_msg_id = str(uuid.uuid4())
                await working_memory_service.create_memory(
                    WorkingMemoryCreate(
                        id=agent_msg_id,
                        userId=request.userId,
                        chatId=request.chatId,
                        chat={
                            "role": "ai",
                            "content": full_response,
                            "timestamp": datetime.now().isoformat(),
                        },
                    )
                )
                if request.chatId:
                    # Update session meta (sidebar snippet)
                    from ..chat_session.application.models import ChatSessionUpdate

                    await chat_session_service.update_session(
                        request.chatId,
                        ChatSessionUpdate(
                            lastMessage=full_response[:100], updatedAt=datetime.now()
                        ),
                    )

            await stream.write_status("completed", "Response finished.")

            # 6. Background: Episodic Synthesis
            asyncio.create_task(
                self._ensure_episodic_memory(
                    request.userId, request.prompt, full_response, relevant_memories
                )
            )

        except Exception as e:
            print(f"DEBUG: Process chat error: {str(e)}")
            await stream.write_status("failed", f"Error: {str(e)}")
        finally:
            await stream.close()

    async def _upgrade_title(self, chat_id: str, prompt: str):
        try:
            title_res = await self.llm.ainvoke(
                f"Short title (3 words) for: '{prompt[:100]}'"
            )
            if title_res.content.strip():
                new_title = title_res.content.strip().replace('"', "")
                from ..chat_session.application.models import ChatSessionUpdate

                await chat_session_service.update_session(
                    chat_id, ChatSessionUpdate(title=new_title)
                )
        except Exception:
            pass

    async def _ensure_episodic_memory(
        self, user_id, prompt, response, existing_memories
    ):
        try:
            if not existing_memories:
                await self._generate_and_save_snapshot(user_id, prompt, response)
            else:
                await self._update_snapshot_with_new_data(
                    user_id, existing_memories[0], prompt, response
                )
        except Exception:
            pass

    async def _generate_and_save_snapshot(self, user_id, prompt, response):
        try:
            gen_prompt = (
                f"Episode: {prompt} -> {response}. JSON summary, importance, timestamp."
            )
            snapshot = await self._invoke_json_llm(gen_prompt)
            if snapshot:
                await episodic_memory_service.create_memory(
                    EpisodicMemoryCreate(
                        id=f"epi_{uuid.uuid4().hex[:8]}",
                        userId=user_id,
                        snapshot=snapshot,
                    )
                )
        except Exception:
            pass

    async def _update_snapshot_with_new_data(self, user_id, memory, prompt, response):
        try:
            gen_prompt = f"Merge interaction into memory. Old: {json.dumps(memory.snapshot)}. New: {prompt}/{response}."
            updated_snapshot = await self._invoke_json_llm(gen_prompt)
            if updated_snapshot:
                await episodic_memory_service.update_memory(
                    memory.id, {"snapshot": updated_snapshot}
                )
        except Exception:
            pass

    async def _invoke_json_llm(self, prompt: str) -> Optional[Dict[str, Any]]:
        try:
            response = await self.llm.ainvoke(prompt)
            content = response.content
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            return json.loads(content)
        except Exception:
            return None


chat_service = ChatService()
