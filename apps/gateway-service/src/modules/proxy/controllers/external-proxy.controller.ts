import {
    Controller,
    Get,
    Req,
    Res,
    HttpStatus,
    Query,
    Param,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import {
    ApiTags,
    ApiBearerAuth,
    ApiOperation,
    ApiResponse,
    ApiParam,
} from '@nestjs/swagger';
import { ProxyService } from '../../../shared/services/proxy.service';

/**
 * External Auth & Content Proxy Controller
 * Forwards requests to the Spring Boot API service for OAuth and External Content
 */
@ApiTags('External Integrations')
@Controller('api/v1')
export class ExternalProxyController {
    constructor(private readonly proxyService: ProxyService) { }

    @Get('external-auth/authorize/:platform')
    @ApiBearerAuth('Authorization')
    @ApiOperation({
        summary: 'Initiate external platform OAuth flow',
        description: 'Redirects to Spotify or YouTube consent screen',
    })
    @ApiParam({ name: 'platform', enum: ['spotify', 'youtube'] })
    async authorize(
        @Req() req: Request,
        @Res() res: Response,
    ): Promise<void> {
        await this.proxyService.proxyRequest(req, res, {
            service: 'api',
            timeout: 30000,
            injectUserId: true,
        });
    }

    @Get('external-auth/callback/:platform')
    @ApiOperation({
        summary: 'OAuth callback handler',
        description: 'Handles the redirect back from Spotify/YouTube',
    })
    async callback(
        @Req() req: Request,
        @Res() res: Response,
    ): Promise<void> {
        await this.proxyService.proxyRequest(req, res, {
            service: 'api',
            timeout: 30000,
            injectUserId: false, // Callback carries state with userId
        });
    }

    @Get('external-content/:platform')
    @ApiBearerAuth('Authorization')
    @ApiOperation({
        summary: 'Get recent content from external platform',
        description: 'Returns top 5 recently played or active items',
    })
    @ApiParam({ name: 'platform', enum: ['spotify', 'youtube'] })
    async getRecentContent(
        @Req() req: Request,
        @Res() res: Response,
    ): Promise<void> {
        await this.proxyService.proxyRequest(req, res, {
            service: 'api',
            timeout: 30000,
            injectUserId: true,
        });
    }
}
