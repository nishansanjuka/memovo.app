import pytest
from unittest.mock import MagicMock, patch
from src.shared.database.mongodb import MongoDBAdapter

@pytest.mark.asyncio
async def test_mongodb_adapter_lifecycle():
    """Test the lifecycle of the MongoDB adapter with mocking."""
    adapter = MongoDBAdapter()
    
    with patch("src.shared.database.mongodb.AsyncIOMotorClient") as mock_client:
        mock_instance = MagicMock()
        mock_client.return_value = mock_instance
        # Mock ping command as an awaitable
        async def mock_command(*args, **kwargs):
            return {"ok": 1.0}
        mock_instance.admin.command = mock_command
        
        await adapter.connect()
        assert adapter.client is not None
        assert adapter.db is not None
        
        db = adapter.get_db()
        assert db is not None
        
        await adapter.close()
        assert adapter.client is None
        assert adapter.db is None

def test_mongodb_adapter_get_db_before_connect():
    """Ensure get_db raises error if not connected."""
    adapter = MongoDBAdapter()
    with pytest.raises(RuntimeError, match="MongoDB not connected"):
        adapter.get_db()
