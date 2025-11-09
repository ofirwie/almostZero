// Deutsche Lernen - Main Application Page

import { useState } from 'react'
import { useAuth } from '@/lib/auth-context'
import { isRTL, SUPPORTED_LANGUAGES } from '@/types'

export default function MainPage() {
  const { user, signOut } = useAuth()
  const [currentLanguage, setCurrentLanguage] = useState(
    user?.current_language || 'hebrew'
  )

  const rtl = isRTL(currentLanguage)
  const languageInfo = SUPPORTED_LANGUAGES[currentLanguage]

  const handleSignOut = async () => {
    try {
      await signOut()
    } catch (error) {
      console.error('Error signing out:', error)
    }
  }

  return (
    <div
      dir={rtl ? 'rtl' : 'ltr'}
      className={`min-h-screen bg-gray-50 ${rtl ? 'rtl-mode' : 'ltr-mode'}`}
    >
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <h1 className="text-2xl font-bold text-gray-900">
                🇩🇪 Deutsche Lernen
              </h1>
            </div>

            <div className="flex items-center space-x-4">
              {/* Language Selector */}
              <select
                value={currentLanguage}
                onChange={(e) => setCurrentLanguage(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                {Object.entries(SUPPORTED_LANGUAGES).map(([key, lang]) => (
                  <option key={key} value={key}>
                    {lang.nativeName}
                  </option>
                ))}
              </select>

              {/* User Menu */}
              <div className="flex items-center space-x-2">
                <span className="text-sm text-gray-700">
                  {user?.email}
                </span>
                <button
                  onClick={handleSignOut}
                  className="px-4 py-2 text-sm text-gray-700 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors"
                >
                  Sign Out
                </button>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content - Split Screen */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 h-[calc(100vh-200px)]">
          {/* Left Panel - Material View */}
          <div className="bg-white rounded-lg shadow-lg p-6 overflow-auto">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">
              {rtl ? 'חומר לימוד' : 'Material View'}
            </h2>

            <div className="empty-state">
              <div className="text-6xl mb-4">📚</div>
              <h3 className="text-lg font-semibold text-gray-700 mb-2">
                {rtl ? 'אין שיעורים עדיין' : 'No lessons yet'}
              </h3>
              <p className="text-gray-500 mb-4">
                {rtl
                  ? 'התחל על ידי ייבוא השיעור הראשון שלך'
                  : 'Start by importing your first lesson'}
              </p>
              <button className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                {rtl ? 'ייבא שיעור' : 'Import Lesson'}
              </button>
            </div>
          </div>

          {/* Right Panel - Notebook */}
          <div className="bg-white rounded-lg shadow-lg p-6 overflow-auto">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">
              {rtl ? 'המחברת שלי' : 'My Notebook'}
            </h2>

            <div className="empty-state">
              <div className="text-6xl mb-4">📝</div>
              <p className="text-gray-500">
                {rtl
                  ? 'רשומות שלך יופיעו כאן'
                  : 'Your notes will appear here'}
              </p>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}
