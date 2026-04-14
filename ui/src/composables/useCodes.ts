/**
 * ============================================================================
 * useCodes.ts — 공통코드 로드 + 캐시 컴포저블 (locale-aware)
 * ============================================================================
 *
 * 【역할】
 *   서버의 공통코드(fw_code)를 그룹 단위로 조회하고 locale별로 캐시하여
 *   반복 조회 시 네트워크 호출을 생략한다. 코드→명칭 변환과 드롭다운
 *   옵션 생성을 제공한다. useLocale의 setLocale() 호출 시 자동으로
 *   새 locale의 코드를 재로드하며, reactive codes ref가 갱신된다.
 *
 * 【캐시 구조】
 *   codeCache: Map<locale, Map<groupCode, CodeItem[]>>
 *
 * 【사용 예시】
 *   const { getCodeName, getOptions, codes, loaded } = useCodes(['CUSTOMER_TYPE', 'REGION'])
 *   getCodeName('CUSTOMER_TYPE', 'VIP')  // → '우수고객' (ko) / 'VIP' (en)
 *   getOptions('REGION')  // → [{ label: '서울', value: 'SEOUL' }, ...]
 */

import { ref, onMounted, watch } from 'vue'
import axios from 'axios'
import { useLocale, getCurrentLocale, type SupportedLocale } from './useLocale'

/**
 * 개별 코드 항목
 */
interface CodeItem {
  /** 코드 값 (DB 저장용) */
  code: string
  /** 코드 명칭 (현재 locale) */
  codeName: string
  /** 코드 영문 명칭 (호환용) */
  codeNameEn?: string
  /** 확장 속성 1 */
  attr1?: string
  /** 확장 속성 2 */
  attr2?: string
  /** 확장 속성 3 */
  attr3?: string
}

/** 모듈 레벨 코드 캐시 — Map<locale, Map<groupCode, CodeItem[]>> */
const codeCache = new Map<SupportedLocale, Map<string, CodeItem[]>>()

/**
 * 코드 캐시 초기화 (전체 또는 특정 locale).
 * 공통코드 관리 화면에서 코드 변경 후 호출하여 캐시 갱신.
 *
 * @param locale - 비우면 모든 locale 캐시 초기화
 */
export function clearCodeCache(locale?: SupportedLocale) {
  if (locale) {
    codeCache.delete(locale)
  } else {
    codeCache.clear()
  }
}

/**
 * 공통코드 컴포저블
 *
 * @param groupCodes - 조회할 코드 그룹 배열 (예: ['CUSTOMER_TYPE', 'REGION'])
 * @returns { codes, loaded, loadCodes, getCodeName, getOptions }
 */
export function useCodes(groupCodes: string[]) {
  /** 그룹별 코드 항목 — { 'CUSTOMER_TYPE': [{ code, codeName, ... }], ... } */
  const codes = ref<Record<string, CodeItem[]>>({})
  /** 로드 완료 여부 */
  const loaded = ref(false)

  /**
   * 서버에서 공통코드를 조회하고 캐시에 저장.
   * 캐시에 없는 그룹만 서버에 요청.
   */
  async function loadCodes() {
    const loc = getCurrentLocale()
    // 해당 locale의 캐시 맵 확보
    if (!codeCache.has(loc)) {
      codeCache.set(loc, new Map())
    }
    const localeMap = codeCache.get(loc)!

    // 캐시 미스 그룹만 필터링
    const uncached = groupCodes.filter(gc => !localeMap.has(gc))

    if (uncached.length > 0) {
      try {
        // 미캐시 그룹만 서버에 배치 요청 (locale 파라미터 함께)
        const response = await axios.get('/api/codes', {
          params: { groups: uncached.join(','), locale: loc }
        })
        if (response.data.success) {
          // 서버 응답을 그룹별로 캐시에 저장
          for (const [group, items] of Object.entries(response.data.data)) {
            localeMap.set(group, items as CodeItem[])
          }
        }
      } catch (e) {
        console.error('Failed to load codes:', e)
      }
    }

    // 요청한 모든 그룹의 코드를 캐시에서 가져와 반응형 객체에 설정
    const result: Record<string, CodeItem[]> = {}
    for (const gc of groupCodes) {
      result[gc] = localeMap.get(gc) || []
    }
    codes.value = result
    loaded.value = true
  }

  /**
   * 코드 값을 명칭으로 변환.
   *
   * @param groupCode - 코드 그룹 (예: 'CUSTOMER_TYPE')
   * @param code - 코드 값 (예: 'VIP')
   * @returns 코드 명칭 — 미발견 시 코드 값 자체 반환
   */
  function getCodeName(groupCode: string, code: string): string {
    const items = codes.value[groupCode]
    if (!items) return code
    const item = items.find(i => i.code === code)
    return item ? item.codeName : code
  }

  /**
   * PrimeVue Dropdown/Select용 옵션 배열 생성.
   *
   * @param groupCode - 코드 그룹 (예: 'REGION')
   * @returns [{ label, value }] 형태
   */
  function getOptions(groupCode: string): { label: string; value: string }[] {
    const items = codes.value[groupCode] || []
    return items.map(i => ({ label: i.codeName, value: i.code }))
  }

  // 컴포넌트 마운트 시 자동 로드
  onMounted(loadCodes)

  // useLocale의 locale이 변경되면 자동으로 코드 재로드
  // (reactive watcher — 컴포넌트 unmount 시 자동 정리)
  const { locale } = useLocale()
  watch(locale, async () => {
    // 캐시는 모듈 레벨에서 locale별로 저장되어 있으므로 다시 loadCodes만 호출
    await loadCodes()
  })

  return {
    /** 그룹별 코드 항목 반응형 객체 */
    codes,
    /** 로드 완료 여부 */
    loaded,
    /** 수동 재로드 함수 */
    loadCodes,
    /** 코드값→명칭 변환 (현재 locale 기준) */
    getCodeName,
    /** PrimeVue Dropdown/Select용 옵션 배열 생성 */
    getOptions
  }
}
