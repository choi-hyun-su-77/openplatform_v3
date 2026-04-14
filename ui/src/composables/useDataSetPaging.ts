/**
 * ============================================================================
 * useDataSetPaging.ts — DataSet 페이징 조회 컴포저블
 * ============================================================================
 *
 * 【역할】
 *   DataSet + useTransaction을 결합하여 서버 사이드 페이징을 구현한다.
 *   PrimeVue DataTable의 Paginator 이벤트와 연동하여
 *   페이지 변경 시 자동으로 서버 재조회를 수행할 수 있게 한다.
 *
 * 【페이징 파라미터】
 *   - _page: 현재 페이지 (1-based, 서버 전송용)
 *   - _pageSize: 페이지당 행 수
 *   - 서버 응답의 totalCount로 전체 건수와 전체 페이지 수 계산
 *
 * 【사용 예시】
 *   const { ds, paging, loading, search, onPage, resetPage } = useDataSetPaging('ds_list', { pageSize: 20 })
 *
 *   // 조회
 *   await search('customer/searchListPaged', ds_search, 'ds_customer')
 *
 *   // PrimeVue Paginator 이벤트
 *   <DataTable @page="onPage" :totalRecords="paging.totalRecords">
 */

import { ref, type Ref } from 'vue'
import { useDataSet, type DataSet } from './useDataSet'
import { useTransaction } from './useTransaction'

/**
 * 페이징 설정 옵션
 */
interface PagingConfig {
  /** 페이지당 행 수 (기본: 20) */
  pageSize?: number
}

/**
 * 페이징 상태 인터페이스
 */
interface PagingState {
  /** 현재 페이지 (0-based, PrimeVue Paginator 호환) */
  page: number
  /** 페이지당 행 수 */
  pageSize: number
  /** 전체 행 수 (서버에서 반환) */
  totalRecords: number
  /** 전체 페이지 수 (계산값) */
  totalPages: number
}

/**
 * DataSet 페이징 컴포저블
 *
 * @param dsName - DataSet 이름
 * @param config - 페이징 설정 (pageSize 등)
 * @returns { ds, paging, loading, search, onPage, resetPage }
 */
export function useDataSetPaging(dsName: string, config?: PagingConfig) {
  /** 데이터 저장용 DataSet */
  const ds = useDataSet(dsName)
  /** 서버 통신 함수 및 로딩 상태 */
  const { transaction, loading } = useTransaction()

  /** 페이징 상태 (반응형) */
  const paging: Ref<PagingState> = ref({
    page: 0, // 0-based (PrimeVue Paginator 호환)
    pageSize: config?.pageSize || 20,
    totalRecords: 0,
    totalPages: 0
  })

  /**
   * 페이징 조회 실행
   *
   * 동작 흐름:
   * 1. 검색 DataSet(dsSearch)의 row에 _page, _pageSize 파라미터 추가
   * 2. 서버에 조회 요청 (serviceName)
   * 3. 응답의 totalCount로 페이징 상태 업데이트
   *
   * @param serviceName - 백엔드 서비스명 (예: 'customer/searchListPaged')
   * @param dsSearch - 검색 조건 DataSet (row에 검색 파라미터 설정)
   * @param outKey - 서버 응답에서 데이터를 가져올 키명
   * @returns TransactionResult
   */
  async function search(serviceName: string, dsSearch: DataSet, outKey: string) {
    // 검색 DataSet에 페이징 파라미터 추가 (서버는 1-based 페이지)
    dsSearch.row._page = paging.value.page + 1 // PrimeVue 0-based → 서버 1-based 변환
    dsSearch.row._pageSize = paging.value.pageSize

    const result = await transaction({
      id: `${dsName}_paging_search`,
      serviceName,
      datasets: { ds_search: dsSearch },
      out: { [outKey]: ds }
    })

    // 서버 응답에서 전체 건수 추출하여 페이징 상태 업데이트
    if (result.success && result.data[outKey]) {
      const outData = result.data[outKey]
      paging.value.totalRecords = outData.totalCount || 0
      paging.value.totalPages = Math.ceil(paging.value.totalRecords / paging.value.pageSize)
    }

    return result
  }

  /**
   * PrimeVue DataTable/Paginator의 page 이벤트 핸들러
   * 페이지 변경 또는 페이지 크기 변경 시 호출
   *
   * @param event - { page: 새 페이지(0-based), rows: 페이지당 행 수 }
   */
  function onPage(event: { page: number; rows: number }) {
    paging.value.page = event.page
    paging.value.pageSize = event.rows
  }

  /**
   * 페이지를 첫 페이지(0)로 초기화
   * 검색 조건 변경 후 재조회 전 호출
   */
  function resetPage() {
    paging.value.page = 0
  }

  return {
    /** 데이터 저장용 DataSet — 서버에서 받은 현재 페이지의 행을 보관 */
    ds,
    /** 페이징 상태 (Ref) — page(0-based), pageSize, totalRecords, totalPages */
    paging,
    /** 서버 통신 진행 중 여부 (Ref<boolean>) */
    loading,
    /** 페이징 조회 실행 — 검색 DataSet에 _page/_pageSize 추가 후 서버 호출 */
    search,
    /** PrimeVue Paginator page 이벤트 핸들러 — 페이지/크기 변경 시 paging 상태 업데이트 */
    onPage,
    /** 첫 페이지로 초기화 — 검색 조건 변경 후 재조회 전 호출 */
    resetPage
  }
}
