from motor.motor_asyncio import AsyncIOMotorClient
from ..config import settings
import logging

logger = logging.getLogger(__name__)


class MongoDBAdapter:
    # Adapter for MongoDB using motor (asyncio driver).
    def __init__(self):
        self.client: AsyncIOMotorClient = None
        self.db = None

    async def connect(self):
        # Initialize the MongoDB connection.
        if self.client is None:
            try:
                self.client = AsyncIOMotorClient(settings.MONGODB_URI)
                self.db = self.client[settings.MONGODB_DB_NAME]
                # Ping the database to verify connection
                await self.client.admin.command("ping")
                logger.info("Successfully connected to MongoDB.")
            except Exception as e:
                logger.error(f"Failed to connect to MongoDB: {e}")
                raise

    async def close(self):
        # Close the MongoDB connection.
        if self.client is not None:
            self.client.close()
            self.client = None
            self.db = None
            logger.info("MongoDB connection closed.")

    def get_db(self):
        # Return the database instance.
        if self.db is None:
            raise RuntimeError("MongoDB not connected. Call connect() first.")
        return self.db


mongodb_adapter = MongoDBAdapter()
