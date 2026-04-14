/**
 * ============================================================================
 * useCombo.ts — 서버 기반 콤보박스 데이터 조회 컴포저블
 * ============================================================================
 *
 * 【역할】
 *   서버에서 콤보박스(드롭다운) 목록을 동적으로 조회하여 캐시한다.
 *   공통코드(useCodes)와 달리, 특정 테이블에서 직접 조회하는 동적 콤보에 사용한다.
 *   예: 부서 목록, 담당자 목록, 거래처 목록 등
 *
 * 【캐시 전략】
 *   - 파라미터가 없는 콤보: comboId를 키로 캐시 (동일 ID 재요청 시 캐시 반환)
 *   - 파라미터가 있는 콤보: 캐시하지 않음 (매번 서버 조회)
 *
 * 【사용 예시】
 *   const { loadCombos, getComboOptions, getComboLabel, comboData } = useCombo()
 *
 *   // 복수 콤보 일괄 로드
 *   await loadCombos(['dept', 'manager'])
 *
 *   // PrimeVue Dropdown 옵션
 *   getComboOptions('dept')  // → [{ value: '10', label: '영업부' }, ...]
 *
 *   // 값 → 라벨 변환 (DataTable 셀 표시)
 *   getComboLabel('dept', '10')  // → '영업부'
 */

import { ref } from 'vue'
import { useTransaction } from './useTransaction'
import { useDataSet } from './useDataSet'

/**
 * 콤보박스 항목 인터페이스
 */
interface ComboItem {
  /** 값 (DB 저장용) */
  value: unknown
  /** 표시 라벨 */
  label: string
  /** 기타 동적 속성 */
  [key: string]: unknown
}

/** 모듈 레벨 콤보 캐시 — comboId를 키로 ComboItem[] 저장 */
const comboCache = new Map<string, ComboItem[]>()

/**
 * 콤보 캐시 초기화
 */
export function clearComboCache() {
  comboCache.clear()
}

/**
 * 콤보박스 데이터 조회 컴포저블
 *
 * @returns { loadCombo, loadCombos, getComboOptions, getComboLabel, comboData }
 */
export function useCombo() {
  const { transaction } = useTransaction()

  /**
   * 단일 콤보 데이터 로드
   *
   * @param comboId - 콤보 식별자 (서버의 combo/search 서비스에서 사용)
   * @param params - 조회 파라미터 (있으면 캐시 미적용)
   * @returns ComboItem 배열
   */
  async function loadCombo(comboId: string, params?: Record<string, unknown>): Promise<ComboItem[]> {
    // 파라미터가 없을 때만 캐시 키 사용 (파라미터가 있으면 매번 서버 조회)
    const cacheKey = params ? null : comboId
    if (cacheKey && comboCache.has(cacheKey)) {
      return comboCache.get(cacheKey)!
    }

    // 검색 조건 DataSet 생성
    const ds_search = useDataSet('ds_comboSearch')
    ds_search.row.comboId = comboId
    if (params) {
      Object.assign(ds_search.row, params)
    }

    // 결과 수신용 DataSet
    const ds_combo = useDataSet('ds_combo')

    // 서버 조회 (silent=true로 로딩 표시 없이 백그라운드 실행)
    const result = await transaction({
      id: `combo_${comboId}`,
      serviceName: 'combo/search',
      datasets: { ds_search },
      out: { ds_combo },
      silent: true
    })

    if (result.success) {
      // 서버 응답을 ComboItem 형태로 변환
      const items: ComboItem[] = ds_combo.visibleRows.value.map(r => ({
        ...r,
        value: r.value as unknown,
        label: r.label as string
      }))
      // 파라미터 없는 경우에만 캐시 저장
      if (cacheKey) {
        comboCache.set(cacheKey, items)
      }
      return items
    }

    return []
  }

  /** 콤보 데이터 반응형 저장소 — comboId별 ComboItem[] */
  const comboData = ref<Record<string, ComboItem[]>>({})

  /**
   * 복수 콤보 일괄 로드
   * 여러 콤보를 병렬로 조회하여 comboData에 저장
   *
   * @param comboIds - 콤보 ID 배열 (예: ['dept', 'manager'])
   */
  async function loadCombos(comboIds: string[]) {
    const promises = comboIds.map(async id => {
      comboData.value[id] = await loadCombo(id)
    })
    await Promise.all(promises)
  }

  /**
   * 콤보 옵션 배열 반환
   * PrimeVue Dropdown의 :options에 바인딩
   *
   * @param comboId - 콤보 ID
   * @returns ComboItem 배열
   */
  function getComboOptions(comboId: string): ComboItem[] {
    return comboData.value[comboId] || []
  }

  /**
   * 콤보 값에 해당하는 라벨 반환
   * DataTable 셀에서 값 → 표시 라벨 변환에 사용
   *
   * @param comboId - 콤보 ID
   * @param value - 조회할 값
   * @returns 라벨 문자열 (미발견 시 값 자체를 문자열로 반환)
   */
  function getComboLabel(comboId: string, value: unknown): string {
    const items = comboData.value[comboId] || []
    // 값 비교: 타입이 다를 수 있으므로 문자열 변환 후 비교도 수행
    const item = items.find(i => i.value === value || String(i.value) === String(value))
    return item ? item.label : String(value || '')
  }

  return {
    /** 단일 콤보 데이터 로드 — 파라미터 없으면 캐시 적용, 있으면 매번 서버 조회 */
    loadCombo,
    /** 복수 콤보 일괄 병렬 로드 — comboIds 배열의 모든 콤보를 동시에 조회 */
    loadCombos,
    /** 콤보 옵션 배열 반환 — PrimeVue Dropdown의 :options에 바인딩 */
    getComboOptions,
    /** 콤보 값→라벨 변환 — DataTable 셀에서 코드 대신 표시명을 보여줄 때 사용 */
    getComboLabel,
    /** 콤보 데이터 반응형 저장소 — comboId별 ComboItem[] 보관 */
    comboData
  }
}
