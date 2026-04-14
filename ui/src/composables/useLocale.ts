/**
 * ============================================================================
 * useLocale.ts — 다국어 로케일 관리 컴포저블 (전역 reactive 상태)
 * ============================================================================
 *
 * 【역할】
 *   현재 사용자의 언어 설정을 전역 reactive 상태로 관리한다.
 *   localStorage에 영속화되며, 언어 변경 시 라벨/메시지/코드 캐시를
 *   자동으로 새 언어로 재로드하고, 모든 화면이 reactive하게 갱신된다.
 *
 * 【저장 우선순위】
 *   1. localStorage 'app_locale' (디바이스 설정)
 *   2. 로그인 응답의 user.preferredLocale (사용자 프로필 — 로그인 시 반영)
 *   3. 브라우저 언어 (navigator.language)
 *   4. 기본값 'ko'
 *
 * 【사용 예시】
 *   import { useLocale } from '@/composables/useLocale'
 *   const { locale, setLocale, supportedLocales } = useLocale()
 *
 *   // 현재 언어 표시
 *   <div>{{ locale }}</div>
 *
 *   // 언어 변경 (캐시 자동 재로드)
 *   await setLocale('en')
 *
 * 【멀티 인스턴스 안전성】
 *   - 사용자 언어 설정은 클라이언트에 영속화되므로 인스턴스 간 동기화 불필요
 *   - 라벨/메시지/코드 캐시는 백엔드 Redis Pub/Sub로 동기화 (CacheService)
 *   - JWT stateless 인증이라 세션 클러스터링도 영향 없음
 */

import { ref, computed } from 'vue'
import axios from 'axios'

/** localStorage 키: 사용자가 마지막으로 선택한 언어 */
const STORAGE_KEY = 'app_locale'

/** 지원 로케일 (백엔드 CacheService.SUPPORTED_LOCALES와 일치해야 함) */
export const SUPPORTED_LOCALES = ['ko', 'en', 'zh', 'ja'] as const
export type SupportedLocale = typeof SUPPORTED_LOCALES[number]

/** 로케일 표시 이름 (UI 드롭다운 표시용) */
export const LOCALE_LABELS: Record<SupportedLocale, string> = {
  ko: '한국어',
  en: 'English',
  zh: '简体中文',
  ja: '日本語'
}

/** 로케일 short code (헤더 버튼 표시용) */
export const LOCALE_SHORT: Record<SupportedLocale, string> = {
  ko: 'KO',
  en: 'EN',
  zh: 'ZH',
  ja: 'JA'
}

/**
 * 초기 로케일 결정:
 *   localStorage > navigator.language > 'ko'
 */
function detectInitialLocale(): SupportedLocale {
  // 1. localStorage 우선
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored && (SUPPORTED_LOCALES as readonly string[]).includes(stored)) {
    return stored as SupportedLocale
  }

  // 2. 브라우저 언어 (예: 'ko-KR' → 'ko')
  const browser = (navigator.language || 'ko').toLowerCase().split('-')[0]
  if ((SUPPORTED_LOCALES as readonly string[]).includes(browser)) {
    return browser as SupportedLocale
  }

  // 3. 기본값
  return 'ko'
}

// ────────────────────────────────────────────────────────────────
// 전역 reactive 상태 (모듈 레벨 — 모든 컴포넌트가 같은 인스턴스 공유)
// ────────────────────────────────────────────────────────────────

/** 현재 활성 로케일 (reactive) */
const currentLocale = ref<SupportedLocale>(detectInitialLocale())

/** 캐시 재로드 콜백 — useLabel/useMessage/useCodes가 등록 */
type ReloadCallback = (newLocale: SupportedLocale) => Promise<void> | void
const reloadCallbacks: ReloadCallback[] = []

/**
 * 다국어 컴포저블
 *
 * @returns {
 *   locale,                   // 현재 로케일 (ComputedRef<string>)
 *   setLocale(loc),           // 로케일 변경 (캐시 재로드 + localStorage 저장)
 *   supportedLocales,         // 지원 로케일 목록
 *   localeLabels,             // 로케일 표시명 매핑
 *   localeShort,              // 로케일 약어 매핑
 *   onLocaleChange(cb)        // 캐시 재로드 콜백 등록 (useLabel 등에서 호출)
 * }
 */
export function useLocale() {
  /** 현재 로케일 (computed로 노출 — 외부에서 직접 set 못 하게 보호) */
  const locale = computed(() => currentLocale.value)

  /**
   * 로케일을 변경한다.
   * - localStorage에 영속화
   * - 모든 등록된 reloadCallbacks를 순차 실행하여 캐시 재로드
   * - axios 기본 헤더에도 반영
   *
   * @param newLocale 변경할 로케일 (예: 'ko', 'en')
   */
  async function setLocale(newLocale: SupportedLocale): Promise<void> {
    if (!(SUPPORTED_LOCALES as readonly string[]).includes(newLocale)) {
      console.warn(`[useLocale] Unsupported locale: ${newLocale}`)
      return
    }
    if (currentLocale.value === newLocale) return

    currentLocale.value = newLocale
    localStorage.setItem(STORAGE_KEY, newLocale)

    // axios 기본 헤더 갱신 (이후 모든 요청에 자동 첨부)
    axios.defaults.headers.common['X-Locale'] = newLocale
    axios.defaults.headers.common['Accept-Language'] = newLocale

    // 등록된 모든 캐시 재로드 콜백 순차 실행
    for (const cb of reloadCallbacks) {
      try {
        await cb(newLocale)
      } catch (e) {
        console.error('[useLocale] Reload callback failed:', e)
      }
    }

    // 사용자 정보(menus 포함) 새 locale로 재로드
    // 사이드바 menu_name이 새 locale로 갱신되도록 한다.
    // authStore를 동적 import로 가져와 순환 참조를 피한다.
    try {
      const { useAuthStore } = await import('@/store/auth')
      const authStore = useAuthStore()
      if (authStore.isAuthenticated) {
        await authStore.loadUserInfo()
        // 열린 탭 제목을 새 locale의 메뉴명으로 갱신
        const { useTabStore } = await import('@/store/tab')
        const tabStore = useTabStore()
        tabStore.refreshTitles(authStore.menus as Record<string, unknown>[])
      }
    } catch (e) {
      console.error('[useLocale] Failed to reload user info:', e)
    }
  }

  /**
   * 로케일 변경 시 호출될 콜백을 등록한다.
   * useLabel/useMessage/useCodes에서 자신의 캐시 클리어+재로드 함수를 등록.
   * 모듈 레벨이므로 한 번만 등록되면 충분 (중복 등록 방지 필요).
   *
   * @param cb 로케일 변경 시 호출될 콜백
   */
  function onLocaleChange(cb: ReloadCallback): void {
    if (!reloadCallbacks.includes(cb)) {
      reloadCallbacks.push(cb)
    }
  }

  return {
    /** 현재 로케일 (ComputedRef<SupportedLocale>) */
    locale,
    /** 로케일 변경 함수 — localStorage 저장 + 캐시 재로드 + 헤더 갱신 */
    setLocale,
    /** 지원 로케일 목록 (readonly) */
    supportedLocales: SUPPORTED_LOCALES,
    /** 로케일 표시명 매핑 (예: 'ko' → '한국어') */
    localeLabels: LOCALE_LABELS,
    /** 로케일 약어 매핑 (예: 'ko' → 'KO') */
    localeShort: LOCALE_SHORT,
    /** 캐시 재로드 콜백 등록 — useLabel/useMessage/useCodes에서 호출 */
    onLocaleChange
  }
}

/**
 * 현재 로케일을 동기적으로 가져오는 함수 (composable 외부 사용)
 * useLabel.ts, useMessage.ts 등에서 setup 컨텍스트가 아닌 곳에서 호출
 */
export function getCurrentLocale(): SupportedLocale {
  return currentLocale.value
}
