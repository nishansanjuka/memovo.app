import json
import asyncio
from langchain_google_genai import ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_pinecone import PineconeVectorStore
from src.shared.config import settings
from .models import CreateSemanticMemoryRequest, SemanticSearchRequest


class StreamWriter:
    # A stream writer that allows pushing status updates to a queue for real-time streaming.

    def __init__(self):
        self._queue: asyncio.Queue = asyncio.Queue()

    async def write(self, status: str, message: str):
        # Write a status update to the stream as JSON bytes.
        data = json.dumps({"status": status, "message": message}) + "\n"
        await self._queue.put(data.encode("utf-8"))

    async def close(self):
        # Signal that the stream is complete.
        await self._queue.put(None)

    async def __aiter__(self):
        # Async iterator to yield chunks from the queue for StreamingResponse.
        while True:
            chunk = await self._queue.get()
            if chunk is None:
                break
            yield chunk


class SemanticMemoryService:
    # Service for processing content and storing it in semantic memory.

    def __init__(self):
        # Initialize the LLM for summarization (using cheapest gemini model)
        self.llm = ChatGoogleGenerativeAI(
            model="gemini-2.5-flash-lite",
            google_api_key=settings.GOOGLE_API_KEY,
            temperature=0,
        )

        # Initialize the embedding model (using cheapest gemini embedding model)
        self.embeddings = GoogleGenerativeAIEmbeddings(
            model="models/gemini-embedding-001",
            google_api_key=settings.GOOGLE_API_KEY,
        )

        # Initialize the text splitter
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=500,
            chunk_overlap=50,
        )

    def create_semantic_memory_stream(
        self, request: CreateSemanticMemoryRequest
    ) -> StreamWriter:
        # Create stream and start background task to process content.
        stream = StreamWriter()
        asyncio.create_task(self._process_semantic_memory(request, stream))
        return stream

    async def _process_semantic_memory(
        self, request: CreateSemanticMemoryRequest, stream: StreamWriter
    ):
        # Background task to process content and push updates to the stream.
        try:
            # 1. Summarizing
            await stream.write(
                "summarizing", "Summarizing content using Gemini 2.5 Flash Lite..."
            )
            summary_response = await self.llm.ainvoke(
                f"Summarize the following content into a semantic-friendly summary:\n\n{request.content}"
            )
            summary = summary_response.content

            # 2. Chunking
            await stream.write("chunking", "Chunking the summary for vector storage...")
            chunks = self.text_splitter.split_text(summary)

            # 3. Embedding and Storing
            await stream.write(
                "storing",
                f"Embedding and storing {len(chunks)} chunks into Pinecone...",
            )

            # Prepare metadata with userId
            metadata = request.metadata.copy()
            metadata["userId"] = request.userId
            metadatas = [metadata for _ in chunks]

            # Store in Pinecone (using thread for non-async split/embed call if needed)
            await asyncio.to_thread(
                PineconeVectorStore.from_texts,
                texts=chunks,
                embedding=self.embeddings,
                index_name=settings.PINECONE_INDEX_NAME,
                pinecone_api_key=settings.PINECONE_API_KEY,
                metadatas=metadatas,
                namespace=f"user_{request.userId}",
            )

            await stream.write("completed", "Semantic memory stored successfully.")

        except Exception as e:
            await stream.write("failed", f"Error occurred: {str(e)}")

        finally:
            await stream.close()

    async def search_semantic_memory(self, request: SemanticSearchRequest) -> str:
        # Search semantic memory for relevant context.
        try:
            vectorstore = PineconeVectorStore(
                index_name=settings.PINECONE_INDEX_NAME,
                embedding=self.embeddings,
                pinecone_api_key=settings.PINECONE_API_KEY,
                namespace=f"user_{request.userId}",
            )

            # Perform similarity search with score and filter
            docs_with_scores = await asyncio.to_thread(
                vectorstore.similarity_search_with_score,
                query=request.prompt,
                k=5,
                filter={"userId": request.userId},
            )

            # Return list of dicts with content and relevance score, filtered by threshold
            return [
                {"content": doc.page_content, "score": score}
                for doc, score in docs_with_scores
                if score >= request.threshold
            ]

        except Exception as e:
            return f"Error during search: {str(e)}"
