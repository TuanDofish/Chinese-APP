import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Repository } from 'typeorm';
import { Grammar } from './entities/grammar.entity';
import { getRepositoryToken } from '@nestjs/typeorm';
import * as fs from 'fs';
import * as path from 'path';
import { Client } from 'pg';

interface GrammarJsonItem {
  id: string;
  level: string;
  title: string;
  pattern: string;
  explanation: string;
  examples: Array<{ cn: string; py: string; vi: string }>;
  note?: string;
}

async function dropTableRaw() {
  const host = process.env.DB_HOST || 'localhost';
  const port = parseInt(process.env.DB_PORT || '5433');
  const user = process.env.DB_USER || 'postgres';
  const password = process.env.DB_PASS || 'password';
  const database = process.env.DB_NAME || 'chinese_app';

  console.log(`Kết nối PostgreSQL trực tiếp để DROP TABLE grammar...`);
  const client = new Client({
    host,
    port,
    user,
    password,
    database,
  });

  try {
    await client.connect();
    // Drop table grammar cascade để TypeORM recreate với kiểu jsonb sạch sẽ
    await client.query('DROP TABLE IF EXISTS grammar CASCADE;');
    console.log('Đã DROP TABLE grammar thành công.');
  } catch (err) {
    console.error('Lỗi khi drop table grammar:', err);
  } finally {
    await client.end();
  }
}

async function main() {
  // 1. Drop bảng cũ để tránh TypeORM alter column jsonb lỗi
  await dropTableRaw();

  // 2. Khởi động NestJS context (TypeORM sẽ sync và tự tạo lại bảng grammar với examples jsonb)
  console.log('Khởi chạy NestJS application context...');
  const app = await NestFactory.createApplicationContext(AppModule);
  const grammarRepo = app.get<Repository<Grammar>>(getRepositoryToken(Grammar));

  // 3. Đọc dữ liệu từ file grammar_hsk.json
  const jsonPath = path.join(
    __dirname,
    '..',
    '..',
    'apps',
    'mobile',
    'assets',
    'data',
    'grammar_hsk.json',
  );
  console.log(`Đọc file ngữ pháp từ: ${jsonPath}`);

  if (!fs.existsSync(jsonPath)) {
    console.error(`Không tìm thấy file grammar_hsk.json tại ${jsonPath}`);
    await app.close();
    process.exit(1);
  }

  const fileContent = fs.readFileSync(jsonPath, 'utf-8');
  const rawData: GrammarJsonItem[] = JSON.parse(fileContent);
  console.log(`Đã load ${rawData.length} cấu trúc ngữ pháp từ JSON.`);

  const toInsert: Partial<Grammar>[] = rawData.map((item) => {
    // Nếu có note thì bổ sung vào giải thích
    let explanation = item.explanation;
    if (item.note && item.note.trim()) {
      explanation += `\nChú ý: ${item.note}`;
    }

    // Ghép pattern vào title nếu khác nhau
    let title = item.title;
    if (item.pattern && item.pattern.trim() && item.pattern !== item.title) {
      title += ` (${item.pattern})`;
    }

    return {
      level: item.level || 'HSK 1',
      title: title,
      explanation: explanation,
      examples: item.examples || [],
    };
  });

  // 4. Bulk insert
  console.log(
    `Đang nạp ${toInsert.length} bài học ngữ pháp vào cơ sở dữ liệu...`,
  );
  const chunkSize = 100;
  for (let i = 0; i < toInsert.length; i += chunkSize) {
    const chunk = toInsert.slice(i, i + chunkSize);
    await grammarRepo
      .createQueryBuilder()
      .insert()
      .into(Grammar)
      .values(chunk)
      .execute();
    console.log(
      `Đã nạp ${Math.min(i + chunkSize, toInsert.length)}/${toInsert.length}`,
    );
  }

  console.log('Nạp dữ liệu ngữ pháp HSK hoàn tất!');
  await app.close();
}

main().catch((e) => {
  console.error('Lỗi khi seed grammar:', e);
  process.exit(1);
});
