import { Test, TestingModule } from '@nestjs/testing';
import { ClerkWebhookController } from './webhooks.controller';
import { ClerkWebhookUseCase } from '../application/webhooks.handle.use-case';
import { WebhookEvent } from '@clerk/express';

// Mock env to prevent top-level config errors
jest.mock('../../../shared/env', () => ({
  baseConfig: () => ({
    apiKey: 'test-api-key',
    url: 'http://localhost:3000',
  }),
}));

// Mock utils
jest.mock('@memovo.app/utils', () => ({
  logDebug: jest.fn(),
}));

describe('ClerkWebhookController', () => {
  let controller: ClerkWebhookController;
  let useCase: ClerkWebhookUseCase;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ClerkWebhookController],
      providers: [
        {
          provide: ClerkWebhookUseCase,
          useValue: {
            handleWebhook: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<ClerkWebhookController>(ClerkWebhookController);
    useCase = module.get<ClerkWebhookUseCase>(ClerkWebhookUseCase);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should delegate handling to UseCase', async () => {
    const event = { type: 'user.created' } as WebhookEvent;

    await controller.handleWebhook(event);

    expect(useCase.handleWebhook).toHaveBeenCalledWith(event);
  });
});
