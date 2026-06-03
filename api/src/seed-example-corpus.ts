import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Repository } from 'typeorm';
import { ExampleSentence } from './entities/example-sentence.entity';
import { Vocabulary } from './entities/vocabulary.entity';
import { getRepositoryToken } from '@nestjs/typeorm';
import * as fs from 'fs';
import * as path from 'path';
import * as readline from 'readline';

type ExampleInput = {
  word: string;
  hskLevel?: number;
  cn: string;
  py?: string;
  vi?: string;
  source?: string;
  quality?: string;
  tags?: string[];
};

function normalizeLine(raw: unknown): ExampleInput | null {
  if (!raw || typeof raw !== 'object') return null;
  const obj = raw as Record<string, unknown>;
  const word = String(obj.word ?? obj.targetWord ?? '').trim();
  const cn = String(obj.cn ?? '').trim();
  if (!word || !cn) return null;
  return {
    word,
    hskLevel: Number(obj.hskLevel ?? obj.hsk_level ?? 0) || undefined,
    cn,
    py: String(obj.py ?? '').trim(),
    vi: String(obj.vi ?? '').trim(),
    source: String(obj.source ?? 'Unknown').trim(),
    quality: String(obj.quality ?? 'community').trim(),
    tags: Array.isArray(obj.tags) ? obj.tags.map((t) => String(t)) : [],
  };
}

function scoreExample(e: ExampleInput): number {
  let score = 0;
  if (e.quality === 'curated') score += 60;
  if (e.quality === 'seeded') score += 40;
  if (e.vi && e.vi.length > 0) score += 15;
  if (e.py && e.py.length > 0) score += 10;
  if (e.cn.includes('。') || e.cn.includes('？') || e.cn.includes('！'))
    score += 5;
  return score;
}

async function readJsonl(filePath: string): Promise<ExampleInput[]> {
  const results: ExampleInput[] = [];
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf8' }),
    crlfDelay: Infinity,
  });
  for await (const line of rl) {
    const trimmed = line.trim();
    if (!trimmed) continue;
    try {
      const parsed = JSON.parse(trimmed);
      const item = normalizeLine(parsed);
      if (item) results.push(item);
    } catch (_) {
      // Ignore malformed line
    }
  }
  return results;
}

async function main() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const exampleRepo = app.get<Repository<ExampleSentence>>(
    getRepositoryToken(ExampleSentence),
  );
  const vocabRepo = app.get<Repository<Vocabulary>>(
    getRepositoryToken(Vocabulary),
  );
  const minLevel = Number(process.env.HSK_MIN_LEVEL || 1);
  const maxLevel = Number(process.env.HSK_MAX_LEVEL || 9);

  const inputFile =
    process.argv[2] ||
    process.env.EXAMPLE_CORPUS_FILE ||
    path.join(process.cwd(), 'src', 'data', 'example_corpus_hsk14.jsonl');

  if (!fs.existsSync(inputFile)) {
    console.error(`Input file not found: ${inputFile}`);
    await app.close();
    process.exit(1);
  }

  console.log(`Reading corpus: ${inputFile}`);
  const raw = await readJsonl(inputFile);
  console.log(`Loaded ${raw.length} raw rows`);

  const vocabWords = await vocabRepo
    .createQueryBuilder('v')
    .select(['v.simplified', 'v.hskLevel'])
    .where('v.hskLevel BETWEEN :min AND :max', { min: minLevel, max: maxLevel })
    .getMany();
  const hskMap = new Map(vocabWords.map((v) => [v.simplified, v.hskLevel]));

  const dedup = new Set<string>();
  const toInsert: Partial<ExampleSentence>[] = [];
  for (const item of raw) {
    const mappedLevel = hskMap.get(item.word);
    if (!mappedLevel) continue; // keep only words that exist in your dictionary table
    const key = `${item.word}||${item.cn}`;
    if (dedup.has(key)) continue;
    dedup.add(key);
    toInsert.push({
      targetWord: item.word,
      hskLevel:
        item.hskLevel && item.hskLevel > 0 ? item.hskLevel : mappedLevel,
      cn: item.cn,
      py: item.py || '',
      vi: item.vi || '',
      source: item.source || 'Unknown',
      quality: item.quality || 'community',
      tags: (item.tags || []).map((t) => ({ tag: t })),
      score: scoreExample(item),
    });
  }

  console.log(
    `Filtered to ${toInsert.length} rows (HSK ${minLevel}-${maxLevel} + dedup)`,
  );
  const chunk = 1000;
  for (let i = 0; i < toInsert.length; i += chunk) {
    const rows = toInsert.slice(i, i + chunk);
    await exampleRepo
      .createQueryBuilder()
      .insert()
      .into(ExampleSentence)
      .values(rows)
      .orIgnore()
      .execute();
    process.stdout.write(
      `\rInserted ${Math.min(i + chunk, toInsert.length)}/${toInsert.length}`,
    );
  }
  process.stdout.write('\nDone.\n');

  await app.close();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
