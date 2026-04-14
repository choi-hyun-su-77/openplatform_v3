/**
 * ============================================================================
 * useLabel.ts — 다국어 라벨 관리 컴포저블 (locale-aware reactive)
 * ============================================================================
 *
 * 【역할】
 *   DB(fw_label)에 저장된 라벨을 locale별로 캐시하고, t() 함수로 조회한다.
 *   useLocale의 setLocale() 호출 시 자동으로 새 locale의 라벨을 재로드하며,
 *   reactive labelVersion ref가 trigger되어 모든 화면이 자동으로 갱신된다.
 *
 * 【캐시 구조】
 *   labelCache: Map<locale, Map<labelId, labelText>>
 *   - 각 locale별로 독립 캐시
 *   - locale 변경 시 새 locale 캐시가 비어 있으면 서버에서 로드
 *
 * 【반응형 처리】
 *   - labelVersion ref가 라벨 캐시 변경 시 증가
 *   - t()는 labelVersion을 의존성으로 참조하지 않지만,
 *     화면의 computed/template에서 t()를 호출하면 useLocale의 locale 변경에
 *     반응하기 위해 labelVersion을 함께 의존하도록 설계
 *
 * 【사용 예시】
 *   import { loadLabels, useLabel } from '@/composables/useLabel'
 *
 *   // App.vue 부트스트랩
 *   await loadLabels()  // 현재 locale의 라벨 로드
 *
 *   // 컴포넌트
 *   const { t } = useLabel()
 *   t('LBL_CUSTOMER_NAME')   // → '고객명' (locale=ko) 또는 'Customer Name' (locale=en)
 */

import { ref } from 'vue'
import axios from 'axios'
import { getCurrentLocale, useLocale, type SupportedLocale } from './useLocale'

/** locale별 라벨 캐시 — Map<locale, Map<labelId, labelText>> */
const labelCache = new Map<SupportedLocale, Map<string, string>>()

/** 캐시 재로드를 트리거하기 위한 reactive 버전 ref (locale 변경 시 증가) */
const labelVersion = ref(0)

/** 진행 중인 로드 Promise (중복 호출 방지) */
const loadingPromises = new Map<SupportedLocale, Promise<void>>()

/**
 * 서버에서 특정 locale의 전체 라벨을 로드하여 캐시에 저장.
 * 이미 캐시되어 있으면 즉시 반환.
 *
 * @param locale - 로케일 (생략 시 현재 활성 로케일)
 */
export async function loadLabels(locale?: SupportedLocale): Promise<void> {
  const loc = locale || getCurrentLocale()

  // 이미 캐시되어 있으면 스킵
  if (labelCache.has(loc) && labelCache.get(loc)!.size > 0) return

  // 진행 중인 로드가 있으면 그것을 재사용
  if (loadingPromises.has(loc)) return loadingPromises.get(loc)

  const promise = (async () => {
    // 부팅 시 backend 재기동 윈도우에 걸려도 포기하지 않도록 짧은 재시도.
    // /api/labels 는 permitAll 이라 인증 상태와 무관하게 접근 가능.
    const MAX_ATTEMPTS = 3
    const RETRY_DELAY_MS = 1500
    try {
      for (let attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
        try {
          const response = await axios.get('/api/labels', { params: { locale: loc } })
          if (response.data.success) {
            const data = response.data.data
            if (data && typeof data === 'object') {
              const map = new Map<string, string>()
              for (const [key, value] of Object.entries(data)) {
                map.set(key, value as string)
              }
              labelCache.set(loc, map)
              labelVersion.value++  // reactive trigger
              return
            }
          }
          // success=false 면 재시도 의미 없음 — 루프 탈출
          break
        } catch (e) {
          if (attempt < MAX_ATTEMPTS - 1) {
            await new Promise(r => setTimeout(r, RETRY_DELAY_MS))
          } else {
            console.error('Failed to load labels after retries:', e)
          }
        }
      }
    } finally {
      loadingPromises.delete(loc)
    }
  })()

  loadingPromises.set(loc, promise)
  return promise
}

/**
 * 라벨 캐시 초기화 (전체 또는 특정 locale).
 * 라벨 관리 화면에서 저장 후 호출하여 캐시 갱신.
 *
 * @param locale - 비우면 모든 locale 캐시 초기화
 */
export function clearLabelCache(locale?: SupportedLocale): void {
  if (locale) {
    labelCache.delete(locale)
  } else {
    labelCache.clear()
  }
  labelVersion.value++
}

/**
 * 개발 환경 여부 (Vite import.meta.env.DEV).
 * 라벨 미발견 시 fallback 동작이 환경에 따라 다르다.
 */
const IS_DEV = import.meta.env.DEV

/**
 * 라벨 조회 함수.
 * 현재 활성 로케일의 캐시에서 labelId에 해당하는 텍스트를 즉시 반환.
 *
 * fallback 우선순위:
 *   1. 현재 locale의 라벨 (정상 케이스)
 *   2. 'ko' 로케일의 라벨 (다른 언어에 라벨이 없을 때 한국어로 폴백)
 *   3. 호출자가 전달한 defaultText
 *   4. (개발) labelId 그대로 노출 — 누락된 라벨 발견에 도움
 *      (운영) labelId 노출 안 함 — 빈 문자열 반환하여 화면이 깨지지 않게
 *
 * @param labelId - 라벨 ID (예: 'LBL_CUSTOMER_NAME')
 * @param defaultText - 미발견 시 대체 텍스트
 * @returns 라벨 텍스트
 */
export function t(labelId: string, defaultText?: string): string {
  // labelVersion을 참조하여 reactive trigger 확보 (vue가 의존성 추적)
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const _v = labelVersion.value
  const loc = getCurrentLocale()

  // 1. 현재 locale의 라벨
  const map = labelCache.get(loc)
  const direct = map?.get(labelId)
  if (direct) return direct

  // 2. 'ko' 폴백 (다른 언어의 라벨이 누락되었을 때 한국어로)
  if (loc !== 'ko') {
    const koMap = labelCache.get('ko')
    const koValue = koMap?.get(labelId)
    if (koValue) return koValue
  }

  // 3. 호출자 defaultText
  if (defaultText) return defaultText

  // 4. 환경별 fallback
  // - 개발: labelId 그대로 노출 (누락 라벨 식별 용이)
  // - 운영: labelId가 화면에 노출되지 않게 빈 문자열
  return IS_DEV ? labelId : ''
}

// ────────────────────────────────────────────────────────────────
// 모듈 레벨 초기화: useLocale의 변경 콜백에 라벨 재로드 등록
// ────────────────────────────────────────────────────────────────
const { onLocaleChange } = useLocale()
onLocaleChange(async (newLocale) => {
  await loadLabels(newLocale)
})

/**
 * 라벨 컴포저블 (컴포넌트에서 사용)
 *
 * @returns { t, loadLabels, clearLabelCache, labelVersion }
 */
export function useLabel() {
  return {
    /** 라벨 조회 함수 — 현재 로케일 캐시에서 labelId 텍스트 반환 */
    t,
    /** 서버에서 라벨 로드 (loadLabels 함수 export) */
    loadLabels,
    /** 라벨 캐시 초기화 */
    clearLabelCache,
    /** reactive 버전 ref — template/computed에서 의존성 추적용 */
    labelVersion
  }
}
