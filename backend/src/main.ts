import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module.js';
import * as Sentry from '@sentry/node';

async function bootstrap() {
  Sentry.init({
    dsn: process.env.SENTRY_DSN, // ponytail: no-op if undefined. Add Tracing when requested.
    environment: process.env.NODE_ENV || 'development',
  });

  const app = await NestFactory.create(AppModule);
  await app.listen(process.env.PORT ?? 3000);
}
await bootstrap();
