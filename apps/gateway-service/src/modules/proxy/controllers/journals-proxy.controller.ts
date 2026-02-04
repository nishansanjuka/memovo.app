import {
  Controller,
  Post,
  Get,
  Put,
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
 * Journals Proxy Controller
 * Forwards journal requests to the Spring Boot API service
 */
@ApiTags('API Service - Journals')
@ApiBearerAuth('Authorization')
@Controller('api/v1/journals')
export class JournalsProxyController {
  constructor(private readonly proxyService: ProxyService) { }

  @Post()
  @ApiOperation({
    summary: 'Create journal entry',
    description: 'Create a new journal entry for a user',
  })
  @ApiBody({
    description: 'Journal creation payload',
    schema: {
      type: 'object',
      required: ['content'],
      properties: {
        content: { type: 'string', description: 'Journal content' },
        title: { type: 'string', description: 'Journal title' },
        mood: { type: 'string', description: 'User mood' },
        tags: {
          type: 'array',
          items: { type: 'string' },
          description: 'Tags for categorization',
        },
      },
    },
  })
  @ApiResponse({ status: 201, description: 'Journal created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @HttpCode(HttpStatus.CREATED)
  async createJournal(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'api',
      timeout: 30000,
    });
  }

  @Get()
  @ApiOperation({
    summary: 'Get journals by user',
    description: 'Retrieve all journal entries for a specific user',
  })
  @ApiQuery({
    name: 'userId',
    description: 'Your User ID (auto-injected)',
    required: false,
    example: 'me',
  })
  @ApiResponse({ status: 200, description: 'List of journal entries' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getJournals(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'api',
      timeout: 30000,
    });
  }

  @Get(':journalId')
  @ApiOperation({
    summary: 'Get journal by ID',
    description: 'Retrieve a specific journal entry by ID with user validation',
  })
  @ApiParam({ name: 'journalId', description: 'Journal identifier' })
  @ApiQuery({
    name: 'userId',
    description: 'Your User ID (auto-injected)',
    required: false,
    example: 'me',
  })
  @ApiResponse({ status: 200, description: 'Journal entry details' })
  @ApiResponse({ status: 404, description: 'Journal not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getJournal(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'api',
      timeout: 30000,
    });
  }

  @Put(':journalId')
  @ApiOperation({
    summary: 'Update journal entry',
    description: 'Update an existing journal entry',
  })
  @ApiParam({ name: 'journalId', description: 'Journal identifier' })
  @ApiBody({
    description: 'Journal update payload',
    schema: {
      type: 'object',
      properties: {
        content: { type: 'string', description: 'Journal content' },
        title: { type: 'string', description: 'Journal title' },
        mood: { type: 'string', description: 'User mood' },
        tags: {
          type: 'array',
          items: { type: 'string' },
          description: 'Tags for categorization',
        },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Journal updated successfully' })
  @ApiResponse({ status: 404, description: 'Journal not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateJournal(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'api',
      timeout: 30000,
    });
  }

  @Delete(':journalId')
  @ApiOperation({
    summary: 'Delete journal entry',
    description: 'Delete a journal entry by its ID',
  })
  @ApiParam({ name: 'journalId', description: 'Journal identifier' })
  @ApiResponse({ status: 204, description: 'Journal deleted successfully' })
  @ApiResponse({ status: 404, description: 'Journal not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteJournal(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'api',
      timeout: 30000,
    });
  }
}
