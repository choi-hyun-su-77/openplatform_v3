/**
 * ============================================================================
 * useDataSet.ts — Dataset 변경 추적 컴포저블 (프레임워크 핵심)
 * ============================================================================
 *
 * 【역할】
 *   fw-choi 철학의 핵심인 "Dataset 중심 변경 추적"을 구현한다.
 *   모든 데이터 행(row)의 상태를 C(Create), U(Update), D(Delete)로 추적하며,
 *   저장 시 변경분(_rowType이 있는 행)만 서버로 전송하여 네트워크 효율을 극대화한다.
 *
 * 【제공 기능】
 *   - 행 추가/삭제/되돌리기 + 상태 자동 추적
 *   - 셀 단위 편집 감지 및 _original 대비 변경 여부 판별
 *   - 문자열 기반 유효성 검증 (required, number, minlength, maxlength, regex)
 *   - 커스텀 검증기 / 교차 필드 검증기
 *   - 데이터 로드/클리어/복사/머지
 *   - 북마크(재조회 후 선택 행 복원)
 *   - 셀 변경 콜백 / 행 이동 가드 / 키 필드 잠금
 *
 * 【사용 예시】
 *   const ds_list = useDataSet('ds_list', {
 *     pkField: 'customerId',
 *     rules: [
 *       { field: 'customerName', label: '고객명', rules: 'required' },
 *       { field: 'email', label: '이메일', rules: 'required,regex=^[^@]+@[^@]+$' }
 *     ]
 *   })
 *
 *   // 서버 데이터 로드
 *   ds_list.load(serverResponseRows)
 *
 *   // 새 행 추가 (C 상태)
 *   ds_list.addRow({ customerName: '신규고객' })
 *
 *   // 변경분만 추출 (서버 전송용)
 *   const changed = ds_list.getChangedRows()  // C/U/D 행만 반환
 *
 * 【_rowType 상태 전이】
 *   - undefined → 서버에서 로드된 원본 행 (변경 없음)
 *   - 'C'       → 신규 추가된 행 (addRow)
 *   - 'U'       → 수정된 행 (setCell에서 _original과 비교 후 자동 설정)
 *   - 'D'       → 삭제 표시된 행 (deleteRow에서 설정, deletedRows로 이동)
 */

import { ref, reactive, computed, watch, type Ref, type ComputedRef } from 'vue'

/**
 * 행 상태 타입
 * - 'C': Create (신규 추가)
 * - 'U': Update (수정됨)
 * - 'D': Delete (삭제 표시)
 * - undefined: 변경 없음 (원본 상태)
 */
export type RowType = 'C' | 'U' | 'D' | undefined

/**
 * DataSet의 개별 행을 나타내는 인터페이스
 */
export interface DataSetRow {
  /** 동적 필드 — 컬럼명을 키로 사용 */
  [key: string]: any
  /** 행의 변경 상태 (C/U/D/undefined) */
  _rowType?: RowType
  /** 서버에서 로드된 원본 데이터 스냅샷 (수정 여부 판별에 사용) */
  _original?: Record<string, any>
}

/**
 * 문자열 기반 유효성 검증 규칙
 * rules 문자열은 쉼표로 구분: "required,number,maxlength=10"
 */
export interface ValidationRule {
  /** 검증 대상 필드명 */
  field: string
  /** 사용자에게 표시할 필드 라벨 */
  label: string
  /** 검증 규칙 문자열 (required, number, minlength=N, maxlength=N, regex=패턴) */
  rules: string
}

/**
 * 커스텀 검증 함수 타입
 * @param value - 검증 대상 필드 값
 * @param row - 해당 행 전체 데이터
 * @returns 오류 메시지 문자열 또는 null(통과)
 */
export type CustomValidator = (value: any, row: DataSetRow) => string | null

/**
 * 교차 필드 검증 함수 타입 (여러 필드 간의 관계 검증)
 * @param row - 검증 대상 행 전체
 * @returns { valid, message } 또는 null(통과)
 */
export type CrossFieldValidator = (row: DataSetRow) => { valid: boolean; message: string } | null

/**
 * 커스텀 검증 규칙 (함수 기반)
 */
export interface CustomRule {
  /** 검증 대상 필드명 */
  field: string
  /** 사용자에게 표시할 필드 라벨 */
  label: string
  /** 커스텀 검증 함수 */
  validator: CustomValidator
}

/**
 * DataSet 생성 옵션
 */
export interface DataSetOptions {
  /** 기본키 필드명 (북마크 복원에 사용) */
  pkField?: string
  /** 초기 유효성 검증 규칙 배열 */
  rules?: ValidationRule[]
  /** DataSet 이름 (디버깅용) */
  name?: string
}

/**
 * DataSet 인터페이스 — useDataSet이 반환하는 객체의 타입 정의
 */
export interface DataSet {
  /** 전체 행 배열 (삭제 표시 행 포함) */
  rows: Ref<DataSetRow[]>
  /** 삭제 표시(D)를 제외한 화면 표시용 행 */
  visibleRows: ComputedRef<DataSetRow[]>
  /** 삭제된 행 보관소 (서버 전송 시 D 타입으로 포함) */
  deletedRows: Ref<DataSetRow[]>
  /** 현재 선택된 행의 인덱스 (visibleRows 기준, -1=선택 없음) */
  currentIndex: Ref<number>
  /** 현재 선택된 행 객체 (없으면 null) */
  selectedRow: ComputedRef<DataSetRow | null>
  /** 변경 여부 (C/U/D 행이 하나라도 있으면 true) */
  isDirty: ComputedRef<boolean>
  /** 로딩 상태 플래그 */
  loading: Ref<boolean>
  /** 검색 DataSet용 reactive 단일 행 객체 (ds_search.row.customerName 형태로 사용) */
  row: Record<string, any>

  /**
   * 새 행을 추가하고 _rowType을 'C'로 설정
   * @param defaults - 새 행의 초기값 객체
   * @returns 추가된 행의 rows 배열 내 인덱스
   */
  addRow: (defaults?: Record<string, any>) => number
  /**
   * 행을 삭제 처리 (C행은 즉시 제거, 기존 행은 D 표시 후 deletedRows로 이동)
   * @param index - visibleRows 기준 인덱스
   */
  deleteRow: (index: number) => void
  /**
   * 확인 다이얼로그를 표시한 후 행 삭제
   * @param index - visibleRows 기준 인덱스
   * @param confirmField - 확인 메시지에 표시할 필드명
   */
  deleteWithConfirm: (index: number, confirmField?: string) => Promise<void>
  /**
   * 행을 원본 상태로 되돌리기 (C행은 삭제, U행은 _original에서 복원)
   * @param index - visibleRows 기준 인덱스
   */
  revertRow: (index: number) => void
  /**
   * 행의 _rowType을 직접 설정 (rows 배열 기준 인덱스)
   * @param index - rows 배열 인덱스
   * @param type - 설정할 RowType
   */
  setRowType: (index: number, type: RowType) => void

  /**
   * 셀 값을 변경하고 변경 추적을 수행
   * _original 대비 값이 다르면 자동으로 'U' 상태로 전환
   * @param index - visibleRows 기준 인덱스
   * @param field - 변경할 필드명
   * @param value - 새 값
   */
  setCell: (index: number, field: string, value: any) => void
  /**
   * PrimeVue DataTable의 cell-edit-complete 이벤트 핸들러
   * @param event - { index, field, newValue, oldValue }
   */
  onCellEdit: (event: { index: number; field: string; newValue: any; oldValue: any }) => void

  /**
   * 서버 응답 데이터를 로드하여 DataSet을 초기화
   * 각 행에 _original 스냅샷을 저장하고 _rowType을 undefined로 설정
   * @param serverRows - 서버에서 받은 행 배열
   */
  load: (serverRows: any[]) => void
  /** DataSet을 완전 초기화 (rows, deletedRows, currentIndex 모두 리셋) */
  clear: () => void
  /**
   * 변경된 행만 추출 (C/U + deletedRows의 D)
   * 서버 저장 전송용 — _original은 제거하고 반환
   * @returns C/U/D 행 배열
   */
  getChangedRows: () => DataSetRow[]
  /**
   * 전체 행을 데이터만 추출하여 반환 (_original, _rowType 제거)
   * @returns 순수 데이터 행 배열
   */
  getAllRows: () => DataSetRow[]
  /**
   * 다른 DataSet의 전체 행을 복사하여 가져옴 (C 상태로 추가)
   * @param source - 원본 DataSet
   * @param fields - 복사할 필드명 배열 (생략 시 전체 필드)
   */
  copyFrom: (source: DataSet, fields?: string[]) => void

  /**
   * 유효성 검증 실행
   * @param changedOnly - true면 C/U 행만, false면 D 제외 전체 행 검증
   * @returns { valid, errors[] } — valid가 false면 errors에 오류 목록
   */
  validate: (changedOnly?: boolean) => { valid: boolean; errors: { field: string; label: string; message: string }[] }
  /**
   * 문자열 기반 검증 규칙을 동적으로 추가/수정
   * @param field - 필드명
   * @param label - 라벨
   * @param rules - 규칙 문자열
   */
  addRule: (field: string, label: string, rules: string) => void
  /**
   * 특정 필드의 검증 규칙 제거
   * @param field - 제거할 필드명
   */
  removeRule: (field: string) => void
  /**
   * 커스텀 함수 기반 검증 규칙 추가
   * @param field - 필드명
   * @param label - 라벨
   * @param validator - 검증 함수
   */
  addCustomRule: (field: string, label: string, validator: CustomValidator) => void
  /**
   * 교차 필드 검증 규칙 추가 (여러 필드 간의 관계 검증)
   * @param validator - 교차 필드 검증 함수
   */
  addCrossFieldRule: (validator: CrossFieldValidator) => void
  /**
   * 다른 DataSet의 데이터를 매칭 필드 기준으로 병합
   * @param source - 원본 DataSet
   * @param matchField - 매칭 기준 필드명
   * @param mergeFields - 병합할 필드명 배열
   */
  mergeFrom: (source: DataSet, matchField: string, mergeFields: string[]) => void

  /**
   * 현재 선택 행의 PK 값을 북마크에 저장
   * 재조회(load) 시 해당 PK를 가진 행으로 currentIndex를 자동 복원
   * @param pkField - PK 필드명 (생략 시 options.pkField 사용)
   */
  bookmark: (pkField?: string) => void

  /**
   * 셀 값 변경 콜백 등록 (setCell 호출 시마다 실행)
   * @param callback - (row, field, newValue, oldValue) => void
   */
  onCellChange: (callback: (row: DataSetRow, field: string, newValue: any, oldValue: any) => void) => void
  /**
   * 행 이동 가드 등록 (currentIndex 변경 전 호출, false 반환 시 이동 취소)
   * @param callback - (fromIndex, toIndex) => boolean
   */
  beforeRowChange: (callback: (fromIndex: number, toIndex: number) => boolean) => void

  /**
   * 수정 시 잠금할 필드 목록 설정 (U 상태 행의 PK 등 키 필드 보호)
   * @param fields - 잠금할 필드명 배열
   */
  lockOnUpdate: (fields: string[]) => void
  /**
   * 현재 잠금 설정된 필드 목록 반환
   * @returns 잠금 필드명 배열
   */
  getLockedFields: () => string[]

  /** DataSet 이름 (레지스트리 키 등에 사용) */
  name: string
  /** 기본키 필드명 */
  pkField: string | undefined
}

/**
 * DataSet 컴포저블 생성 함수
 *
 * @param name - DataSet 이름 (레지스트리 키, inds/outds 매핑에 사용)
 * @param options - 생성 옵션 (pkField, rules 등)
 * @returns DataSet 인터페이스 구현체
 *
 * @example
 * // 검색용 DataSet (pkField 없음 → row 객체를 파라미터로 전송)
 * const ds_search = useDataSet('ds_search')
 * ds_search.row.customerName = '홍길동'
 *
 * // 목록용 DataSet (pkField 있음 → 행 배열을 관리)
 * const ds_list = useDataSet('ds_list', {
 *   pkField: 'customerId',
 *   rules: [{ field: 'customerName', label: '고객명', rules: 'required' }]
 * })
 */
export function useDataSet(name: string, options?: DataSetOptions): DataSet {
  /** 기본키 필드명 — 북마크 복원 및 inds 전송 방식 결정에 사용 */
  const pkField = options?.pkField
  /** DataSet 식별 이름 */
  const dsName = name

  // ── 반응형 상태 ──

  /** 전체 행 배열 (D 표시 행 포함) */
  const rows = ref<DataSetRow[]>([])
  /** 삭제된 행 보관소 — 서버 전송 시 D 타입으로 포함 */
  const deletedRows = ref<DataSetRow[]>([])
  /** 현재 선택 행 인덱스 (visibleRows 기준) */
  const currentIndex = ref<number>(-1)
  /** 로딩 상태 */
  const loading = ref(false)
  /** 문자열 기반 유효성 규칙 목록 */
  const validationRules = ref<ValidationRule[]>(options?.rules || [])
  /** 커스텀 함수 기반 검증 규칙 목록 */
  const customRules = ref<CustomRule[]>([])
  /** 교차 필드 검증 함수 목록 */
  const crossFieldRules: CrossFieldValidator[] = []
  /** 수정 시 잠금 필드 목록 (U 상태에서 편집 불가) */
  const lockedFields = ref<string[]>([])
  /** 북마크 값 — 재조회 후 선택 행 복원용 PK 값 */
  const bookmarkValue = ref<any>(null)

  /** 검색 DataSet용 reactive 단일 행 (ds_search.row.xxx 형태로 양방향 바인딩) */
  const row = reactive<Record<string, any>>({})

  /** 셀 변경 콜백 함수 목록 */
  const cellChangeCallbacks: Array<(row: DataSetRow, field: string, newValue: any, oldValue: any) => void> = []
  /** 행 이동 가드 함수 (null이면 가드 없음) */
  let rowChangeGuard: ((from: number, to: number) => boolean) | null = null

  /**
   * 삭제 표시(D)를 제외한 화면 표시용 행 목록
   * PrimeVue DataTable의 :value에 바인딩
   */
  const visibleRows = computed(() => rows.value.filter(r => r._rowType !== 'D'))

  /**
   * 현재 선택된 행 객체
   * currentIndex가 유효 범위 내이면 해당 행, 아니면 null
   */
  const selectedRow = computed(() => {
    const visible = visibleRows.value
    if (currentIndex.value >= 0 && currentIndex.value < visible.length) {
      return visible[currentIndex.value]
    }
    return null
  })

  /**
   * 변경 여부 판별 (computed)
   * deletedRows에 항목이 있거나, rows 중 C/U 상태가 있으면 true
   * 저장 버튼 활성화 등에 활용
   */
  const isDirty = computed(() => {
    if (deletedRows.value.length > 0) return true
    return rows.value.some(r => r._rowType === 'C' || r._rowType === 'U')
  })

  /**
   * 서버 응답 데이터를 DataSet에 로드
   * - 각 행에 _original(원본 스냅샷)을 저장하여 나중에 변경 여부를 판별
   * - _rowType을 undefined(변경 없음)로 초기화
   * - 북마크가 있으면 해당 PK 행으로 currentIndex 복원
   *
   * @param serverRows - 서버에서 받은 원본 행 배열
   */
  function load(serverRows: any[]) {
    rows.value = serverRows.map(r => {
      // _original에 원본 스냅샷 저장 (깊은 복사)
      const newRow: DataSetRow = { ...r, _rowType: undefined, _original: { ...r } }
      return newRow
    })
    // 삭제 행 보관소 초기화
    deletedRows.value = []

    // 북마크가 설정되어 있으면 해당 PK 값을 가진 행으로 인덱스 복원
    if (bookmarkValue.value && pkField) {
      const idx = rows.value.findIndex(r => r[pkField] === bookmarkValue.value)
      currentIndex.value = idx >= 0 ? idx : (rows.value.length > 0 ? 0 : -1)
    } else {
      // 북마크 없으면 첫 번째 행 선택
      currentIndex.value = rows.value.length > 0 ? 0 : -1
    }
    // 북마크 사용 후 초기화
    bookmarkValue.value = null
  }

  /**
   * 새 행 추가
   * - _rowType을 'C'(Create)로 설정
   * - 추가된 행이 자동으로 선택됨 (currentIndex를 마지막으로 이동)
   *
   * @param defaults - 새 행의 초기값 (예: { customerType: 'A', status: 'active' })
   * @returns rows 배열 내 인덱스
   */
  function addRow(defaults?: Record<string, any>): number {
    const newRow: DataSetRow = { ...defaults, _rowType: 'C' }
    rows.value.push(newRow)
    // 새 행을 선택 상태로 설정
    currentIndex.value = visibleRows.value.length - 1
    return rows.value.length - 1
  }

  /**
   * 행 삭제 처리
   * - C(신규) 행: 즉시 배열에서 제거 (서버에 없으므로 전송 불필요)
   * - 기존 행: _rowType을 'D'로 설정하고 deletedRows로 이동
   *   → 서버 저장 시 D 타입으로 전송되어 DB에서 삭제됨
   *
   * @param index - visibleRows 기준 인덱스
   */
  function deleteRow(index: number) {
    const visible = visibleRows.value
    if (index < 0 || index >= visible.length) return

    const targetRow = visible[index]
    // visibleRows의 인덱스를 실제 rows 배열의 인덱스로 변환
    const actualIndex = rows.value.indexOf(targetRow)

    if (targetRow._rowType === 'C') {
      // 신규 행은 서버에 없으므로 바로 제거
      rows.value.splice(actualIndex, 1)
    } else {
      // 기존 행은 D 표시 후 deletedRows로 이동
      targetRow._rowType = 'D'
      deletedRows.value.push(targetRow)
      rows.value.splice(actualIndex, 1)
    }

    // 삭제 후 currentIndex가 범위를 초과하면 마지막 행으로 조정
    if (currentIndex.value >= visibleRows.value.length) {
      currentIndex.value = visibleRows.value.length - 1
    }
  }

  /**
   * 확인 다이얼로그를 표시한 후 행 삭제
   *
   * @param index - visibleRows 기준 인덱스
   * @param confirmField - 확인 메시지에 표시할 필드명 (예: 'customerName' → "홍길동을(를) 삭제하시겠습니까?")
   */
  async function deleteWithConfirm(index: number, confirmField?: string) {
    const visible = visibleRows.value
    if (index < 0 || index >= visible.length) return

    const targetRow = visible[index]
    // 확인 메시지에 표시할 값 결정
    const displayValue = confirmField ? targetRow[confirmField] : `행 ${index + 1}`

    const confirmed = window.confirm(`'${displayValue}'을(를) 삭제하시겠습니까?`)
    if (confirmed) {
      deleteRow(index)
    }
  }

  /**
   * 행을 원본 상태로 되돌리기
   * - C 행: 삭제 (addRow 자체를 취소)
   * - U 행: _original 스냅샷에서 모든 필드를 복원하고 _rowType을 undefined로 초기화
   *
   * @param index - visibleRows 기준 인덱스
   */
  function revertRow(index: number) {
    const visible = visibleRows.value
    if (index < 0 || index >= visible.length) return

    const targetRow = visible[index]
    if (targetRow._rowType === 'C') {
      // 신규 행은 되돌릴 원본이 없으므로 삭제
      deleteRow(index)
    } else if (targetRow._original) {
      // _original 스냅샷에서 필드 값 복원
      Object.keys(targetRow).forEach(key => {
        if (key !== '_rowType' && key !== '_original') {
          targetRow[key] = targetRow._original![key]
        }
      })
      // 원본으로 복원했으므로 변경 없음 상태로 초기화
      targetRow._rowType = undefined
    }
  }

  /**
   * 행의 _rowType을 직접 설정 (내부용)
   *
   * @param index - rows 배열 인덱스 (visibleRows가 아님)
   * @param type - 설정할 RowType
   */
  function setRowType(index: number, type: RowType) {
    if (index >= 0 && index < rows.value.length) {
      rows.value[index]._rowType = type
    }
  }

  /**
   * 셀 값 변경 + 자동 변경 추적
   *
   * 동작 흐름:
   * 1. 해당 셀의 값을 newValue로 업데이트
   * 2. C/D 행이 아닌 경우, _original과 비교하여 값이 다르면 'U'로 전환
   * 3. 등록된 cellChangeCallbacks를 모두 호출
   *
   * @param index - visibleRows 기준 인덱스
   * @param field - 변경할 필드명
   * @param value - 새 값
   */
  function setCell(index: number, field: string, value: any) {
    const visible = visibleRows.value
    if (index < 0 || index >= visible.length) return

    const targetRow = visible[index]
    const oldValue = targetRow[field]
    targetRow[field] = value

    // C(신규) 또는 D(삭제) 행은 상태 변경 불필요
    if (targetRow._rowType !== 'C' && targetRow._rowType !== 'D') {
      // _original 스냅샷과 비교하여 실제 변경이 있으면 'U'로 전환
      if (targetRow._original && targetRow._original[field] !== value) {
        targetRow._rowType = 'U'
      }
    }

    // 등록된 셀 변경 콜백 실행 (연쇄 계산 등에 활용)
    cellChangeCallbacks.forEach(cb => cb(targetRow, field, value, oldValue))
  }

  /**
   * PrimeVue DataTable의 cell-edit-complete 이벤트를 setCell로 위임
   *
   * @param event - PrimeVue 셀 편집 완료 이벤트 객체
   */
  function onCellEditHandler(event: { index: number; field: string; newValue: any; oldValue: any }) {
    setCell(event.index, event.field, event.newValue)
  }

  /**
   * DataSet 완전 초기화
   * rows, deletedRows, currentIndex, bookmarkValue를 모두 리셋
   */
  function clear() {
    rows.value = []
    deletedRows.value = []
    currentIndex.value = -1
    bookmarkValue.value = null
  }

  /**
   * 변경된 행만 추출하여 반환 (서버 저장 전송용)
   *
   * - C/U 행: rows에서 _original을 제외하고 추출
   * - D 행: deletedRows에서 _original을 제외하고 _rowType='D'를 명시적으로 설정
   *
   * @returns C/U/D 행 배열 (서버 전송용)
   */
  function getChangedRows(): DataSetRow[] {
    // C(신규) + U(수정) 행 추출 — _original 제거
    const changed = rows.value
      .filter(r => r._rowType === 'C' || r._rowType === 'U')
      .map(r => {
        const { _original, ...data } = r
        return data
      })

    // D(삭제) 행 추출 — deletedRows에서 가져오고 _rowType='D' 명시
    const deleted = deletedRows.value.map(r => {
      const { _original, ...data } = r
      return { ...data, _rowType: 'D' as RowType }
    })

    return [...changed, ...deleted]
  }

  /**
   * 전체 행을 순수 데이터로 반환 (_original, _rowType 제거)
   * inds에서 A(전체) 필터로 전송할 때 사용
   *
   * @returns 순수 데이터 행 배열
   */
  function getAllRows(): DataSetRow[] {
    return rows.value.map(r => {
      const { _original, _rowType, ...data } = r
      return data
    })
  }

  /**
   * 다른 DataSet의 데이터를 복사하여 가져옴
   * 복사된 행은 모두 'C'(신규) 상태로 설정
   *
   * @param source - 원본 DataSet
   * @param fields - 복사할 필드명 배열 (생략 시 전체 필드 복사)
   */
  function copyFrom(source: DataSet, fields?: string[]) {
    const sourceRows = source.getAllRows()
    if (fields) {
      // 지정된 필드만 선택적으로 복사
      rows.value = sourceRows.map(r => {
        const filtered: DataSetRow = { _rowType: 'C' }
        fields.forEach(f => {
          filtered[f] = r[f]
        })
        return filtered
      })
    } else {
      // 전체 필드 복사
      rows.value = sourceRows.map(r => ({ ...r, _rowType: 'C' }))
    }
  }

  /**
   * 유효성 검증 실행
   *
   * 검증 순서:
   * 1. 문자열 기반 규칙 (validationRules) — required, number, minlength, maxlength, regex
   * 2. 커스텀 함수 규칙 (customRules) — 비즈니스 로직 검증
   * 3. 교차 필드 규칙 (crossFieldRules) — 필드 간 관계 검증
   *
   * @param changedOnly - true(기본값)면 C/U 행만 검증, false면 D 제외 전체 행 검증
   * @returns { valid: boolean, errors: Array<{ field, label, message }> }
   */
  function validate(changedOnly = true): { valid: boolean; errors: { field: string; label: string; message: string }[] } {
    const errors: { field: string; label: string; message: string }[] = []

    // 검증 대상 행 결정 — changedOnly면 C/U만, 아니면 D 제외 전체
    const targetRows = changedOnly
      ? rows.value.filter(r => r._rowType === 'C' || r._rowType === 'U')
      : rows.value.filter(r => r._rowType !== 'D')

    for (const currentRow of targetRows) {
      // ── 1단계: 문자열 기반 검증 규칙 ──
      for (const rule of validationRules.value) {
        const value = currentRow[rule.field]
        // 쉼표로 구분된 규칙 문자열을 분리 (예: "required,maxlength=50")
        const ruleList = rule.rules.split(',').map(r => r.trim())

        for (const r of ruleList) {
          // required: 필수 입력 검증 (null, undefined, 공백 문자열)
          if (r === 'required' && (value === null || value === undefined || String(value).trim() === '')) {
            errors.push({ field: rule.field, label: rule.label, message: `${rule.label}은(는) 필수 입력입니다.` })
          }
          // number: 숫자 형식 검증
          if (r === 'number' && value !== null && value !== undefined && String(value).trim() !== '' && isNaN(Number(value))) {
            errors.push({ field: rule.field, label: rule.label, message: `${rule.label}은(는) 숫자만 입력 가능합니다.` })
          }
          // minlength=N: 최소 문자 길이 검증
          if (r.startsWith('minlength=')) {
            const min = parseInt(r.split('=')[1])
            if (value && String(value).length < min) {
              errors.push({ field: rule.field, label: rule.label, message: `${rule.label}은(는) 최소 ${min}자 이상 입력해야 합니다.` })
            }
          }
          // maxlength=N: 최대 문자 길이 검증
          if (r.startsWith('maxlength=')) {
            const max = parseInt(r.split('=')[1])
            if (value && String(value).length > max) {
              errors.push({ field: rule.field, label: rule.label, message: `${rule.label}은(는) ${max}자 이내로 입력해야 합니다.` })
            }
          }
          // regex=패턴: 정규식 패턴 검증
          if (r.startsWith('regex=')) {
            const pattern = r.substring(6)
            if (value !== null && value !== undefined && String(value).trim() !== '') {
              try {
                const regex = new RegExp(pattern)
                if (!regex.test(String(value))) {
                  errors.push({ field: rule.field, label: rule.label, message: `${rule.label}의 형식이 올바르지 않습니다.` })
                }
              } catch {
                errors.push({ field: rule.field, label: rule.label, message: `${rule.label}의 정규식 패턴이 잘못되었습니다.` })
              }
            }
          }
        }
      }

      // ── 2단계: 커스텀 함수 검증기 ──
      for (const cr of customRules.value) {
        const value = currentRow[cr.field]
        const errorMsg = cr.validator(value, currentRow)
        if (errorMsg) {
          errors.push({ field: cr.field, label: cr.label, message: errorMsg })
        }
      }

      // ── 3단계: 교차 필드 검증기 ──
      for (const cfr of crossFieldRules) {
        const result = cfr(currentRow)
        if (result && !result.valid) {
          errors.push({ field: '', label: '', message: result.message })
        }
      }
    }

    return { valid: errors.length === 0, errors }
  }

  /**
   * 문자열 기반 검증 규칙 추가 또는 수정
   * 같은 field에 대한 규칙이 이미 있으면 덮어씀
   *
   * @param field - 대상 필드명
   * @param label - 표시 라벨
   * @param rules - 규칙 문자열 (예: "required,maxlength=100")
   */
  function addRule(field: string, label: string, rules: string) {
    const existing = validationRules.value.findIndex(r => r.field === field)
    if (existing >= 0) {
      validationRules.value[existing] = { field, label, rules }
    } else {
      validationRules.value.push({ field, label, rules })
    }
  }

  /**
   * 특정 필드의 문자열 기반 검증 규칙 제거
   *
   * @param field - 제거할 필드명
   */
  function removeRule(field: string) {
    validationRules.value = validationRules.value.filter(r => r.field !== field)
  }

  /**
   * 커스텀 함수 기반 검증 규칙 추가
   * 문자열 규칙으로 표현하기 어려운 비즈니스 로직 검증에 사용
   *
   * @param field - 대상 필드명
   * @param label - 표시 라벨
   * @param validator - 검증 함수 (value, row) => errorMsg | null
   */
  function addCustomRule(field: string, label: string, validator: CustomValidator) {
    customRules.value.push({ field, label, validator })
  }

  /**
   * 교차 필드 검증 규칙 추가
   * 예: "시작일이 종료일보다 이후일 수 없습니다" 같은 필드 간 관계 검증
   *
   * @param validator - 교차 필드 검증 함수 (row) => { valid, message } | null
   */
  function addCrossFieldRule(validator: CrossFieldValidator) {
    crossFieldRules.push(validator)
  }

  /**
   * 다른 DataSet의 데이터를 매칭 필드 기준으로 병합
   *
   * 동작 흐름:
   * 1. source DataSet의 행을 matchField 값을 키로 Map에 저장
   * 2. 현재 DataSet의 각 행에서 matchField가 일치하는 source 행을 찾음
   * 3. 일치하면 mergeFields에 지정된 필드 값을 복사하고 'U' 상태로 설정
   *
   * @param source - 원본 DataSet
   * @param matchField - 매칭 기준 필드명 (예: 'productId')
   * @param mergeFields - 병합할 필드명 배열 (예: ['productName', 'price'])
   */
  function mergeFrom(source: DataSet, matchField: string, mergeFields: string[]) {
    const sourceRows = source.getAllRows()
    // matchField 값을 키로 하는 빠른 조회용 Map 생성
    const sourceMap = new Map<string, Record<string, any>>()
    for (const sr of sourceRows) {
      const key = String(sr[matchField] ?? '')
      sourceMap.set(key, sr)
    }
    // 현재 DataSet의 각 행에서 매칭하여 필드 병합
    for (const row of rows.value) {
      const key = String(row[matchField] ?? '')
      const matched = sourceMap.get(key)
      if (matched) {
        for (const f of mergeFields) {
          row[f] = matched[f]
        }
        // 병합으로 값이 변경되었으므로 C가 아니면 U로 전환
        if (row._rowType !== 'C') {
          row._rowType = 'U'
        }
      }
    }
  }

  /**
   * 현재 선택 행의 PK 값을 북마크에 저장
   *
   * 사용 시나리오:
   * 1. 저장 전 bookmark() 호출 → 현재 선택 행의 PK 저장
   * 2. 저장 후 재조회(load) 실행
   * 3. load() 내부에서 bookmarkValue를 확인하여 해당 PK 행으로 currentIndex 자동 복원
   *
   * @param pk - PK 필드명 (생략 시 options.pkField 사용)
   */
  function saveBookmark(pk?: string) {
    const field = pk || pkField
    if (field && selectedRow.value) {
      bookmarkValue.value = selectedRow.value[field]
    }
  }

  /**
   * 셀 변경 콜백 등록
   * setCell 호출 시마다 등록된 모든 콜백이 실행됨
   * 연쇄 계산(예: 수량*단가=금액)에 활용
   *
   * @param callback - (row, field, newValue, oldValue) => void
   */
  function onCellChange(callback: (row: DataSetRow, field: string, newValue: any, oldValue: any) => void) {
    cellChangeCallbacks.push(callback)
  }

  /**
   * 행 이동 가드 등록
   * currentIndex 변경 시 호출되며, false를 반환하면 이동이 취소됨
   * 예: 현재 행에 미저장 변경이 있을 때 경고
   *
   * @param callback - (fromIndex, toIndex) => boolean (false면 이동 취소)
   */
  function beforeRowChange(callback: (fromIndex: number, toIndex: number) => boolean) {
    rowChangeGuard = callback
  }

  /**
   * 수정 시 잠금할 필드 목록 설정
   * U(수정) 상태의 행에서 PK 등 키 필드의 편집을 막기 위해 사용
   *
   * @param fields - 잠금할 필드명 배열 (예: ['customerId'])
   */
  function lockOnUpdate(fields: string[]) {
    lockedFields.value = fields
  }

  /**
   * 현재 잠금 설정된 필드 목록 반환
   *
   * @returns 잠금 필드명 배열
   */
  function getLockedFields(): string[] {
    return lockedFields.value
  }

  /**
   * currentIndex 변경 감시 — 행 이동 가드 적용
   * rowChangeGuard가 등록되어 있으면 이동 전 검사하고,
   * false 반환 시 이전 인덱스로 되돌림
   */
  watch(currentIndex, (newIdx, oldIdx) => {
    if (rowChangeGuard && oldIdx !== newIdx) {
      if (!rowChangeGuard(oldIdx, newIdx)) {
        currentIndex.value = oldIdx
      }
    }
  })

  return {
    // ── 반응형 상태 ──
    /** 전체 행 배열 (D 표시 행 포함, PrimeVue DataTable에서는 visibleRows 사용) */
    rows,
    /** 삭제 표시(D)를 제외한 화면 표시용 행 (DataTable의 :value에 바인딩) */
    visibleRows,
    /** 삭제된 행 보관소 (getChangedRows에서 D 타입으로 포함하여 서버 전송) */
    deletedRows,
    /** 현재 선택된 행의 visibleRows 기준 인덱스 (-1이면 선택 없음) */
    currentIndex,
    /** 현재 선택된 행 객체 (currentIndex 기반 computed, null이면 선택 없음) */
    selectedRow,
    /** 변경 여부 — C/U/D 행이 하나라도 있으면 true (저장 버튼 활성화 등에 사용) */
    isDirty,
    /** 로딩 상태 플래그 (UI 로딩 표시에 바인딩) */
    loading,
    /** 검색 DataSet용 reactive 단일 행 객체 (ds_search.row.customerName 형태로 양방향 바인딩) */
    row,
    // ── 행 조작 ──
    /** 새 행 추가 (C 상태) — defaults로 초기값 설정, 추가된 행이 자동 선택됨 */
    addRow,
    /** 행 삭제 — C행은 즉시 제거, 기존 행은 D 표시 후 deletedRows로 이동 */
    deleteRow,
    /** 확인 다이얼로그 후 행 삭제 — confirmField로 표시할 값 지정 */
    deleteWithConfirm,
    /** 행 되돌리기 — C행은 삭제, U행은 _original에서 복원하여 변경 없음 상태로 */
    revertRow,
    /** 행의 _rowType을 직접 설정 (rows 배열 인덱스 기준, 내부 제어용) */
    setRowType,
    // ── 셀 편집 ──
    /** 셀 값 변경 + 자동 변경 추적 (_original 대비 변경 시 U 상태 전환) */
    setCell,
    /** PrimeVue DataTable cell-edit-complete 이벤트 핸들러 (setCell로 위임) */
    onCellEdit: onCellEditHandler,
    // ── 데이터 로드/초기화 ──
    /** 서버 응답 데이터 로드 — _original 스냅샷 저장 + 북마크 복원 */
    load,
    /** DataSet 완전 초기화 (rows, deletedRows, currentIndex 모두 리셋) */
    clear,
    /** 변경된 행만 추출 — C/U + deletedRows의 D (서버 저장 전송용) */
    getChangedRows,
    /** 전체 행을 순수 데이터로 반환 (_original, _rowType 제거) */
    getAllRows,
    /** 다른 DataSet의 전체 행을 복사 (모두 C 상태로 추가) */
    copyFrom,
    // ── 유효성 검증 ──
    /** 검증 실행 — changedOnly=true면 C/U만, false면 전체 (D 제외) 행 검증 */
    validate,
    /** 문자열 기반 검증 규칙 동적 추가/수정 (같은 field면 덮어씀) */
    addRule,
    /** 특정 필드의 문자열 기반 검증 규칙 제거 */
    removeRule,
    /** 커스텀 함수 기반 검증 규칙 추가 (비즈니스 로직 검증) */
    addCustomRule,
    /** 교차 필드 검증 규칙 추가 (필드 간 관계 검증, 예: 시작일 < 종료일) */
    addCrossFieldRule,
    /** 다른 DataSet의 데이터를 매칭 필드 기준으로 병합 (일치하는 행의 지정 필드 복사) */
    mergeFrom,
    // ── 북마크/콜백/가드 ──
    /** 현재 선택 행의 PK를 북마크에 저장 — 재조회(load) 시 해당 행으로 자동 복원 */
    bookmark: saveBookmark,
    /** 셀 변경 콜백 등록 — setCell 호출 시마다 실행 (연쇄 계산 등에 활용) */
    onCellChange,
    /** 행 이동 가드 등록 — false 반환 시 currentIndex 변경 취소 */
    beforeRowChange,
    /** 수정 시 잠금 필드 설정 — U 상태 행의 PK 등 키 필드 편집 방지 */
    lockOnUpdate,
    /** 현재 잠금 설정된 필드명 배열 반환 */
    getLockedFields,
    // ── 메타 정보 ──
    /** DataSet 이름 (레지스트리 키, 디버깅 식별용) */
    name: dsName,
    /** 기본키 필드명 (북마크 복원, inds 전송 방식 결정에 사용) */
    pkField
  }
}
