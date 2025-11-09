// Deutsche Lernen - Utility Functions

import { Language, LanguageDisplay, SUPPORTED_LANGUAGES } from '@/types'

/**
 * Convert language display name to ISO code
 * Example: 'hebrew' -> 'he'
 */
export function languageDisplayToCode(display: LanguageDisplay): Language {
  const lang = SUPPORTED_LANGUAGES[display]
  return (lang?.code || 'en') as Language
}

/**
 * Check if a language is RTL
 */
export function isRTL(language: LanguageDisplay): boolean {
  return SUPPORTED_LANGUAGES[language]?.direction === 'rtl'
}

/**
 * Normalize German text (trim, preserve umlauts)
 */
export function normalizeGerman(text: string): string {
  return text.trim()
}

/**
 * Remove UTF-8 BOM if present
 */
export function removeBOM(text: string): string {
  return text.replace(/^\uFEFF/, '')
}

/**
 * Format date for display
 */
export function formatDate(date: string | Date): string {
  const d = typeof date === 'string' ? new Date(date) : date
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  }).format(d)
}

/**
 * Format time ago (e.g., "2 minutes ago")
 */
export function timeAgo(date: string | Date): string {
  const d = typeof date === 'string' ? new Date(date) : date
  const seconds = Math.floor((new Date().getTime() - d.getTime()) / 1000)

  const intervals = {
    year: 31536000,
    month: 2592000,
    week: 604800,
    day: 86400,
    hour: 3600,
    minute: 60,
    second: 1,
  }

  for (const [name, value] of Object.entries(intervals)) {
    const interval = Math.floor(seconds / value)
    if (interval >= 1) {
      return `${interval} ${name}${interval === 1 ? '' : 's'} ago`
    }
  }

  return 'just now'
}

/**
 * Debounce function
 */
export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: ReturnType<typeof setTimeout> | null = null

  return function executedFunction(...args: Parameters<T>) {
    const later = () => {
      timeout = null
      func(...args)
    }

    if (timeout) clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

/**
 * Class name helper (simple alternative to clsx)
 */
export function cn(...classes: (string | undefined | null | false)[]): string {
  return classes.filter(Boolean).join(' ')
}
