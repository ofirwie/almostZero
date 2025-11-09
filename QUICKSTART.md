# Deutsche Lernen - Quick Start Guide

התחל לעבוד עם המערכת תוך 5 דקות! ⚡

---

## שלב 1: התקנת Dependencies

```bash
npm install
```

זה יתקין את כל הספריות הנדרשות (React, TypeScript, Supabase, וכו').

---

## שלב 2: הגדרת Supabase

### 2.1 צור פרויקט Supabase

1. היכנס ל-[supabase.com](https://supabase.com)
2. לחץ על "New Project"
3. מלא פרטים:
   - **Name**: deutsche-lernen
   - **Database Password**: (שמור את זה!)
   - **Region**: בחר קרוב אליך
4. לחץ "Create new project"
5. המתן ~2 דקות עד שהפרויקט מוכן

### 2.2 העתק את המפתחות

1. לך ל-**Settings** > **API**
2. העתק:
   - **Project URL** (משהו כמו: `https://xxxxx.supabase.co`)
   - **anon/public key** (מפתח ארוך)
3. שמור לשלב הבא

### 2.3 צור קובץ `.env`

```bash
cp .env.example .env
```

ערוך את `.env` והדבק את הפרטים שלך:

```env
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

---

## שלב 3: הרץ Database Migrations

### 3.1 פתח SQL Editor בSupabase

Dashboard -> **SQL Editor** -> "New Query"

### 3.2 הרץ את ה-migrations בסדר הבא:

#### Migration 1: Schema הבסיסי

העתק והדבק את כל התוכן מ-`supabase/migrations/20250109_initial_schema.sql`

לחץ **Run** ✅

#### Migration 2: פונקציית Import

העתק והדבק את כל התוכן מ-`supabase/migrations/20250109_atomic_import_function.sql`

לחץ **Run** ✅

---

## שלב 4: צור משתמש דמו

### אופן 1: דרך ממשק Supabase (מומלץ)

1. Dashboard -> **Authentication** -> **Users**
2. לחץ **"Add user"** -> **"Create new user"**
3. מלא:
   - **Email**: `demo@deutschelernen.com`
   - **Password**: `Orion393$`
   - ✅ **Auto Confirm User** (סמן!)
4. לחץ **"Create user"**
5. המתן רגע, ואז:

#### צור את הפרופיל

פתח **SQL Editor** והרץ:

```sql
INSERT INTO public.users (id, email, name, native_language, current_language, role)
SELECT
  id,
  email,
  'Demo User',
  'hebrew',
  'hebrew',
  'student'
FROM auth.users
WHERE email = 'demo@deutschelernen.com'
ON CONFLICT (id) DO NOTHING;
```

### אופן 2: דרך הרשמה רגילה

אם אתה מעדיף, תוכל להירשם ישירות דרך האפליקציה:

1. הרץ את השרת (ראה שלב 5)
2. לך ל-`http://localhost:3000/signup`
3. הירשם עם מייל וסיסמה שלך
4. בחר **Hebrew** כשפת אם

**אבל שים לב:** בדף הכניסה העיקרי צריך להשתמש בסיסמה `Orion393$` בלבד.

---

## שלב 5: הרץ את האפליקציה

```bash
npm run dev
```

פתח את הדפדפן ב-`http://localhost:3000`

---

## שלב 6: התחבר

בדף ההתחברות:
- **הזן רק סיסמה**: `Orion393$`
- לחץ "כניסה למערכת"

🎉 **אתה בפנים!**

---

## אימות שהכל עובד

### בדוק שהטבלאות נוצרו

Supabase Dashboard -> **Table Editor**

אמור לראות:
- ✅ users
- ✅ terms
- ✅ term_translations
- ✅ lessons
- ✅ lesson_terms
- ✅ notebooks

### בדוק שהמשתמש קיים

**SQL Editor** -> הרץ:

```sql
SELECT * FROM auth.users WHERE email = 'demo@deutschelernen.com';
SELECT * FROM public.users WHERE email = 'demo@deutschelernen.com';
```

שני ה-queries צריכים להחזיר שורה אחת.

---

## השלבים הבאים

### 1. ייבא שיעור ראשון

- הורד את התבנית: `public/german-lesson-template.csv`
- ערוך אותה עם המילים שלך
- לחץ "ייבא שיעור" באפליקציה (בקרוב!)

### 2. חקור את המערכת

- **חומר לימוד** (שמאל): יראה את השיעורים שלך
- **מחברת** (ימין): כתוב הערות
- **Tooltips**: לחץ על סימני ה-ℹ️ להסברים

---

## פתרון בעיות נפוצות

### "Missing Supabase environment variables"

✅ **פתרון**: בדוק ש-`.env` קיים ומכיל את הערכים הנכונים

### "Invalid login credentials"

✅ **פתרון**: ודא שהסיסמה היא בדיוק `Orion393$` (case-sensitive!)

### "Failed to fetch"

✅ **פתרון**:
1. בדוק שהפרויקט Supabase רץ (Dashboard צריך להיות ירוק)
2. ודא שה-URL ו-KEY נכונים ב-`.env`
3. הפעל מחדש את השרת (`npm run dev`)

### משתמש לא נוצר ב-public.users

✅ **פתרון**: הרץ ידנית:

```sql
INSERT INTO public.users (id, email, name, native_language, current_language, role)
SELECT id, email, 'Demo User', 'hebrew', 'hebrew', 'student'
FROM auth.users
WHERE email = 'demo@deutschelernen.com'
ON CONFLICT (id) DO NOTHING;
```

---

## קיצורי מקלדת שימושיים

| מקש | פעולה |
|-----|-------|
| `/` | פוקוס על חיפוש |
| `Ctrl+S` | שמירת הערות |
| `Esc` | סגירת מודלים |

---

## תמיכה נוספת

- 📚 **README.md**: תיעוד מלא של הפרויקט
- 🔧 **SETUP.md**: הוראות התקנה מפורטות
- 🤝 **CONTRIBUTING.md**: איך לתרום לפרויקט

---

**גרסה**: 0.1.0
**תאריך**: 2025-11-09
**סטטוס**: Phase 1 Development

🇩🇪 **Viel Erfolg!** (בהצלחה!)
