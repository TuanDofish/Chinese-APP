import { Body, Controller, Get, Headers, Param, Post, Put } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LearningService } from './learning.service';

@Controller('learning')
export class LearningController {
  constructor(
    private readonly learningService: LearningService,
    private readonly authService: AuthService,
  ) {}

  @Get('summary')
  summary(@Headers('authorization') authorization = '') {
    return this.learningService.summary(this.token(authorization));
  }

  @Put('goal')
  goal(
    @Headers('authorization') authorization = '',
    @Body()
    body: { level?: string; words?: number; minutes?: number; reminder?: string },
  ) {
    return this.learningService.updateGoal(this.token(authorization), body);
  }

  @Put('words/:word')
  word(
    @Headers('authorization') authorization = '',
    @Param('word') word: string,
    @Body()
    body: { favorite?: boolean; learned?: boolean; correct?: boolean },
  ) {
    return this.learningService.updateWord(
      this.token(authorization),
      word,
      body,
    );
  }

  @Post('attempts')
  attempt(
    @Headers('authorization') authorization = '',
    @Body() body: Record<string, any>,
  ) {
    return this.learningService.recordAttempt(
      this.token(authorization),
      body,
    );
  }

  @Post('reading')
  reading(
    @Headers('authorization') authorization = '',
    @Body() body: Record<string, any>,
  ) {
    return this.learningService.recordReading(
      this.token(authorization),
      body,
    );
  }

  @Post('study-time')
  studyTime(
    @Headers('authorization') authorization = '',
    @Body() body: { seconds?: number },
  ) {
    return this.learningService.addStudyTime(
      this.token(authorization),
      Number(body.seconds || 0),
    );
  }

  private token(authorization: string) {
    return this.authService.tokenFromAuthorization(authorization);
  }
}
