import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import * as express from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const config = new DocumentBuilder()
    .setTitle('Memovo Gateway Service API')
    .setDescription(
      'OpenAPI documentation for the Memovo Gateway Service. This service acts as the main entry point for routing, authentication, and API aggregation across Memovo microservices.',
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
    .addServer(process.env.API_URL || 'http://localhost:3000')
    .build();

  const document = SwaggerModule.createDocument(app, config, {
    deepScanRoutes: true,
  });
  document.security = [{ Authorization: [] }];

  // Expose the OpenAPI JSON
  app
    .getHttpAdapter()
    .get('/api-json', (req: express.Request, res: express.Response) => {
      res.json(document);
    });

  await app.listen(process.env.PORT ?? 3000);
}

bootstrap();
