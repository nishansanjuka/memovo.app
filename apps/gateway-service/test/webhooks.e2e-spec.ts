import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { forwardReq } from '@memovo.app/utils';

// Mock dependencies
jest.mock('@memovo.app/utils', () => ({
    forwardReq: jest.fn(),
    logDebug: jest.fn(),
}));

jest.mock('../src/shared/env', () => ({
    baseConfig: () => ({ url: 'http://localhost:3000', apiKey: 'test_key' }),
    loadConfig: () => ({
        CLERK_WEBHOOK_SIGNING_SECRET: 'whsec_test',
        BASE_API_URL: 'http://localhost:3000',
        API_KEY: 'test_key'
    }),
}));

jest.mock('svix', () => ({
    Webhook: jest.fn().mockImplementation(() => ({
        verify: jest.fn((payload) => JSON.parse(payload)),
    })),
}));

describe('Webhooks (e2e)', () => {
    let app: INestApplication;

    beforeEach(async () => {
        const moduleFixture: TestingModule = await Test.createTestingModule({
            imports: [AppModule],
        }).compile();

        app = moduleFixture.createNestApplication();
        await app.init();

        (forwardReq as jest.Mock).mockResolvedValue({
            ok: true,
            json: async () => ({}),
        });
    });

    afterEach(async () => {
        jest.clearAllMocks();
    });

    afterAll(async () => {
        await app.close();
    });

    const svixHeaders = {
        'svix-id': 'msg_123',
        'svix-timestamp': '1234567890',
        'svix-signature': 'v1,signature',
    };

    it('/api/webhooks/clerk (POST) - user.created', async () => {
        const payload = {
            type: 'user.created',
            data: {
                id: 'user_123',
                first_name: 'Alice',
                last_name: 'Smith',
                email_addresses: [{ email_address: 'alice@example.com' }],
            },
        };

        await request(app.getHttpServer())
            .post('/api/webhooks/clerk')
            .set(svixHeaders)
            .send(payload)
            .expect(201);

        expect(forwardReq).toHaveBeenCalledWith(
            'http://localhost:3000/api/v1/users',
            'POST',
            'test_key',
            expect.objectContaining({
                id: 'user_123',
                firstName: 'Alice',
                lastName: 'Smith',
                email: 'alice@example.com',
            }),
        );
    });

    it('/api/webhooks/clerk (POST) - user.updated', async () => {
        const payload = {
            type: 'user.updated',
            data: {
                id: 'user_123',
                first_name: 'Alice',
                last_name: 'Wonderland',
                email_addresses: [{ email_address: 'alice@example.com' }],
            },
        };

        await request(app.getHttpServer())
            .post('/api/webhooks/clerk')
            .set(svixHeaders)
            .send(payload)
            .expect(201);

        expect(forwardReq).toHaveBeenCalledWith(
            'http://localhost:3000/api/v1/users/user_123',
            'PUT',
            'test_key',
            expect.objectContaining({
                id: 'user_123',
                lastName: 'Wonderland',
            }),
        );
    });

    it('/api/webhooks/clerk (POST) - user.deleted', async () => {
        const payload = {
            type: 'user.deleted',
            data: {
                id: 'user_123',
                deleted: true
            },
        };

        await request(app.getHttpServer())
            .post('/api/webhooks/clerk')
            .set(svixHeaders)
            .send(payload)
            .expect(201);

        expect(forwardReq).toHaveBeenCalledWith(
            'http://localhost:3000/api/v1/users/user_123',
            'DELETE',
            'test_key',
        );
    });

    it('should return 400 if svix headers are missing', async () => {
        await request(app.getHttpServer())
            .post('/api/webhooks/clerk')
            .send({ type: 'user.created' })
            .expect(400);
    });
});
