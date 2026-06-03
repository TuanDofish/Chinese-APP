import { Controller, Get, Post, Body, Query, Param } from '@nestjs/common';
import { DictionaryService } from './dictionary.service';

@Controller('dictionary')
export class DictionaryController {
  constructor(private readonly dictionaryService: DictionaryService) {}

  @Get('search')
  async search(@Query('q') q: string) {
    return this.dictionaryService.search(q);
  }

  /** Autocomplete endpoint - called on every keystroke for suggestions */
  @Get('autocomplete')
  async autocomplete(@Query('q') q: string) {
    return this.dictionaryService.autocomplete(q);
  }

  /** Full detail for a single word - used by the Hanzii-style detail panel */
  @Get('detail/:word')
  async detail(@Param('word') word: string) {
    const result = await this.dictionaryService.getDetail(word);
    return result ?? null;
  }

  @Post('cache')
  async cache(
    @Body()
    body: {
      simplified: string;
      pinyin?: string;
      hanViet?: string;
      radical?: string;
      wordType?: string;
      meaningVi: string;
      meaningEn?: string;
      hskLevel?: number;
      examples?: object[];
      definitions?: object[];
    },
  ) {
    await this.dictionaryService.cacheWord(body);
    return { ok: true };
  }

  /** Fast examples endpoint: local corpus first, then template fallback. */
  @Get('examples')
  async getExamples(
    @Query('q') q: string,
    @Query('hskLevel') hskLevel?: string,
  ) {
    if (!q) return { results: [] };

    const parsedLevel = Number(hskLevel ?? 0);
    const safeLevel = Number.isFinite(parsedLevel) ? parsedLevel : 0;
    const local = await this.dictionaryService.getLocalExamples(
      q,
      safeLevel,
      8,
    );
    if (local.results.length > 0) {
      return { results: local.results };
    }

    const templates = [
      {
        cn: `我今天学习“${q}”。`,
        py: `Wǒ jīntiān xuéxí "${q}".`,
        vi: `Hôm nay tôi học từ "${q}".`,
      },
      {
        cn: `这个“${q}”很常用。`,
        py: `Zhège "${q}" hěn chángyòng.`,
        vi: `Từ "${q}" này dùng rất thường xuyên.`,
      },
      {
        cn: `请用“${q}”造句。`,
        py: `Qǐng yòng "${q}" zàojù.`,
        vi: `Hãy đặt câu với từ "${q}".`,
      },
      {
        cn: `在HSK里，“${q}”很重要。`,
        py: `Zài HSK lǐ, "${q}" hěn zhòngyào.`,
        vi: `Trong HSK, từ "${q}" rất quan trọng.`,
      },
    ];

    return {
      results: templates.map((t) => ({
        ...t,
        source: 'Template Local',
        quality: 'curated',
      })),
    };
  }

  @Get('translate')
  async translate(@Query('q') q: string) {
    if (!q) return { text: '' };
    try {
      const url = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=zh-CN&tl=vi&dt=t&q=${encodeURIComponent(q)}`;
      const response = await fetch(url, { signal: AbortSignal.timeout(5000) });
      if (!response.ok) return { text: '' };
      const data = await response.json();
      return { text: data[0]?.[0]?.[0] || '' };
    } catch (e) {
      return { text: '' };
    }
  }

  /** Curated examples from local HSK seed corpus (prioritized by HSK proximity). */
  @Get('examples-curated')
  async getCuratedExamples(
    @Query('q') q: string,
    @Query('hskLevel') hskLevel?: string,
  ) {
    const parsedLevel = Number(hskLevel ?? 0);
    const safeLevel = Number.isFinite(parsedLevel) ? parsedLevel : 0;
    return this.dictionaryService.getCuratedExamples(q, safeLevel);
  }

  /** Ultra-fast local examples from preloaded DB table (no external calls). */
  @Get('examples-local')
  async getLocalExamples(
    @Query('q') q: string,
    @Query('hskLevel') hskLevel?: string,
    @Query('limit') limit?: string,
  ) {
    const parsedLevel = Number(hskLevel ?? 0);
    const safeLevel = Number.isFinite(parsedLevel) ? parsedLevel : 0;
    const parsedLimit = Number(limit ?? 6);
    const safeLimit = Number.isFinite(parsedLimit) ? parsedLimit : 6;
    return this.dictionaryService.getLocalExamples(q, safeLevel, safeLimit);
  }
}
