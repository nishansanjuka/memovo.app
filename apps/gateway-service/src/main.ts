import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import * as express from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({ origin: '*', credentials: true });

  const config = new DocumentBuilder()
    .setTitle('Memovo Gateway Service API')
    .setDescription(
      'OpenAPI documentation for the Memovo Gateway Service.\n\n' +
        'Authentication:\n' +
        '- Most routes require a Bearer token (JWT) in the Authorization header.\n' +
        '- The Clerk webhook route (/api/webhooks/clerk) uses a custom webhook authentication scheme, requiring the following headers:\n' +
        '    - svix-id: Unique Svix webhook event ID\n' +
        '    - svix-timestamp: Timestamp of the Svix webhook event\n' +
        '    - svix-signature: Signature for verifying the Svix webhook event\n' +
        '\nRefer to each route for specific requirements.',
    )
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        in: 'header',
      },
      'Authorization',
    )
    .addApiKey(
      {
        type: 'apiKey',
        in: 'header',
        name: 'svix-signature',
        description:
          'Svix webhook signature. Also requires svix-id and svix-timestamp headers.',
      },
      'webhook',
    )
    .addServer(process.env.API_URL || 'http://localhost:3000')
    .build();

  const document = SwaggerModule.createDocument(app, config, {
    deepScanRoutes: true,
  });

  // Expose the OpenAPI JSON
  app
    .getHttpAdapter()
    .get('/api-json', (req: express.Request, res: express.Response) => {
      res.json(document);
    });

  await app.listen(process.env.PORT ?? 3000);
}

bootstrap();
