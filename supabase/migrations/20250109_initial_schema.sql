-- Deutsche Lernen - Initial Database Schema
-- Version: 2.0
-- Created: 2025-11-09
-- Description: Normalized data model with proper RLS, enums, and full-text search

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For fast text search

-- ============================================================================
-- ENUMS
-- ============================================================================

-- Part of speech classification
CREATE TYPE part_of_speech AS ENUM ('noun', 'verb', 'adjective', 'adverb', 'phrase', 'other');

-- German noun gender
CREATE TYPE gender AS ENUM ('der', 'die', 'das', 'none');

-- ============================================================================
-- TABLES
-- ============================================================================

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT,
  native_language TEXT NOT NULL DEFAULT 'hebrew',
  current_language TEXT NOT NULL DEFAULT 'hebrew',
  preferences JSONB DEFAULT '{}'::jsonb,
  role TEXT DEFAULT 'student',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.users IS 'User profiles with language preferences';
COMMENT ON COLUMN public.users.native_language IS 'User native language (he/en/it)';
COMMENT ON COLUMN public.users.current_language IS 'Currently selected UI language';
COMMENT ON COLUMN public.users.preferences IS 'JSON object for user preferences';

-- Terms table (German vocabulary - unique)
CREATE TABLE public.terms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  german TEXT NOT NULL,
  part part_of_speech NOT NULL DEFAULT 'other',
  gender gender NOT NULL DEFAULT 'none',
  ipa TEXT,
  audio_url TEXT,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_german UNIQUE (german)
);

COMMENT ON TABLE public.terms IS 'German vocabulary terms (normalized, unique)';
COMMENT ON COLUMN public.terms.german IS 'German word/phrase (unique, trimmed)';
COMMENT ON COLUMN public.terms.part IS 'Part of speech classification';
COMMENT ON COLUMN public.terms.gender IS 'Noun gender (der/die/das) or none';
COMMENT ON COLUMN public.terms.ipa IS 'International Phonetic Alphabet (future)';
COMMENT ON COLUMN public.terms.audio_url IS 'Pronunciation audio URL (future)';

-- Term translations table
CREATE TABLE public.term_translations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  term_id UUID NOT NULL REFERENCES public.terms(id) ON DELETE CASCADE,
  lang TEXT NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_term_lang UNIQUE (term_id, lang)
);

COMMENT ON TABLE public.term_translations IS 'Translations for terms in multiple languages';
COMMENT ON COLUMN public.term_translations.lang IS 'ISO language code (he/en/it/es/fr)';
COMMENT ON COLUMN public.term_translations.text IS 'Translation text';

-- Lessons table
CREATE TABLE public.lessons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_number INTEGER NOT NULL,
  lesson_name TEXT,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_user_lesson UNIQUE (created_by, lesson_number)
);

COMMENT ON TABLE public.lessons IS 'Learning lessons';
COMMENT ON COLUMN public.lessons.lesson_number IS 'Lesson sequence number (1, 2, 3...)';
COMMENT ON COLUMN public.lessons.lesson_name IS 'Optional lesson title';

-- Lesson-Term mapping (M2M)
CREATE TABLE public.lesson_terms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  term_id UUID NOT NULL REFERENCES public.terms(id) ON DELETE CASCADE,
  category TEXT,
  subcategory TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_lesson_term UNIQUE (lesson_id, term_id)
);

COMMENT ON TABLE public.lesson_terms IS 'Many-to-many mapping between lessons and terms';
COMMENT ON COLUMN public.lesson_terms.category IS 'Display category (Verbs, Nouns, Adjectives)';
COMMENT ON COLUMN public.lesson_terms.subcategory IS 'Optional sub-grouping (sein, Furniture, Family)';
COMMENT ON COLUMN public.lesson_terms.order_index IS 'Display order within lesson/category';

-- Notebooks table (Markdown format)
CREATE TABLE public.notebooks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES public.lessons(id) ON DELETE SET NULL,
  content TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.notebooks IS 'User notes in Markdown format';
COMMENT ON COLUMN public.notebooks.lesson_id IS 'Associated lesson (NULL = general notes)';
COMMENT ON COLUMN public.notebooks.content IS 'Markdown content (secure, portable)';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Terms indexes
CREATE INDEX idx_terms_german_trgm ON public.terms USING gin (german gin_trgm_ops);
CREATE INDEX idx_terms_created_by ON public.terms(created_by);
CREATE INDEX idx_terms_part ON public.terms(part);

-- Term translations indexes
CREATE INDEX idx_term_translations_term ON public.term_translations(term_id);
CREATE INDEX idx_term_translations_lang ON public.term_translations(lang);

-- Lessons indexes
CREATE INDEX idx_lessons_created_by ON public.lessons(created_by);
CREATE INDEX idx_lessons_number ON public.lessons(lesson_number);

-- Lesson terms indexes
CREATE INDEX idx_lesson_terms_lesson ON public.lesson_terms(lesson_id);
CREATE INDEX idx_lesson_terms_term ON public.lesson_terms(term_id);
CREATE INDEX idx_lesson_terms_category ON public.lesson_terms(category);

-- Notebooks indexes
CREATE INDEX idx_notebooks_user ON public.notebooks(user_id);
CREATE INDEX idx_notebooks_lesson ON public.notebooks(lesson_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.term_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notebooks ENABLE ROW LEVEL SECURITY;

-- USERS POLICIES
CREATE POLICY "Users can view own data" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- TERMS POLICIES (only owner can see/modify their terms in Phase 1)
CREATE POLICY "Users can view own terms" ON public.terms
  FOR SELECT USING (auth.uid() = created_by);

CREATE POLICY "Users can create terms" ON public.terms
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own terms" ON public.terms
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own terms" ON public.terms
  FOR DELETE USING (auth.uid() = created_by);

-- TERM_TRANSLATIONS POLICIES (follow term ownership)
CREATE POLICY "Users can view own term translations" ON public.term_translations
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.terms
      WHERE terms.id = term_translations.term_id
      AND terms.created_by = auth.uid()
    )
  );

CREATE POLICY "Users can create term translations" ON public.term_translations
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.terms
      WHERE terms.id = term_translations.term_id
      AND terms.created_by = auth.uid()
    )
  );

CREATE POLICY "Users can update own term translations" ON public.term_translations
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.terms
      WHERE terms.id = term_translations.term_id
      AND terms.created_by = auth.uid()
    )
  );

CREATE POLICY "Users can delete own term translations" ON public.term_translations
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.terms
      WHERE terms.id = term_translations.term_id
      AND terms.created_by = auth.uid()
    )
  );

-- LESSONS POLICIES (only owner can see/modify)
CREATE POLICY "Users can view own lessons" ON public.lessons
  FOR SELECT USING (auth.uid() = created_by);

CREATE POLICY "Users can create lessons" ON public.lessons
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own lessons" ON public.lessons
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own lessons" ON public.lessons
  FOR DELETE USING (auth.uid() = created_by);

-- LESSON_TERMS POLICIES (follow lesson ownership)
CREATE POLICY "Users can view own lesson_terms" ON public.lesson_terms
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.lessons
      WHERE lessons.id = lesson_terms.lesson_id
      AND lessons.created_by = auth.uid()
    )
  );

CREATE POLICY "Users can create lesson_terms" ON public.lesson_terms
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.lessons
      WHERE lessons.id = lesson_terms.lesson_id
      AND lessons.created_by = auth.uid()
    )
  );

CREATE POLICY "Users can update own lesson_terms" ON public.lesson_terms
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.lessons
      WHERE lessons.id = lesson_terms.lesson_id
      AND lessons.created_by = auth.uid()
    )
  );

CREATE POLICY "Users can delete own lesson_terms" ON public.lesson_terms
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.lessons
      WHERE lessons.id = lesson_terms.lesson_id
      AND lessons.created_by = auth.uid()
    )
  );

-- NOTEBOOKS POLICIES (own notebooks only)
CREATE POLICY "Users can view own notebooks" ON public.notebooks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own notebooks" ON public.notebooks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notebooks" ON public.notebooks
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notebooks" ON public.notebooks
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_terms_updated_at BEFORE UPDATE ON public.terms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lessons_updated_at BEFORE UPDATE ON public.lessons
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notebooks_updated_at BEFORE UPDATE ON public.notebooks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Search terms function (full-text search)
CREATE OR REPLACE FUNCTION search_terms(
  search_query TEXT,
  user_id UUID,
  language TEXT DEFAULT 'he'
) RETURNS TABLE (
  term_id UUID,
  german TEXT,
  translation TEXT,
  relevance FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    t.id,
    t.german,
    tr.text,
    similarity(t.german, search_query) as relevance
  FROM public.terms t
  LEFT JOIN public.term_translations tr ON tr.term_id = t.id AND tr.lang = language
  WHERE
    t.created_by = user_id
    AND (
      t.german ILIKE '%' || search_query || '%'
      OR tr.text ILIKE '%' || search_query || '%'
    )
  ORDER BY relevance DESC
  LIMIT 50;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION search_terms IS 'Full-text search across terms and translations';

-- ============================================================================
-- INITIAL DATA
-- ============================================================================

-- No initial data needed for Phase 1
