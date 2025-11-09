// Deutsche Lernen - Main Application Page

import { useState } from 'react'
import { useAuth } from '@/lib/auth-context'
import { isRTL, SUPPORTED_LANGUAGES } from '@/types'
import { InfoTooltip } from '@/components/ui/Tooltip'

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
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold text-gray-900">
                🇩🇪 Deutsche Lernen
              </h1>
              <InfoTooltip
                content={
                  <div className="text-right">
                    <p className="font-semibold mb-1">המסך הראשי</p>
                    <p className="text-xs mb-2">
                      כאן תוכל לראות את כל החומר שלך ולכתוב הערות
                    </p>
                    <ul className="text-xs space-y-1">
                      <li>📚 שמאל: חומר לימוד מהשיעורים</li>
                      <li>📝 ימין: מחברת הערות אישית</li>
                    </ul>
                  </div>
                }
                position="bottom"
              />
            </div>

            <div className="flex items-center gap-4">
              {/* Language Selector */}
              <div className="flex items-center gap-2">
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
                <InfoTooltip
                  content={
                    <div className="text-right">
                      <p className="font-semibold mb-1">בחירת שפה</p>
                      <p className="text-xs">
                        שנה את שפת הממשק והתרגומים
                      </p>
                    </div>
                  }
                  position="bottom"
                />
              </div>

              {/* User Menu */}
              <div className="flex items-center gap-2">
                <span className="text-sm text-gray-700">
                  {user?.email}
                </span>
                <button
                  onClick={handleSignOut}
                  className="px-4 py-2 text-sm text-gray-700 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors"
                >
                  {rtl ? 'יציאה' : 'Sign Out'}
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
            <div className="flex items-center gap-2 mb-4">
              <h2 className="text-xl font-semibold text-gray-900">
                {rtl ? 'חומר לימוד' : 'Material View'}
              </h2>
              <InfoTooltip
                content={
                  <div className="text-right" style={{ maxWidth: '250px' }}>
                    <p className="font-semibold mb-2">📚 חלונית חומר הלימוד</p>
                    <p className="text-xs mb-2">
                      כאן יופיעו כל השיעורים שתייבא למערכת:
                    </p>
                    <ul className="text-xs space-y-1 mr-4">
                      <li>• טבלאות עם מילים ופעלים בגרמנית</li>
                      <li>• תרגום לעברית, אנגלית ואיטלקית</li>
                      <li>• סינון לפי שיעור או קטגוריה</li>
                      <li>• חיפוש מהיר של מילים</li>
                    </ul>
                    <p className="text-xs mt-2 text-gray-300">
                      החומר כאן הוא לקריאה בלבד
                    </p>
                  </div>
                }
                position="left"
              />
            </div>

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
              <div className="flex items-center gap-2 justify-center">
                <button className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                  {rtl ? 'ייבא שיעור' : 'Import Lesson'}
                </button>
                <InfoTooltip
                  content={
                    <div className="text-right">
                      <p className="font-semibold mb-1">ייבוא שיעורים</p>
                      <p className="text-xs mb-2">
                        העלה קובץ CSV עם מילים גרמניות והתרגומים שלהן
                      </p>
                      <p className="text-xs text-gray-300">
                        תבנית לדוגמה זמינה להורדה
                      </p>
                    </div>
                  }
                  position="top"
                />
              </div>
            </div>
          </div>

          {/* Right Panel - Notebook */}
          <div className="bg-white rounded-lg shadow-lg p-6 overflow-auto">
            <div className="flex items-center gap-2 mb-4">
              <h2 className="text-xl font-semibold text-gray-900">
                {rtl ? 'המחברת שלי' : 'My Notebook'}
              </h2>
              <InfoTooltip
                content={
                  <div className="text-right" style={{ maxWidth: '250px' }}>
                    <p className="font-semibold mb-2">📝 מחברת אישית</p>
                    <p className="text-xs mb-2">
                      כאן תוכל לכתוב הערות חופשיות:
                    </p>
                    <ul className="text-xs space-y-1 mr-4">
                      <li>• רשימות של מילים חשובות</li>
                      <li>• הערות למבחן</li>
                      <li>• דוגמאות שהמורה נתנה בכיתה</li>
                      <li>• תזכורות לתרגול</li>
                    </ul>
                    <p className="text-xs mt-2 text-gray-300">
                      הכל נשמר אוטומטית בענן
                    </p>
                  </div>
                }
                position="right"
              />
            </div>

            <div className="empty-state">
              <div className="text-6xl mb-4">📝</div>
              <p className="text-gray-500 mb-2">
                {rtl
                  ? 'רשומות שלך יופיעו כאן'
                  : 'Your notes will appear here'}
              </p>
              <p className="text-sm text-gray-400">
                {rtl
                  ? 'לחץ כדי להתחיל לכתוב...'
                  : 'Click to start writing...'}
              </p>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}
