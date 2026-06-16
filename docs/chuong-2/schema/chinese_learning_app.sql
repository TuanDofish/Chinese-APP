BEGIN;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('LEARNER', 'EDITOR', 'REVIEWER', 'ADMIN');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'content_status') THEN
    CREATE TYPE content_status AS ENUM ('DRAFT', 'REVIEW', 'PUBLISHED', 'ARCHIVED');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lesson_type') THEN
    CREATE TYPE lesson_type AS ENUM (
      'VOCABULARY', 'GRAMMAR', 'READING', 'PRONUNCIATION', 'VIDEO', 'QUIZ'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'attempt_type') THEN
    CREATE TYPE attempt_type AS ENUM (
      'QUIZ', 'PRONUNCIATION', 'READING', 'VIDEO_SHADOWING'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ai_interaction_type') THEN
    CREATE TYPE ai_interaction_type AS ENUM ('GRAMMAR_CHECK', 'TUTOR_CHAT');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ai_status') THEN
    CREATE TYPE ai_status AS ENUM ('SUCCESS', 'ERROR');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'article_source_type') THEN
    CREATE TYPE article_source_type AS ENUM ('MANUAL', 'RSS', 'API');
  END IF;
END
$$;

-- Nang cap tu schema TypeORM 9 bang cu ma khong xoa du lieu/cot cu.
-- Cac cot camelCase duoc giu lai de API hien tai van hoat dong.
DO $$
BEGIN
  IF to_regclass('public.users') IS NOT NULL THEN
    ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);
    ALTER TABLE users ADD COLUMN IF NOT EXISTS display_name VARCHAR(100);
    ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url TEXT;
    ALTER TABLE users ADD COLUMN IF NOT EXISTS target_hsk_level SMALLINT DEFAULT 1;
    ALTER TABLE users ADD COLUMN IF NOT EXISTS daily_goal_words SMALLINT DEFAULT 10;
    ALTER TABLE users ADD COLUMN IF NOT EXISTS daily_goal_minutes SMALLINT DEFAULT 15;
    ALTER TABLE users ADD COLUMN IF NOT EXISTS reminder_time TIME;
    UPDATE users SET
      password_hash = COALESCE(password_hash, "passwordHash"),
      display_name = COALESCE(display_name, "displayName"),
      avatar_url = COALESCE(avatar_url, "avatarUrl"),
      target_hsk_level = COALESCE(
        target_hsk_level,
        NULLIF(REGEXP_REPLACE(COALESCE("targetLevel", ''), '\D', '', 'g'), '')::SMALLINT,
        1
      );
  END IF;

  IF to_regclass('public.course_levels') IS NOT NULL THEN
    ALTER TABLE course_levels ADD COLUMN IF NOT EXISTS code VARCHAR(20);
    ALTER TABLE course_levels ADD COLUMN IF NOT EXISTS level_number SMALLINT;
    ALTER TABLE course_levels ADD COLUMN IF NOT EXISTS display_order SMALLINT DEFAULT 0;
    ALTER TABLE course_levels ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT TRUE;
    ALTER TABLE course_levels ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
    ALTER TABLE course_levels ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
    UPDATE course_levels SET
      level_number = COALESCE(
        level_number,
        NULLIF(REGEXP_REPLACE(name, '\D', '', 'g'), '')::SMALLINT,
        id::SMALLINT
      ),
      code = COALESCE(code, 'HSK' || COALESCE(
        NULLIF(REGEXP_REPLACE(name, '\D', '', 'g'), ''),
        id::TEXT
      )),
      display_order = COALESCE(display_order, id),
      active = COALESCE(active, TRUE);
  END IF;

  IF to_regclass('public.lessons') IS NOT NULL THEN
    ALTER TABLE lessons ADD COLUMN IF NOT EXISTS course_level_id BIGINT;
    ALTER TABLE lessons ADD COLUMN IF NOT EXISTS code VARCHAR(100);
    ALTER TABLE lessons ADD COLUMN IF NOT EXISTS title_cn VARCHAR(255);
    ALTER TABLE lessons ADD COLUMN IF NOT EXISTS lesson_type lesson_type;
    ALTER TABLE lessons ADD COLUMN IF NOT EXISTS content_json JSONB DEFAULT '{}'::JSONB;
    ALTER TABLE lessons ADD COLUMN IF NOT EXISTS display_order INT DEFAULT 0;
    ALTER TABLE lessons ADD COLUMN IF NOT EXISTS status content_status DEFAULT 'PUBLISHED';
    ALTER TABLE lessons ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
    ALTER TABLE lessons ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
    UPDATE lessons SET
      course_level_id = COALESCE(course_level_id, "courseLevelId"),
      code = COALESCE(code, 'legacy_lesson_' || id),
      lesson_type = COALESCE(lesson_type, 'VOCABULARY'),
      content_json = COALESCE(content_json, '{}'::JSONB),
      display_order = COALESCE(display_order, order_index, 0),
      status = COALESCE(status, 'PUBLISHED');
  END IF;

  IF to_regclass('public.vocabularies') IS NOT NULL THEN
    ALTER TABLE vocabularies ADD COLUMN IF NOT EXISTS part_of_speech VARCHAR(80);
    ALTER TABLE vocabularies ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::JSONB;
    ALTER TABLE vocabularies ADD COLUMN IF NOT EXISTS status content_status DEFAULT 'PUBLISHED';
    ALTER TABLE vocabularies ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
    UPDATE vocabularies SET
      part_of_speech = COALESCE(part_of_speech, word_type),
      metadata = COALESCE(metadata, '{}'::JSONB) ||
        JSONB_BUILD_OBJECT('definitions', COALESCE(definitions, '[]'::JSONB)),
      status = COALESCE(status, 'PUBLISHED');
  END IF;

  IF to_regclass('public.quiz_questions') IS NOT NULL THEN
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS lesson_id BIGINT;
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS topic_id BIGINT;
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS vocabulary_id BIGINT;
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS question_type VARCHAR(40);
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS question_text TEXT;
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS options_json JSONB;
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS correct_answer TEXT;
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS explanation TEXT;
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS difficulty SMALLINT DEFAULT 1;
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS status content_status DEFAULT 'PUBLISHED';
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
    ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
    UPDATE quiz_questions SET
      lesson_id = COALESCE(lesson_id, "lessonId"),
      question_type = COALESCE(question_type, "questionType", 'CN_TO_VI'),
      question_text = COALESCE(question_text, "questionText"),
      options_json = COALESCE(options_json, options, '[]'::JSONB),
      correct_answer = COALESCE(correct_answer, "correctAnswer"),
      difficulty = COALESCE(difficulty, 1),
      status = COALESCE(status, 'PUBLISHED');
  END IF;

  IF to_regclass('public.articles') IS NOT NULL THEN
    ALTER TABLE articles ADD COLUMN IF NOT EXISTS external_id VARCHAR(120);
    ALTER TABLE articles ADD COLUMN IF NOT EXISTS source_id BIGINT;
    ALTER TABLE articles ADD COLUMN IF NOT EXISTS summary_vi TEXT;
    ALTER TABLE articles ADD COLUMN IF NOT EXISTS sentences_json JSONB DEFAULT '[]'::JSONB;
    ALTER TABLE articles ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ;
    ALTER TABLE articles ADD COLUMN IF NOT EXISTS status content_status DEFAULT 'PUBLISHED';
    ALTER TABLE articles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
    UPDATE articles SET
      external_id = COALESCE(external_id, 'legacy_article_' || id),
      status = COALESCE(status, CASE WHEN active THEN 'PUBLISHED' ELSE 'ARCHIVED' END::content_status),
      sentences_json = COALESCE(sentences_json, '[]'::JSONB);
  END IF;
END
$$;

-- 1. Tai khoan hoc vien va tai khoan quan tri dung chung mot bang.
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(150) UNIQUE,
  password_hash VARCHAR(255),
  display_name VARCHAR(100) NOT NULL,
  avatar_url TEXT,
  role user_role NOT NULL DEFAULT 'LEARNER',
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
    CHECK (status IN ('ACTIVE', 'LOCKED', 'PENDING')),
  target_hsk_level SMALLINT NOT NULL DEFAULT 1
    CHECK (target_hsk_level BETWEEN 1 AND 6),
  daily_goal_words SMALLINT NOT NULL DEFAULT 10 CHECK (daily_goal_words >= 0),
  daily_goal_minutes SMALLINT NOT NULL DEFAULT 15 CHECK (daily_goal_minutes >= 0),
  reminder_time TIME,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Lich su thao tac quan tri, khong can bang admins rieng.
CREATE TABLE IF NOT EXISTS admin_audit_logs (
  id BIGSERIAL PRIMARY KEY,
  admin_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  action VARCHAR(80) NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id VARCHAR(100),
  change_data JSONB NOT NULL DEFAULT '{}'::JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Cap do HSK. Du an hien phat hanh HSK 1-4, san sang mo rong 5-6.
CREATE TABLE IF NOT EXISTS course_levels (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  level_number SMALLINT NOT NULL UNIQUE CHECK (level_number BETWEEN 1 AND 6),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  display_order SMALLINT NOT NULL DEFAULT 0,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Don vi hoc tap dung chung cho tu vung, ngu phap, doc, phat am, video, quiz.
CREATE TABLE IF NOT EXISTS lessons (
  id BIGSERIAL PRIMARY KEY,
  course_level_id BIGINT NOT NULL REFERENCES course_levels(id) ON DELETE RESTRICT,
  code VARCHAR(100) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  title_cn VARCHAR(255),
  lesson_type lesson_type NOT NULL,
  description TEXT,
  content_json JSONB NOT NULL DEFAULT '{}'::JSONB,
  display_order INT NOT NULL DEFAULT 0,
  status content_status NOT NULL DEFAULT 'DRAFT',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5-8. Kho tu dien va flashcard theo chu de.
CREATE TABLE IF NOT EXISTS topics (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  name_cn VARCHAR(150),
  hsk_level SMALLINT NOT NULL CHECK (hsk_level BETWEEN 1 AND 6),
  description TEXT,
  color_hex VARCHAR(9),
  image_path TEXT,
  display_order INT NOT NULL DEFAULT 0,
  status content_status NOT NULL DEFAULT 'PUBLISHED',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS vocabularies (
  id BIGSERIAL PRIMARY KEY,
  simplified VARCHAR(80) NOT NULL UNIQUE,
  traditional VARCHAR(80),
  pinyin VARCHAR(255),
  meaning_vi TEXT,
  meaning_en TEXT,
  han_viet VARCHAR(255),
  part_of_speech VARCHAR(80),
  radical VARCHAR(50),
  hsk_level SMALLINT NOT NULL CHECK (hsk_level BETWEEN 1 AND 6),
  stroke_count SMALLINT,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  status content_status NOT NULL DEFAULT 'PUBLISHED',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS topic_vocabularies (
  topic_id BIGINT NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
  vocabulary_id BIGINT NOT NULL REFERENCES vocabularies(id) ON DELETE CASCADE,
  image_path TEXT,
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (topic_id, vocabulary_id)
);

CREATE TABLE IF NOT EXISTS vocabulary_examples (
  id BIGSERIAL PRIMARY KEY,
  vocabulary_id BIGINT NOT NULL REFERENCES vocabularies(id) ON DELETE CASCADE,
  example_cn TEXT NOT NULL,
  example_pinyin TEXT,
  example_vi TEXT,
  source VARCHAR(100) NOT NULL DEFAULT 'app_seed',
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (vocabulary_id, example_cn)
);

-- 9-10. Noi dung ngu phap va bai tap.
CREATE TABLE IF NOT EXISTS grammar_lessons (
  id BIGSERIAL PRIMARY KEY,
  lesson_id BIGINT NOT NULL UNIQUE REFERENCES lessons(id) ON DELETE CASCADE,
  external_id VARCHAR(100) UNIQUE,
  hsk_level SMALLINT NOT NULL CHECK (hsk_level BETWEEN 1 AND 6),
  title VARCHAR(255) NOT NULL,
  pattern_text TEXT,
  explanation TEXT NOT NULL,
  examples_json JSONB NOT NULL DEFAULT '[]'::JSONB,
  note TEXT,
  status content_status NOT NULL DEFAULT 'PUBLISHED',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS quiz_questions (
  id BIGSERIAL PRIMARY KEY,
  lesson_id BIGINT REFERENCES lessons(id) ON DELETE CASCADE,
  topic_id BIGINT REFERENCES topics(id) ON DELETE SET NULL,
  vocabulary_id BIGINT REFERENCES vocabularies(id) ON DELETE SET NULL,
  question_type VARCHAR(40) NOT NULL
    CHECK (question_type IN ('CN_TO_VI', 'VI_TO_CN', 'PINYIN', 'GRAMMAR')),
  question_text TEXT NOT NULL,
  options_json JSONB NOT NULL,
  correct_answer TEXT NOT NULL,
  explanation TEXT,
  difficulty SMALLINT NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
  status content_status NOT NULL DEFAULT 'PUBLISHED',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (lesson_id, question_type, question_text)
);

-- 11-13. Doc hieu va lich su doc.
CREATE TABLE IF NOT EXISTS article_sources (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  source_type article_source_type NOT NULL DEFAULT 'MANUAL',
  source_url TEXT,
  default_hsk_level SMALLINT CHECK (default_hsk_level BETWEEN 1 AND 6),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS articles (
  id BIGSERIAL PRIMARY KEY,
  external_id VARCHAR(120) UNIQUE,
  source_id BIGINT REFERENCES article_sources(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  title_vi TEXT,
  summary_vi TEXT,
  content TEXT NOT NULL,
  sentences_json JSONB NOT NULL DEFAULT '[]'::JSONB,
  link TEXT,
  hsk_level SMALLINT NOT NULL CHECK (hsk_level BETWEEN 1 AND 6),
  published_at TIMESTAMPTZ,
  status content_status NOT NULL DEFAULT 'PUBLISHED',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reading_sessions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  article_id BIGINT NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  time_spent_seconds INT NOT NULL DEFAULT 0 CHECK (time_spent_seconds >= 0),
  looked_up_words_json JSONB NOT NULL DEFAULT '[]'::JSONB,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  last_read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, article_id)
);

-- 14-15. Luyen phat am va video.
CREATE TABLE IF NOT EXISTS pronunciation_sentences (
  id BIGSERIAL PRIMARY KEY,
  lesson_id BIGINT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  external_id VARCHAR(120) UNIQUE,
  hsk_level SMALLINT NOT NULL CHECK (hsk_level BETWEEN 1 AND 6),
  topic VARCHAR(150),
  sentence_cn TEXT NOT NULL,
  sentence_pinyin TEXT,
  sentence_vi TEXT,
  difficulty SMALLINT NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
  display_order INT NOT NULL DEFAULT 0,
  status content_status NOT NULL DEFAULT 'PUBLISHED',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS video_transcript_lines (
  id BIGSERIAL PRIMARY KEY,
  lesson_id BIGINT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  line_number INT NOT NULL,
  start_seconds NUMERIC(10,3) NOT NULL DEFAULT 0,
  end_seconds NUMERIC(10,3) NOT NULL DEFAULT 0,
  sentence_cn TEXT NOT NULL,
  sentence_pinyin TEXT,
  sentence_vi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (lesson_id, line_number)
);

-- 16-18. Lich su hoc va thong ke. practice_attempts gom nhieu loai luyen tap.
CREATE TABLE IF NOT EXISTS practice_attempts (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_id BIGINT REFERENCES lessons(id) ON DELETE SET NULL,
  attempt_type attempt_type NOT NULL,
  target_type VARCHAR(50),
  target_id VARCHAR(100),
  score NUMERIC(5,2) CHECK (score BETWEEN 0 AND 100),
  correct_count INT NOT NULL DEFAULT 0 CHECK (correct_count >= 0),
  total_count INT NOT NULL DEFAULT 0 CHECK (total_count >= 0),
  duration_seconds INT NOT NULL DEFAULT 0 CHECK (duration_seconds >= 0),
  result_json JSONB NOT NULL DEFAULT '{}'::JSONB,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_word_progress (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vocabulary_id BIGINT NOT NULL REFERENCES vocabularies(id) ON DELETE CASCADE,
  is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
  mastery_level SMALLINT NOT NULL DEFAULT 0 CHECK (mastery_level BETWEEN 0 AND 5),
  review_count INT NOT NULL DEFAULT 0 CHECK (review_count >= 0),
  correct_count INT NOT NULL DEFAULT 0 CHECK (correct_count >= 0),
  next_review_at TIMESTAMPTZ,
  last_reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, vocabulary_id)
);

CREATE TABLE IF NOT EXISTS daily_learning_stats (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  study_date DATE NOT NULL,
  learned_words_count INT NOT NULL DEFAULT 0,
  reviewed_words_count INT NOT NULL DEFAULT 0,
  lessons_completed_count INT NOT NULL DEFAULT 0,
  quiz_count INT NOT NULL DEFAULT 0,
  pronunciation_count INT NOT NULL DEFAULT 0,
  reading_count INT NOT NULL DEFAULT 0,
  ai_interaction_count INT NOT NULL DEFAULT 0,
  study_seconds INT NOT NULL DEFAULT 0,
  streak_snapshot INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, study_date)
);

-- 19. Lich su AI cung la log nghiep vu de truy vet loi 429/503.
CREATE TABLE IF NOT EXISTS ai_interactions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  interaction_type ai_interaction_type NOT NULL,
  session_key VARCHAR(120),
  input_text TEXT NOT NULL,
  response_text TEXT,
  score NUMERIC(5,2),
  response_json JSONB NOT NULL DEFAULT '{}'::JSONB,
  provider VARCHAR(50) NOT NULL DEFAULT 'GEMINI',
  model VARCHAR(100),
  status ai_status NOT NULL,
  http_status SMALLINT,
  error_code VARCHAR(100),
  error_message TEXT,
  duration_ms INT CHECK (duration_ms >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 20. Quan ly phien ban du lieu va trang thai publish cua admin.
CREATE TABLE IF NOT EXISTS content_versions (
  id BIGSERIAL PRIMARY KEY,
  version_code VARCHAR(80) NOT NULL UNIQUE,
  content_type VARCHAR(80) NOT NULL,
  description TEXT,
  source_checksum VARCHAR(128),
  item_count INT NOT NULL DEFAULT 0,
  status content_status NOT NULL DEFAULT 'DRAFT',
  published_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
  published_at TIMESTAMPTZ,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE content_versions
  ADD COLUMN IF NOT EXISTS metadata JSONB NOT NULL DEFAULT '{}'::JSONB;

CREATE UNIQUE INDEX IF NOT EXISTS uq_course_levels_code ON course_levels (code);
CREATE UNIQUE INDEX IF NOT EXISTS uq_course_levels_number ON course_levels (level_number);
CREATE UNIQUE INDEX IF NOT EXISTS uq_lessons_code ON lessons (code);
CREATE UNIQUE INDEX IF NOT EXISTS uq_articles_external_id ON articles (external_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_quiz_question_seed
  ON quiz_questions (lesson_id, question_type, question_text);

CREATE INDEX IF NOT EXISTS idx_lessons_level_type
  ON lessons (course_level_id, lesson_type, display_order);
CREATE INDEX IF NOT EXISTS idx_topics_level_order
  ON topics (hsk_level, display_order);
CREATE INDEX IF NOT EXISTS idx_vocabularies_level_word
  ON vocabularies (hsk_level, simplified);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_lesson
  ON quiz_questions (lesson_id, difficulty);
CREATE INDEX IF NOT EXISTS idx_articles_level_date
  ON articles (hsk_level, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_pronunciation_level
  ON pronunciation_sentences (hsk_level, display_order);
CREATE INDEX IF NOT EXISTS idx_practice_attempts_user_time
  ON practice_attempts (user_id, completed_at DESC);
CREATE INDEX IF NOT EXISTS idx_word_progress_due
  ON user_word_progress (user_id, next_review_at);
CREATE INDEX IF NOT EXISTS idx_daily_stats_user_date
  ON daily_learning_stats (user_id, study_date DESC);
CREATE INDEX IF NOT EXISTS idx_ai_interactions_status_time
  ON ai_interactions (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_audit_time
  ON admin_audit_logs (admin_id, created_at DESC);

COMMIT;
