import { DataSource } from 'typeorm';
import { AppModule } from './src/app.module';
import { NestFactory } from '@nestjs/core';

async function run() {
    const app = await NestFactory.createApplicationContext(AppModule);
    const ds = app.get(DataSource);
    const res = await ds.query("SELECT simplified, pinyin, meaning_vi, examples FROM vocabularies WHERE simplified = '谁'");
    console.log(JSON.stringify(res, null, 2));
    await app.close();
    process.exit(0);
}
run();
