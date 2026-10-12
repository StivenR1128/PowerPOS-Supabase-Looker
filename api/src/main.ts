import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import * as path from 'path';

async function bootstrap() {
  if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL es obligatoria');
  if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) throw new Error('JWT_SECRET debe tener al menos 32 caracteres');
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.enableCors({
    origin: (process.env.CORS_ORIGINS || 'http://localhost:3001').split(',').map(origin => origin.trim()),
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  const uploadsPath = path.join(process.cwd(), 'uploads');
  console.log('Sirviendo archivos estáticos desde:', uploadsPath);
  
  app.useStaticAssets(uploadsPath, {
    prefix: '/uploads/',
  });

  await app.listen(process.env.PORT || 3000);
}
bootstrap();
