import { Controller, Get, Param } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Grammar } from './entities/grammar.entity';
import { cleanText } from './utils/text-normalizer';

@Controller('grammar')
export class GrammarController {
  constructor(
    @InjectRepository(Grammar)
    private readonly grammarRepo: Repository<Grammar>,
  ) {}

  private sanitizeGrammar(item: Grammar) {
    let sanitizedExamples: { cn: string; py: string; vi: string }[] = [];
    if (Array.isArray(item.examples)) {
      sanitizedExamples = item.examples.map((ex: any) => ({
        cn: cleanText(ex.cn),
        py: cleanText(ex.py),
        vi: cleanText(ex.vi),
      }));
    }
    return {
      ...item,
      level: cleanText(item.level),
      title: cleanText(item.title),
      explanation: cleanText(item.explanation),
      examples: sanitizedExamples,
    };
  }

  @Get()
  async getAllGrammar() {
    const rows = await this.grammarRepo.find({
      order: { level: 'ASC', id: 'ASC' },
    });
    return rows.map((r) => this.sanitizeGrammar(r));
  }

  @Get('level/:level')
  async getGrammarByLevel(@Param('level') level: string) {
    const rows = await this.grammarRepo.find({
      where: { level },
      order: { id: 'ASC' },
    });
    return rows.map((r) => this.sanitizeGrammar(r));
  }
}
