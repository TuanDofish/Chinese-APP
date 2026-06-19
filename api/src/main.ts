import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { existsSync, mkdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import express, { json, urlencoded } from 'express';
import { DataSource } from 'typeorm';
import { AppModule } from './app.module';

function loadLocalEnv() {
  const envPath = join(process.cwd(), '.env');
  if (!existsSync(envPath)) return;

  const lines = readFileSync(envPath, 'utf8').split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const separator = trimmed.indexOf('=');
    if (separator <= 0) continue;

    const key = trimmed.slice(0, separator).trim();
    const rawValue = trimmed.slice(separator + 1).trim();
    const value = rawValue.replace(/^['"]|['"]$/g, '');
    if (!process.env[key]) process.env[key] = value;
  }
}

async function tryInitializeDatabase(
  dataSource: DataSource,
  logger: Logger,
  announceOnlyFailures = false,
) {
  if (dataSource.isInitialized) return;
  try {
    await dataSource.initialize();
    logger.log(
      JSON.stringify({
        action: 'database.connected',
        at: new Date().toISOString(),
      }),
    );
  } catch (error) {
    const payload = {
      action: 'database.unavailable',
      at: new Date().toISOString(),
      message: error instanceof Error ? error.message : String(error),
    };
    if (!announceOnlyFailures) logger.warn(JSON.stringify(payload));
  }
}

async function bootstrap() {
  loadLocalEnv();
  const logger = new Logger('HttpAction');
  const app = await NestFactory.create(AppModule, { bodyParser: false });
  app.use(json({ limit: '10mb' }));
  app.use(urlencoded({ extended: true, limit: '10mb' }));
  const uploadRoot = process.env.UPLOAD_DIR || join(process.cwd(), 'uploads');
  if (!existsSync(uploadRoot)) mkdirSync(uploadRoot, { recursive: true });
  app.use('/uploads', express.static(uploadRoot));
  app.use((req, res, next) => {
    const startedAt = Date.now();
    const requestId = `http_${Date.now().toString(36)}_${Math.random()
      .toString(36)
      .slice(2, 8)}`;
    res.on('finish', () => {
      const payload = {
        action: 'http.request',
        requestId,
        at: new Date().toISOString(),
        method: req.method,
        path: req.originalUrl || req.url,
        statusCode: res.statusCode,
        durationMs: Date.now() - startedAt,
      };
      const line = JSON.stringify(payload);
      if (res.statusCode >= 500) logger.error(line);
      else if (res.statusCode >= 400) logger.warn(line);
      else logger.log(line);
    });
    next();
  });
  app.enableCors({
    origin: true,
    methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  const dataSource = app.get(DataSource, { strict: false });
  void tryInitializeDatabase(dataSource, logger);
  const retryTimer = setInterval(
    () => void tryInitializeDatabase(dataSource, logger, true),
    15000,
  );
  retryTimer.unref?.();

  await app.listen(process.env.PORT ?? 3001);
}
bootstrap();
