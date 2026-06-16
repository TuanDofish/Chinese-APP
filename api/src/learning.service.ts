import { BadRequestException, Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { AuthService } from './auth.service';

type WordProgressInput = {
  favorite?: boolean;
  learned?: boolean;
  correct?: boolean;
};

type AttemptInput = {
  lessonId?: number;
  type?: string;
  targetType?: string;
  targetId?: string;
  score?: number;
  correctCount?: number;
  totalCount?: number;
  durationSeconds?: number;
  result?: Record<string, unknown>;
};

@Injectable()
export class LearningService {
  constructor(
    private readonly dataSource: DataSource,
    private readonly authService: AuthService,
  ) {}

  async summary(token: string) {
    const user = await this.authService.requireUser(token);
    const [
      profileRows,
      wordRows,
      todayRows,
      aggregateRows,
      dailyRows,
      roadmapRows,
      recentRows,
      aiRows,
      readingRows,
      activeDateRows,
    ] = await Promise.all([
      this.dataSource.query(
        `SELECT id, COALESCE(display_name, "displayName", email) AS display_name,
                  COALESCE(target_hsk_level,
                    NULLIF(REGEXP_REPLACE("targetLevel", '\\D', '', 'g'), '')::smallint,
                    1) AS target_hsk_level,
                  COALESCE(daily_goal_words, 10) AS daily_goal_words,
                  COALESCE(daily_goal_minutes, 15) AS daily_goal_minutes,
                  reminder_time
           FROM users WHERE id = $1`,
        [user.id],
      ),
      this.dataSource.query(
        `SELECT v.simplified, uwp.is_favorite, uwp.mastery_level,
                  uwp.review_count, uwp.correct_count, uwp.next_review_at
           FROM user_word_progress uwp
           JOIN vocabularies v ON v.id = uwp.vocabulary_id
           WHERE uwp.user_id = $1
           ORDER BY uwp.updated_at DESC`,
        [user.id],
      ),
      this.dataSource.query(
        `SELECT *
           FROM daily_learning_stats
           WHERE user_id = $1 AND study_date = CURRENT_DATE`,
        [user.id],
      ),
      this.dataSource.query(
        `SELECT
             COUNT(*)::int AS attempts,
             COUNT(*) FILTER (WHERE attempt_type = 'QUIZ')::int AS quiz_attempts,
             COUNT(*) FILTER (WHERE attempt_type = 'PRONUNCIATION')::int AS pronunciation_attempts,
             COUNT(*) FILTER (WHERE attempt_type = 'READING')::int AS reading_attempts,
             COALESCE(SUM(correct_count), 0)::int AS correct_count,
             COALESCE(SUM(total_count), 0)::int AS total_count,
             COALESCE(SUM(duration_seconds), 0)::int AS duration_seconds,
             COALESCE(ROUND(AVG(score)), 0)::int AS average_score,
             COALESCE(ROUND(AVG(score) FILTER (
               WHERE attempt_type = 'QUIZ' AND target_type = 'GRAMMAR'
             )), 0)::int AS grammar_score,
             COALESCE(ROUND(AVG(score) FILTER (
               WHERE attempt_type = 'PRONUNCIATION'
             )), 0)::int AS speaking_score
           FROM practice_attempts
           WHERE user_id = $1`,
        [user.id],
      ),
      this.dataSource.query(
        `SELECT study_date, learned_words_count, reviewed_words_count,
                  lessons_completed_count, quiz_count, pronunciation_count,
                  reading_count, ai_interaction_count, study_seconds
           FROM daily_learning_stats
           WHERE user_id = $1
             AND study_date >= CURRENT_DATE - INTERVAL '6 days'
           ORDER BY study_date`,
        [user.id],
      ),
      this.dataSource.query(
        `SELECT v.hsk_level,
                  COUNT(*)::int AS total_words,
                  COUNT(*) FILTER (
                    WHERE COALESCE(uwp.mastery_level, 0) > 0
                  )::int AS learned_words,
                  COUNT(*) FILTER (
                    WHERE COALESCE(uwp.mastery_level, 0) >= 4
                  )::int AS mastered_words,
                  COUNT(*) FILTER (
                    WHERE COALESCE(uwp.mastery_level, 0) > 0
                      AND uwp.next_review_at <= NOW()
                  )::int AS due_review
           FROM vocabularies v
           LEFT JOIN user_word_progress uwp
             ON uwp.vocabulary_id = v.id AND uwp.user_id = $1
           WHERE v.status = 'PUBLISHED'
           GROUP BY v.hsk_level
           ORDER BY v.hsk_level`,
        [user.id],
      ),
      this.dataSource.query(
        `SELECT *
           FROM (
             SELECT pa.completed_at AS occurred_at,
                    pa.attempt_type::text AS activity_type,
                    pa.score,
                    COALESCE(pa.target_id, pa.target_type, '') AS detail
             FROM practice_attempts pa
             WHERE pa.user_id = $1
             UNION ALL
             SELECT rs.last_read_at AS occurred_at,
                    'READING_SESSION' AS activity_type,
                    NULL::numeric AS score,
                    a.title AS detail
             FROM reading_sessions rs
             JOIN articles a ON a.id = rs.article_id
             WHERE rs.user_id = $1
             UNION ALL
             SELECT uwp.updated_at AS occurred_at,
                    'VOCABULARY' AS activity_type,
                    (uwp.mastery_level * 20)::numeric AS score,
                    v.simplified AS detail
             FROM user_word_progress uwp
             JOIN vocabularies v ON v.id = uwp.vocabulary_id
             WHERE uwp.user_id = $1 AND uwp.mastery_level > 0
           ) activities
           ORDER BY occurred_at DESC
           LIMIT 8`,
        [user.id],
      ),
      this.dataSource.query(
        `SELECT
             COUNT(*) FILTER (
               WHERE interaction_type = 'GRAMMAR_CHECK' AND status = 'SUCCESS'
             )::int AS grammar_checks,
             COALESCE(ROUND(AVG(score) FILTER (
               WHERE interaction_type = 'GRAMMAR_CHECK' AND status = 'SUCCESS'
             )), 0)::int AS grammar_score
           FROM ai_interactions
           WHERE user_id = $1`,
        [user.id],
      ),
      this.dataSource.query(
        `SELECT COUNT(*)::int AS sessions,
                  COUNT(*) FILTER (WHERE completed)::int AS completed,
                  COALESCE(SUM(time_spent_seconds), 0)::int AS study_seconds
           FROM reading_sessions
           WHERE user_id = $1`,
        [user.id],
      ),
      this.dataSource.query(
        `SELECT study_date
           FROM daily_learning_stats
           WHERE user_id = $1
             AND (
               learned_words_count + reviewed_words_count +
               lessons_completed_count + quiz_count + pronunciation_count +
               reading_count + ai_interaction_count + study_seconds
             ) > 0
           ORDER BY study_date DESC
           LIMIT 366`,
        [user.id],
      ),
    ]);
    const profile = profileRows[0] || {};
    const today = todayRows[0] || {};
    const aggregate = aggregateRows[0] || {};
    const ai = aiRows[0] || {};
    const reading = readingRows[0] || {};
    const targetLevel = Number(profile.target_hsk_level || 1);
    const officialTotals = [150, 300, 600, 1200, 2500, 5000];
    const roadmapByLevel = new Map(
      roadmapRows.map((row: any) => [Number(row.hsk_level), row]),
    );
    const roadmap = officialTotals.map((officialTotal, index) => {
      const level = index + 1;
      const row: any = roadmapByLevel.get(level) || {};
      const totalWords = Math.max(officialTotal, Number(row.total_words || 0));
      const learnedWords = Number(row.learned_words || 0);
      return {
        level: `HSK ${level}`,
        totalWords,
        learnedWords,
        masteredWords: Number(row.mastered_words || 0),
        dueReview: Number(row.due_review || 0),
        progress:
          totalWords > 0 ? Number((learnedWords / totalWords).toFixed(4)) : 0,
      };
    });
    const dailyByDate = new Map(
      dailyRows.map((row: any) => [this.dateKey(row.study_date), row]),
    );
    const activity = Array.from({ length: 7 }, (_, offset) => {
      const date = new Date();
      date.setHours(0, 0, 0, 0);
      date.setDate(date.getDate() - (6 - offset));
      const dateKey = this.dateKey(date);
      const row: any = dailyByDate.get(dateKey) || {};
      return {
        date: dateKey,
        learnedWords: Number(row.learned_words_count || 0),
        reviewedWords: Number(row.reviewed_words_count || 0),
        lessons: Number(row.lessons_completed_count || 0),
        quizzes: Number(row.quiz_count || 0),
        pronunciation: Number(row.pronunciation_count || 0),
        reading: Number(row.reading_count || 0),
        aiInteractions: Number(row.ai_interaction_count || 0),
        studyMinutes: Math.round(Number(row.study_seconds || 0) / 60),
      };
    });
    const weekly = activity.reduce(
      (result, day) => {
        result.learnedWords += day.learnedWords;
        result.reviewedWords += day.reviewedWords;
        result.lessons += day.lessons;
        result.studyMinutes += day.studyMinutes;
        if (
          day.learnedWords +
            day.reviewedWords +
            day.lessons +
            day.quizzes +
            day.pronunciation +
            day.reading +
            day.aiInteractions +
            day.studyMinutes >
          0
        ) {
          result.activeDays += 1;
        }
        return result;
      },
      {
        learnedWords: 0,
        reviewedWords: 0,
        lessons: 0,
        studyMinutes: 0,
        activeDays: 0,
      },
    );
    const totalQuestions = Number(aggregate.total_count || 0);
    const accuracy =
      totalQuestions > 0
        ? Math.round(
            (Number(aggregate.correct_count || 0) / totalQuestions) * 100,
          )
        : Number(aggregate.average_score || 0);
    const targetRoadmap = roadmap[targetLevel - 1] || roadmap[0];
    const grammarScore =
      Number(ai.grammar_score || 0) || Number(aggregate.grammar_score || 0);
    const readingSessions = Number(reading.sessions || 0);
    const readingCompleted = Number(reading.completed || 0);
    return {
      profile: {
        id: user.id,
        displayName: profile.display_name || user.displayName,
        targetLevel: `HSK ${targetLevel}`,
        dailyGoalWords: Number(profile.daily_goal_words || 10),
        dailyGoalMinutes: Number(profile.daily_goal_minutes || 15),
        reminderTime: profile.reminder_time || null,
      },
      favoriteWords: wordRows
        .filter((row: any) => row.is_favorite)
        .map((row: any) => row.simplified),
      learnedWords: wordRows
        .filter((row: any) => Number(row.mastery_level) > 0)
        .map((row: any) => row.simplified),
      wordProgress: wordRows.map((row: any) => ({
        word: row.simplified,
        favorite: row.is_favorite,
        masteryLevel: Number(row.mastery_level || 0),
        reviewCount: Number(row.review_count || 0),
        correctCount: Number(row.correct_count || 0),
        nextReviewAt: row.next_review_at,
      })),
      today: {
        learnedWords: Number(today.learned_words_count || 0),
        reviewedWords: Number(today.reviewed_words_count || 0),
        lessonsCompleted: Number(today.lessons_completed_count || 0),
        quizzes: Number(today.quiz_count || 0),
        pronunciation: Number(today.pronunciation_count || 0),
        reading: Number(today.reading_count || 0),
        aiInteractions: Number(today.ai_interaction_count || 0),
        studySeconds: Number(today.study_seconds || 0),
        streak: this.calculateStreak(activeDateRows),
      },
      weekly,
      activity,
      roadmap,
      skills: {
        vocabulary:
          targetRoadmap.totalWords > 0
            ? Math.round(
                (targetRoadmap.learnedWords / targetRoadmap.totalWords) * 100,
              )
            : 0,
        grammar: grammarScore,
        listeningSpeaking: Number(aggregate.speaking_score || 0),
        reading:
          readingSessions > 0
            ? Math.round((readingCompleted / readingSessions) * 100)
            : 0,
      },
      recentActivities: recentRows.map((row: any) => this.formatActivity(row)),
      totals: {
        attempts: Number(aggregate.attempts || 0),
        quizAttempts: Number(aggregate.quiz_attempts || 0),
        pronunciationAttempts: Number(aggregate.pronunciation_attempts || 0),
        readingAttempts: Number(aggregate.reading_attempts || 0),
        grammarChecks: Number(ai.grammar_checks || 0),
        speakingScore: Number(aggregate.speaking_score || 0),
        accuracy,
        learnedWords: wordRows.filter(
          (row: any) => Number(row.mastery_level) > 0,
        ).length,
        masteredWords: wordRows.filter(
          (row: any) => Number(row.mastery_level) >= 4,
        ).length,
        dueReview: wordRows.filter(
          (row: any) =>
            Number(row.mastery_level) > 0 &&
            row.next_review_at &&
            new Date(row.next_review_at).getTime() <= Date.now(),
        ).length,
        studyMinutes: Math.round(
          (Number(aggregate.duration_seconds || 0) +
            Number(reading.study_seconds || 0)) /
            60,
        ),
      },
    };
  }

  async updateGoal(
    token: string,
    body: {
      level?: string;
      words?: number;
      minutes?: number;
      reminder?: string;
    },
  ) {
    const user = await this.authService.requireUser(token);
    const level = this.levelNumber(body.level);
    const words = this.integer(body.words, 1, 500, 10);
    const minutes = this.integer(body.minutes, 1, 1440, 15);
    const reminder = String(body.reminder || '').trim() || null;
    await this.dataSource.query(
      `UPDATE users SET
         target_hsk_level = $2,
         "targetLevel" = $3,
         daily_goal_words = $4,
         daily_goal_minutes = $5,
         reminder_time = COALESCE($6::time, reminder_time),
         updated_at = NOW()
       WHERE id = $1`,
      [user.id, level, `HSK ${level}`, words, minutes, reminder],
    );
    return this.summary(token);
  }

  async updateWord(token: string, word: string, body: WordProgressInput) {
    const user = await this.authService.requireUser(token);
    const rows = await this.dataSource.query(
      'SELECT id FROM vocabularies WHERE simplified = $1 LIMIT 1',
      [word.trim()],
    );
    if (!rows.length) {
      throw new BadRequestException('Từ này chưa có trong từ điển.');
    }
    const vocabularyId = Number(rows[0].id);
    const previous = await this.dataSource.query(
      `SELECT is_favorite, mastery_level
       FROM user_word_progress
       WHERE user_id = $1 AND vocabulary_id = $2`,
      [user.id, vocabularyId],
    );
    const oldMastery = Number(previous[0]?.mastery_level || 0);
    const favorite =
      body.favorite === undefined
        ? Boolean(previous[0]?.is_favorite)
        : Boolean(body.favorite);
    const learned = Boolean(body.learned);
    await this.dataSource.query(
      `INSERT INTO user_word_progress
        (user_id, vocabulary_id, is_favorite, mastery_level,
         review_count, correct_count, next_review_at, last_reviewed_at)
       VALUES ($1, $2, $3, $4, 1, $5, NOW() + INTERVAL '1 day', NOW())
       ON CONFLICT (user_id, vocabulary_id) DO UPDATE SET
         is_favorite = $3,
         mastery_level = GREATEST(user_word_progress.mastery_level, $4),
         review_count = user_word_progress.review_count + 1,
         correct_count = user_word_progress.correct_count + $5,
         next_review_at = CASE
           WHEN GREATEST(user_word_progress.mastery_level, $4) >= 4
             THEN NOW() + INTERVAL '14 days'
           WHEN GREATEST(user_word_progress.mastery_level, $4) >= 2
             THEN NOW() + INTERVAL '3 days'
           ELSE NOW() + INTERVAL '1 day'
         END,
         last_reviewed_at = NOW(),
         updated_at = NOW()`,
      [
        user.id,
        vocabularyId,
        favorite,
        learned ? Math.max(1, oldMastery) : oldMastery,
        body.correct === true ? 1 : 0,
      ],
    );
    if (learned && oldMastery === 0) {
      await this.incrementDaily(user.id, {
        learned_words_count: 1,
        study_seconds: 120,
      });
    } else {
      await this.incrementDaily(user.id, { reviewed_words_count: 1 });
    }
    return { ok: true, word, favorite, learned: learned || oldMastery > 0 };
  }

  async recordAttempt(token: string, body: AttemptInput) {
    const user = await this.authService.requireUser(token);
    const type = this.attemptType(body.type);
    const score = Math.max(0, Math.min(100, Number(body.score || 0)));
    const correctCount = Math.max(0, Number(body.correctCount || 0));
    const totalCount = Math.max(0, Number(body.totalCount || 0));
    const duration = Math.max(0, Number(body.durationSeconds || 0));
    const rows = await this.dataSource.query(
      `INSERT INTO practice_attempts
        (user_id, lesson_id, attempt_type, target_type, target_id, score,
         correct_count, total_count, duration_seconds, result_json)
       VALUES ($1, $2, $3::attempt_type, $4, $5, $6, $7, $8, $9, $10::jsonb)
       RETURNING id, completed_at`,
      [
        user.id,
        body.lessonId || null,
        type,
        String(body.targetType || '').trim() || null,
        String(body.targetId || '').trim() || null,
        score,
        correctCount,
        totalCount,
        duration,
        JSON.stringify(body.result || {}),
      ],
    );
    await this.incrementDaily(user.id, {
      quiz_count: type === 'QUIZ' ? 1 : 0,
      pronunciation_count: type === 'PRONUNCIATION' ? 1 : 0,
      reading_count: type === 'READING' ? 1 : 0,
      lessons_completed_count: 1,
      study_seconds: duration,
    });
    return { ok: true, id: rows[0].id, completedAt: rows[0].completed_at };
  }

  async recordReading(
    token: string,
    body: {
      articleId?: number;
      externalId?: string;
      seconds?: number;
      completed?: boolean;
      lookedUpWords?: unknown[];
    },
  ) {
    const user = await this.authService.requireUser(token);
    let articleId = Number(body.articleId || 0);
    if (!articleId && body.externalId) {
      const rows = await this.dataSource.query(
        'SELECT id FROM articles WHERE external_id = $1 LIMIT 1',
        [body.externalId],
      );
      articleId = Number(rows[0]?.id || 0);
    }
    if (!articleId) {
      throw new BadRequestException('Không tìm thấy bài đọc.');
    }
    const seconds = Math.max(0, Number(body.seconds || 0));
    await this.dataSource.query(
      `INSERT INTO reading_sessions
        (user_id, article_id, time_spent_seconds, looked_up_words_json,
         completed, last_read_at)
       VALUES ($1, $2, $3, $4::jsonb, $5, NOW())
       ON CONFLICT (user_id, article_id) DO UPDATE SET
         time_spent_seconds = reading_sessions.time_spent_seconds + $3,
         looked_up_words_json = EXCLUDED.looked_up_words_json,
         completed = reading_sessions.completed OR EXCLUDED.completed,
         last_read_at = NOW(),
         updated_at = NOW()`,
      [
        user.id,
        articleId,
        seconds,
        JSON.stringify(
          Array.isArray(body.lookedUpWords) ? body.lookedUpWords : [],
        ),
        Boolean(body.completed),
      ],
    );
    await this.incrementDaily(user.id, {
      reading_count: body.completed ? 1 : 0,
      study_seconds: seconds,
    });
    return { ok: true };
  }

  async addStudyTime(token: string, seconds: number) {
    const user = await this.authService.requireUser(token);
    await this.incrementDaily(user.id, {
      study_seconds: Math.max(0, Math.round(seconds)),
    });
    return { ok: true };
  }

  private async incrementDaily(userId: number, values: Record<string, number>) {
    const columns = [
      'learned_words_count',
      'reviewed_words_count',
      'lessons_completed_count',
      'quiz_count',
      'pronunciation_count',
      'reading_count',
      'ai_interaction_count',
      'study_seconds',
    ];
    const safe = Object.fromEntries(
      columns.map((column) => [column, Math.max(0, values[column] || 0)]),
    );
    await this.dataSource.query(
      `INSERT INTO daily_learning_stats
        (user_id, study_date, learned_words_count, reviewed_words_count,
         lessons_completed_count, quiz_count, pronunciation_count,
         reading_count, ai_interaction_count, study_seconds)
       VALUES ($1, CURRENT_DATE, $2, $3, $4, $5, $6, $7, $8, $9)
       ON CONFLICT (user_id, study_date) DO UPDATE SET
         learned_words_count = daily_learning_stats.learned_words_count + $2,
         reviewed_words_count = daily_learning_stats.reviewed_words_count + $3,
         lessons_completed_count = daily_learning_stats.lessons_completed_count + $4,
         quiz_count = daily_learning_stats.quiz_count + $5,
         pronunciation_count = daily_learning_stats.pronunciation_count + $6,
         reading_count = daily_learning_stats.reading_count + $7,
         ai_interaction_count = daily_learning_stats.ai_interaction_count + $8,
         study_seconds = daily_learning_stats.study_seconds + $9,
         updated_at = NOW()`,
      [
        userId,
        safe.learned_words_count,
        safe.reviewed_words_count,
        safe.lessons_completed_count,
        safe.quiz_count,
        safe.pronunciation_count,
        safe.reading_count,
        safe.ai_interaction_count,
        safe.study_seconds,
      ],
    );
  }

  private levelNumber(value: unknown) {
    const match = String(value || '').match(/[1-6]/);
    return match ? Number(match[0]) : 1;
  }

  private integer(
    value: unknown,
    minimum: number,
    maximum: number,
    fallback: number,
  ) {
    const number = Number(value);
    return Number.isFinite(number)
      ? Math.max(minimum, Math.min(maximum, Math.round(number)))
      : fallback;
  }

  private attemptType(value: unknown) {
    const type = String(value || 'QUIZ')
      .trim()
      .toUpperCase();
    return ['QUIZ', 'PRONUNCIATION', 'READING', 'VIDEO_SHADOWING'].includes(
      type,
    )
      ? type
      : 'QUIZ';
  }

  private dateKey(value: unknown) {
    if (value instanceof Date) return value.toISOString().slice(0, 10);
    return String(value || '').slice(0, 10);
  }

  private calculateStreak(rows: Array<{ study_date: unknown }>) {
    if (!rows.length) return 0;
    const dates = rows
      .map((row) => this.dateKey(row.study_date))
      .filter(Boolean)
      .map((value) => new Date(`${value}T00:00:00`));
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const latest = dates[0];
    const firstGap = Math.round(
      (today.getTime() - latest.getTime()) / 86400000,
    );
    if (firstGap > 1) return 0;
    let streak = 1;
    for (let index = 1; index < dates.length; index += 1) {
      const difference = Math.round(
        (dates[index - 1].getTime() - dates[index].getTime()) / 86400000,
      );
      if (difference !== 1) break;
      streak += 1;
    }
    return streak;
  }

  private formatActivity(row: any) {
    const type = String(row.activity_type || '');
    const detail = String(row.detail || '').trim();
    const score =
      row.score === null || row.score === undefined
        ? null
        : Math.round(Number(row.score));
    const labels: Record<string, { title: string; kind: string }> = {
      QUIZ: { title: 'Hoàn thành bài kiểm tra', kind: 'quiz' },
      PRONUNCIATION: { title: 'Luyện phát âm', kind: 'speaking' },
      READING: { title: 'Luyện đọc hiểu', kind: 'reading' },
      READING_SESSION: { title: 'Đọc bài báo', kind: 'reading' },
      VIDEO_SHADOWING: { title: 'Luyện nói theo video', kind: 'speaking' },
      VOCABULARY: { title: 'Học từ mới', kind: 'vocabulary' },
    };
    const label = labels[type] || {
      title: 'Hoàn thành hoạt động học',
      kind: 'practice',
    };
    return {
      kind: label.kind,
      title: label.title,
      detail: [detail, score === null ? '' : `${score} điểm`]
        .filter(Boolean)
        .join(' · '),
      occurredAt: row.occurred_at,
    };
  }
}
