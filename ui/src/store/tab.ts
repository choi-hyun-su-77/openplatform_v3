/**
 * 탭 스토어 (store/tab.ts)
 *
 * [용도]
 * - Pinia 스토어로 메뉴 탭 상태를 전역 관리한다
 * - 헤더와 콘텐츠 영역 사이에 표시되는 탭 바의 데이터 소스
 * - 열린 탭 목록, 활성 탭, keep-alive 캐시 대상을 관리한다
 * - sessionStorage를 통해 새로고침 시에도 탭 상태를 복원한다
 *
 * [상태 (State)]
 * - tabs: 현재 열려 있는 탭 목록 (TabItem 배열)
 * - activeMenuId: 현재 활성화된 탭의 menuId
 *
 * [Getters]
 * - activeTab: 현재 활성 탭 객체 (tabs에서 activeMenuId로 조회)
 * - cachedComponentNames: keep-alive의 include 배열에 전달할 컴포넌트명 목록
 *
 * [Actions]
 * - openTab: 탭 열기 (이미 존재하면 활성화, 없으면 추가, 최대 15개 제한)
 * - closeTab: 탭 닫기 (활성 탭이면 인접 탭으로 전환, closable=false면 무시)
 * - switchTab: 탭 전환 (activeMenuId 변경)
 * - closeOthers: 지정 탭 외 모든 closable 탭 닫기
 * - closeRight: 지정 탭 우측의 closable 탭 모두 닫기
 * - closeAll: closable=true인 모든 탭 닫기 (대시보드 등 고정 탭 유지)
 * - initTabs: 초기화 — sessionStorage 복원 또는 대시보드 기본 탭 추가
 *
 * [sessionStorage 키]
 * - 'tab_tabs': 탭 목록 JSON
 * - 'tab_activeMenuId': 활성 탭 menuId
 *
 * [사용처]
 * - LayoutTabBar.vue: 탭 바 렌더링 및 탭 클릭/닫기 이벤트 처리
 * - LayoutSidebar.vue: 메뉴 클릭 시 openTab 호출
 * - LayoutDefault.vue: cachedComponentNames를 keep-alive include에 바인딩
 */
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

/**
 * 탭 항목 인터페이스
 * 탭 바에 표시되는 개별 탭의 데이터 구조를 정의한다
 */
export interface TabItem {
  /** 메뉴 고유 ID — 탭의 식별자로 사용 (fw_menu.menu_id와 매칭) */
  menuId: string
  /** 탭에 표시되는 제목 (route.meta.title 또는 메뉴명) */
  title: string
  /** 라우터 경로 (클릭 시 이동할 URL) */
  path: string
  /** PrimeIcons 클래스명 (예: 'pi pi-home') — 탭에 아이콘 표시용 */
  icon?: string
  /** keep-alive include에 사용할 컴포넌트명 (라우터 name과 매칭) */
  componentName: string
  /** 닫기 가능 여부 (false: 대시보드 등 고정 탭, true: 일반 탭) */
  closable: boolean
}

/** sessionStorage 키: 탭 목록 JSON 저장 */
const STORAGE_KEY_TABS = 'tab_tabs'
/** sessionStorage 키: 활성 탭 menuId 저장 */
const STORAGE_KEY_ACTIVE = 'tab_activeMenuId'
/** localStorage 키: 탭 스키마 버전 (마이그레이션 트리거) */
const STORAGE_KEY_SCHEMA = 'tab_schema_version'
/** 현재 탭 스키마 버전. menuId/탭 구조가 변경되면 이 값을 올려서 구버전 데이터를 자동 정리. */
const CURRENT_SCHEMA_VERSION = '2'
/** 동시에 열 수 있는 최대 탭 수 */
const MAX_TAB_COUNT = 15

/**
 * 대시보드 기본 탭
 * 초기화 시 항상 추가되며, closable=false로 닫을 수 없다
 */
const DEFAULT_DASHBOARD_TAB: TabItem = {
  menuId: 'dashboard',
  title: '대시보드',
  path: '/dashboard',
  icon: 'pi pi-home',
  componentName: 'PageDashboard',
  closable: false
}

export const useTabStore = defineStore('tab', () => {
  // ─── 상태 (State) ───

  /** 현재 열려 있는 탭 목록 */
  const tabs = ref<TabItem[]>([])

  /** 현재 활성화된 탭의 menuId */
  const activeMenuId = ref<string>('')

  /** 초기화 완료 여부 — 중복 initTabs 호출 방지 (하이버네이트 복귀 등) */
  let initialized = false

  // ─── Getters ───

  /**
   * 현재 활성 탭 객체
   * - tabs 배열에서 activeMenuId와 일치하는 탭을 찾아 반환
   * - 일치하는 탭이 없으면 undefined
   */
  const activeTab = computed<TabItem | undefined>(() => {
    return tabs.value.find(tab => tab.menuId === activeMenuId.value)
  })

  /**
   * keep-alive include 배열
   * - 열려 있는 모든 탭의 componentName을 추출하여 배열로 반환
   * - keep-alive의 :include에 바인딩하면 해당 컴포넌트들만 캐시됨
   * - 탭이 닫히면 자동으로 캐시에서 제외되어 메모리 절약
   */
  const cachedComponentNames = computed<string[]>(() => {
    return tabs.value.map(tab => tab.componentName)
  })

  // ─── 내부 헬퍼 함수 ───

  /**
   * 현재 탭 상태를 sessionStorage에 저장
   * - 새로고침 시 탭 목록과 활성 탭을 복원하기 위해 사용
   */
  function _saveToStorage(): void {
    sessionStorage.setItem(STORAGE_KEY_TABS, JSON.stringify(tabs.value))
    sessionStorage.setItem(STORAGE_KEY_ACTIVE, activeMenuId.value)
  }

  /**
   * sessionStorage에서 탭 상태를 복원
   * @returns 복원 성공 여부 (저장된 데이터가 있으면 true)
   */
  function _restoreFromStorage(): boolean {
    // sessionStorage에서 탭 목록 JSON 로드
    const savedTabs = sessionStorage.getItem(STORAGE_KEY_TABS)
    const savedActive = sessionStorage.getItem(STORAGE_KEY_ACTIVE)

    if (savedTabs) {
      try {
        // JSON 파싱 후 탭 목록 복원
        const parsed = JSON.parse(savedTabs) as TabItem[]
        if (Array.isArray(parsed) && parsed.length > 0) {
          tabs.value = parsed
          // 활성 탭 복원: 저장된 값이 없거나 유효하지 않으면 첫 번째 탭 활성화
          activeMenuId.value = savedActive && parsed.some(t => t.menuId === savedActive)
            ? savedActive
            : parsed[0].menuId
          return true
        }
      } catch {
        // JSON 파싱 실패 시 무시하고 초기화 진행
      }
    }
    return false
  }

  // ─── Actions ───

  /**
   * 탭 초기화
   * - 페이지 최초 로드 또는 로그인 후 호출
   * - sessionStorage에 저장된 탭 상태가 있으면 복원
   * - 없으면 대시보드 기본 탭만 추가
   */
  function initTabs(): void {
    // ─── 스키마 마이그레이션: 구버전 sessionStorage 자동 정리 ───
    // tab.ts의 menuId/탭 구조가 변경되면 CURRENT_SCHEMA_VERSION을 올리고,
    // 저장된 버전과 다르면 sessionStorage 탭 데이터를 일괄 폐기한다.
    // 이렇게 하면 사용자가 구버전 잘못된 menuId(예: 'order-list'/'order-form' 혼재)
    // 탭이 복원되는 문제를 자동으로 해결한다.
    const storedSchemaVersion = localStorage.getItem(STORAGE_KEY_SCHEMA)
    if (storedSchemaVersion !== CURRENT_SCHEMA_VERSION) {
      sessionStorage.removeItem(STORAGE_KEY_TABS)
      sessionStorage.removeItem(STORAGE_KEY_ACTIVE)
      localStorage.setItem(STORAGE_KEY_SCHEMA, CURRENT_SCHEMA_VERSION)
    }

    // sessionStorage에 탭 데이터가 없으면 초기화 플래그 리셋 (로그인/로그아웃 후)
    const savedTabs = sessionStorage.getItem(STORAGE_KEY_TABS)
    if (!savedTabs) initialized = false

    // 중복 초기화 방지 (하이버네이트 복귀, HMR 등)
    if (initialized && tabs.value.length > 0) return
    initialized = true

    // sessionStorage 복원 시도
    const restored = _restoreFromStorage()
    if (!restored) {
      // 복원할 데이터가 없으면 대시보드 탭으로 초기화
      tabs.value = [{ ...DEFAULT_DASHBOARD_TAB }]
      activeMenuId.value = DEFAULT_DASHBOARD_TAB.menuId
      _saveToStorage()
    }

    // 중복 탭 제거 안전장치 (menuId 기준 dedup)
    const seen = new Set<string>()
    tabs.value = tabs.value.filter(tab => {
      if (seen.has(tab.menuId)) return false
      seen.add(tab.menuId)
      return true
    })

    // 대시보드 탭 누락 보장 — 어떤 이유로(이전 세션 잘못된 데이터, 수동 sessionStorage
    // 조작 등) 대시보드 탭이 빠져 있으면 첫 번째 위치에 강제로 추가한다.
    // 대시보드는 closable=false 고정 탭이므로 항상 존재해야 한다.
    if (!tabs.value.find(t => t.menuId === DEFAULT_DASHBOARD_TAB.menuId)) {
      tabs.value.unshift({ ...DEFAULT_DASHBOARD_TAB })
    }

    // 대시보드 탭이 첫 번째 위치에 없으면 첫 번째로 이동 (정렬 보장)
    const dashIdx = tabs.value.findIndex(t => t.menuId === DEFAULT_DASHBOARD_TAB.menuId)
    if (dashIdx > 0) {
      const [dashTab] = tabs.value.splice(dashIdx, 1)
      tabs.value.unshift(dashTab)
    }

    _saveToStorage()
  }

  /**
   * 탭 열기
   * - **중복 식별 기준은 menuId 단일** — 같은 화면(메뉴)은 절대 두 개 이상 열리지 않는다.
   *   path/query/route params가 달라도 menuId가 같으면 동일 탭으로 간주한다.
   *   예) /customer 와 /customer?keyword=삼성, /order/form/5 와 /order/form/7 → 모두 같은 탭
   * - 이미 같은 menuId의 탭이 있으면 활성화하면서 path/title/icon을 새 값으로 **갱신**한다.
   *   이렇게 해야 딥링크로 들어왔을 때 검색조건(query string)이 탭에 보존되어,
   *   다른 탭 갔다가 돌아와도 동일한 상태로 복원된다.
   * - 없으면 새 탭을 추가하고 활성화한다.
   * - 최대 탭 수(15개)를 초과하면 추가하지 않고 false 반환.
   *
   * @param item - 열 탭 정보 (TabItem)
   * @returns 탭이 성공적으로 열렸으면 true, 최대 수 초과 시 false
   */
  function openTab(item: TabItem): boolean {
    // 1. 이미 열린 탭인지 확인 — menuId만으로 식별 (한 메뉴 = 한 탭 원칙)
    const existing = tabs.value.find(tab => tab.menuId === item.menuId)
    if (existing) {
      // 기존 탭의 path/title/icon을 새 값으로 갱신 (딥링크의 query string 보존)
      // closable과 menuId는 변경하지 않는다(고정 탭의 closable=false 보호).
      existing.path = item.path
      if (item.title) existing.title = item.title
      if (item.icon !== undefined) existing.icon = item.icon
      activeMenuId.value = existing.menuId
      _saveToStorage()
      return true
    }

    // 2. 최대 탭 수 제한 확인
    if (tabs.value.length >= MAX_TAB_COUNT) {
      return false
    }

    // 3. 새 탭 추가 및 활성화
    //    - 대시보드(또는 closable=false인 고정 탭)는 항상 첫 번째 위치에 추가
    //    - 그 외 일반 탭은 마지막에 추가
    //    이 규칙은 사용자가 어떤 순서로 메뉴를 열어도 대시보드 탭이 항상 좌측 첫 번째에
    //    위치하도록 보장한다. 어떤 이유로 대시보드 탭이 사라진 상태에서 다시 열릴 때도
    //    올바른 위치에 복원된다.
    if (item.menuId === 'dashboard' || item.closable === false) {
      tabs.value.unshift({ ...item })
    } else {
      tabs.value.push({ ...item })
    }
    activeMenuId.value = item.menuId
    _saveToStorage()
    return true
  }

  /**
   * 탭 닫기
   * - closable=false인 탭은 닫을 수 없다 (대시보드 등)
   * - 활성 탭을 닫으면 인접 탭으로 자동 전환한다 (우측 우선, 없으면 좌측)
   * - 닫힌 후 이동해야 할 경로를 반환한다
   *
   * @param menuId - 닫을 탭의 menuId
   * @returns 이동해야 할 path (활성 탭이 변경된 경우) 또는 빈 문자열 (변경 없음)
   */
  function closeTab(menuId: string): string {
    // 1. 닫을 탭 조회
    const tabIndex = tabs.value.findIndex(tab => tab.menuId === menuId)
    if (tabIndex === -1) return ''

    // 2. closable=false면 닫기 불가
    const tab = tabs.value[tabIndex]
    if (!tab.closable) return ''

    // 3. 활성 탭인 경우 인접 탭으로 전환 준비
    let nextPath = ''
    if (activeMenuId.value === menuId) {
      // 우측 탭 우선, 없으면 좌측 탭으로 전환
      const nextTab = tabs.value[tabIndex + 1] || tabs.value[tabIndex - 1]
      if (nextTab) {
        activeMenuId.value = nextTab.menuId
        nextPath = nextTab.path
      }
    }

    // 4. 탭 제거
    tabs.value.splice(tabIndex, 1)
    _saveToStorage()

    return nextPath
  }

  /**
   * 탭 전환 (활성 탭 변경)
   * @param menuId - 활성화할 탭의 menuId
   * @returns 해당 탭의 path (라우터 이동용)
   */
  function switchTab(menuId: string): string {
    const tab = tabs.value.find(t => t.menuId === menuId)
    if (tab) {
      activeMenuId.value = menuId
      _saveToStorage()
      return tab.path
    }
    return ''
  }

  /**
   * 다른 탭 모두 닫기
   * - 지정된 탭과 closable=false인 탭만 유지하고 나머지 모두 닫기
   * - 지정된 탭이 활성화된다
   *
   * @param menuId - 유지할 탭의 menuId
   */
  function closeOthers(menuId: string): void {
    // closable=false이거나 지정된 menuId인 탭만 남김
    tabs.value = tabs.value.filter(
      tab => !tab.closable || tab.menuId === menuId
    )
    // 지정된 탭을 활성화
    activeMenuId.value = menuId
    _saveToStorage()
  }

  /**
   * 우측 탭 닫기
   * - 지정된 탭의 우측에 있는 closable 탭을 모두 닫기
   * - 활성 탭이 닫힌 경우 지정된 탭으로 전환
   *
   * @param menuId - 기준 탭의 menuId (이 탭의 우측 탭들을 닫음)
   */
  function closeRight(menuId: string): void {
    const tabIndex = tabs.value.findIndex(tab => tab.menuId === menuId)
    if (tabIndex === -1) return

    // 기준 탭 이하(포함)는 유지, 우측 중 closable=false도 유지
    tabs.value = tabs.value.filter(
      (tab, index) => index <= tabIndex || !tab.closable
    )

    // 활성 탭이 사라졌으면 기준 탭으로 전환
    if (!tabs.value.find(t => t.menuId === activeMenuId.value)) {
      activeMenuId.value = menuId
    }
    _saveToStorage()
  }

  /**
   * 모든 탭 닫기
   * - closable=true인 모든 탭을 닫는다
   * - closable=false인 탭(대시보드)만 남으며, 남은 탭 중 첫 번째를 활성화
   *
   * @returns 활성화된 탭의 path (라우터 이동용)
   */
  function closeAll(): string {
    // closable=false인 탭만 유지
    tabs.value = tabs.value.filter(tab => !tab.closable)

    // 남은 탭이 있으면 첫 번째 활성화
    if (tabs.value.length > 0) {
      activeMenuId.value = tabs.value[0].menuId
      _saveToStorage()
      return tabs.value[0].path
    }

    // 탭이 하나도 없는 경우 (이론상 대시보드가 있어야 하지만 안전장치)
    activeMenuId.value = ''
    _saveToStorage()
    return '/dashboard'
  }

  /**
   * 언어 전환 시 열린 탭들의 제목을 서버 메뉴명으로 갱신한다.
   * authStore.menus가 새 locale로 재로드된 후 호출되어야 한다.
   *
   * @param menus - authStore.menus (서버에서 locale에 맞게 내려준 메뉴 목록)
   */
  function refreshTitles(menus: Record<string, unknown>[]) {
    for (const tab of tabs.value) {
      const serverMenu = menus.find(m => m.menuId === tab.menuId)
      if (serverMenu?.menuName) {
        tab.title = serverMenu.menuName as string
      }
    }
    sessionStorage.setItem(STORAGE_KEY_TABS, JSON.stringify(tabs.value))
  }

  return {
    // ── 상태 (State) ──
    /** 현재 열려 있는 탭 목록 배열 */
    tabs,
    /** 현재 활성 탭의 menuId */
    activeMenuId,
    // ── Getters ──
    /** 현재 활성 탭 객체 (undefined일 수 있음) */
    activeTab,
    /** keep-alive include용 컴포넌트명 배열 */
    cachedComponentNames,
    // ── Actions ──
    /** 탭 초기화: sessionStorage 복원 또는 대시보드 기본 탭 추가 */
    initTabs,
    /** 탭 열기: 이미 있으면 활성화, 없으면 추가 (최대 15개) */
    openTab,
    /** 탭 닫기: 활성 탭이면 인접 탭 전환, 이동할 path 반환 */
    closeTab,
    /** 탭 전환: activeMenuId 변경 + path 반환 */
    switchTab,
    /** 다른 탭 닫기: 지정 탭 + 고정 탭만 유지 */
    closeOthers,
    /** 우측 탭 닫기: 기준 탭 우측의 closable 탭 제거 */
    closeRight,
    /** 모든 탭 닫기: closable 탭 전부 제거, 활성 탭 path 반환 */
    closeAll,
    /** 언어 전환 시 열린 탭 제목을 서버 메뉴명으로 갱신 */
    refreshTitles
  }
})
