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
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { ContentController } from './content.controller';
import { ContentService } from './content.service';
import { LearningController } from './learning.controller';
import { LearningService } from './learning.service';
import { MediaController } from './media.controller';
import { AdminAuthGuard } from './admin-auth.guard';

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
      synchronize: process.env.DB_SYNC === 'true',
      logging: process.env.DB_LOGGING === 'true',
      manualInitialization: true,
    }),
    TypeOrmModule.forFeature([Grammar, User]),
    DictionaryModule,
  ],
  controllers: [
    AppController,
    GrammarController,
    GrammarCheckController,
    ReadingController,
    AuthController,
    ContentController,
    LearningController,
    MediaController,
  ],
  providers: [
    AppService,
    AuthService,
    ContentService,
    LearningService,
    AdminAuthGuard,
  ],
})
export class AppModule {}
