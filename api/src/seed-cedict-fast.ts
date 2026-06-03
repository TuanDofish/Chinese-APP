import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DataSource } from 'typeorm';
import * as https from 'https';
import * as zlib from 'zlib';
import * as readline from 'readline';

async function bootstrap() {
  console.log('Khởi tạo Fast Seeder...');
  const app = await NestFactory.createApplicationContext(AppModule);
  const dataSource = app.get(DataSource);

  console.log('Bắt đầu tải CC-CEDICT (toàn bộ)...');
  const url =
    'https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz';

  let count = 0;
  const batchSize = 5000;
  let batch: any[] = [];

  https
    .get(url, (response) => {
      if (response.statusCode !== 200) {
        console.error('Lỗi khi tải CC-CEDICT:', response.statusCode);
        process.exit(1);
      }

      const unzip = zlib.createGunzip();
      response.pipe(unzip);

      const rl = readline.createInterface({
        input: unzip,
        crlfDelay: Infinity,
      });

      rl.on('line', async (line) => {
        if (line.startsWith('#')) return;

        const match = line.match(/^(\S+)\s+(\S+)\s+\[([^\]]+)\]\s+\/(.+)\/$/);
        if (match) {
          batch.push({
            traditional: match[1],
            simplified: match[2],
            pinyin: match[3],
            meaning_en: match[4].replace(/\//g, '; '),
            meaning_vi: '',
            han_viet: '',
            radical: '',
            word_type: '',
            hsk_level: 0,
          });

          if (batch.length >= batchSize) {
            rl.pause();
            const currentBatch = [...batch];
            batch = [];

            try {
              await dataSource
                .createQueryBuilder()
                .insert()
                .into('vocabularies')
                .values(currentBatch)
                .orIgnore() // Ignore conflicts if unique constraint exists
                .execute();
              count += currentBatch.length;
              console.log(`Đã nạp ${count} từ...`);
            } catch (e) {
              console.error('Lỗi nạp batch:', e);
            }
            rl.resume();
          }
        }
      });

      rl.on('close', async () => {
        if (batch.length > 0) {
          try {
            await dataSource
              .createQueryBuilder()
              .insert()
              .into('vocabularies')
              .values(batch)
              .orIgnore()
              .execute();
            count += batch.length;
          } catch (e) {}
        }
        console.log(`Hoàn thành! Nạp tổng cộng ${count} từ.`);
        await app.close();
        process.exit(0);
      });
    })
    .on('error', (err) => {
      console.error('Lỗi kết nối:', err);
      process.exit(1);
    });
}

bootstrap();
