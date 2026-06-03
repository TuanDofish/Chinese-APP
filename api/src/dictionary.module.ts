import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DictionaryController } from './dictionary.controller';
import { DictionaryService } from './dictionary.service';
import { Vocabulary } from './entities/vocabulary.entity';
import { ExampleSentence } from './entities/example-sentence.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Vocabulary, ExampleSentence])],
  controllers: [DictionaryController],
  providers: [DictionaryService],
})
export class DictionaryModule {}
