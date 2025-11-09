# Setup Instructions - Deutsche Lernen

Complete setup guide for Deutsche Lernen German learning platform.

## Table of Contents

1. [Supabase Setup](#supabase-setup)
2. [Local Development Setup](#local-development-setup)
3. [Environment Variables](#environment-variables)
4. [Database Migration](#database-migration)
5. [First Run](#first-run)
6. [Troubleshooting](#troubleshooting)

---

## Supabase Setup

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in:
   - **Name**: deutsche-lernen
   - **Database Password**: (save this securely!)
   - **Region**: Choose closest to you
4. Click "Create new project"
5. Wait for project to be ready (~2 minutes)

### 2. Get API Credentials

1. In your Supabase project, go to **Settings** > **API**
2. Copy these values:
   - **Project URL** (under "Project URL")
   - **anon/public key** (under "Project API keys")
3. Save these for the next step

### 3. Configure Authentication

1. Go to **Authentication** > **Settings**
2. Under "Site URL", set:
   - For development: `http://localhost:3000`
   - For production: Your deployed URL
3. Under "Auth Providers", ensure:
   - **Email** is enabled
   - **Confirm email** can be disabled for development
4. Click "Save"

### 4. Run Database Migrations

1. Go to **SQL Editor** in Supabase
2. Click "New Query"
3. Copy and paste contents of `supabase/migrations/20250109_initial_schema.sql`
4. Click "Run" (bottom right)
5. Wait for success message
6. Create another new query
7. Copy and paste contents of `supabase/migrations/20250109_atomic_import_function.sql`
8. Click "Run"
9. Verify success

### 5. Verify Database Setup

1. Go to **Table Editor**
2. You should see these tables:
   - users
   - terms
   - term_translations
   - lessons
   - lesson_terms
   - notebooks

---

## Local Development Setup

### 1. Prerequisites

Ensure you have:
- Node.js 18 or higher ([download](https://nodejs.org))
- npm (comes with Node.js)
- Git
- A code editor (VS Code recommended)

Check versions:
```bash
node --version  # Should be 18+
npm --version   # Should be 9+
```

### 2. Clone Repository

```bash
git clone <repository-url>
cd almostZero
```

### 3. Install Dependencies

```bash
npm install
```

This will install:
- React & React DOM
- Supabase client
- React Query
- TipTap editor
- Tailwind CSS
- TypeScript
- And all other dependencies

---

## Environment Variables

### 1. Create `.env` File

```bash
cp .env.example .env
```

### 2. Edit `.env`

Open `.env` in your editor and add your Supabase credentials:

```env
# Supabase Configuration
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here

# App Configuration
VITE_APP_NAME=Deutsche Lernen
VITE_APP_VERSION=0.1.0
```

Replace:
- `https://your-project-id.supabase.co` with your **Project URL** from Supabase
- `your-anon-key-here` with your **anon/public key** from Supabase

### 3. Verify Configuration

The app will throw an error if these are missing, so you'll know immediately.

---

## Database Migration

Already covered in [Supabase Setup](#4-run-database-migrations), but here's a quick checklist:

- [ ] Run `20250109_initial_schema.sql` in Supabase SQL Editor
- [ ] Run `20250109_atomic_import_function.sql` in Supabase SQL Editor
- [ ] Verify tables exist in Table Editor
- [ ] Verify RLS (Row Level Security) is enabled on all tables

To verify RLS:
1. Go to **Table Editor**
2. Click on any table (e.g., `users`)
3. Click **RLS** tab
4. Should see "RLS enabled" and multiple policies

---

## First Run

### 1. Start Development Server

```bash
npm run dev
```

You should see:
```
  VITE v5.0.10  ready in 500 ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: use --host to expose
```

### 2. Open in Browser

Navigate to: `http://localhost:3000`

### 3. Create First Account

1. Click "Sign up"
2. Enter email and password
3. Select native language (Hebrew/English/Italian)
4. Click "Sign Up"
5. You should be logged in automatically

### 4. Verify User in Supabase

1. Go to Supabase **Authentication** > **Users**
2. You should see your new user
3. Go to **Table Editor** > **users** table
4. You should see your user profile with native_language set

---

## Troubleshooting

### Issue: "Missing Supabase environment variables"

**Solution**:
- Check that `.env` file exists in root directory
- Verify `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` are set
- Restart dev server after editing `.env`

### Issue: "Failed to fetch" on signup/login

**Solution**:
- Verify Supabase project is running (check Supabase dashboard)
- Check that API URL and key are correct in `.env`
- Check browser console for specific error
- Verify database migrations ran successfully

### Issue: Sign up succeeds but user not in database

**Solution**:
- Go to Supabase SQL Editor
- Run:
  ```sql
  SELECT * FROM auth.users;
  SELECT * FROM public.users;
  ```
- If user exists in `auth.users` but not `public.users`, there's an RLS issue
- Verify the "Users can create own data" policy exists on `users` table

### Issue: RLS policy errors

**Solution**:
- Verify all RLS policies from migration file are created
- Go to Table Editor > [table] > RLS tab
- Should see multiple policies for each table
- Re-run migration if policies are missing

### Issue: Import function not working

**Solution**:
- Verify `import_lesson_atomic` function exists:
  ```sql
  SELECT routine_name
  FROM information_schema.routines
  WHERE routine_name = 'import_lesson_atomic';
  ```
- If not found, re-run `20250109_atomic_import_function.sql`

### Issue: Hebrew text not displaying correctly

**Solution**:
- Ensure UTF-8 encoding in browser
- Check that `dir="rtl"` is applied to root element
- Verify Hebrew fonts are loading
- Check browser console for font errors

### Issue: "npm install" fails

**Solution**:
- Clear npm cache: `npm cache clean --force`
- Delete `node_modules` and `package-lock.json`
- Run `npm install` again
- If still failing, check Node.js version (must be 18+)

### Issue: TypeScript errors

**Solution**:
- Ensure TypeScript is installed: `npm list typescript`
- Run `npm run build` to see full error list
- Check that `tsconfig.json` exists and is valid
- Restart VS Code TypeScript server (Cmd+Shift+P > "Restart TS Server")

---

## Next Steps

Once setup is complete:

1. **Import test data**: Use the CSV template at `/public/german-lesson-template.csv`
2. **Test filtering**: Verify lessons display and filters work
3. **Test notebook**: Create notes and verify auto-save
4. **Test RTL**: Switch to Hebrew and verify text direction

---

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [React Query Documentation](https://tanstack.com/query/latest)
- [TipTap Documentation](https://tiptap.dev)
- [Tailwind CSS Documentation](https://tailwindcss.com)

---

**Last Updated**: 2025-11-09
**Version**: 0.1.0
