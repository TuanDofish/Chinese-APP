import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { Vocabulary } from './entities/vocabulary.entity';
import { Article } from './entities/article.entity';
import { Grammar } from './entities/grammar.entity';
import { UserProgress } from './entities/user-progress.entity';
import { User } from './entities/user.entity';
import { CourseLevel } from './entities/course-level.entity';
import { Lesson } from './entities/lesson.entity';
import { QuizQuestion } from './entities/quiz-question.entity';
import { ExampleSentence } from './entities/example-sentence.entity';
import { GrammarController } from './grammar.controller';
import { GrammarCheckController } from './grammar-check.controller';
import { DictionaryModule } from './dictionary.module';
import { ReadingController } from './reading.controller';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5433'),
      username: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASS || 'password',
      database: process.env.DB_NAME || 'chinese_app',
      entities: [
        Vocabulary,
        Article,
        UserProgress,
        Grammar,
        User,
        CourseLevel,
        Lesson,
        QuizQuestion,
        ExampleSentence,
      ],
      synchronize: true, // Auto-create tables in dev. Set to false in production!
      logging: true,
    }),
    TypeOrmModule.forFeature([Grammar]),
    DictionaryModule,
  ],
  controllers: [
    AppController,
    GrammarController,
    GrammarCheckController,
    ReadingController,
  ],
  providers: [AppService],
})
export class AppModule {}
