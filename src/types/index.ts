// Deutsche Lernen - Type Exports

export * from './database.types';

// UI-specific types
export type ViewMode = 'lessons' | 'categories';

export interface FilterState {
  viewMode: ViewMode;
  selectedLessons: number[];
  selectedCategories: string[];
  searchQuery: string;
}

export interface LanguageOption {
  code: string;
  name: string;
  nativeName: string;
  direction: 'ltr' | 'rtl';
}

export const SUPPORTED_LANGUAGES: Record<string, LanguageOption> = {
  hebrew: {
    code: 'he',
    name: 'Hebrew',
    nativeName: 'עברית',
    direction: 'rtl',
  },
  english: {
    code: 'en',
    name: 'English',
    nativeName: 'English',
    direction: 'ltr',
  },
  italian: {
    code: 'it',
    name: 'Italian',
    nativeName: 'Italiano',
    direction: 'ltr',
  },
};
