import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DictionaryService } from './dictionary.service';
import * as https from 'https';
import * as zlib from 'zlib';
import * as readline from 'readline';

async function bootstrap() {
  console.log('Khởi tạo ứng dụng NestJS để Seed Database...');
  const app = await NestFactory.createApplicationContext(AppModule);
  const dictionaryService = app.get(DictionaryService);

  console.log('Bắt đầu tải CC-CEDICT...');
  const url =
    'https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz';

  let count = 0;
  const batchSize = 1000;
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
        if (line.startsWith('#')) return; // Bỏ qua comment

        // Format: Traditional Simplified [pin1 yin1] /meaning 1/meaning 2/
        const match = line.match(/^(\S+)\s+(\S+)\s+\[([^\]]+)\]\s+\/(.+)\/$/);
        if (match) {
          const traditional = match[1];
          const simplified = match[2];
          const pinyinRaw = match[3];
          const meaningEn = match[4].replace(/\//g, '; ');

          batch.push({
            simplified,
            pinyin: pinyinRaw, // TODO: Convert number to tone marks if needed
            meaningEn: meaningEn,
            meaningVi: '', // AI sẽ dịch tự động hoặc dịch sau
            hanViet: '', // Nguồn CC-CEDICT không có âm Hán Việt
          });

          count++;

          if (batch.length >= batchSize) {
            rl.pause();
            const currentBatch = [...batch];
            batch = [];

            try {
              // Bulk insert can be optimized, but here we use cacheWord logic or direct Repo
              // To keep it safe, we'll just insert the first 5000 words for demonstration
              // (CC-CEDICT has 120k+ words which takes too long to seed fully in one go via AI script)
              for (const item of currentBatch) {
                await dictionaryService.cacheWord(item);
              }
              console.log(`Đã nạp ${count} từ vựng...`);
            } catch (e) {
              console.error('Lỗi khi nạp data:', e);
            }

            if (count >= 5000) {
              console.log(
                'Đã nạp xong 5000 từ phổ biến từ CC-CEDICT (Demo mode).',
              );
              rl.close();
              response.destroy();
              app.close();
              process.exit(0);
            } else {
              rl.resume();
            }
          }
        }
      });

      rl.on('close', async () => {
        if (batch.length > 0) {
          for (const item of batch) {
            await dictionaryService.cacheWord(item);
          }
        }
        console.log(`Hoàn thành! Tổng cộng đã nạp ${count} từ vựng.`);
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
