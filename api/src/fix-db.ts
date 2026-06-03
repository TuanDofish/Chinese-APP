import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DataSource } from 'typeorm';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const dataSource = app.get(DataSource);

  console.log('Đang dọn dẹp dữ liệu rác trong Database...');

  // Reset meaning_vi nếu nó là 'Đang tải nghĩa...' hoặc rỗng hoặc các placeholder không có dấu
  await dataSource.query(
    `UPDATE vocabularies 
     SET meaning_vi = NULL, 
         examples = '[]' 
     WHERE meaning_vi = 'Đang tải nghĩa...' 
        OR meaning_vi = '...' 
        OR meaning_vi = '' 
        OR meaning_vi = 'Dang cap nhat nghia...' 
        OR meaning_vi = 'Dang cap nhat nghia' 
        OR meaning_vi LIKE 'Dang cap nhat%'`,
  );

  // Reset examples nếu chứa mock data
  await dataSource.query(
    `UPDATE vocabularies 
     SET examples = '[]' 
     WHERE examples::text LIKE '%Đang tải nghĩa...%' 
        OR examples::text LIKE '%Wǒmen zhèngzài tǎolùn%'
        OR examples::text LIKE '%Dang cap nhat%'`,
  );

  console.log('Hoàn thành dọn dẹp!');
  await app.close();
  process.exit(0);
}

bootstrap();
