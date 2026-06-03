import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Vocabulary } from './entities/vocabulary.entity';
import { ExampleSentence } from './entities/example-sentence.entity';
import { cleanText } from './utils/text-normalizer';

@Injectable()
export class DictionaryService {
  constructor(
    @InjectRepository(Vocabulary)
    private vocabRepo: Repository<Vocabulary>,
    @InjectRepository(ExampleSentence)
    private exampleRepo: Repository<ExampleSentence>,
  ) {}

  /**
   * Search - supports: Hanzi, Pinyin, Vietnamese meaning, Han Viet reading
   */
  async search(q: string): Promise<Vocabulary[]> {
    if (!q || q.trim().length === 0) return [];
    const term = q.trim();

    // Bước 1: Ưu tiên tìm chính xác 100% trước (Siêu nhanh, dùng Index)
    const exactMatches = await this.vocabRepo
      .createQueryBuilder('v')
      .where('v.simplified = :exact OR v.traditional = :exact', { exact: term })
      .getMany();

    if (exactMatches.length > 0) {
      return exactMatches.map((v) => this.sanitizeVocabulary(v));
    }

    // Bước 2: Nếu không có từ chính xác, mới tìm kiếm tương đối (Pinyin, Hán Việt, Prefix)
    const results = await this.vocabRepo
      .createQueryBuilder('v')
      .where('v.pinyin ILIKE :pinyin', { pinyin: `%${term}%` })
      .orWhere('v."meaning_vi" ILIKE :vi', { vi: `%${term}%` })
      .orWhere('v.han_viet ILIKE :hanviet', { hanviet: `%${term}%` })
      .orWhere('v.simplified LIKE :prefix', { prefix: `${term}%` })
      .orderBy('v."hsk_level"', 'ASC')
      .take(20)
      .getMany();

    return results.map((v) => this.sanitizeVocabulary(v));
  }

  /**
   * Autocomplete - returns quick suggestions as user types (max 8 results)
   */
  async autocomplete(q: string): Promise<
    {
      simplified: string;
      pinyin: string;
      meaningVi: string;
      meaningEn: string;
    }[]
  > {
    if (!q || q.trim().length === 0) return [];
    const term = q.trim();

    const results = await this.vocabRepo
      .createQueryBuilder('v')
      .select(['v.simplified', 'v.pinyin', 'v.meaningVi', 'v.meaningEn'])
      .where('v.simplified LIKE :prefix', { prefix: `${term}%` })
      .orWhere('v.pinyin ILIKE :py', { py: `${term}%` })
      .orWhere('v.han_viet ILIKE :hv', { hv: `${term}%` })
      .orderBy('v.hskLevel', 'ASC')
      .take(8)
      .getMany();

    return results.map((v) => ({
      simplified: cleanText(v.simplified),
      pinyin: cleanText(v.pinyin),
      meaningVi: cleanText(v.meaningVi || ''),
      meaningEn: cleanText(v.meaningEn || ''),
    }));
  }

  /**
   * Get full detail for a single word - used by the Hanzii-style detail screen
   */
  async getDetail(word: string): Promise<Vocabulary | null> {
    const result = await this.vocabRepo.findOne({
      where: [{ simplified: word }, { traditional: word }],
    });
    return result ? this.sanitizeVocabulary(result) : null;
  }

  /**
   * Find example sentences from local HSK vocabulary rows.
   * This keeps example quality stable and HSK-aligned before falling back to external sources.
   */
  async getCuratedExamples(
    q: string,
    hskLevel = 0,
  ): Promise<{
    results: {
      cn: string;
      py: string;
      vi: string;
      source: string;
      quality: string;
    }[];
  }> {
    if (!q || q.trim().length === 0) return { results: [] };
    const term = q.trim();

    const rows = await this.vocabRepo
      .createQueryBuilder('v')
      .select(['v.examples', 'v.hskLevel', 'v.simplified'])
      .where(`v.examples::text ILIKE :needle`, { needle: `%${term}%` })
      .orderBy('ABS(v.hskLevel - :target)', 'ASC')
      .setParameter('target', Math.max(1, hskLevel || 1))
      .addOrderBy('v.hskLevel', 'ASC')
      .take(60)
      .getMany();

    const dedup = new Set<string>();
    const results: {
      cn: string;
      py: string;
      vi: string;
      source: string;
      quality: string;
    }[] = [];

    for (const row of rows) {
      const examples = Array.isArray(row.examples) ? row.examples : [];
      for (const raw of examples) {
        if (!raw || typeof raw !== 'object') continue;
        const ex = raw as Record<string, unknown>;
        const cn = cleanText(ex.cn ?? '');
        const py = cleanText(ex.py ?? '');
        const vi = cleanText(ex.vi ?? '');
        if (!cn || !cn.includes(term)) continue;
        if (dedup.has(cn)) continue;
        dedup.add(cn);
        results.push({
          cn,
          py,
          vi,
          source: 'HSK Seed Corpus',
          quality: 'curated',
        });
        if (results.length >= 6) {
          return { results };
        }
      }
    }

    return { results };
  }

  /**
   * Fast local lookup from preloaded `example_sentences` table.
   * This endpoint never calls external services and is designed for low-latency dictionary UX.
   */
  async getLocalExamples(
    q: string,
    hskLevel = 0,
    limit = 6,
  ): Promise<{
    results: {
      cn: string;
      py: string;
      vi: string;
      source: string;
      quality: string;
    }[];
  }> {
    if (!q || q.trim().length === 0) return { results: [] };
    const term = q.trim();
    const safeLimit = Math.min(Math.max(limit, 1), 20);
    const target = Math.max(1, hskLevel || 1);

    const rows = await this.exampleRepo
      .createQueryBuilder('e')
      .where('e.targetWord = :word', { word: term })
      .orderBy('ABS(e.hskLevel - :target)', 'ASC')
      .setParameter('target', target)
      .addOrderBy('e.score', 'DESC')
      .addOrderBy('e.id', 'ASC')
      .take(safeLimit)
      .getMany();

    if (rows.length > 0) {
      return {
        results: rows.map((r) => ({
          cn: cleanText(r.cn),
          py: cleanText(r.py || ''),
          vi: cleanText(r.vi || ''),
          source: cleanText(r.source || 'Local Corpus'),
          quality: cleanText(r.quality || 'community'),
        })),
      };
    }

    // Backward-compatible fallback from `vocabularies.examples` when local corpus has no data.
    return this.getCuratedExamples(term, target);
  }

  /**
   * Upsert a word+examples into the local DB (called when AI generates new content).
   * Subsequent lookups are always served from DB without hitting AI again.
   */
  async cacheWord(dto: {
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
  }): Promise<void> {
    const isInvalidMeaning = (m: string | undefined | null) => {
      if (!m) return true;
      const cleaned = m.trim().toLowerCase();
      return (
        cleaned === 'dang cap nhat nghia...' ||
        cleaned === 'dang cap nhat nghia' ||
        cleaned === 'đang tải nghĩa...' ||
        cleaned === '...' ||
        cleaned === '' ||
        cleaned.startsWith('dang cap nhat') ||
        cleaned.startsWith('đang tải')
      );
    };

    const meaningVi = isInvalidMeaning(dto.meaningVi) ? null : dto.meaningVi;

    const existing = await this.vocabRepo.findOne({
      where: { simplified: dto.simplified },
    });

    if (existing) {
      if (
        meaningVi &&
        (!existing.meaningVi || isInvalidMeaning(existing.meaningVi))
      ) {
        existing.meaningVi = meaningVi;
      }
      if (dto.pinyin) existing.pinyin = dto.pinyin;
      if (dto.hanViet) existing.hanViet = dto.hanViet;
      if (dto.radical) existing.radical = dto.radical;
      if (dto.wordType) existing.wordType = dto.wordType;
      if (dto.examples && dto.examples.length > 0)
        existing.examples = dto.examples;
      if (dto.definitions && dto.definitions.length > 0)
        existing.definitions = dto.definitions;
      await this.vocabRepo.save(existing);
    } else {
      const word = this.vocabRepo.create({
        simplified: dto.simplified,
        pinyin: dto.pinyin ?? '',
        hanViet: dto.hanViet ?? '',
        radical: dto.radical ?? '',
        wordType: dto.wordType ?? '',
        meaningVi: meaningVi ?? '',
        meaningEn: dto.meaningEn ?? '',
        hskLevel: dto.hskLevel ?? 3,
        examples: dto.examples ?? [],
        definitions: dto.definitions ?? [],
      });
      await this.vocabRepo.save(word);
    }
  }

  private sanitizeVocabulary(v: Vocabulary): Vocabulary {
    v.simplified = cleanText(v.simplified);
    v.traditional = cleanText(v.traditional);
    v.pinyin = cleanText(v.pinyin);
    v.meaningVi = cleanText(v.meaningVi);
    v.meaningEn = cleanText(v.meaningEn);
    v.hanViet = cleanText(v.hanViet);
    v.wordType = cleanText(v.wordType);
    v.radical = cleanText(v.radical);

    if (Array.isArray(v.examples)) {
      v.examples = v.examples.map((ex: any) => ({
        ...ex,
        cn: cleanText(ex?.cn),
        py: cleanText(ex?.py),
        vi: cleanText(ex?.vi),
      }));
    }
    return v;
  }
}
