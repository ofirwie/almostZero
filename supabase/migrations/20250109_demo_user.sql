-- Deutsche Lernen - Demo User Setup
-- Version: 0.1.0
-- Created: 2025-11-09
-- Description: Create demo user for development phase

-- ============================================================================
-- DEMO USER CREATION
-- ============================================================================

-- NOTE: This script creates a demo user for development purposes only.
-- In production, users should register through the normal signup flow.

-- Demo user credentials:
-- Email: demo@deutschelernen.com
-- Password: Orion393$

-- IMPORTANT: Run this in Supabase SQL Editor AFTER running the initial schema.
-- This will create both an auth user and a profile entry.

-- ============================================================================
-- INSTRUCTIONS
-- ============================================================================

/*
To create the demo user:

1. Go to Supabase Dashboard -> Authentication -> Users
2. Click "Add user" -> "Create new user"
3. Fill in:
   - Email: demo@deutschelernen.com
   - Password: Orion393$
   - Auto Confirm User: YES (check this box)
4. Click "Create user"
5. Copy the user ID that was created
6. Run the SQL below, replacing YOUR_USER_ID_HERE with the actual ID

OR use the Supabase Auth API (recommended):
*/

-- If you have the user ID from the auth.users table, create the profile:
-- Replace 'YOUR_USER_ID_HERE' with the actual UUID from auth.users

/*
INSERT INTO public.users (
  id,
  email,
  name,
  native_language,
  current_language,
  role,
  preferences
) VALUES (
  'YOUR_USER_ID_HERE',  -- Replace with actual UUID from auth.users
  'demo@deutschelernen.com',
  'Demo User',
  'hebrew',
  'hebrew',
  'student',
  '{}'::jsonb
);
*/

-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================

-- After creating the user, verify it exists:
-- SELECT * FROM auth.users WHERE email = 'demo@deutschelernen.com';
-- SELECT * FROM public.users WHERE email = 'demo@deutschelernen.com';

-- ============================================================================
-- ALTERNATIVE: Manual Setup Instructions
-- ============================================================================

/*
Step-by-step manual setup:

1. Open Supabase Dashboard
2. Go to Authentication -> Users
3. Click "Add user" button
4. Enter:
   - Email: demo@deutschelernen.com
   - Password: Orion393$
   - Check "Auto Confirm User"
5. Click "Create user"
6. The system will automatically create:
   - Auth user in auth.users
   - Profile in public.users (via trigger/RPC)

If the profile is NOT auto-created, run this query in SQL Editor:

INSERT INTO public.users (
  id,
  email,
  name,
  native_language,
  current_language,
  role
)
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

*/

-- ============================================================================
-- CLEANUP (for testing - removes demo user)
-- ============================================================================

-- WARNING: This will DELETE the demo user. Use only for testing/cleanup.
-- DELETE FROM auth.users WHERE email = 'demo@deutschelernen.com';
-- DELETE FROM public.users WHERE email = 'demo@deutschelernen.com';
