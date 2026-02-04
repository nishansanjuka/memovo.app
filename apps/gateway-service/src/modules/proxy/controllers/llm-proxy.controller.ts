import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Req,
  Res,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
  ApiBody,
} from '@nestjs/swagger';
import { ProxyService } from '../../../shared/services/proxy.service';

/**
 * LLM Proxy Controller
 * Forwards all /llm/** requests to the FastAPI LLM service
 */
@ApiTags('LLM Service')
@ApiBearerAuth('Authorization')
@Controller('llm')
export class LlmProxyController {
  constructor(private readonly proxyService: ProxyService) { }

  // ============================================
  // Chat Service Endpoints
  // ============================================

  @Post('chat')
  @ApiOperation({
    summary: 'Chat with AI',
    description:
      'Context-aware chat endpoint with episodic and semantic memory integration. Streams status updates and response chunks back to the client.',
  })
  @ApiBody({
    description: 'Chat request with user ID, chat ID, and user message',
    schema: {
      type: 'object',
      required: ['prompt'],
      properties: {
        prompt: { type: 'string', description: "User's message content" },
        chatId: { type: 'string', description: 'Optional chat session identifier' },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Streaming response with chat messages',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 502, description: 'LLM service unavailable' })
  @HttpCode(HttpStatus.OK)
  async chat(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      stream: true,
      timeout: 120000,
    });
  }

  // ============================================
  // Working Memory Endpoints
  // ============================================

  @Post('working-memory')
  @ApiOperation({
    summary: 'Create working memory',
    description: 'Create a new working memory entry for a user',
  })
  @ApiBody({
    description: 'Working memory creation payload',
    schema: {
      type: 'object',
      required: ['id', 'chat'],
      properties: {
        id: { type: 'string', description: 'Unique identifier for the memory' },
        chatId: { type: 'string', description: 'Optional chat session ID' },
        chat: {
          type: 'object',
          description: 'Chat content',
          additionalProperties: true,
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Memory created successfully, returns memory ID',
  })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @HttpCode(HttpStatus.CREATED)
  async createWorkingMemory(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Get('working-memory/:memoryId')
  @ApiOperation({
    summary: 'Get working memory by ID',
    description: 'Retrieve a specific working memory entry by its ID',
  })
  @ApiParam({ name: 'memoryId', description: 'Memory identifier' })
  @ApiResponse({ status: 200, description: 'Working memory entry' })
  @ApiResponse({ status: 404, description: 'Memory not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getWorkingMemory(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Patch('working-memory/:memoryId')
  @ApiOperation({
    summary: 'Update working memory',
    description: 'Update an existing working memory entry',
  })
  @ApiParam({ name: 'memoryId', description: 'Memory identifier' })
  @ApiBody({
    description: 'Working memory update payload',
    schema: {
      type: 'object',
      properties: {
        chatId: { type: 'string', description: 'Updated chat session ID' },
        chat: {
          type: 'object',
          description: 'Updated chat content',
          additionalProperties: true,
        },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Memory updated successfully' })
  @ApiResponse({ status: 404, description: 'Memory not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateWorkingMemory(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Delete('working-memory/:memoryId')
  @ApiOperation({
    summary: 'Delete working memory',
    description: 'Delete a working memory entry by its ID',
  })
  @ApiParam({ name: 'memoryId', description: 'Memory identifier' })
  @ApiResponse({ status: 200, description: 'Memory deleted successfully' })
  @ApiResponse({ status: 404, description: 'Memory not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deleteWorkingMemory(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Get('working-memory')
  @ApiOperation({
    summary: 'List working memories by IDs',
    description: 'Retrieve multiple working memory entries by their IDs',
  })
  @ApiQuery({
    name: 'ids',
    description: 'List of memory IDs to retrieve',
    type: [String],
    required: true,
  })
  @ApiResponse({ status: 200, description: 'List of working memory entries' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async listWorkingMemories(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Get('working-memory/user/:userId')
  @ApiOperation({
    summary: 'Get all working memories for current user',
    description: 'Retrieve all working memory entries for the authenticated user. The :userId parameter is automatically replaced with your ID.',
  })
  @ApiParam({ name: 'userId', description: 'Your User ID (auto-injected)', example: 'me' })
  @ApiResponse({ status: 200, description: 'List of working memory entries' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getWorkingMemoryByUser(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Get('working-memory/user/:userId/session/:chatId')
  @ApiOperation({
    summary: 'Get session working memory',
    description:
      'Retrieve all working memory entries for a specific chat session of the authenticated user. The :userId parameter is automatically replaced.',
  })
  @ApiParam({ name: 'userId', description: 'Your User ID (auto-injected)', example: 'me' })
  @ApiParam({ name: 'chatId', description: 'Chat session identifier' })
  @ApiResponse({ status: 200, description: 'List of working memory entries' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getWorkingMemoryBySession(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Delete('working-memory/user/:userId/session/:chatId')
  @ApiOperation({
    summary: 'Delete session working memory',
    description:
      'Delete all working memory entries for a specific chat session of the authenticated user. The :userId parameter is automatically replaced.',
  })
  @ApiParam({ name: 'userId', description: 'Your User ID (auto-injected)', example: 'me' })
  @ApiParam({ name: 'chatId', description: 'Chat session identifier' })
  @ApiResponse({ status: 200, description: 'Session memory deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deleteWorkingMemoryBySession(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  // ============================================
  // Episodic Memory Endpoints
  // ============================================

  @Post('episodic-memory')
  @ApiOperation({
    summary: 'Create episodic memory',
    description: 'Create a new episodic memory entry for current user',
  })
  @ApiBody({
    description: 'Episodic memory creation payload',
    schema: {
      type: 'object',
      required: ['id', 'snapshot'],
      properties: {
        id: { type: 'string', description: 'Unique identifier for the memory' },
        snapshot: {
          type: 'object',
          description: 'Memory snapshot content',
          additionalProperties: true,
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Memory created successfully, returns memory ID',
  })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @HttpCode(HttpStatus.CREATED)
  async createEpisodicMemory(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Get('episodic-memory/:memoryId')
  @ApiOperation({
    summary: 'Get episodic memory by ID',
    description: 'Retrieve a specific episodic memory entry by its ID',
  })
  @ApiParam({ name: 'memoryId', description: 'Memory identifier' })
  @ApiResponse({ status: 200, description: 'Episodic memory entry' })
  @ApiResponse({ status: 404, description: 'Memory not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getEpisodicMemory(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Patch('episodic-memory/:memoryId')
  @ApiOperation({
    summary: 'Update episodic memory',
    description: 'Update an existing episodic memory entry',
  })
  @ApiParam({ name: 'memoryId', description: 'Memory identifier' })
  @ApiBody({
    description: 'Episodic memory update payload',
    schema: {
      type: 'object',
      properties: {
        snapshot: {
          type: 'object',
          description: 'Updated snapshot content',
          additionalProperties: true,
        },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Memory updated successfully' })
  @ApiResponse({ status: 404, description: 'Memory not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateEpisodicMemory(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Delete('episodic-memory/:memoryId')
  @ApiOperation({
    summary: 'Delete episodic memory',
    description: 'Delete an episodic memory entry by its ID',
  })
  @ApiParam({ name: 'memoryId', description: 'Memory identifier' })
  @ApiResponse({ status: 200, description: 'Memory deleted successfully' })
  @ApiResponse({ status: 404, description: 'Memory not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deleteEpisodicMemory(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Get('episodic-memory')
  @ApiOperation({
    summary: 'List episodic memories by IDs',
    description: 'Retrieve multiple episodic memory entries by their IDs',
  })
  @ApiQuery({
    name: 'ids',
    description: 'List of memory IDs to retrieve',
    type: [String],
    required: true,
  })
  @ApiResponse({ status: 200, description: 'List of episodic memory entries' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async listEpisodicMemories(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  // ============================================
  // Semantic Memory Endpoints
  // ============================================

  @Post('semantic-memory')
  @ApiOperation({
    summary: 'Create semantic memory',
    description:
      'Create a semantic memory from content for the authenticated user. Returns a real-time stream of status updates.',
  })
  @ApiBody({
    description: 'Semantic memory creation payload',
    schema: {
      type: 'object',
      required: ['content'],
      properties: {
        content: { type: 'string', description: 'Content to process' },
        metadata: {
          type: 'object',
          description: 'Optional metadata',
          additionalProperties: true,
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Streaming response with creation status updates',
  })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @HttpCode(HttpStatus.OK)
  async createSemanticMemory(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      stream: true,
      timeout: 120000,
    });
  }

  @Post('semantic-memory/search')
  @ApiOperation({
    summary: 'Search semantic memory',
    description: 'Search semantic memory for relevant context using embeddings (linked to current user)',
  })
  @ApiBody({
    description: 'Semantic search request',
    schema: {
      type: 'object',
      required: ['prompt'],
      properties: {
        prompt: { type: 'string', description: 'Search prompt' },
        threshold: {
          type: 'number',
          description: 'Relevance score threshold',
          default: 0.8,
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Search results with relevance scores',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @HttpCode(HttpStatus.OK)
  async searchSemanticMemory(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  // ============================================
  // Chat Session Endpoints
  // ============================================

  @Post('sessions')
  @ApiOperation({
    summary: 'Create chat session',
    description: 'Manually create a new chat session',
  })
  @ApiBody({
    description: 'Chat session creation payload',
    schema: {
      type: 'object',
      required: ['id', 'title'],
      properties: {
        id: { type: 'string', description: 'Unique session ID' },
        title: { type: 'string', description: 'Session title' },
      },
    },
  })
  @ApiResponse({ status: 201, description: 'Session created' })
  @HttpCode(HttpStatus.CREATED)
  async createSession(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Get('sessions/user/:userId')
  @ApiOperation({
    summary: 'List user sessions',
    description: 'Retrieve all chat sessions for the authenticated user',
  })
  @ApiParam({ name: 'userId', description: 'Your User ID (auto-injected)', example: 'me' })
  @ApiResponse({ status: 200, description: 'List of chat sessions' })
  async listUserSessions(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Get('sessions/:id')
  @ApiOperation({
    summary: 'Get session by ID',
    description: 'Retrieve a specific chat session by its ID',
  })
  @ApiParam({ name: 'id', description: 'Session identifier' })
  @ApiResponse({ status: 200, description: 'Chat session details' })
  async getSession(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Patch('sessions/:id')
  @ApiOperation({
    summary: 'Update session',
    description: 'Update metadata for an existing chat session',
  })
  @ApiParam({ name: 'id', description: 'Session identifier' })
  @ApiBody({
    description: 'Session update payload',
    schema: {
      type: 'object',
      properties: {
        title: { type: 'string' },
        lastMessage: { type: 'string' },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Session updated' })
  async updateSession(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  @Delete('sessions/:id')
  @ApiOperation({
    summary: 'Delete session',
    description: 'Delete a chat session and all associated messages',
  })
  @ApiParam({ name: 'id', description: 'Session identifier' })
  @ApiResponse({ status: 200, description: 'Session deleted' })
  async deleteSession(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  // ============================================
  // Wellbeing Endpoints
  // ============================================

  @Post('wellbeing/insights')
  @ApiOperation({
    summary: 'Get digital wellbeing insights',
    description: 'Analyze app usage and mood snapshots to provide wellness insights',
  })
  @ApiResponse({ status: 200, description: 'Wellbeing insights response' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @HttpCode(HttpStatus.OK)
  async getWellbeingInsights(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 30000,
    });
  }

  // ============================================
  // LLM Healthcheck
  // ============================================

  @Get('healthcheck')
  @ApiOperation({
    summary: 'LLM Service Health Check',
    description:
      'Check the health status of the LLM service and its database connection',
  })
  @ApiResponse({
    status: 200,
    description: 'Health check response',
    schema: {
      type: 'object',
      properties: {
        status: { type: 'string', example: 'ok' },
        database: { type: 'string', example: 'connected' },
        environment: { type: 'string', example: 'development' },
      },
    },
  })
  @ApiResponse({ status: 502, description: 'LLM service unavailable' })
  async healthcheck(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'llm',
      stripPrefix: '/llm',
      timeout: 10000,
    });
  }
}
