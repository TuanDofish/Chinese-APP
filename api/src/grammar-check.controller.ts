import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { AppService } from './app.service';

interface CheckGrammarDto {
  text?: string;
}

@Controller('grammar')
export class GrammarCheckController {
  constructor(private readonly appService: AppService) {}

  @Post('check')
  @HttpCode(HttpStatus.OK)
  checkGrammar(@Body() dto: CheckGrammarDto) {
    return this.appService.checkGrammar(dto?.text ?? '');
  }
}
