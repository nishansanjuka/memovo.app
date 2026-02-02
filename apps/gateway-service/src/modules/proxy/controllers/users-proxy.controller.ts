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
  ApiBody,
} from '@nestjs/swagger';
import { ProxyService } from '../../../shared/services/proxy.service';

/**
 * Users Proxy Controller
 * Forwards user requests to the Spring Boot API service
 */
@ApiTags('API Service - Users')
@ApiBearerAuth('Authorization')
@Controller('api/v1/users')
export class UsersProxyController {
  constructor(private readonly proxyService: ProxyService) {}

  @Post()
  @ApiOperation({
    summary: 'Create user',
    description: 'Create a new user in the system',
  })
  @ApiBody({
    description: 'User creation payload',
    schema: {
      type: 'object',
      required: ['clerkId', 'email'],
      properties: {
        clerkId: { type: 'string', description: 'Clerk user identifier' },
        email: { type: 'string', format: 'email', description: 'User email' },
        firstName: { type: 'string', description: 'User first name' },
        lastName: { type: 'string', description: 'User last name' },
        imageUrl: { type: 'string', description: 'Profile image URL' },
      },
    },
  })
  @ApiResponse({ status: 201, description: 'User created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @HttpCode(HttpStatus.CREATED)
  async createUser(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'api',
      timeout: 30000,
    });
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get user by ID',
    description: 'Retrieve a user by their ID',
  })
  @ApiParam({ name: 'id', description: 'User identifier' })
  @ApiResponse({ status: 200, description: 'User details' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUser(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'api',
      timeout: 30000,
    });
  }

  @Put(':id')
  @ApiOperation({
    summary: 'Update user',
    description: 'Update an existing user',
  })
  @ApiParam({ name: 'id', description: 'User identifier' })
  @ApiBody({
    description: 'User update payload',
    schema: {
      type: 'object',
      properties: {
        email: { type: 'string', format: 'email', description: 'User email' },
        firstName: { type: 'string', description: 'User first name' },
        lastName: { type: 'string', description: 'User last name' },
        imageUrl: { type: 'string', description: 'Profile image URL' },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'User updated successfully' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateUser(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'api',
      timeout: 30000,
    });
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Delete user',
    description: 'Delete a user by their ID',
  })
  @ApiParam({ name: 'id', description: 'User identifier' })
  @ApiResponse({ status: 204, description: 'User deleted successfully' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteUser(@Req() req: Request, @Res() res: Response): Promise<void> {
    await this.proxyService.proxyRequest(req, res, {
      service: 'api',
      timeout: 30000,
    });
  }
}
