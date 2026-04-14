/**
 * ============================================================================
 * useTransaction.ts — 서버 통신 단일 진입점 (프레임워크 핵심)
 * ============================================================================
 *
 * 【역할】
 *   모든 서버 통신은 이 컴포저블의 transaction() 함수를 통해 수행된다.
 *   DataSet 기반의 요청/응답 처리를 추상화하며, 다음 두 엔드포인트만 사용한다:
 *     - /api/dataset/search  (조회)
 *     - /api/dataset/save    (저장 — C/U/D 변경분 전송)
 *
 * 【동작 흐름】
 *   1. config.datasets에서 DataSet 객체를 직렬화 (search: row 전송, save: getChangedRows 전송)
 *   2. detectType()으로 요청 타입 자동 판별 (변경 행이 있으면 save, 없으면 search)
 *   3. axios.post()로 서버 호출
 *   4. 응답의 data를 config.out에 매핑된 DataSet에 자동 로드
 *   5. 오류 시 글로벌 토스트로 에러 메시지 표시
 *
 * 【사용 예시】
 *   const { transaction, loading, error } = useTransaction()
 *
 *   const result = await transaction({
 *     id: 'searchCustomer',
 *     serviceName: 'customer/searchList',
 *     datasets: { ds_search: ds_search },
 *     out: { ds_customer: ds_list }
 *   })
 *
 * 【참고】
 *   일반적으로 이 컴포저블은 직접 사용하지 않고,
 *   useFramework의 $transaction() (문자열 기반 매핑)을 통해 간접 호출한다.
 */

import { ref } from 'vue'
import axios from 'axios'
import type { DataSet } from './useDataSet'

/**
 * 트랜잭션 요청 설정
 */
interface TransactionConfig {
  /** 트랜잭션 식별자 (콜백에서 어떤 요청인지 구분용) */
  id: string
  /** 서버 서비스 매핑명 (예: 'customer/searchList') — @DataSetServiceMapping 값과 일치 */
  serviceName: string
  /** 서버로 전송할 DataSet 매핑 (키=서버DS명, 값=DataSet객체 또는 원시 데이터) */
  datasets?: Record<string, any>
  /** 서버 응답을 자동 로드할 DataSet 매핑 (키=서버응답DS명, 값=클라이언트DataSet) */
  out?: Record<string, DataSet>
  /** 추가 파라미터 (datasets 외에 별도 전달할 값) */
  params?: Record<string, any>
  /** true면 loading 상태를 변경하지 않음 (백그라운드 요청) */
  silent?: boolean
  /** 요청 타입 강제 지정 (생략 시 자동 판별) */
  type?: 'search' | 'save'
  /** 호출 페이지명 (서비스 로그 추적용) */
  _caller?: string
}

/**
 * 트랜잭션 응답 결과
 */
interface TransactionResult {
  /** 성공 여부 */
  success: boolean
  /** 서버 응답 데이터 (DataSet별로 구분된 객체) */
  data: Record<string, any>
  /** 서버 메시지 (성공/실패 메시지) */
  message: string | null
}

/** 전역 토스트 인스턴스 — App.vue에서 setGlobalToast()로 설정 */
let globalToast: any = null

/**
 * 전역 토스트 인스턴스 설정
 * App.vue의 setup에서 호출하여 에러 토스트를 표시할 수 있게 함
 *
 * @param toast - PrimeVue useToast() 인스턴스
 */
export function setGlobalToast(toast: any) {
  globalToast = toast
}

/**
 * 서버 통신 컴포저블
 *
 * @returns { transaction, loading, error }
 *   - transaction: 서버 통신 실행 함수
 *   - loading: 통신 중 여부 (ref)
 *   - error: 마지막 오류 메시지 (ref)
 */
export function useTransaction() {
  /** 서버 통신 진행 중 여부 (UI 로딩 표시에 바인딩) */
  const loading = ref(false)
  /** 마지막 오류 메시지 (null이면 오류 없음) */
  const error = ref<string | null>(null)

  /**
   * 서버 트랜잭션 실행
   *
   * 동작 흐름:
   * 1. config.type이 없으면 detectType()으로 search/save 자동 판별
   * 2. config.datasets의 각 항목을 직렬화:
   *    - DataSet 객체(getChangedRows 보유): save면 변경분, search면 row(파라미터) 전송
   *    - { rows: [...] } 형태: 그대로 전송
   *    - 기타 객체: 그대로 전송
   * 3. /api/dataset/search 또는 /api/dataset/save로 POST 요청
   * 4. 성공 시 config.out에 매핑된 DataSet에 응답 데이터 자동 로드
   * 5. 실패 시 에러 토스트 표시 (401/403은 인터셉터가 처리하므로 제외)
   *
   * @param config - 트랜잭션 설정 객체
   * @returns { success, data, message }
   */
  async function transaction(config: TransactionConfig): Promise<TransactionResult> {
    // silent 모드가 아니면 로딩 상태 활성화
    if (!config.silent) loading.value = true
    error.value = null

    try {
      // 요청 타입 결정: 명시적으로 지정되었으면 사용, 아니면 자동 판별
      const type = config.type || detectType(config)

      // 서버 요청 본문 구성
      const body: any = {
        serviceName: config.serviceName,
        _caller: config._caller || '',
        datasets: {}
      }

      // ── datasets 직렬화 ──
      if (config.datasets) {
        for (const [key, value] of Object.entries(config.datasets)) {
          if (value && typeof value === 'object' && 'getChangedRows' in value) {
            // DataSet 객체인 경우
            const ds = value as DataSet
            // 저장 전 북마크 설정 (재조회 후 선택 행 복원용)
            ds.bookmark()
            if (type === 'save') {
              // save 요청: 변경분(C/U/D)만 추출하여 전송
              body.datasets[key] = { rows: ds.getChangedRows() }
            } else {
              // search 요청: 검색 파라미터(row 객체)만 전송
              body.datasets[key] = ds.row || {}
            }
          } else if (value && typeof value === 'object' && 'rows' in value) {
            // { rows: [...] } 형태로 직접 전달된 경우 — 그대로 전송
            body.datasets[key] = value
          } else if (value && typeof value === 'object' && 'row' in value) {
            // DataSet의 row만 전달하는 경우
            body.datasets[key] = (value as DataSet).row
          } else {
            // 기타 원시 값 — 그대로 전송
            body.datasets[key] = value
          }
        }
      }

      // 추가 파라미터가 있으면 본문에 포함
      if (config.params) {
        body.params = config.params
      }

      // ── API 호출 (단일 엔드포인트 패턴) ──
      const url = type === 'save' ? '/api/dataset/save' : '/api/dataset/search'
      const response = await axios.post(url, body)
      const result = response.data as TransactionResult

      // 서버에서 success=false 응답 시 에러 처리
      if (!result.success) {
        throw new Error(result.message || '서버 오류가 발생했습니다.')
      }

      // ── 응답 데이터를 출력 DataSet에 자동 로드 ──
      if (config.out && result.data) {
        for (const [key, ds] of Object.entries(config.out)) {
          if (result.data[key]) {
            const outData = result.data[key]
            if (Array.isArray(outData)) {
              // 배열 형태의 응답 → 바로 로드
              ds.load(outData)
            } else if (outData.rows) {
              // { rows: [...] } 형태의 응답 → rows 추출 후 로드
              ds.load(outData.rows)
            }
          }
        }
      }

      // 서버 메시지 자동 토스트 제거 — 각 페이지에서 msg.byId()로 명시적으로 처리

      return result
    } catch (err: any) {
      const status = err.response?.status
      // 401/403은 axios 인터셉터에서 로그인 페이지로 리다이렉트 → 토스트 불필요
      if (status === 401 || status === 403) {
        return { success: false, data: {}, message: '' }
      }

      // 에러 메시지 추출 (서버 응답 > JS 에러 > 기본 메시지)
      const msg = err.response?.data?.message || err.message || '서버 통신 오류'
      error.value = msg

      // 전역 토스트로 에러 표시
      if (globalToast) {
        globalToast.add({ severity: 'error', summary: '오류', detail: msg, life: 5000 })
      }

      return { success: false, data: {}, message: msg }
    } finally {
      // 로딩 상태 복원 (silent 모드가 아닌 경우에만)
      if (!config.silent) loading.value = false
    }
  }

  /**
   * 요청 타입 자동 판별
   *
   * datasets 내 DataSet 객체 중 getChangedRows()가 비어있지 않으면 'save',
   * 또는 직접 전달된 { rows: [...] }에 _rowType이 있으면 'save',
   * 그 외에는 'search'로 판별
   *
   * @param config - 트랜잭션 설정
   * @returns 'search' 또는 'save'
   */
  function detectType(config: TransactionConfig): 'search' | 'save' {
    if (config.datasets) {
      for (const value of Object.values(config.datasets)) {
        // DataSet 객체: 변경된 행이 있으면 save
        if (value && typeof value === 'object' && 'getChangedRows' in value) {
          const ds = value as DataSet
          if (ds.getChangedRows().length > 0) {
            return 'save'
          }
          continue
        }
        // 직접 전달된 { rows: [...] } 형태: _rowType이 있는 행이 있으면 save
        if (value && typeof value === 'object' && 'rows' in value) {
          const rows = (value as any).rows
          if (Array.isArray(rows) && rows.some((r: any) => r._rowType)) {
            return 'save'
          }
        }
      }
    }
    return 'search'
  }

  return {
    /** 서버 트랜잭션 실행 함수 — config 객체로 서비스명/DataSet/출력 매핑 등을 설정하여 호출 */
    transaction,
    /** 서버 통신 진행 중 여부 (Ref<boolean>) — UI 로딩 표시에 바인딩 */
    loading,
    /** 마지막 오류 메시지 (Ref<string|null>) — null이면 오류 없음 */
    error
  }
}
