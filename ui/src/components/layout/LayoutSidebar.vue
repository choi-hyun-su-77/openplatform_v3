<!--
  레이아웃 사이드바 (LayoutSidebar)

  [용도]
  - 화면 좌측에 고정되는 네비게이션 사이드바 컴포넌트
  - 사용자의 역할(Role)에 따라 허가된 메뉴만 트리 구조로 표시
  - 그룹 메뉴(폴더)는 클릭 시 펼침/접힘, 리프 메뉴는 클릭 시 탭 열기 + 페이지 이동
  - collapsed 상태에서는 아이콘만 표시 (60px 너비)

  [Props]
  - collapsed: boolean — 사이드바 접힘 상태

  [Emits]
  - toggle — 사이드바 토글 요청 (현재 미사용, 헤더에서 직접 처리)

  [메뉴 데이터 소스]
  - authStore.menuTree: 로그인 시 서버에서 받은 메뉴 목록을 트리 구조로 변환한 computed
  - 1단계: 그룹 메뉴 (children이 있는 항목) 또는 단일 메뉴 (대시보드 등)
  - 2단계: 자식 메뉴 (실제 페이지로 이동하는 링크)

  [탭 연동]
  - 메뉴 클릭 시 router-link 대신 handleMenuClick으로 탭 생성 + 라우터 이동
  - tabStore.openTab으로 탭 추가/활성화, router.push로 페이지 이동
  - router.resolve로 menuPath에서 라우트 meta (title, componentName) 추출

  [참고]
  - 현재 활성 메뉴는 route.path와 비교하여 하이라이트 표시 (기존 로직 유지)
  - 메뉴 아이콘은 PrimeIcons 클래스를 사용 (pi pi-*)
-->
<template>
  <div class="layout-sidebar" :class="{ collapsed: collapsed, 'topnav-sidebar': topnavMode }">
    <!-- 사이드바 헤더: 로고 텍스트 (접힘 시 축약 표시) -->
    <div class="sidebar-header">
      <span class="logo-text" v-if="!collapsed">TS-Spring FW</span>
      <span class="logo-text" v-else>TS</span>
    </div>
    <!-- 네비게이션 메뉴 영역: authStore.menuTree를 순회하며 메뉴 렌더링 -->
    <nav class="sidebar-nav">
      <div v-for="menu in displayMenus" :key="menu.menuId" class="menu-group">
        <!-- 그룹 메뉴: 자식이 있는 폴더형 메뉴 (클릭 시 하위 메뉴 펼침/접힘) -->
        <div
          v-if="menu.children && menu.children.length > 0"
          class="menu-parent"
          :class="{ active: isParentActive(menu) }"
          @click="toggleGroup(menu.menuId)"
        >
          <i :class="menu.icon || 'ti ti-folder'" class="menu-icon"></i>
          <span v-if="!collapsed" class="menu-label">{{ menu.menuName }}</span>
          <i
            v-if="!collapsed"
            class="pi menu-arrow"
            :class="expandedGroups.has(menu.menuId) ? 'pi-chevron-down' : 'pi-chevron-right'"
          ></i>
        </div>
        <!-- 단일 메뉴: 자식이 없는 루트 메뉴 (대시보드 등) — 클릭 시 탭 열기 + 페이지 이동 -->
        <div
          v-else
          class="menu-parent"
          :class="{ active: isMenuActive(menu.menuPath) }"
          @click="handleMenuClick(menu)"
        >
          <i :class="menu.icon || 'ti ti-point'" class="menu-icon"></i>
          <span v-if="!collapsed" class="menu-label">{{ menu.menuName }}</span>
        </div>
        <!-- 자식 메뉴 목록: 그룹이 펼쳐진 상태이고 사이드바가 확장된 경우에만 표시 -->
        <div
          v-if="!collapsed && menu.children && menu.children.length > 0 && expandedGroups.has(menu.menuId)"
          class="menu-children"
        >
          <!-- 자식 메뉴: 클릭 시 탭 열기 + 페이지 이동 (router-link 대신 handleMenuClick 사용) -->
          <div
            v-for="child in menu.children"
            :key="child.menuId"
            class="menu-child"
            :class="{ active: isMenuActive(child.menuPath) }"
            @click="handleMenuClick(child)"
          >
            <i :class="child.icon || 'ti ti-point'" class="menu-icon"></i>
            <span class="menu-label">{{ child.menuName }}</span>
          </div>
        </div>
      </div>
    </nav>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/store/auth'  // 인증 스토어 (메뉴 트리 데이터)

/** 사이드바 메뉴 항목 타입 (authStore.menuTree 항목과 동일 구조) */
interface SidebarMenu {
  menuId: string
  menuName: string
  menuPath: string
  icon?: string | null
  children?: SidebarMenu[]
}

/**
 * Props 정의
 * @prop collapsed - 사이드바 접힘 상태 (true: 60px 축소, false: 전체 너비)
 * @prop filterGroupId - topnav 모드에서 선택된 그룹 ID (해당 그룹의 하위 메뉴만 표시, 빈 문자열이면 전체 표시)
 */
const props = defineProps<{
  collapsed: boolean
  /** topnav 모드에서 선택된 그룹 ID (해당 그룹의 하위 메뉴만 표시) */
  filterGroupId?: string
  /** topnav 모드 여부 — true이면 position: relative로 전환 */
  topnavMode?: boolean
}>()

/**
 * 부모(LayoutDefault)로 전달하는 이벤트
 * 현재 toggle 이벤트는 미사용 — 사이드바 토글은 LayoutHeader에서 직접 처리
 */
defineEmits<{
  /** 사이드바 토글 요청 — 현재 미사용 (LayoutHeader의 toggleSidebar 이벤트가 담당) */
  toggle: []
}>()

const route = useRoute()          // 현재 라우트 (활성 메뉴 하이라이트용)
const router = useRouter()        // 라우터 인스턴스 (push로 navigation 트리거 → router.afterEach가 탭 생성)
const authStore = useAuthStore()  // 인증 스토어 (menuTree 접근)

/**
 * 표시할 메뉴 목록 (computed)
 * - filterGroupId가 있으면: 해당 그룹의 children만 표시 (topnav 모드)
 * - filterGroupId가 없으면: 전체 menuTree 표시 (sidebar 모드)
 */
const displayMenus = computed((): SidebarMenu[] => {
  const tree = authStore.menuTree as SidebarMenu[]
  if (props.filterGroupId) {
    // topnav 모드: 선택된 그룹의 하위 메뉴만 플랫하게 표시
    const group = tree.find(m => m.menuId === props.filterGroupId)
    if (group?.children) {
      return group.children
    }
    return []
  }
  // sidebar 모드: 전체 메뉴 트리
  return tree
})

/** 현재 펼쳐진 그룹 메뉴 ID 집합 */
const expandedGroups = ref(new Set<string>())

/**
 * 그룹 메뉴 펼침/접힘 토글
 * @param menuId - 토글할 그룹 메뉴의 ID
 */
function toggleGroup(menuId: string) {
  if (expandedGroups.value.has(menuId)) {
    expandedGroups.value.delete(menuId)
  } else {
    expandedGroups.value.add(menuId)
  }
}

/**
 * 메뉴 클릭 핸들러
 *
 * router.push만 호출하고 탭 생성은 router.afterEach에 위임한다(SSOT 원칙).
 * 직접 tabStore.openTab을 호출하면 사이드바 메뉴의 fw_menu.menu_id와
 * router meta.menuId가 다른 경우 같은 화면이 두 개의 탭으로 분리되는 버그가 발생한다.
 * router.afterEach가 to.meta.menuId 기준으로 단일하게 탭을 관리하므로,
 * 사이드바/탑네브 클릭은 router.push만 호출하여 일관성을 보장한다.
 *
 * @param menu - 클릭된 메뉴 객체 (menuPath만 사용)
 */
function handleMenuClick(menu: { menuId: string; menuName: string; menuPath: string; icon?: string | null }): void {
  const menuPath = menu.menuPath || '/dashboard'
  router.push(menuPath)
}

/**
 * 모든 leaf 메뉴(자식이 없는 메뉴)의 menuPath를 평탄하게 수집한다.
 * 가장 구체적인 매칭 메뉴를 결정할 때 사용 (prefix 충돌 방지).
 */
function collectLeafPaths(menus: SidebarMenu[]): string[] {
  const result: string[] = []
  function visit(list: SidebarMenu[]) {
    for (const m of list) {
      if (m.children && m.children.length > 0) {
        visit(m.children)
      } else if (m.menuPath) {
        result.push(m.menuPath)
      }
    }
  }
  visit(menus)
  return result
}

/**
 * 현재 route.path에 매칭되는 가장 구체적인(가장 긴 prefix) leaf 메뉴 경로.
 * computed로 캐시되어, 같은 라우트 안에서 isMenuActive 호출이 반복돼도 한 번만 계산된다.
 *
 * 예) route.path = '/order/form'
 *   - 후보: '/order' (startsWith 매칭), '/order/form' (정확 일치)
 *   - 가장 긴 매칭: '/order/form' → 이것만 active로 처리
 */
const mostSpecificActivePath = computed<string | null>(() => {
  const leafPaths = collectLeafPaths(displayMenus.value)
  let best: string | null = null
  for (const p of leafPaths) {
    if (route.path === p || route.path.startsWith(p + '/')) {
      if (best === null || p.length > best.length) {
        best = p
      }
    }
  }
  return best
})

/**
 * 개별 메뉴 활성 상태 판단
 *
 * - 가장 구체적인(가장 긴 prefix) 매칭 메뉴 하나만 active로 표시한다.
 * - 예: route.path='/order/form'일 때, '주문조회'(/order)와 '주문등록'(/order/form)이
 *   모두 startsWith 매칭되지만 가장 긴 매칭인 '주문등록'만 active로 표시.
 * - 이렇게 해야 부모 경로의 메뉴가 함께 active로 표시되는 시각적 혼동을 방지할 수 있다.
 *
 * @param menuPath - 메뉴의 라우터 경로
 * @returns 가장 구체적인 매칭 메뉴이면 true
 */
function isMenuActive(menuPath: string): boolean {
  if (!menuPath) return false
  return mostSpecificActivePath.value === menuPath
}

/**
 * 그룹 메뉴의 활성 상태 판단
 * - 자식 메뉴 중 현재 route.path와 일치하는 항목이 있으면 true
 * @param menu - 그룹 메뉴 객체
 * @returns 자식 중 활성 메뉴가 있으면 true
 */
function isParentActive(menu: unknown): boolean {
  const m = menu as { children?: { menuPath: string }[] }
  if (m.children && m.children.length > 0) {
    return m.children.some((c) => route.path === c.menuPath || route.path.startsWith(c.menuPath + '/'))
  }
  return false
}

/**
 * 현재 활성 라우트의 부모 그룹을 expandedGroups에 자동으로 추가한다.
 * URL 직접 진입, 새로고침, 외부 링크로 화면에 들어왔을 때 사이드바의
 * 해당 부모 메뉴가 자동으로 펼쳐져, 사용자가 자기 위치를 시각적으로
 * 확인할 수 있도록 한다.
 *
 * 동작:
 *  - displayMenus(트리)를 순회하면서 isParentActive(menu)가 true인 그룹의
 *    menuId를 expandedGroups Set에 추가한다.
 *  - 기존에 사용자가 수동으로 펼쳐 놓은 그룹은 그대로 유지(접지 않음).
 *  - Set.add는 멱등 연산이므로 중복 호출에 부작용 없음.
 */
function syncExpandedFromRoute(): void {
  for (const menu of displayMenus.value) {
    if (menu.children && menu.children.length > 0 && isParentActive(menu)) {
      expandedGroups.value.add(menu.menuId)
    }
  }
}

// 마운트 시 1회 실행: URL 직접 진입/새로고침으로 처음 화면에 들어온 케이스
onMounted(syncExpandedFromRoute)

// 라우트 경로 변경 시 재계산: 탭 전환, 프로그래밍 방식 navigation 등
watch(() => route.path, syncExpandedFromRoute)

// 메뉴 트리가 비동기로 로드되는 케이스(loadUserInfo 후) 대비
watch(displayMenus, syncExpandedFromRoute)
</script>

<style scoped>
.layout-sidebar {
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  width: var(--sidebar-width);
  background-color: var(--p-content-background);
  color: var(--p-text-color);
  border-right: 1px solid var(--p-content-border-color);
  display: flex;
  flex-direction: column;
  transition: width 0.3s ease;
  z-index: 100;
  overflow-x: hidden;
}

.layout-sidebar.collapsed {
  width: 60px;
}

/* topnav 모드: fixed → relative (topnav-body 안에서 자연 배치) */
.layout-sidebar.topnav-sidebar {
  position: relative;
  top: auto;
  bottom: auto;
  left: auto;
  z-index: auto;
}

.sidebar-header {
  height: var(--header-height);
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid var(--p-content-border-color);
  flex-shrink: 0;
}

.logo-text {
  font-size: 18px;
  font-weight: 700;
  color: var(--p-primary-color);
  white-space: nowrap;
}

.sidebar-nav {
  flex: 1;
  overflow-y: auto;
  padding: 8px 0;
}

.menu-parent {
  display: flex;
  align-items: center;
  padding: 10px 16px;
  cursor: pointer;
  transition: background-color 0.2s;
  gap: 10px;
}

.menu-parent:hover {
  background-color: var(--p-content-hover-background);
}

.menu-parent.active {
  background-color: color-mix(in srgb, var(--p-primary-color) 12%, transparent);
  border-left: 3px solid var(--p-primary-color);
}

/* 메뉴 아이콘 — 배경 없이 컬러 아이콘만 표시 (깔끔한 모던 스타일) */
.menu-icon {
  font-size: 16px;
  width: 20px;
  text-align: center;
  flex-shrink: 0;
  color: var(--p-text-muted-color);
  transition: color 0.2s;
}

/* (child-icon 클래스 제거 — 자식도 부모와 동일 크기 16px 아이콘 표시) */

/* 호버 시 아이콘 색상 변경 */
.menu-parent:hover .menu-icon,
.menu-child:hover .menu-icon {
  color: var(--p-primary-color);
}

/* 활성 메뉴 아이콘 — primary 색상 강조 */
.menu-parent.active .menu-icon,
.menu-child.active .menu-icon {
  color: var(--p-primary-color);
}

.menu-label {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-size: 13px;
}

.menu-arrow {
  font-size: 12px;
  flex-shrink: 0;
}

.menu-children {
  background-color: var(--p-content-hover-background);
}

.menu-child {
  display: flex;
  align-items: center;
  padding: 8px 16px 8px 40px;
  cursor: pointer;
  transition: background-color 0.2s;
  gap: 10px;
  text-decoration: none;
  color: var(--p-text-muted-color);
  font-size: 13px;
}

.menu-child:hover {
  background-color: var(--p-content-hover-background);
  color: var(--p-text-color);
}

.menu-child.active {
  color: var(--p-primary-color);
  background-color: color-mix(in srgb, var(--p-primary-color) 12%, transparent);
}

</style>
