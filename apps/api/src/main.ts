import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger, VersioningType } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log'],
    rawBody: true,
  });
  app.enableVersioning({ type: VersioningType.URI, defaultVersion: '2' });

  const config = app.get(ConfigService);
  const port = config.get<number>('PORT', 3000);
  const adminUrl = config.get<string>('ADMIN_URL', 'http://localhost:3001');
  const nodeEnv = config.get<string>('NODE_ENV', 'development');

  app.enableCors({
    origin: nodeEnv === 'development' ? true : [adminUrl],
    credentials: true,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  app.useGlobalInterceptors(new TransformInterceptor());
  app.useGlobalFilters(new HttpExceptionFilter());

  if (nodeEnv !== 'production') {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('mQuiz API')
      .setDescription('mQuiz Platform NestJS Backend — see DEVELOPER_ROADMAP.md')
      .setVersion('2.0')
      .addBearerAuth(
        { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
        'firebase-token',
      )
      .build();
    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('docs', app, document);
  }

  await app.listen(port);
  Logger.log(`mQuiz API listening on http://localhost:${port}`, 'Bootstrap');
  if (nodeEnv !== 'production') {
    Logger.log(`Swagger UI at http://localhost:${port}/docs`, 'Bootstrap');
  }
}

bootstrap();
