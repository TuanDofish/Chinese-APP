BEGIN;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('LEARNER', 'ADMIN');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'login_mode') THEN
    CREATE TYPE login_mode AS ENUM ('GUEST', 'LOCAL');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'hsk_level') THEN
    CREATE TYPE hsk_level AS ENUM ('HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'article_source_type') THEN
    CREATE TYPE article_source_type AS ENUM ('RSS', 'MANUAL');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'pronunciation_target_type') THEN
    CREATE TYPE pronunciation_target_type AS ENUM ('WORD', 'SENTENCE');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'grammar_engine') THEN
    CREATE TYPE grammar_engine AS ENUM ('GEMINI', 'MOCK', 'MANUAL');
  END IF;
END
$$;

CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(150) UNIQUE,
  password_hash VARCHAR(255),
  display_name VARCHAR(100) NOT NULL,
  avatar_url VARCHAR(255),
  role user_role NOT NULL DEFAULT 'LEARNER',
  login_mode login_mode NOT NULL DEFAULT 'GUEST',
  target_hsk_level hsk_level,
  preferred_language VARCHAR(10) NOT NULL DEFAULT 'vi',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_users_login_mode
    CHECK (
      (login_mode = 'GUEST')
      OR (login_mode = 'LOCAL' AND email IS NOT NULL AND password_hash IS NOT NULL)
    )
);

CREATE TABLE IF NOT EXISTS topics (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  hsk_level hsk_level NOT NULL,
  description TEXT,
  display_order INT NOT NULL DEFAULT 0,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS vocabularies (
  id BIGSERIAL PRIMARY KEY,
  simplified VARCHAR(50) NOT NULL UNIQUE,
  traditional VARCHAR(50),
  pinyin VARCHAR(255),
  meaning_vi TEXT,
  meaning_en TEXT,
  part_of_speech VARCHAR(50),
  radical VARCHAR(20),
  hsk_level hsk_level NOT NULL,
  frequency INT,
  stroke_count INT,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS topic_vocabularies (
  topic_id BIGINT NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
  vocabulary_id BIGINT NOT NULL REFERENCES vocabularies(id) ON DELETE CASCADE,
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
  source VARCHAR(50) NOT NULL DEFAULT 'manual',
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS grammar_lessons (
  id BIGSERIAL PRIMARY KEY,
  hsk_level hsk_level NOT NULL,
  title VARCHAR(255) NOT NULL,
  pattern_text VARCHAR(255),
  explanation TEXT NOT NULL,
  source VARCHAR(100) NOT NULL DEFAULT 'manual',
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS grammar_examples (
  id BIGSERIAL PRIMARY KEY,
  lesson_id BIGINT NOT NULL REFERENCES grammar_lessons(id) ON DELETE CASCADE,
  example_cn TEXT NOT NULL,
  example_pinyin TEXT,
  example_vi TEXT,
  notes TEXT,
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pronunciation_lessons (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  hsk_level hsk_level NOT NULL,
  description TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pronunciation_sentences (
  id BIGSERIAL PRIMARY KEY,
  lesson_id BIGINT NOT NULL REFERENCES pronunciation_lessons(id) ON DELETE CASCADE,
  sentence_cn TEXT NOT NULL,
  sentence_pinyin TEXT,
  sentence_vi TEXT,
  difficulty SMALLINT NOT NULL DEFAULT 1,
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS article_sources (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  source_type article_source_type NOT NULL DEFAULT 'RSS',
  rss_url TEXT,
  homepage_url TEXT,
  default_hsk_level hsk_level,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS articles (
  id BIGSERIAL PRIMARY KEY,
  source_id BIGINT REFERENCES article_sources(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  title_vi TEXT,
  content TEXT NOT NULL,
  link TEXT,
  hsk_level hsk_level,
  published_at TIMESTAMPTZ,
  cached_at TIMESTAMPTZ,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_articles_source_link
  ON articles (source_id, link)
  WHERE link IS NOT NULL;

CREATE TABLE IF NOT EXISTS user_word_progress (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vocabulary_id BIGINT NOT NULL REFERENCES vocabularies(id) ON DELETE CASCADE,
  is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
  is_learned BOOLEAN NOT NULL DEFAULT FALSE,
  reveal_count INT NOT NULL DEFAULT 0,
  review_count INT NOT NULL DEFAULT 0,
  best_pronunciation_score NUMERIC(5,2) NOT NULL DEFAULT 0,
  last_reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_user_word_progress UNIQUE (user_id, vocabulary_id)
);

CREATE TABLE IF NOT EXISTS grammar_check_sessions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  input_text TEXT NOT NULL,
  score NUMERIC(5,2) NOT NULL,
  correction_cn TEXT,
  correction_pinyin TEXT,
  correction_vi TEXT,
  style_tips TEXT,
  engine grammar_engine NOT NULL DEFAULT 'GEMINI',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS grammar_check_issues (
  id BIGSERIAL PRIMARY KEY,
  session_id BIGINT NOT NULL REFERENCES grammar_check_sessions(id) ON DELETE CASCADE,
  issue_type VARCHAR(100) NOT NULL,
  explanation TEXT NOT NULL,
  display_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS grammar_check_suggestions (
  id BIGSERIAL PRIMARY KEY,
  session_id BIGINT NOT NULL REFERENCES grammar_check_sessions(id) ON DELETE CASCADE,
  suggestion_cn TEXT NOT NULL,
  suggestion_pinyin TEXT,
  suggestion_vi TEXT,
  reason TEXT,
  display_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS pronunciation_attempts (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_type pronunciation_target_type NOT NULL,
  vocabulary_id BIGINT REFERENCES vocabularies(id) ON DELETE SET NULL,
  sentence_id BIGINT REFERENCES pronunciation_sentences(id) ON DELETE SET NULL,
  target_text TEXT NOT NULL,
  recognized_text TEXT,
  score NUMERIC(5,2) NOT NULL DEFAULT 0,
  audio_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_pronunciation_target
    CHECK (
      (target_type = 'WORD' AND vocabulary_id IS NOT NULL AND sentence_id IS NULL)
      OR
      (target_type = 'SENTENCE' AND sentence_id IS NOT NULL AND vocabulary_id IS NULL)
    )
);

CREATE TABLE IF NOT EXISTS reading_sessions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  article_id BIGINT NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  time_spent_seconds INT NOT NULL DEFAULT 0,
  looked_up_words_count INT NOT NULL DEFAULT 0,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  last_read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_reading_sessions UNIQUE (user_id, article_id)
);

CREATE TABLE IF NOT EXISTS reading_word_lookups (
  id BIGSERIAL PRIMARY KEY,
  session_id BIGINT NOT NULL REFERENCES reading_sessions(id) ON DELETE CASCADE,
  vocabulary_id BIGINT REFERENCES vocabularies(id) ON DELETE SET NULL,
  word VARCHAR(50) NOT NULL,
  meaning_vi TEXT,
  saved_to_notebook BOOLEAN NOT NULL DEFAULT FALSE,
  looked_up_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS daily_goals (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  goal_words INT NOT NULL DEFAULT 10,
  goal_minutes INT NOT NULL DEFAULT 15,
  effective_from DATE NOT NULL DEFAULT CURRENT_DATE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_daily_goals_user UNIQUE (user_id)
);

CREATE TABLE IF NOT EXISTS daily_learning_stats (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  study_date DATE NOT NULL,
  learned_words_count INT NOT NULL DEFAULT 0,
  review_count INT NOT NULL DEFAULT 0,
  study_minutes INT NOT NULL DEFAULT 0,
  grammar_checks_count INT NOT NULL DEFAULT 0,
  pronunciation_attempts_count INT NOT NULL DEFAULT 0,
  streak_snapshot INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_daily_learning_stats UNIQUE (user_id, study_date)
);

CREATE INDEX IF NOT EXISTS idx_topics_hsk_level
  ON topics (hsk_level, display_order);

CREATE INDEX IF NOT EXISTS idx_vocabularies_hsk_level
  ON vocabularies (hsk_level, simplified);

CREATE INDEX IF NOT EXISTS idx_grammar_lessons_hsk_level
  ON grammar_lessons (hsk_level, active);

CREATE INDEX IF NOT EXISTS idx_pronunciation_lessons_hsk_level
  ON pronunciation_lessons (hsk_level, display_order);

CREATE INDEX IF NOT EXISTS idx_articles_published_at
  ON articles (published_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_word_progress_user
  ON user_word_progress (user_id, is_favorite, is_learned);

CREATE INDEX IF NOT EXISTS idx_grammar_check_sessions_user_time
  ON grammar_check_sessions (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_pronunciation_attempts_user_time
  ON pronunciation_attempts (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_reading_sessions_user_time
  ON reading_sessions (user_id, last_read_at DESC);

CREATE INDEX IF NOT EXISTS idx_daily_learning_stats_user_date
  ON daily_learning_stats (user_id, study_date DESC);

COMMIT;
