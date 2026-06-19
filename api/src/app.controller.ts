import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('health')
  getHealth() {
    return this.appService.getHealth();
  }

  @Get('profile')
  getProfile() {
    return this.appService.getProfile();
  }

  @Post('profile/goal')
  updateGoal(
    @Body() body: { level?: string; words?: number; minutes?: number },
  ) {
    return this.appService.updateGoal(body);
  }

  @Post('ai/chat')
  chat(
    @Body()
    body: {
      message?: string;
      level?: string;
      history?: { role?: string; text?: string }[];
    },
  ) {
    return this.appService.chat(
      body.message ?? '',
      body.level ?? 'HSK 2',
      body.history ?? [],
    );
  }

  @Post('pronunciation/score')
  scorePronunciation(
    @Body()
    body: {
      target?: string;
      targetPinyin?: string;
      recognized?: string;
      lessonId?: string;
      lineIndex?: number;
    },
  ) {
    return this.appService.scorePronunciation(
      body.target ?? '',
      body.recognized ?? '',
      {
        targetPinyin: body.targetPinyin,
        lessonId: body.lessonId,
        lineIndex: body.lineIndex,
      },
    );
  }

  @Get('flashcard/image-suggestion')
  getFlashcardImageSuggestion(
    @Query('q') q = '',
    @Query('meaning') meaning = '',
  ) {
    return this.appService.getFlashcardImageSuggestion(q, meaning);
  }
}
