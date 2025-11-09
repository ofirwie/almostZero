// Deutsche Lernen - Supabase Client Configuration

import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase environment variables. Please check your .env file.'
  )
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
})

// Helper function to handle Supabase errors
export function handleSupabaseError(error: any): string {
  if (error?.message) {
    // User-friendly error messages
    const message = error.message.toLowerCase()

    if (message.includes('invalid login credentials')) {
      return 'Invalid email or password'
    }
    if (message.includes('user already registered')) {
      return 'This email is already registered'
    }
    if (message.includes('email not confirmed')) {
      return 'Please confirm your email address'
    }
    if (message.includes('permission')) {
      return 'You do not have permission to perform this action'
    }

    return error.message
  }

  return 'An unexpected error occurred'
}
