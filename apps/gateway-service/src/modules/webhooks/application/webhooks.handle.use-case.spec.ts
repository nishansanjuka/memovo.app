
import { Test, TestingModule } from '@nestjs/testing';
import { ClerkWebhookUseCase } from './webhooks.handle.use-case';
import { ClerkWebhookService } from '../infrastructure/webhook.service';
import { WebhookEvent } from '@clerk/express';
import { logDebug } from '@memovo.app/utils';

// Mock dependencies
jest.mock('@memovo.app/utils', () => ({
    logDebug: jest.fn(),
    forwardReq: jest.fn(),
}));

// Mock env to prevent top-level config errors
jest.mock('../../../shared/env', () => ({
    baseConfig: () => ({
        apiKey: 'test-api-key',
        url: 'http://localhost:3000',
    }),
}));

describe('ClerkWebhookUseCase', () => {
    let useCase: ClerkWebhookUseCase;
    let webhookService: ClerkWebhookService;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                ClerkWebhookUseCase,
                {
                    provide: ClerkWebhookService,
                    useValue: {
                        handleUserCreated: jest.fn().mockResolvedValue({ success: true }),
                        handleUserUpdated: jest.fn().mockResolvedValue({ success: true }),
                        handleUserDeleted: jest.fn().mockResolvedValue({ success: true }),
                    },
                },
            ],
        }).compile();

        useCase = module.get<ClerkWebhookUseCase>(ClerkWebhookUseCase);
        webhookService = module.get<ClerkWebhookService>(ClerkWebhookService);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should be defined', () => {
        expect(useCase).toBeDefined();
    });

    it('should call handleUserCreated when event type is user.created', async () => {
        const event = { type: 'user.created', data: {} } as WebhookEvent;

        await useCase.handleWebhook(event);

        expect(webhookService.handleUserCreated).toHaveBeenCalledWith(event);
    });

    it('should call handleUserUpdated when event type is user.updated', async () => {
        const event = { type: 'user.updated', data: {} } as WebhookEvent;

        await useCase.handleWebhook(event);

        expect(webhookService.handleUserUpdated).toHaveBeenCalledWith(event);
    });

    it('should call handleUserDeleted when event type is user.deleted', async () => {
        const event = { type: 'user.deleted', data: {} } as WebhookEvent;

        await useCase.handleWebhook(event);

        expect(webhookService.handleUserDeleted).toHaveBeenCalledWith(event);
    });

    it('should log unhandled event types', async () => {
        const event = { type: 'session.created', data: {} } as unknown as WebhookEvent;

        await useCase.handleWebhook(event);

        expect(logDebug).toHaveBeenCalledWith('Received webhook event:', 'session.created');
        expect(logDebug).toHaveBeenCalledWith('Unhandled webhook event type:', 'session.created');
        expect(webhookService.handleUserCreated).not.toHaveBeenCalled();
        expect(webhookService.handleUserUpdated).not.toHaveBeenCalled();
        expect(webhookService.handleUserDeleted).not.toHaveBeenCalled();
    });
});
