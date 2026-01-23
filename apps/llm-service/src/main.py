from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.shared import settings, mongodb_adapter
from src.module.working_memory_layer.presentation.controller import (
    router as working_memory_router,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Connect to MongoDB
    await mongodb_adapter.connect()
    yield
    # Shutdown: Close MongoDB connection
    await mongodb_adapter.close()


app = FastAPI(
    title="Memovo LLM Service",
    description="Backend service for handling RAG, chat management, memory layers, and AI Therapy assistant orchestration in the Memovo app.",
    version="1.0.0",
    lifespan=lifespan,
    docs_url=None,
    redoc_url=None,
    openapi_url="/api-json",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(working_memory_router)


@app.get("/healthcheck")
async def healthcheck():
    # Verify DB connectivity
    try:
        db = mongodb_adapter.get_db()
        await db.command("ping")
        db_status = "connected"
    except Exception:
        db_status = "disconnected"

    return {"status": "ok", "database": db_status, "environment": settings.APP_ENV}
