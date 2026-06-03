import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DataSource } from 'typeorm';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const ds = app.get(DataSource);

  // Clear any cached examples so Tatoeba proxy runs again and fetches english fallbacks
  console.log('Clearing cached examples...');
  await ds.query(
    `UPDATE vocabularies SET examples = '[]' WHERE jsonb_array_length(examples) = 0 OR examples::text LIKE '%我们正在讨论关于%'`,
  );

  console.log('Cache cleared!');
  await app.close();
  process.exit(0);
}
bootstrap();
