
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

// Mock dependencies to avoid environment issues during E2E tests
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

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  // Since there is no root controller returning "Hello World", 
  // we check if the Swagger JSON endpoint is available as a health/smoke test.
  // Note: Swagger setup logic is in main.ts, not AppModule, so in a pure module test 
  // without main.ts bootstrapping, swagger endpoints might NOT be registered automatically 
  // if they are setup in bootstrap function.

  // Actually, AppModule doesn't have controllers. 
  // We can just check that the app initializes and returns 404 for root,
  // which confirms the app is running but no root route exists.
  it('/ (GET)', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(404);
  });
});
