# Deutsche Lernen - German Learning Platform

A flexible German learning platform supporting classroom learning with split-screen interface, multi-language support, and intelligent filtering.

## Features

- **Split-Screen Interface**: Learned material (left) + free notebook (right)
- **Multi-Language Support**: Hebrew, English, Italian (extensible)
- **Intelligent Filtering**: By lesson, category, or search
- **CSV/JSON Import**: Atomic data import with de-duplication
- **Full RTL Support**: Native Hebrew support with proper text direction
- **Normalized Data Model**: Terms reused across lessons

## Tech Stack

- **Frontend**: React + TypeScript + Vite
- **UI**: Tailwind CSS
- **Backend**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **State Management**: React Query + Zustand
- **Rich Text**: TipTap

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- Supabase account

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd almostZero
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env
```

Edit `.env` and add your Supabase credentials:
```
VITE_SUPABASE_URL=your-supabase-project-url
VITE_SUPABASE_ANON_KEY=your-supabase-anon-key
```

4. Set up Supabase database:

Go to your Supabase project SQL editor and run:
- `supabase/migrations/20250109_initial_schema.sql`
- `supabase/migrations/20250109_atomic_import_function.sql`

5. Start the development server:
```bash
npm run dev
```

The app will be available at `http://localhost:3000`

## Project Structure

```
almostZero/
├── public/
│   └── german-lesson-template.csv    # CSV template for imports
├── src/
│   ├── components/
│   │   ├── auth/                      # Authentication components
│   │   ├── layout/                    # Layout components
│   │   ├── lesson/                    # Lesson display components
│   │   └── notebook/                  # Notebook editor components
│   ├── hooks/                         # Custom React hooks
│   ├── lib/
│   │   ├── auth-context.tsx          # Authentication context
│   │   ├── supabase.ts               # Supabase client
│   │   └── utils.ts                  # Utility functions
│   ├── pages/
│   │   ├── LoginPage.tsx             # Login page
│   │   ├── SignupPage.tsx            # Signup page
│   │   └── MainPage.tsx              # Main application
│   ├── types/
│   │   ├── database.types.ts         # Database types
│   │   └── index.ts                  # Exported types
│   ├── App.tsx                        # Main app component
│   ├── main.tsx                       # Entry point
│   └── index.css                      # Global styles
├── supabase/
│   └── migrations/                    # Database migrations
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## Usage

### 1. Sign Up

- Create an account with email/password
- Select your native language (Hebrew/English/Italian)
- This sets your default UI language and translation preferences

### 2. Import Lessons

#### CSV Format

Download the template from `/public/german-lesson-template.csv`

Required columns:
- `German`: German word/phrase (REQUIRED)
- `Lesson`: Lesson number (REQUIRED)
- `Category`: Display category (REQUIRED)

Optional columns:
- `Hebrew`, `English`, `Italian`: Translations
- `PartOfSpeech`: noun/verb/adjective/adverb/phrase/other
- `Gender`: der/die/das/none (for nouns)
- `Subcategory`: Additional grouping

Example:
```csv
German,Hebrew,English,Italian,Lesson,PartOfSpeech,Gender,Category,Subcategory
ich bin,אני,I am,io sono,1,verb,none,Verbs,sein
Tisch,שולחן,table,tavolo,1,noun,der,Nouns,Furniture
```

### 3. Study

- **Left Panel**: View learned material
  - Filter by lesson or category
  - Search for specific terms
  - Read-only display

- **Right Panel**: Take notes
  - Rich text editor
  - Auto-saves every 1 second
  - Markdown storage

## Database Schema

### Core Tables

- `users`: User profiles with language preferences
- `terms`: German vocabulary (normalized, unique)
- `term_translations`: Translations in multiple languages
- `lessons`: Learning lessons
- `lesson_terms`: Many-to-many mapping
- `notebooks`: User notes (Markdown)

### Key Features

- **Normalized Model**: Terms exist once, reused across lessons
- **RLS Security**: Row-level security on all tables
- **Full-Text Search**: PostgreSQL pg_trgm for fast search
- **Atomic Imports**: Transaction-safe CSV imports

## Development Phases

### Phase 1: MVP - Solo User ✅ (Current)
- User authentication
- Split-screen layout
- CSV import with de-duplication
- Basic filtering and search
- Rich text notebook

### Phase 2: Enhanced Learning (Planned)
- Practice modes (flashcards, matching)
- Spaced repetition algorithm
- Progress tracking
- JSON import
- Mistake logging

### Phase 3: Class Creator (Planned)
- Multi-user support
- Class management
- Student progress tracking
- Content sharing

### Phase 4: Collaborative (Future)
- Student contributions
- Approval workflow
- Gamification
- Advanced analytics

## Configuration

### Language Support

To add a new language, edit `src/types/index.ts`:

```typescript
export const SUPPORTED_LANGUAGES: Record<string, LanguageOption> = {
  // ... existing languages
  spanish: {
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    direction: 'ltr',
  },
}
```

### RTL Support

The app automatically detects RTL languages and applies proper text direction:

- Hebrew: RTL by default
- English, Italian: LTR
- User can switch language anytime

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## License

This project is private and proprietary.

## Support

For issues and questions, contact the project owner: Ofir

---

**Version**: 0.1.0
**Created**: 2025-11-09
**Status**: Phase 1 Development
