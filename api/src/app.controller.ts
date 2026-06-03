import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Post('grammar/check')
  checkGrammar(@Body('text') text: string) {
    return this.appService.checkGrammar(text ?? '');
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

  @Get('flashcard/image-suggestion')
  getFlashcardImageSuggestion(
    @Query('q') q = '',
    @Query('meaning') meaning = '',
  ) {
    return this.appService.getFlashcardImageSuggestion(q, meaning);
  }
}
