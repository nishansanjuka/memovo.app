
import { Test, TestingModule } from '@nestjs/testing';
import { ClerkWebhookService } from './webhook.service';
import { forwardReq } from '@memovo.app/utils';
import { WEBHOOKS_ROUTES } from '../webhooks.config';
import { BadRequestException } from '@nestjs/common';
import { UserWebhookEvent } from '@clerk/express';

// Mock utils
jest.mock('@memovo.app/utils', () => ({
    forwardReq: jest.fn(),
    logDebug: jest.fn(),
}));

// Mock env
jest.mock('../../../shared/env', () => ({
    baseConfig: () => ({
        apiKey: 'test-api-key',
        url: 'http://localhost:3000',
    }),
}));

describe('ClerkWebhookService', () => {
    let service: ClerkWebhookService;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [ClerkWebhookService],
        }).compile();

        service = module.get<ClerkWebhookService>(ClerkWebhookService);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('handleUserCreated', () => {
        const mockUserCreatedEvent = {
            type: 'user.created',
            data: {
                id: 'user_123',
                first_name: 'John',
                last_name: 'Doe',
                email_addresses: [{ email_address: 'john@example.com' }],
            },
        } as UserWebhookEvent;

        it('should forward user created event successfully', async () => {
            (forwardReq as jest.Mock).mockResolvedValue({
                ok: true,
            });

            const result = await service.handleUserCreated(mockUserCreatedEvent);

            expect(result).toEqual({ success: true });
            expect(forwardReq).toHaveBeenCalledWith(
                WEBHOOKS_ROUTES.UserCreated,
                'POST',
                'test-api-key',
                {
                    id: 'user_123',
                    firstName: 'John',
                    lastName: 'Doe',
                    email: 'john@example.com',
                },
            );
        });

        it('should construct email from id if email addresses are empty', async () => {
            const eventNoEmail = {
                ...mockUserCreatedEvent,
                data: {
                    ...mockUserCreatedEvent.data,
                    email_addresses: []
                }
            } as unknown as UserWebhookEvent;

            (forwardReq as jest.Mock).mockResolvedValue({
                ok: true,
            });

            await service.handleUserCreated(eventNoEmail);

            expect(forwardReq).toHaveBeenCalledWith(
                expect.anything(),
                expect.anything(),
                expect.anything(),
                expect.objectContaining({
                    email: 'user_123@memovo.app',
                }),
            );
        });

        it('should throw BadRequestException if forwarding fails', async () => {
            (forwardReq as jest.Mock).mockResolvedValue({
                ok: false,
                json: async () => ({ message: 'Error', errors: ['Validation failed'] }),
            });

            await expect(service.handleUserCreated(mockUserCreatedEvent))
                .rejects.toThrow(BadRequestException);
        });
    });

    describe('handleUserUpdated', () => {
        const mockUserUpdatedEvent = {
            type: 'user.updated',
            data: {
                id: 'user_123',
                first_name: 'John',
                last_name: 'Doe',
                email_addresses: [{ email_address: 'john@example.com' }],
            },
        } as UserWebhookEvent;

        it('should forward user updated event successfully', async () => {
            (forwardReq as jest.Mock).mockResolvedValue({
                ok: true,
            });

            const result = await service.handleUserUpdated(mockUserUpdatedEvent);

            expect(result).toEqual({ success: true });
            expect(forwardReq).toHaveBeenCalledWith(
                WEBHOOKS_ROUTES.UserUpdated.replace('{id}', 'user_123'),
                'PUT',
                'test-api-key',
                expect.objectContaining({
                    id: 'user_123',
                    firstName: 'John',
                    lastName: 'Doe',
                })
            );
        });

        it('should throw BadRequestException if forwarding fails', async () => {
            (forwardReq as jest.Mock).mockResolvedValue({
                ok: false,
                json: async () => ({ message: 'Error', errors: ['Update failed'] }),
            });

            await expect(service.handleUserUpdated(mockUserUpdatedEvent))
                .rejects.toThrow(BadRequestException);
        });
    });

    describe('handleUserDeleted', () => {
        const mockUserDeletedEvent = {
            type: 'user.deleted',
            data: {
                id: 'user_123',
                deleted: true
            },
        } as UserWebhookEvent;

        it('should forward user deleted event successfully', async () => {
            (forwardReq as jest.Mock).mockResolvedValue({
                ok: true,
            });

            const result = await service.handleUserDeleted(mockUserDeletedEvent);

            expect(result).toEqual({ success: true });
            expect(forwardReq).toHaveBeenCalledWith(
                WEBHOOKS_ROUTES.UserDeleted.replace('{id}', 'user_123'),
                'DELETE',
                'test-api-key',
            );
        });

        it('should throw BadRequestException if user ID is missing', async () => {
            const invalidEvent = {
                type: 'user.deleted',
                data: { deleted: true } // Missing ID
            } as UserWebhookEvent;

            await expect(service.handleUserDeleted(invalidEvent))
                .rejects.toThrow(BadRequestException);
        });

        it('should throw BadRequestException if forwarding fails', async () => {
            (forwardReq as jest.Mock).mockResolvedValue({
                ok: false,
                json: async () => ({ message: 'Error', errors: ['Delete failed'] }),
            });

            await expect(service.handleUserDeleted(mockUserDeletedEvent))
                .rejects.toThrow(BadRequestException);
        });
    });
});
