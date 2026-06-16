import { createHash } from 'crypto';
import * as fs from 'fs';
import * as path from 'path';
import { Client } from 'pg';

type JsonObject = Record<string, any>;

const apiDir = path.resolve(__dirname, '..');
const projectDir = path.resolve(apiDir, '..');
let legacyTypeOrmSchema = false;

function loadEnv(filePath: string) {
  if (!fs.existsSync(filePath)) return;
  for (const rawLine of fs.readFileSync(filePath, 'utf8').split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    const separator = line.indexOf('=');
    if (separator < 1) continue;
    const key = line.slice(0, separator).trim();
    const value = line
      .slice(separator + 1)
      .trim()
      .replace(/^(['"])(.*)\1$/, '$2');
    if (process.env[key] === undefined) process.env[key] = value;
  }
}

loadEnv(path.join(apiDir, '.env'));

function readJson(relativePath: string): any {
  const filePath = path.join(projectDir, relativePath);
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function levelNumber(value: unknown): number {
  const match = String(value ?? '').match(/[1-6]/);
  return match ? Number(match[0]) : 1;
}

function text(value: unknown): string {
  return String(value ?? '').trim();
}

function checksum(value: unknown): string {
  return createHash('sha256').update(JSON.stringify(value)).digest('hex');
}

async function upsertReturningId(
  client: Client,
  sql: string,
  values: unknown[],
): Promise<number> {
  const result = await client.query(sql, values);
  return Number(result.rows[0].id);
}

async function applySchema(client: Client) {
  const schemaPath = path.join(
    projectDir,
    'docs',
    'chuong-2',
    'schema',
    'chinese_learning_app.sql',
  );
  console.log(`Applying schema: ${schemaPath}`);
  await client.query(fs.readFileSync(schemaPath, 'utf8'));
}

async function seedLevels(client: Client): Promise<Map<number, number>> {
  const descriptions: Record<number, string> = {
    1: 'Nền tảng giao tiếp: chào hỏi, số đếm, gia đình và sinh hoạt cơ bản.',
    2: 'Mở rộng giao tiếp hằng ngày, mô tả sự việc và nhu cầu quen thuộc.',
    3: 'Giao tiếp độc lập trong học tập, công việc và đời sống.',
    4: 'Đọc hiểu và diễn đạt các chủ đề xã hội ở mức trung cấp.',
  };
  const ids = new Map<number, number>();
  for (let level = 1; level <= 4; level += 1) {
    const id = await upsertReturningId(
      client,
      `INSERT INTO course_levels
        (code, level_number, name, description, display_order, active)
       VALUES ($1, $2, $3, $4, $2, TRUE)
       ON CONFLICT (code) DO UPDATE SET
         level_number = EXCLUDED.level_number,
         name = EXCLUDED.name,
         description = EXCLUDED.description,
         active = TRUE,
         updated_at = NOW()
       RETURNING id`,
      [`HSK${level}`, level, `HSK ${level}`, descriptions[level]],
    );
    ids.set(level, id);
  }
  return ids;
}

async function seedLesson(
  client: Client,
  levelIds: Map<number, number>,
  input: {
    code: string;
    level: number;
    title: string;
    titleCn?: string;
    type: string;
    description?: string;
    content?: JsonObject;
    order?: number;
  },
): Promise<number> {
  if (legacyTypeOrmSchema) {
    return upsertReturningId(
      client,
      `INSERT INTO lessons
        (course_level_id, "courseLevelId", code, title, title_cn, lesson_type,
         description, content_json, display_order, order_index, status)
       VALUES ($1::bigint, $1::integer, $2, $3, $4, $5::lesson_type, $6, $7::jsonb, $8, $8, 'PUBLISHED')
       ON CONFLICT (code) DO UPDATE SET
         course_level_id = EXCLUDED.course_level_id,
         "courseLevelId" = EXCLUDED."courseLevelId",
         title = EXCLUDED.title,
         title_cn = EXCLUDED.title_cn,
         lesson_type = EXCLUDED.lesson_type,
         description = EXCLUDED.description,
         content_json = EXCLUDED.content_json,
         display_order = EXCLUDED.display_order,
         order_index = EXCLUDED.order_index,
         status = 'PUBLISHED',
         updated_at = NOW()
       RETURNING id`,
      [
        levelIds.get(input.level),
        input.code,
        input.title,
        input.titleCn || null,
        input.type,
        input.description || null,
        JSON.stringify(input.content || {}),
        input.order || 0,
      ],
    );
  }
  return upsertReturningId(
    client,
    `INSERT INTO lessons
      (course_level_id, code, title, title_cn, lesson_type, description,
       content_json, display_order, status)
     VALUES ($1, $2, $3, $4, $5::lesson_type, $6, $7::jsonb, $8, 'PUBLISHED')
     ON CONFLICT (code) DO UPDATE SET
       course_level_id = EXCLUDED.course_level_id,
       title = EXCLUDED.title,
       title_cn = EXCLUDED.title_cn,
       lesson_type = EXCLUDED.lesson_type,
       description = EXCLUDED.description,
       content_json = EXCLUDED.content_json,
       display_order = EXCLUDED.display_order,
       status = 'PUBLISHED',
       updated_at = NOW()
     RETURNING id`,
    [
      levelIds.get(input.level),
      input.code,
      input.title,
      input.titleCn || null,
      input.type,
      input.description || null,
      JSON.stringify(input.content || {}),
      input.order || 0,
    ],
  );
}

async function seedDictionary(client: Client) {
  const compact: JsonObject[] = readJson(
    'apps/mobile/assets/data/dictionary_hsk14_compact.json',
  );
  const rich: JsonObject[] = readJson(
    'apps/mobile/assets/data/dictionary_seed_clean.json',
  );
  const flashcardIndex = readJson(
    'apps/mobile/assets/images/flashcards/index.json',
  );
  const merged = new Map<string, JsonObject>();

  for (const item of compact) merged.set(text(item.simplified), { ...item });
  for (const item of rich) {
    const key = text(item.simplified);
    merged.set(key, { ...(merged.get(key) || {}), ...item });
  }
  for (const topic of flashcardIndex.topics as JsonObject[]) {
    for (const word of topic.words as JsonObject[]) {
      const key = text(word.word);
      merged.set(key, {
        hskLevel: 1,
        ...(merged.get(key) || {}),
        simplified: key,
        pinyin: text(word.pinyin) || merged.get(key)?.pinyin,
        meaningVi: text(word.meaning) || merged.get(key)?.meaningVi,
      });
    }
  }

  const vocabIds = new Map<string, number>();
  let index = 0;
  for (const item of merged.values()) {
    const word = text(item.simplified);
    if (!word) continue;
    const id = await upsertReturningId(
      client,
      `INSERT INTO vocabularies
        (simplified, traditional, pinyin, meaning_vi, meaning_en, han_viet,
         part_of_speech, radical, hsk_level, stroke_count, metadata, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11::jsonb, 'PUBLISHED')
       ON CONFLICT (simplified) DO UPDATE SET
         traditional = COALESCE(EXCLUDED.traditional, vocabularies.traditional),
         pinyin = COALESCE(EXCLUDED.pinyin, vocabularies.pinyin),
         meaning_vi = COALESCE(EXCLUDED.meaning_vi, vocabularies.meaning_vi),
         meaning_en = COALESCE(EXCLUDED.meaning_en, vocabularies.meaning_en),
         han_viet = COALESCE(EXCLUDED.han_viet, vocabularies.han_viet),
         part_of_speech = COALESCE(EXCLUDED.part_of_speech, vocabularies.part_of_speech),
         radical = COALESCE(EXCLUDED.radical, vocabularies.radical),
         hsk_level = EXCLUDED.hsk_level,
         stroke_count = COALESCE(EXCLUDED.stroke_count, vocabularies.stroke_count),
         metadata = vocabularies.metadata || EXCLUDED.metadata,
         status = 'PUBLISHED',
         updated_at = NOW()
       RETURNING id`,
      [
        word,
        text(item.traditional) || null,
        text(item.pinyin) || null,
        text(item.meaningVi) || null,
        text(item.meaningEn) || null,
        text(item.hanViet) || null,
        text(item.wordType) || null,
        text(item.radical) || null,
        levelNumber(item.hskLevel),
        Number(item.strokeCount) || null,
        JSON.stringify({ definitions: item.definitions || [] }),
      ],
    );
    vocabIds.set(word, id);
    index += 1;
    if (index % 500 === 0) console.log(`  vocabularies: ${index}/${merged.size}`);
  }

  for (const item of rich) {
    const vocabularyId = vocabIds.get(text(item.simplified));
    if (!vocabularyId) continue;
    for (const [exampleOrder, example] of (item.examples || []).entries()) {
      if (!text(example.cn)) continue;
      await client.query(
        `INSERT INTO vocabulary_examples
          (vocabulary_id, example_cn, example_pinyin, example_vi, source, display_order)
         VALUES ($1, $2, $3, $4, 'dictionary_seed_clean', $5)
         ON CONFLICT (vocabulary_id, example_cn) DO UPDATE SET
           example_pinyin = EXCLUDED.example_pinyin,
           example_vi = EXCLUDED.example_vi,
           display_order = EXCLUDED.display_order`,
        [
          vocabularyId,
          text(example.cn),
          text(example.py) || null,
          text(example.vi) || null,
          exampleOrder,
        ],
      );
    }
  }

  return { compact, rich, flashcardIndex, vocabIds };
}

async function seedTopicsAndQuizzes(
  client: Client,
  levelIds: Map<number, number>,
  flashcardIndex: JsonObject,
  vocabIds: Map<string, number>,
) {
  const topicLevels: Record<string, number> = {
    greeting: 1,
    family: 1,
    colors: 1,
    animals: 1,
    food: 1,
    school: 2,
    home: 2,
    body: 2,
    clothes: 2,
    transport: 2,
    weather: 2,
    places: 2,
    shopping: 3,
    sports: 3,
    health: 3,
    nature: 3,
    entertainment: 3,
    daily_life: 3,
    city_life: 4,
    media_society: 4,
  };

  for (const [topicOrder, topic] of (
    flashcardIndex.topics as JsonObject[]
  ).entries()) {
    const level = topicLevels[topic.id] || 1;
    const topicId = await upsertReturningId(
      client,
      `INSERT INTO topics
        (code, name, name_cn, hsk_level, description, color_hex, display_order, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'PUBLISHED')
       ON CONFLICT (code) DO UPDATE SET
         name = EXCLUDED.name,
         name_cn = EXCLUDED.name_cn,
         hsk_level = EXCLUDED.hsk_level,
         description = EXCLUDED.description,
         color_hex = EXCLUDED.color_hex,
         display_order = EXCLUDED.display_order,
         status = 'PUBLISHED',
         updated_at = NOW()
       RETURNING id`,
      [
        topic.id,
        topic.name,
        topic.nameCn || null,
        level,
        `Flashcard chủ đề ${topic.name}, phù hợp HSK ${level}.`,
        topic.color || null,
        topicOrder,
      ],
    );
    const lessonId = await seedLesson(client, levelIds, {
      code: `flashcard_${topic.id}`,
      level,
      title: `Từ vựng: ${topic.name}`,
      titleCn: topic.nameCn,
      type: 'VOCABULARY',
      description: `Học từ vựng theo hình ảnh thuộc chủ đề ${topic.name}.`,
      content: { topicCode: topic.id, wordCount: topic.words.length },
      order: topicOrder,
    });
    const quizLessonId = await seedLesson(client, levelIds, {
      code: `quiz_${topic.id}`,
      level,
      title: `Luyện tập: ${topic.name}`,
      titleCn: topic.nameCn,
      type: 'QUIZ',
      description: `Trắc nghiệm nghĩa và nhận diện chữ Hán chủ đề ${topic.name}.`,
      content: { topicCode: topic.id },
      order: topicOrder,
    });
    const words: JsonObject[] = topic.words;

    for (const [wordOrder, word] of words.entries()) {
      const vocabularyId = vocabIds.get(text(word.word));
      if (!vocabularyId) continue;
      const imagePath = `assets/images/flashcards/${topic.id}/${word.image}`;
      await client.query(
        `INSERT INTO topic_vocabularies
          (topic_id, vocabulary_id, image_path, display_order)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (topic_id, vocabulary_id) DO UPDATE SET
           image_path = EXCLUDED.image_path,
           display_order = EXCLUDED.display_order`,
        [topicId, vocabularyId, imagePath, wordOrder],
      );

      const distractors = words
        .filter((candidate) => candidate.word !== word.word)
        .slice(wordOrder % Math.max(words.length - 1, 1))
        .concat(words)
        .filter(
          (candidate, candidateIndex, all) =>
            candidate.word !== word.word &&
            all.findIndex((item) => item.word === candidate.word) ===
              candidateIndex,
        )
        .slice(0, 3);
      const viOptions = [word, ...distractors]
        .map((item) => text(item.meaning))
        .sort((a, b) => a.localeCompare(b, 'vi'));
      const cnOptions = [word, ...distractors]
        .map((item) => text(item.word))
        .sort((a, b) => a.localeCompare(b, 'zh'));

      const legacyCnColumns = legacyTypeOrmSchema
        ? ', "lessonId", "questionType", "questionText", options, "correctAnswer"'
        : '';
      const legacyCnValues = legacyTypeOrmSchema
        ? ", $1::integer, 'CN_TO_VI', $4, $5::jsonb, $6::varchar"
        : '';
      await client.query(
        `INSERT INTO quiz_questions
          (lesson_id, topic_id, vocabulary_id, question_type, question_text,
           options_json, correct_answer, explanation, difficulty, status${legacyCnColumns})
         VALUES ($1::bigint, $2, $3, 'CN_TO_VI', $4, $5::jsonb, $6::text, $7, $8, 'PUBLISHED'${legacyCnValues})
         ON CONFLICT (lesson_id, question_type, question_text) DO UPDATE SET
           options_json = EXCLUDED.options_json,
           correct_answer = EXCLUDED.correct_answer,
           explanation = EXCLUDED.explanation,
           difficulty = EXCLUDED.difficulty`,
        [
          quizLessonId,
          topicId,
          vocabularyId,
          `“${word.word}” có nghĩa là gì?`,
          JSON.stringify(viOptions),
          text(word.meaning),
          `Pinyin: ${text(word.pinyin)}.`,
          Math.min(level, 5),
        ],
      );
      const legacyViColumns = legacyTypeOrmSchema
        ? ', "lessonId", "questionType", "questionText", options, "correctAnswer"'
        : '';
      const legacyViValues = legacyTypeOrmSchema
        ? ", $1::integer, 'VI_TO_CN', $4, $5::jsonb, $6::varchar"
        : '';
      await client.query(
        `INSERT INTO quiz_questions
          (lesson_id, topic_id, vocabulary_id, question_type, question_text,
           options_json, correct_answer, explanation, difficulty, status${legacyViColumns})
         VALUES ($1::bigint, $2, $3, 'VI_TO_CN', $4, $5::jsonb, $6::text, $7, $8, 'PUBLISHED'${legacyViValues})
         ON CONFLICT (lesson_id, question_type, question_text) DO UPDATE SET
           options_json = EXCLUDED.options_json,
           correct_answer = EXCLUDED.correct_answer,
           explanation = EXCLUDED.explanation,
           difficulty = EXCLUDED.difficulty`,
        [
          quizLessonId,
          topicId,
          vocabularyId,
          `Từ tiếng Trung nào có nghĩa là “${word.meaning}”?`,
          JSON.stringify(cnOptions),
          text(word.word),
          `Đáp án ${word.word}, đọc là ${text(word.pinyin)}.`,
          Math.min(level, 5),
        ],
      );
    }
    void lessonId;
  }
}

async function seedGrammar(
  client: Client,
  levelIds: Map<number, number>,
): Promise<JsonObject[]> {
  const items: JsonObject[] = readJson(
    'apps/mobile/assets/data/grammar_hsk14.json',
  );
  for (const [order, item] of items.entries()) {
    const level = levelNumber(item.level);
    const lessonId = await seedLesson(client, levelIds, {
      code: `grammar_${item.id}`,
      level,
      title: item.title,
      type: 'GRAMMAR',
      description: item.explanation,
      content: { externalId: item.id },
      order,
    });
    await client.query(
      `INSERT INTO grammar_lessons
        (lesson_id, external_id, hsk_level, title, pattern_text, explanation,
         examples_json, note, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8, 'PUBLISHED')
       ON CONFLICT (external_id) DO UPDATE SET
         lesson_id = EXCLUDED.lesson_id,
         hsk_level = EXCLUDED.hsk_level,
         title = EXCLUDED.title,
         pattern_text = EXCLUDED.pattern_text,
         explanation = EXCLUDED.explanation,
         examples_json = EXCLUDED.examples_json,
         note = EXCLUDED.note,
         status = 'PUBLISHED',
         updated_at = NOW()`,
      [
        lessonId,
        item.id,
        level,
        item.title,
        item.pattern || null,
        item.explanation,
        JSON.stringify(item.examples || []),
        text(item.note) || null,
      ],
    );
  }
  return items;
}

async function seedReadingAndPronunciation(
  client: Client,
  levelIds: Map<number, number>,
) {
  const readings: JsonObject[] = readJson(
    'apps/mobile/assets/data/reading_hsk.json',
  );
  const news: JsonObject[] = readJson(
    'apps/mobile/assets/data/reading_news_seed.json',
  );
  const manualSourceId = await upsertReturningId(
    client,
    `INSERT INTO article_sources
      (name, source_type, source_url, default_hsk_level, active)
     VALUES ('VNChinese HSK Corpus', 'MANUAL', NULL, 1, TRUE)
     ON CONFLICT (name) DO UPDATE SET active = TRUE, updated_at = NOW()
     RETURNING id`,
    [],
  );
  const newsSourceId = await upsertReturningId(
    client,
    `INSERT INTO article_sources
      (name, source_type, source_url, default_hsk_level, active)
     VALUES ('VNChinese Easy News', 'MANUAL', NULL, 1, TRUE)
     ON CONFLICT (name) DO UPDATE SET active = TRUE, updated_at = NOW()
     RETURNING id`,
    [],
  );

  const pronunciationLessonIds = new Map<number, number>();
  for (let level = 1; level <= 4; level += 1) {
    await seedLesson(client, levelIds, {
      code: `reading_hsk${level}`,
      level,
      title: `Đọc hiểu HSK ${level}`,
      type: 'READING',
      description: `Luyện đọc các câu và bài ngắn phù hợp HSK ${level}.`,
      order: level,
    });
    pronunciationLessonIds.set(
      level,
      await seedLesson(client, levelIds, {
        code: `pronunciation_hsk${level}`,
        level,
        title: `Phát âm HSK ${level}`,
        type: 'PRONUNCIATION',
        description: `Nghe, đọc và đối chiếu phát âm các câu HSK ${level}.`,
        order: level,
      }),
    );
  }

  for (const [order, item] of readings.entries()) {
    const level = levelNumber(item.level);
    await client.query(
      `INSERT INTO articles
        (external_id, source_id, title, title_vi, summary_vi, content,
         sentences_json, hsk_level, status)
       VALUES ($1, $2, $3::varchar, $4, $5, $3::text, $6::jsonb, $7, 'PUBLISHED')
       ON CONFLICT (external_id) DO UPDATE SET
         source_id = EXCLUDED.source_id,
         title = EXCLUDED.title,
         title_vi = EXCLUDED.title_vi,
         summary_vi = EXCLUDED.summary_vi,
         content = EXCLUDED.content,
         sentences_json = EXCLUDED.sentences_json,
         hsk_level = EXCLUDED.hsk_level,
         status = 'PUBLISHED',
         updated_at = NOW()`,
      [
        item.id,
        manualSourceId,
        item.cn,
        item.vi || null,
        item.topic || null,
        JSON.stringify([{ cn: item.cn, py: item.py, vi: item.vi }]),
        level,
      ],
    );
    await client.query(
      `INSERT INTO pronunciation_sentences
        (lesson_id, external_id, hsk_level, topic, sentence_cn,
         sentence_pinyin, sentence_vi, difficulty, display_order, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'PUBLISHED')
       ON CONFLICT (external_id) DO UPDATE SET
         lesson_id = EXCLUDED.lesson_id,
         hsk_level = EXCLUDED.hsk_level,
         topic = EXCLUDED.topic,
         sentence_cn = EXCLUDED.sentence_cn,
         sentence_pinyin = EXCLUDED.sentence_pinyin,
         sentence_vi = EXCLUDED.sentence_vi,
         difficulty = EXCLUDED.difficulty,
         display_order = EXCLUDED.display_order,
         status = 'PUBLISHED'`,
      [
        pronunciationLessonIds.get(level),
        `pron_${item.id}`,
        level,
        item.topic || null,
        item.cn,
        item.py || null,
        item.vi || null,
        Math.min(level, 5),
        order,
      ],
    );
  }

  for (const item of news) {
    const level = levelNumber(item.level);
    await client.query(
      `INSERT INTO articles
        (external_id, source_id, title, title_vi, summary_vi, content,
         sentences_json, hsk_level, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8, 'PUBLISHED')
       ON CONFLICT (external_id) DO UPDATE SET
         source_id = EXCLUDED.source_id,
         title = EXCLUDED.title,
         title_vi = EXCLUDED.title_vi,
         summary_vi = EXCLUDED.summary_vi,
         content = EXCLUDED.content,
         sentences_json = EXCLUDED.sentences_json,
         hsk_level = EXCLUDED.hsk_level,
         status = 'PUBLISHED',
         updated_at = NOW()`,
      [
        item.id,
        newsSourceId,
        item.title,
        item.titleVi || null,
        item.summaryVi || null,
        item.content,
        JSON.stringify(item.sentences || []),
        level,
      ],
    );
  }
  return { readings, news };
}

async function seedVideos(
  client: Client,
  levelIds: Map<number, number>,
): Promise<JsonObject[]> {
  const videos: JsonObject[] = readJson(
    'apps/mobile/assets/data/video_lessons.json',
  );
  for (const [videoOrder, video] of videos.entries()) {
    const level = levelNumber(video.level);
    const lessonId = await seedLesson(client, levelIds, {
      code: `video_${video.id}`,
      level,
      title: video.title,
      titleCn: video.titleCn,
      type: 'VIDEO',
      description: `Video ${video.source || ''} kèm phụ đề Trung - Pinyin - Việt.`,
      content: {
        externalId: video.id,
        youtubeId: video.youtubeId,
        source: video.source,
        transcriptStatus: video.transcriptStatus,
        transcriptSource: video.transcriptSource,
        reviewStatus: video.reviewStatus,
      },
      order: videoOrder,
    });
    for (const [lineNumber, line] of (video.subtitles || []).entries()) {
      await client.query(
        `INSERT INTO video_transcript_lines
          (lesson_id, line_number, start_seconds, end_seconds, sentence_cn,
           sentence_pinyin, sentence_vi)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         ON CONFLICT (lesson_id, line_number) DO UPDATE SET
           start_seconds = EXCLUDED.start_seconds,
           end_seconds = EXCLUDED.end_seconds,
           sentence_cn = EXCLUDED.sentence_cn,
           sentence_pinyin = EXCLUDED.sentence_pinyin,
           sentence_vi = EXCLUDED.sentence_vi`,
        [
          lessonId,
          lineNumber,
          Number(line.start) || 0,
          Number(line.end) || 0,
          line.cn,
          line.py || null,
          line.vi || null,
        ],
      );
    }
  }
  return videos;
}

async function recordVersions(
  client: Client,
  datasets: Array<{ code: string; type: string; data: unknown; count: number }>,
) {
  for (const dataset of datasets) {
    await client.query(
      `INSERT INTO content_versions
        (version_code, content_type, description, source_checksum,
         item_count, status, published_at)
       VALUES ($1, $2, $3, $4, $5, 'PUBLISHED', NOW())
       ON CONFLICT (version_code) DO UPDATE SET
         description = EXCLUDED.description,
         source_checksum = EXCLUDED.source_checksum,
         item_count = EXCLUDED.item_count,
         status = 'PUBLISHED',
         published_at = NOW()`,
      [
        dataset.code,
        dataset.type,
        `Dữ liệu chuẩn được đồng bộ từ assets của ứng dụng VNChinese.`,
        checksum(dataset.data),
        dataset.count,
      ],
    );
  }
}

async function printCounts(client: Client) {
  const tables = [
    'course_levels',
    'lessons',
    'topics',
    'vocabularies',
    'topic_vocabularies',
    'vocabulary_examples',
    'grammar_lessons',
    'quiz_questions',
    'article_sources',
    'articles',
    'pronunciation_sentences',
    'video_transcript_lines',
    'content_versions',
  ];
  console.log('\nSeed summary');
  for (const table of tables) {
    const result = await client.query(`SELECT COUNT(*)::int AS count FROM ${table}`);
    console.log(`  ${table.padEnd(27)} ${result.rows[0].count}`);
  }
  console.log(
    '\nHistory tables remain empty until learners use the app: ' +
      'reading_sessions, practice_attempts, user_word_progress, ' +
      'daily_learning_stats, ai_interactions, admin_audit_logs.',
  );
}

async function main() {
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 5433),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASS || 'password',
    database: process.env.DB_NAME || 'chinese_app',
  });
  await client.connect();
  try {
    if (!process.argv.includes('--skip-schema')) await applySchema(client);
    const legacyResult = await client.query(
      `SELECT EXISTS (
         SELECT 1 FROM information_schema.columns
         WHERE table_schema = 'public'
           AND table_name = 'lessons'
           AND column_name = 'courseLevelId'
       ) AS legacy`,
    );
    legacyTypeOrmSchema = Boolean(legacyResult.rows[0].legacy);
    if (process.argv.includes('--schema-only')) return;

    await client.query('BEGIN');
    const levelIds = await seedLevels(client);
    console.log('Seeding HSK 1-4 dictionary and examples...');
    const dictionary = await seedDictionary(client);
    console.log('Seeding flashcard topics and generated quizzes...');
    await seedTopicsAndQuizzes(
      client,
      levelIds,
      dictionary.flashcardIndex,
      dictionary.vocabIds,
    );
    console.log('Seeding grammar lessons...');
    const grammar = await seedGrammar(client, levelIds);
    console.log('Seeding reading and pronunciation content...');
    const reading = await seedReadingAndPronunciation(client, levelIds);
    console.log('Seeding video lessons and transcript lines...');
    const videos = await seedVideos(client, levelIds);
    await recordVersions(client, [
      {
        code: 'dictionary-hsk14-v1',
        type: 'DICTIONARY',
        data: dictionary.compact,
        count: dictionary.vocabIds.size,
      },
      {
        code: 'flashcards-v1',
        type: 'FLASHCARD',
        data: dictionary.flashcardIndex,
        count: dictionary.flashcardIndex.topics.length,
      },
      {
        code: 'grammar-hsk14-v1',
        type: 'GRAMMAR',
        data: grammar,
        count: grammar.length,
      },
      {
        code: 'reading-hsk14-v1',
        type: 'READING',
        data: reading,
        count: reading.readings.length + reading.news.length,
      },
      {
        code: 'video-lessons-v1',
        type: 'VIDEO',
        data: videos,
        count: videos.length,
      },
    ]);
    await client.query('COMMIT');
    await printCounts(client);
  } catch (error) {
    await client.query('ROLLBACK').catch(() => undefined);
    throw error;
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error('seed:app-data failed:', error);
  process.exitCode = 1;
});
