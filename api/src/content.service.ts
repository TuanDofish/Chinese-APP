import { Injectable } from '@nestjs/common';
import { DataSource, QueryRunner } from 'typeorm';

export type ManagedContentBundle = {
  version: string;
  publishedAt: string;
  vocabulary: Record<string, any>[];
  flashcards: Record<string, any>[];
  pronunciation: Record<string, any>[];
  videos: Record<string, any>[];
  lessons: Record<string, any>[];
  readingSources: Record<string, any>[];
  grammar: Record<string, any>[];
  articles: Record<string, any>[];
  games: Record<string, any>[];
  aiSettings: Record<string, unknown>;
};

@Injectable()
export class ContentService {
  constructor(private readonly dataSource: DataSource) {}

  async getCatalog(publishedOnly = true): Promise<ManagedContentBundle> {
    const [
      version,
      vocabulary,
      flashcards,
      pronunciation,
      videos,
      lessons,
      readingSources,
      grammar,
      articles,
      metadata,
    ] = await Promise.all([
      this.getCurrentVersion(),
      this.getVocabulary(publishedOnly),
      this.getFlashcards(publishedOnly),
      this.getPronunciation(publishedOnly),
      this.getVideos(publishedOnly),
      this.getLessons(publishedOnly),
      this.getReadingSources(publishedOnly),
      this.getGrammar(publishedOnly),
      this.getArticles(publishedOnly),
      this.getPublishedMetadata(),
    ]);
    return {
      version: version?.version_code || 'database',
      publishedAt: version?.published_at || '',
      vocabulary,
      flashcards,
      pronunciation,
      videos,
      lessons,
      readingSources,
      grammar,
      articles,
      games: this.catalogGames(metadata, publishedOnly),
      aiSettings:
        metadata.aiSettings &&
        typeof metadata.aiSettings === 'object' &&
        !Array.isArray(metadata.aiSettings)
          ? metadata.aiSettings
          : {},
    };
  }

  async getVocabulary(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT id, simplified, pinyin, meaning_vi, hsk_level,
              COALESCE(part_of_speech, word_type, '') AS word_type,
              LOWER(COALESCE(status::text, 'PUBLISHED')) AS status
       FROM vocabularies
       WHERE meaning_vi IS NOT NULL
         AND BTRIM(meaning_vi) <> ''
         AND hsk_level BETWEEN 1 AND 6
         AND ($1::boolean = FALSE OR status = 'PUBLISHED')
       ORDER BY hsk_level, simplified
       LIMIT 5000`,
      [publishedOnly],
    );
    return rows.map((row: any) => ({
      id: row.id,
      simplified: row.simplified,
      pinyin: row.pinyin || '',
      meaningVi: row.meaning_vi || '',
      hsk: `HSK ${row.hsk_level}`,
      type: row.word_type || '',
      status: row.status,
    }));
  }

  async getFlashcards(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT t.id AS topic_pk, t.code, t.name, t.name_cn, t.hsk_level,
              t.color_hex, t.image_path AS topic_image_path,
              LOWER(t.status::text) AS topic_status,
              v.id AS vocabulary_id, v.simplified, v.pinyin, v.meaning_vi,
              tv.image_path, tv.display_order,
              COALESCE((
                SELECT JSONB_AGG(
                  JSONB_BUILD_OBJECT(
                    'cn', ve.example_cn,
                    'py', COALESCE(ve.example_pinyin, ''),
                    'vi', COALESCE(ve.example_vi, '')
                  )
                  ORDER BY ve.display_order, ve.id
                )
                FROM vocabulary_examples ve
                WHERE ve.vocabulary_id = v.id
              ), '[]'::JSONB) AS examples
       FROM topics t
       LEFT JOIN topic_vocabularies tv ON tv.topic_id = t.id
       LEFT JOIN vocabularies v ON v.id = tv.vocabulary_id
       WHERE ($1::boolean = FALSE OR t.status = 'PUBLISHED')
       ORDER BY t.display_order, t.id, tv.display_order, v.id`,
      [publishedOnly],
    );
    const topics = new Map<string, Record<string, any>>();
    for (const row of rows) {
      let topic = topics.get(row.code);
      if (!topic) {
        topic = {
          id: row.code,
          name: row.name,
          nameCn: row.name_cn || '',
          level: `HSK ${row.hsk_level}`,
          color: row.color_hex || '',
          status: row.topic_status,
          imagePath: row.topic_image_path || '',
          words: [],
        };
        topics.set(row.code, topic);
      }
      if (!row.vocabulary_id) continue;
      topic.words.push({
        id: row.vocabulary_id,
        word: row.simplified,
        pinyin: row.pinyin || '',
        meaning: row.meaning_vi || '',
        image: this.fileName(row.image_path),
        imagePath: row.image_path || '',
        examples: Array.isArray(row.examples) ? row.examples : [],
      });
    }
    return [...topics.values()];
  }

  async getVideos(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT l.id, l.code, l.title, l.title_cn, l.content_json,
              cl.level_number, LOWER(l.status::text) AS status,
              vtl.line_number, vtl.start_seconds, vtl.end_seconds,
              vtl.sentence_cn, vtl.sentence_pinyin, vtl.sentence_vi
       FROM lessons l
       JOIN course_levels cl ON cl.id = l.course_level_id
       LEFT JOIN video_transcript_lines vtl ON vtl.lesson_id = l.id
       WHERE l.lesson_type = 'VIDEO'
         AND ($1::boolean = FALSE OR l.status = 'PUBLISHED')
       ORDER BY l.display_order, l.id, vtl.line_number`,
      [publishedOnly],
    );
    const videos = new Map<number, Record<string, any>>();
    for (const row of rows) {
      let video = videos.get(row.id);
      if (!video) {
        const meta = this.objectValue(row.content_json);
        video = {
          id: meta.externalId || String(row.code).replace(/^video_/, ''),
          lessonId: row.id,
          title: row.title,
          titleCn: row.title_cn || '',
          level: `HSK ${row.level_number}`,
          youtubeId: meta.youtubeId || '',
          source: meta.source || 'YouTube',
          transcriptStatus: meta.transcriptStatus || 'timed',
          transcriptSource: meta.transcriptSource || '',
          reviewStatus: meta.reviewStatus || '',
          status: row.status,
          subtitles: [],
        };
        videos.set(row.id, video);
      }
      if (row.line_number === null) continue;
      video.subtitles.push({
        start: Number(row.start_seconds || 0),
        end: Number(row.end_seconds || 0),
        cn: row.sentence_cn,
        py: row.sentence_pinyin || '',
        vi: row.sentence_vi || '',
      });
    }
    return [...videos.values()];
  }

  async getPronunciation(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT ps.id, ps.external_id, ps.hsk_level, ps.topic,
              ps.sentence_cn, ps.sentence_pinyin, ps.sentence_vi,
              LOWER(ps.status::text) AS status
       FROM pronunciation_sentences ps
       WHERE ($1::boolean = FALSE OR ps.status = 'PUBLISHED')
       ORDER BY ps.hsk_level, ps.display_order, ps.id`,
      [publishedOnly],
    );
    return rows.map((row: any) => ({
      id: row.external_id || String(row.id),
      databaseId: row.id,
      level: `HSK ${row.hsk_level}`,
      topic: row.topic || 'Giao tiếp hằng ngày',
      cn: row.sentence_cn,
      py: row.sentence_pinyin || '',
      vi: row.sentence_vi || '',
      status: row.status,
    }));
  }

  async getGrammar(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT id, external_id, hsk_level, title, pattern_text, explanation,
              examples_json, note, LOWER(status::text) AS status
       FROM grammar_lessons
       WHERE ($1::boolean = FALSE OR status = 'PUBLISHED')
       ORDER BY hsk_level, id`,
      [publishedOnly],
    );
    return rows.map((row: any) => ({
      id: row.external_id || String(row.id),
      databaseId: row.id,
      level: `HSK ${row.hsk_level}`,
      title: row.title,
      pattern: row.pattern_text || row.title,
      explanation: row.explanation,
      examples: Array.isArray(row.examples_json) ? row.examples_json : [],
      note: row.note || '',
      status: row.status,
    }));
  }

  async getReadingSources(activeOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT id, name, source_type, source_url, default_hsk_level, active
       FROM article_sources
       WHERE ($1::boolean = FALSE OR active = TRUE)
       ORDER BY name`,
      [activeOnly],
    );
    return rows.map((row: any) => ({
      id: String(row.id),
      name: row.name,
      type: String(row.source_type || 'MANUAL').toLowerCase(),
      url: row.source_url || '',
      level: `HSK ${row.default_hsk_level || 4}`,
      status: row.active ? 'active' : 'archived',
    }));
  }

  async getArticles(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT a.id, a.external_id, a.title, a.title_vi, a.summary_vi,
              a.content, a.sentences_json, a.link, a.hsk_level,
              a.published_at, LOWER(a.status::text) AS status,
              COALESCE(s.name, a.source, 'VNChinese') AS source
       FROM articles a
       LEFT JOIN article_sources s ON s.id = a.source_id
       WHERE ($1::boolean = FALSE OR a.status = 'PUBLISHED')
       ORDER BY a.hsk_level, a.id`,
      [publishedOnly],
    );
    return rows.map((row: any) => ({
      id: row.external_id || String(row.id),
      databaseId: row.id,
      level: this.levelLabel(row.hsk_level),
      source: row.source,
      title: row.title,
      titleVi: row.title_vi || '',
      summaryVi: row.summary_vi || '',
      content: row.content,
      sentences: Array.isArray(row.sentences_json) ? row.sentences_json : [],
      link: row.link || '',
      publishedAt: row.published_at || '',
      status: row.status,
    }));
  }

  async getLessons(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT l.id, l.code, l.title, l.title_cn, l.lesson_type,
              l.content_json, l.display_order, LOWER(l.status::text) AS status,
              cl.level_number,
              CASE
                WHEN l.lesson_type = 'VIDEO' THEN
                  (SELECT COUNT(*) FROM video_transcript_lines x WHERE x.lesson_id = l.id)
                WHEN l.lesson_type = 'QUIZ' THEN
                  (SELECT COUNT(*) FROM quiz_questions x WHERE x.lesson_id = l.id)
                ELSE 1
              END::int AS items
       FROM lessons l
       JOIN course_levels cl ON cl.id = l.course_level_id
       WHERE ($1::boolean = FALSE OR l.status = 'PUBLISHED')
       ORDER BY cl.level_number, l.display_order, l.id`,
      [publishedOnly],
    );
    return rows.map((row: any) => {
      const metadata = this.objectValue(row.content_json);
      return {
        id: row.id,
        code: row.code,
        type: this.lessonTypeLabel(row.lesson_type),
        lessonType: row.lesson_type,
        title: row.title,
        titleCn: row.title_cn || '',
        level: `HSK ${row.level_number}`,
        items: Number(row.items || 0),
        status: row.status,
        youtubeId: metadata.youtubeId || '',
        source: metadata.source || '',
        transcriptStatus: metadata.transcriptStatus || '',
      };
    });
  }

  async getGames() {
    const metadata = await this.getPublishedMetadata();
    return this.catalogGames(metadata, true);
  }

  private catalogGames(metadata: Record<string, any>, publishedOnly: boolean) {
    if (Array.isArray(metadata.games) && metadata.games.length) {
      return metadata.games.filter(
        (game: any) =>
          !publishedOnly ||
          String(game?.status || 'published').toLowerCase() === 'published',
      );
    }
    return [
      {
        id: 'flashcard_quiz',
        title: 'Quiz nghĩa từ',
        type: 'multiple_choice',
        level: 'HSK 1-4',
        source: 'Flashcard đã published',
        scope: 'Theo chủ đề flashcard',
        generation: 'auto',
        questionCount: 10,
        status: 'published',
      },
      {
        id: 'listening_pick_word',
        title: 'Nghe và chọn từ',
        type: 'listening',
        level: 'HSK 1-4',
        source: 'Từ vựng đã published',
        scope: 'HSK 1-4',
        generation: 'auto',
        questionCount: 10,
        status: publishedOnly ? 'published' : 'draft',
      },
      {
        id: 'sentence_order',
        title: 'Xếp câu đúng',
        type: 'sentence_order',
        level: 'HSK 1-4',
        source: 'Ngữ pháp đã published',
        scope: 'Ngữ pháp',
        generation: 'auto',
        questionCount: 8,
        status: publishedOnly ? 'published' : 'draft',
      },
    ];
  }

  async getAuditLogs(limit = 50) {
    const safeLimit = Math.max(1, Math.min(200, Math.round(limit)));
    const rows = await this.dataSource.query(
      `SELECT aal.id, aal.action, aal.entity_type, aal.entity_id,
              aal.change_data, aal.created_at,
              COALESCE(u.display_name, u."displayName", u.email, 'System') AS admin_name
       FROM admin_audit_logs aal
       LEFT JOIN users u ON u.id = aal.admin_id
       ORDER BY aal.created_at DESC, aal.id DESC
       LIMIT $1`,
      [safeLimit],
    );
    return rows.map((row: any) => ({
      id: row.id,
      action: row.action,
      entityType: row.entity_type,
      entityId: row.entity_id,
      changeData: this.objectValue(row.change_data),
      adminName: row.admin_name,
      createdAt: row.created_at,
    }));
  }

  async publish(
    input: Partial<ManagedContentBundle>,
    adminId: number,
  ): Promise<Record<string, any>> {
    const runner = this.dataSource.createQueryRunner();
    await runner.connect();
    await runner.startTransaction();
    try {
      const counts = {
        vocabulary: await this.publishVocabulary(
          runner,
          this.arrayValue(input.vocabulary),
        ),
        flashcards: await this.publishFlashcards(
          runner,
          this.arrayValue(input.flashcards),
        ),
        pronunciation: await this.publishPronunciation(
          runner,
          this.arrayValue(input.pronunciation),
        ),
        videos: await this.publishVideos(runner, this.arrayValue(input.videos)),
        lessons: await this.publishLessons(
          runner,
          this.arrayValue(input.lessons),
        ),
        readingSources: await this.publishReadingSources(
          runner,
          this.arrayValue(input.readingSources),
        ),
        grammar: await this.publishGrammar(
          runner,
          this.arrayValue(input.grammar),
        ),
        articles: await this.publishArticles(
          runner,
          this.arrayValue(input.articles),
        ),
        games: this.arrayValue(input.games).length,
      };
      const version =
        String(input.version || '').trim() ||
        `admin-${new Date().toISOString().replace(/[:.]/g, '-')}`;
      const published = await runner.query(
        `INSERT INTO content_versions
          (version_code, content_type, description, item_count, status,
           published_by, published_at, metadata)
         VALUES ($1, 'CATALOG', $2, $3, 'PUBLISHED', $4, NOW(), $5::jsonb)
         ON CONFLICT (version_code) DO UPDATE SET
           description = EXCLUDED.description,
           item_count = EXCLUDED.item_count,
           status = 'PUBLISHED',
           published_by = EXCLUDED.published_by,
           published_at = NOW(),
           metadata = EXCLUDED.metadata
         RETURNING version_code, published_at`,
        [
          version,
          'Xuất bản từ VNChinese Admin vào PostgreSQL.',
          Object.values(counts).reduce((sum, value) => sum + value, 0),
          adminId,
          JSON.stringify({
            games: this.arrayValue(input.games),
            aiSettings: this.objectValue(input.aiSettings),
          }),
        ],
      );
      await this.audit(runner, adminId, 'PUBLISH', 'content_catalog', version, {
        counts,
      });
      await runner.commitTransaction();
      return {
        ok: true,
        version: published[0].version_code,
        publishedAt: published[0].published_at,
        counts,
      };
    } catch (error) {
      await runner.rollbackTransaction();
      throw error;
    } finally {
      await runner.release();
    }
  }

  private async publishVocabulary(
    runner: QueryRunner,
    items: Record<string, any>[],
  ) {
    let count = 0;
    for (const item of items) {
      const simplified = String(item.simplified || item.word || '').trim();
      if (!simplified) continue;
      const level = this.levelNumber(item.hsk || item.level || item.hskLevel);
      const status = this.contentStatus(item.status);
      await runner.query(
        `INSERT INTO vocabularies
          (simplified, pinyin, meaning_vi, hsk_level, word_type,
           part_of_speech, status, updated_at)
         VALUES ($1, $2, $3, $4, $5, $5, $6::content_status, NOW())
         ON CONFLICT (simplified) DO UPDATE SET
           pinyin = EXCLUDED.pinyin,
           meaning_vi = EXCLUDED.meaning_vi,
           hsk_level = EXCLUDED.hsk_level,
           word_type = EXCLUDED.word_type,
           part_of_speech = EXCLUDED.part_of_speech,
           status = EXCLUDED.status,
           updated_at = NOW()`,
        [
          simplified,
          String(item.pinyin || '').trim() || null,
          String(item.meaningVi || item.meaning || '').trim() || null,
          level,
          String(item.type || item.wordType || '').trim() || null,
          status,
        ],
      );
      count += 1;
    }
    return count;
  }

  private async publishFlashcards(
    runner: QueryRunner,
    topics: Record<string, any>[],
  ) {
    let count = 0;
    for (const [topicOrder, topic] of topics.entries()) {
      const code = String(topic.id || topic.code || '').trim();
      if (!code) continue;
      const level = this.levelNumber(topic.level || topic.hsk);
      const status = this.contentStatus(topic.status);
      const topicRows = await runner.query(
        `INSERT INTO topics
          (code, name, name_cn, hsk_level, color_hex, image_path,
           display_order, status, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8::content_status, NOW())
         ON CONFLICT (code) DO UPDATE SET
           name = EXCLUDED.name,
           name_cn = EXCLUDED.name_cn,
           hsk_level = EXCLUDED.hsk_level,
           color_hex = EXCLUDED.color_hex,
           image_path = EXCLUDED.image_path,
           display_order = EXCLUDED.display_order,
           status = EXCLUDED.status,
           updated_at = NOW()
         RETURNING id`,
        [
          code,
          String(topic.name || code).trim(),
          String(topic.nameCn || '').trim() || null,
          level,
          String(topic.color || '').trim() || null,
          String(topic.imagePath || '').trim() || null,
          topicOrder,
          status,
        ],
      );
      const topicId = Number(topicRows[0].id);
      await runner.query('DELETE FROM topic_vocabularies WHERE topic_id = $1', [
        topicId,
      ]);
      for (const [wordOrder, word] of this.arrayValue(topic.words).entries()) {
        const simplified = String(word.word || word.simplified || '').trim();
        if (!simplified) continue;
        const vocabRows = await runner.query(
          `INSERT INTO vocabularies
            (simplified, pinyin, meaning_vi, hsk_level, status, updated_at)
           VALUES ($1, $2, $3, $4, 'PUBLISHED', NOW())
           ON CONFLICT (simplified) DO UPDATE SET
             pinyin = COALESCE(NULLIF(EXCLUDED.pinyin, ''), vocabularies.pinyin),
             meaning_vi = COALESCE(NULLIF(EXCLUDED.meaning_vi, ''), vocabularies.meaning_vi),
             hsk_level = EXCLUDED.hsk_level,
             updated_at = NOW()
           RETURNING id`,
          [
            simplified,
            String(word.pinyin || '').trim(),
            String(word.meaning || word.meaningVi || '').trim(),
            level,
          ],
        );
        const vocabularyId = Number(vocabRows[0].id);
        const imagePath =
          String(word.imagePath || '').trim() ||
          (word.image
            ? `assets/images/flashcards/${code}/${this.fileName(word.image)}`
            : null);
        await runner.query(
          `INSERT INTO topic_vocabularies
            (topic_id, vocabulary_id, image_path, display_order)
           VALUES ($1, $2, $3, $4)`,
          [topicId, vocabularyId, imagePath, wordOrder],
        );
        for (const [exampleOrder, example] of this.arrayValue(
          word.examples,
        ).entries()) {
          const cn = String(example.cn || '').trim();
          if (!cn) continue;
          await runner.query(
            `INSERT INTO vocabulary_examples
              (vocabulary_id, example_cn, example_pinyin, example_vi,
               source, display_order)
             VALUES ($1, $2, $3, $4, 'admin', $5)
             ON CONFLICT (vocabulary_id, example_cn) DO UPDATE SET
               example_pinyin = EXCLUDED.example_pinyin,
               example_vi = EXCLUDED.example_vi,
               source = 'admin',
               display_order = EXCLUDED.display_order`,
            [
              vocabularyId,
              cn,
              String(example.py || '').trim() || null,
              String(example.vi || '').trim() || null,
              exampleOrder,
            ],
          );
        }
      }
      count += 1;
    }
    return count;
  }

  private async publishPronunciation(
    runner: QueryRunner,
    items: Record<string, any>[],
  ) {
    let count = 0;
    for (const [order, item] of items.entries()) {
      const cn = String(item.cn || item.sentenceCn || '').trim();
      if (!cn) continue;
      const level = this.levelNumber(item.level);
      const lessonId = await this.ensureLesson(
        runner,
        `pronunciation_hsk${level}`,
        level,
        `Phát âm HSK ${level}`,
        'PRONUNCIATION',
      );
      const externalId =
        String(item.id || '').trim() ||
        `admin_pron_${level}_${Buffer.from(cn).toString('base64url').slice(0, 16)}`;
      await runner.query(
        `INSERT INTO pronunciation_sentences
          (lesson_id, external_id, hsk_level, topic, sentence_cn,
           sentence_pinyin, sentence_vi, difficulty, display_order, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $3, $8, $9::content_status)
         ON CONFLICT (external_id) DO UPDATE SET
           lesson_id = EXCLUDED.lesson_id,
           hsk_level = EXCLUDED.hsk_level,
           topic = EXCLUDED.topic,
           sentence_cn = EXCLUDED.sentence_cn,
           sentence_pinyin = EXCLUDED.sentence_pinyin,
           sentence_vi = EXCLUDED.sentence_vi,
           display_order = EXCLUDED.display_order,
           status = EXCLUDED.status`,
        [
          lessonId,
          externalId,
          level,
          String(item.topic || 'Giao tiếp hằng ngày').trim(),
          cn,
          String(item.py || item.pinyin || '').trim() || null,
          String(item.vi || item.meaningVi || '').trim() || null,
          order,
          this.contentStatus(item.status),
        ],
      );
      count += 1;
    }
    return count;
  }

  private async publishVideos(
    runner: QueryRunner,
    videos: Record<string, any>[],
  ) {
    let count = 0;
    for (const [order, video] of videos.entries()) {
      const externalId = String(video.id || '').trim();
      const youtubeId = String(video.youtubeId || '').trim();
      const title = String(video.title || '').trim();
      if (!externalId || !title) continue;
      const level = this.levelNumber(video.level);
      const lessonId = await this.ensureLesson(
        runner,
        `video_${externalId}`,
        level,
        title,
        'VIDEO',
        {
          externalId,
          youtubeId,
          source: video.source || 'YouTube',
          transcriptStatus: video.transcriptStatus || 'untimed',
          transcriptSource: video.transcriptSource || 'admin',
          reviewStatus: video.reviewStatus || '',
        },
        order,
        video.titleCn,
        video.status,
      );
      await runner.query(
        'DELETE FROM video_transcript_lines WHERE lesson_id = $1',
        [lessonId],
      );
      for (const [lineNumber, line] of this.arrayValue(
        video.subtitles || video.transcript,
      ).entries()) {
        const cn = String(line.cn || '').trim();
        if (!cn) continue;
        await runner.query(
          `INSERT INTO video_transcript_lines
            (lesson_id, line_number, start_seconds, end_seconds,
             sentence_cn, sentence_pinyin, sentence_vi)
           VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [
            lessonId,
            lineNumber,
            Number(line.start || 0),
            Number(line.end || 0),
            cn,
            String(line.py || '').trim() || null,
            String(line.vi || '').trim() || null,
          ],
        );
      }
      count += 1;
    }
    return count;
  }

  private async publishLessons(
    runner: QueryRunner,
    lessons: Record<string, any>[],
  ) {
    let count = 0;
    for (const [order, lesson] of lessons.entries()) {
      const title = String(lesson.title || '').trim();
      if (!title || this.lessonType(lesson) === 'VIDEO') continue;
      const type = this.lessonType(lesson);
      const level = this.levelNumber(lesson.level);
      const code =
        String(lesson.code || '').trim() ||
        `admin_${type.toLowerCase()}_${String(lesson.id || order)}`;
      await this.ensureLesson(
        runner,
        code,
        level,
        title,
        type,
        { adminItems: Number(lesson.items || 0) },
        order,
        lesson.titleCn,
        lesson.status,
      );
      count += 1;
    }
    return count;
  }

  private async publishReadingSources(
    runner: QueryRunner,
    sources: Record<string, any>[],
  ) {
    let count = 0;
    for (const source of sources) {
      const name = String(source.name || '').trim();
      if (!name) continue;
      await runner.query(
        `INSERT INTO article_sources
          (name, source_type, source_url, default_hsk_level, active, updated_at)
         VALUES ($1, $2::article_source_type, $3, $4, $5, NOW())
         ON CONFLICT (name) DO UPDATE SET
           source_type = EXCLUDED.source_type,
           source_url = EXCLUDED.source_url,
           default_hsk_level = EXCLUDED.default_hsk_level,
           active = EXCLUDED.active,
           updated_at = NOW()`,
        [
          name,
          this.sourceType(source.type),
          String(source.url || '').trim() || null,
          this.levelNumber(source.level),
          String(source.status || 'active').toLowerCase() !== 'archived',
        ],
      );
      count += 1;
    }
    return count;
  }

  private async publishGrammar(
    runner: QueryRunner,
    items: Record<string, any>[],
  ) {
    let count = 0;
    for (const [order, item] of items.entries()) {
      const title = String(item.title || '').trim();
      const explanation = String(item.explanation || '').trim();
      if (!title || !explanation) continue;
      const level = this.levelNumber(item.level || item.hskLevel);
      const externalId =
        String(item.id || item.externalId || '').trim() ||
        `admin_grammar_${level}_${order}`;
      const lessonId = await this.ensureLesson(
        runner,
        `grammar_${externalId}`,
        level,
        title,
        'GRAMMAR',
        {},
        order,
        '',
        item.status,
      );
      await runner.query(
        `INSERT INTO grammar_lessons
          (lesson_id, external_id, hsk_level, title, pattern_text,
           explanation, examples_json, note, status, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8,
                 $9::content_status, NOW())
         ON CONFLICT (external_id) DO UPDATE SET
           lesson_id = EXCLUDED.lesson_id,
           hsk_level = EXCLUDED.hsk_level,
           title = EXCLUDED.title,
           pattern_text = EXCLUDED.pattern_text,
           explanation = EXCLUDED.explanation,
           examples_json = EXCLUDED.examples_json,
           note = EXCLUDED.note,
           status = EXCLUDED.status,
           updated_at = NOW()`,
        [
          lessonId,
          externalId,
          level,
          title,
          String(item.pattern || item.patternText || title).trim(),
          explanation,
          JSON.stringify(this.arrayValue(item.examples)),
          String(item.note || '').trim() || null,
          this.contentStatus(item.status),
        ],
      );
      count += 1;
    }
    return count;
  }

  private async publishArticles(
    runner: QueryRunner,
    items: Record<string, any>[],
  ) {
    let count = 0;
    for (const [order, item] of items.entries()) {
      const title = String(item.title || '').trim();
      const content = String(item.content || '').trim();
      if (!title || !content) continue;
      const sourceName = String(item.source || 'VNChinese').trim();
      const sourceRows = await runner.query(
        `INSERT INTO article_sources
          (name, source_type, default_hsk_level, active, updated_at)
         VALUES ($1, 'MANUAL', $2, TRUE, NOW())
         ON CONFLICT (name) DO UPDATE SET updated_at = NOW()
         RETURNING id`,
        [sourceName, this.levelNumber(item.level)],
      );
      const externalId =
        String(item.id || item.externalId || '').trim() ||
        `admin_article_${Date.now()}_${order}`;
      await runner.query(
        `INSERT INTO articles
          (external_id, source_id, source, title, title_vi, summary_vi,
           content, sentences_json, link, hsk_level, published_at,
           status, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8::jsonb, $9, $10,
                 COALESCE($11::timestamptz, NOW()), $12::content_status, NOW())
         ON CONFLICT (external_id) DO UPDATE SET
           source_id = EXCLUDED.source_id,
           source = EXCLUDED.source,
           title = EXCLUDED.title,
           title_vi = EXCLUDED.title_vi,
           summary_vi = EXCLUDED.summary_vi,
           content = EXCLUDED.content,
           sentences_json = EXCLUDED.sentences_json,
           link = EXCLUDED.link,
           hsk_level = EXCLUDED.hsk_level,
           published_at = EXCLUDED.published_at,
           status = EXCLUDED.status,
           updated_at = NOW()`,
        [
          externalId,
          Number(sourceRows[0].id),
          sourceName,
          title,
          String(item.titleVi || '').trim() || null,
          String(item.summaryVi || '').trim() || null,
          content,
          JSON.stringify(this.arrayValue(item.sentences)),
          String(item.link || '').trim() || null,
          this.levelNumber(item.level),
          String(item.publishedAt || '').trim() || null,
          this.contentStatus(item.status),
        ],
      );
      count += 1;
    }
    return count;
  }

  private async ensureLesson(
    runner: QueryRunner,
    code: string,
    level: number,
    title: string,
    type: string,
    metadata: Record<string, any> = {},
    order = 0,
    titleCn?: string,
    status?: string,
  ): Promise<number> {
    const levels = await runner.query(
      'SELECT id FROM course_levels WHERE level_number = $1 LIMIT 1',
      [level],
    );
    if (!levels.length) {
      throw new Error(`Không tìm thấy cấp độ HSK ${level}.`);
    }
    const levelId = Number(levels[0].id);
    const rows = await runner.query(
      `INSERT INTO lessons
        (course_level_id, "courseLevelId", code, title, title_cn,
         lesson_type, content_json, display_order, order_index, status,
         updated_at)
       VALUES ($1::bigint, $1::integer, $2, $3, $4, $5::lesson_type,
               $6::jsonb, $7, $7, $8::content_status, NOW())
       ON CONFLICT (code) DO UPDATE SET
         course_level_id = EXCLUDED.course_level_id,
         "courseLevelId" = EXCLUDED."courseLevelId",
         title = EXCLUDED.title,
         title_cn = EXCLUDED.title_cn,
         lesson_type = EXCLUDED.lesson_type,
         content_json = EXCLUDED.content_json,
         display_order = EXCLUDED.display_order,
         order_index = EXCLUDED.order_index,
         status = EXCLUDED.status,
         updated_at = NOW()
       RETURNING id`,
      [
        levelId,
        code,
        title,
        String(titleCn || '').trim() || null,
        type,
        JSON.stringify(metadata),
        order,
        this.contentStatus(status),
      ],
    );
    return Number(rows[0].id);
  }

  private async getCurrentVersion() {
    const rows = await this.dataSource.query(
      `SELECT version_code, published_at
       FROM content_versions
       WHERE status = 'PUBLISHED'
       ORDER BY published_at DESC NULLS LAST, id DESC
       LIMIT 1`,
    );
    return rows[0] || null;
  }

  private async getPublishedMetadata(): Promise<Record<string, any>> {
    const rows = await this.dataSource.query(
      `SELECT metadata
       FROM content_versions
       WHERE status = 'PUBLISHED'
       ORDER BY published_at DESC NULLS LAST, id DESC
       LIMIT 1`,
    );
    return this.objectValue(rows[0]?.metadata);
  }

  private async audit(
    runner: QueryRunner,
    adminId: number,
    action: string,
    entityType: string,
    entityId: string,
    changeData: Record<string, unknown>,
  ) {
    await runner.query(
      `INSERT INTO admin_audit_logs
        (admin_id, action, entity_type, entity_id, change_data)
       VALUES ($1, $2, $3, $4, $5::jsonb)`,
      [adminId, action, entityType, entityId, JSON.stringify(changeData)],
    );
  }

  private arrayValue(value: unknown): Record<string, any>[] {
    return Array.isArray(value)
      ? value.filter(
          (item): item is Record<string, any> =>
            Boolean(item) && typeof item === 'object' && !Array.isArray(item),
        )
      : [];
  }

  private objectValue(value: unknown): Record<string, any> {
    return value && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, any>)
      : {};
  }

  private levelNumber(value: unknown) {
    const match = String(value || '').match(/[1-6]/);
    return match ? Number(match[0]) : 1;
  }

  private levelLabel(value: unknown) {
    const raw = String(value || '').trim();
    return /^HSK\s*[1-6]$/i.test(raw)
      ? `HSK ${this.levelNumber(raw)}`
      : `HSK ${this.levelNumber(value)}`;
  }

  private contentStatus(value: unknown) {
    const status = String(value || 'published')
      .trim()
      .toUpperCase();
    return ['DRAFT', 'REVIEW', 'PUBLISHED', 'ARCHIVED'].includes(status)
      ? status
      : 'PUBLISHED';
  }

  private sourceType(value: unknown) {
    const type = String(value || 'MANUAL')
      .trim()
      .toUpperCase();
    return ['MANUAL', 'RSS', 'API'].includes(type) ? type : 'MANUAL';
  }

  private lessonType(lesson: Record<string, any>) {
    const raw = String(lesson.lessonType || lesson.type || '')
      .trim()
      .toUpperCase();
    const map: Record<string, string> = {
      'NGỮ PHÁP': 'GRAMMAR',
      'ĐỌC HIỂU': 'READING',
      'PHÁT ÂM': 'PRONUNCIATION',
      'TỪ VỰNG': 'VOCABULARY',
      VIDEO: 'VIDEO',
      QUIZ: 'QUIZ',
    };
    const type = map[raw] || raw;
    return [
      'VOCABULARY',
      'GRAMMAR',
      'READING',
      'PRONUNCIATION',
      'VIDEO',
      'QUIZ',
    ].includes(type)
      ? type
      : 'VOCABULARY';
  }

  private lessonTypeLabel(value: string) {
    return (
      {
        VOCABULARY: 'Từ vựng',
        GRAMMAR: 'Ngữ pháp',
        READING: 'Đọc hiểu',
        PRONUNCIATION: 'Phát âm',
        VIDEO: 'Video',
        QUIZ: 'Quiz',
      }[value] || value
    );
  }

  private fileName(value: unknown) {
    return (
      String(value || '')
        .split(/[\\/]/)
        .pop() || ''
    );
  }
}
