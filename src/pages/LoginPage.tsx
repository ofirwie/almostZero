// Deutsche Lernen - Login Page (Simplified for Development)

import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { toast } from 'sonner'
import { useAuth } from '@/lib/auth-context'
import { handleSupabaseError } from '@/lib/supabase'
import { InfoTooltip } from '@/components/ui/Tooltip'

// Demo user for development phase
const DEMO_EMAIL = 'demo@deutschelernen.com'

export default function LoginPage() {
  const navigate = useNavigate()
  const { signIn } = useAuth()
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      await signIn(DEMO_EMAIL, password)
      toast.success('!ברוך הבא - Welcome!')
      navigate('/')
    } catch (error: any) {
      toast.error(handleSupabaseError(error))
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 px-4">
      <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-2">
            <h1 className="text-3xl font-bold text-gray-900">
              🇩🇪 Deutsche Lernen
            </h1>
            <InfoTooltip
              content={
                <div className="text-right">
                  <p className="font-semibold mb-1">פלטפורמה ללימוד גרמנית</p>
                  <p className="text-xs">
                    מערכת לניהול שיעורים, אוצר מילים ותרגול
                  </p>
                </div>
              }
              position="bottom"
            />
          </div>
          <p className="text-gray-600">German Learning Platform</p>
        </div>

        {/* Info Box */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
          <div className="flex items-start gap-2">
            <svg
              className="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fillRule="evenodd"
                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
                clipRule="evenodd"
              />
            </svg>
            <div className="text-sm text-blue-800">
              <p className="font-medium mb-1">גישה פשוטה בשלב הפיתוח</p>
              <p>הזן את הסיסמה כדי להיכנס למערכת</p>
            </div>
          </div>
        </div>

        {/* Login Form */}
        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <label
                htmlFor="password"
                className="block text-sm font-medium text-gray-700"
              >
                סיסמה / Password
              </label>
              <InfoTooltip
                content={
                  <div className="text-right">
                    <p className="mb-1">הזן את סיסמת הגישה למערכת</p>
                    <p className="text-xs text-gray-300">
                      בשלב מאוחר יותר נוסיף מערכת משתמשים מלאה
                    </p>
                  </div>
                }
                position="right"
              />
            </div>
            <input
              id="password"
              type="password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-lg"
              placeholder="••••••••"
              autoFocus
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-blue-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors text-lg"
          >
            {loading ? '...נכנס' : 'כניסה למערכת'}
          </button>
        </form>

        {/* Help Text */}
        <div className="mt-6 text-center">
          <p className="text-sm text-gray-500">
            Version 0.1.0 - Development Phase
          </p>
        </div>
      </div>
    </div>
  )
}
