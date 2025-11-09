// Deutsche Lernen - Database Types
// Auto-generated from Supabase schema

export type PartOfSpeech = 'noun' | 'verb' | 'adjective' | 'adverb' | 'phrase' | 'other';
export type Gender = 'der' | 'die' | 'das' | 'none';
export type Language = 'he' | 'en' | 'it' | 'es' | 'fr';
export type LanguageDisplay = 'hebrew' | 'english' | 'italian' | 'spanish' | 'french';

export interface User {
  id: string;
  email: string;
  name: string | null;
  native_language: LanguageDisplay;
  current_language: LanguageDisplay;
  preferences: Record<string, any>;
  role: 'student' | 'creator';
  created_at: string;
  updated_at: string;
}

export interface Term {
  id: string;
  german: string;
  part: PartOfSpeech;
  gender: Gender;
  ipa: string | null;
  audio_url: string | null;
  created_by: string | null;
  created_at: string;
  updated_at: string;
}

export interface TermTranslation {
  id: string;
  term_id: string;
  lang: Language;
  text: string;
  created_at: string;
}

export interface Lesson {
  id: string;
  lesson_number: number;
  lesson_name: string | null;
  created_by: string;
  created_at: string;
  updated_at: string;
}

export interface LessonTerm {
  id: string;
  lesson_id: string;
  term_id: string;
  category: string;
  subcategory: string | null;
  order_index: number;
  created_at: string;
}

export interface Notebook {
  id: string;
  user_id: string;
  lesson_id: string | null;
  content: string;
  created_at: string;
  updated_at: string;
}

// Joined types for queries
export interface TermWithTranslations extends Term {
  translations: TermTranslation[];
}

export interface LessonWithTerms extends Lesson {
  lesson_terms: (LessonTerm & {
    terms: TermWithTranslations;
  })[];
}

// CSV Import types
export interface CSVRow {
  german: string;
  hebrew?: string;
  english?: string;
  italian?: string;
  lesson?: string;
  part_of_speech?: string;
  gender?: string;
  category?: string;
  subcategory?: string;
  fld1?: string;
  fld2?: string;
  fld3?: string;
  fld4?: string;
  fld5?: string;
}

export interface ImportResult {
  success: boolean;
  lesson_id: string;
  summary: {
    total_rows: number;
    created_terms: number;
    reused_terms: number;
    created_translations: number;
    updated_translations: number;
    linked_to_lesson: number;
    error_count: number;
  };
  errors: Array<{
    german: string;
    error: string;
  }>;
}
