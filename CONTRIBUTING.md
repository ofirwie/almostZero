# Contributing to Deutsche Lernen

Thank you for your interest in contributing to Deutsche Lernen!

## Development Workflow

### 1. Branch Naming

Use descriptive branch names:
- `feature/` - New features (e.g., `feature/spaced-repetition`)
- `fix/` - Bug fixes (e.g., `fix/rtl-alignment`)
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions

### 2. Commit Messages

Follow the format:
```
type: brief description

Longer explanation if needed

Fixes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting changes
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat: add flashcard practice mode

Implements basic flashcard mode with front/back flip animation.
Uses existing term data from lessons.

Fixes #45
```

```
fix: correct RTL text alignment in tables

Hebrew text was aligning left instead of right.
Added text-right class to RTL mode table cells.

Fixes #67
```

### 3. Code Style

- **TypeScript**: Use strict mode, avoid `any` when possible
- **React**: Functional components with hooks
- **CSS**: Tailwind utility classes, avoid custom CSS when possible
- **Formatting**: Prettier (runs on save in VS Code)
- **Linting**: ESLint (fix before committing)

### 4. Testing

Before submitting a PR:

1. **Manual Testing**:
   - Test in Chrome and Firefox
   - Test RTL mode (Hebrew)
   - Test responsive design (mobile, tablet, desktop)
   - Test authentication flows

2. **Check for Errors**:
   ```bash
   npm run lint
   npm run build
   ```

3. **Verify Types**:
   - No TypeScript errors in VS Code
   - Build succeeds without type errors

### 5. Pull Request Process

1. **Create PR**:
   - Use a descriptive title
   - Reference related issues
   - Describe what changed and why
   - Include screenshots for UI changes

2. **PR Template**:
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] Tested locally
   - [ ] Tested RTL mode
   - [ ] Tested responsive design
   - [ ] No console errors

   ## Screenshots
   (if applicable)

   ## Related Issues
   Fixes #123
   ```

3. **Review Process**:
   - Address review comments
   - Keep commits clean (squash if needed)
   - Ensure CI passes (when available)

## Project Structure

### Adding a New Component

1. Create component file in appropriate directory:
   ```
   src/components/[category]/[ComponentName].tsx
   ```

2. Use TypeScript with proper types:
   ```typescript
   interface ComponentProps {
     title: string
     onClose: () => void
   }

   export default function Component({ title, onClose }: ComponentProps) {
     // ...
   }
   ```

3. Export from index if needed:
   ```typescript
   // src/components/[category]/index.ts
   export { default as Component } from './Component'
   ```

### Adding a Database Table

1. Create migration file:
   ```sql
   -- supabase/migrations/YYYYMMDD_description.sql
   ```

2. Include:
   - Table creation
   - Indexes
   - RLS policies
   - Comments

3. Update TypeScript types:
   ```typescript
   // src/types/database.types.ts
   export interface NewTable {
     // ...
   }
   ```

### Adding a New Language

1. Update language constants:
   ```typescript
   // src/types/index.ts
   export const SUPPORTED_LANGUAGES = {
     // ... existing
     spanish: {
       code: 'es',
       name: 'Spanish',
       nativeName: 'Español',
       direction: 'ltr',
     },
   }
   ```

2. Add translations:
   - Create translation files if needed
   - Update UI strings

3. Test RTL if applicable

## Database Guidelines

### RLS Policies

Always include RLS policies for new tables:

```sql
ALTER TABLE public.new_table ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own data" ON public.new_table
  FOR SELECT USING (auth.uid() = user_id);
```

### Indexes

Add indexes for:
- Foreign keys
- Frequently queried columns
- Text search columns (with pg_trgm)

```sql
CREATE INDEX idx_table_column ON public.table(column);
CREATE INDEX idx_table_text_trgm ON public.table USING gin (text_column gin_trgm_ops);
```

## Common Tasks

### Run Development Server
```bash
npm run dev
```

### Build for Production
```bash
npm run build
```

### Preview Production Build
```bash
npm run preview
```

### Lint Code
```bash
npm run lint
```

### Format Code
```bash
npx prettier --write .
```

## Questions?

If you have questions:
1. Check existing documentation (README, SETUP)
2. Search closed issues on GitHub
3. Ask in discussions (if available)
4. Contact project maintainer

---

Thank you for contributing! 🙏
