<!--
  상단 메뉴 바 (LayoutTopNav) — 드롭다운 방식

  [용도]
  - topnav 레이아웃 모드에서 헤더 아래에 표시되는 메뉴 바
  - PrimeVue Menubar 컴포넌트를 활용하여 그룹 메뉴는 호버 드롭다운으로 하위 표시
  - 단일 메뉴(대시보드 등)는 직접 클릭으로 탭 열기 + 페이지 이동
  - 사이드바 없이 메뉴 바만으로 전체 네비게이션 처리

  [구조]
  [주문관리 ▼] [시스템관리 ▼] [리포트 ▼] [쇼케이스 ▼] [템플릿 ▼]
       │
       ├─ 고객관리
       ├─ 상품관리
       ├─ 주문조회
       └─ 주문등록

  [스타일]
  - PrimeVue Menubar 기본 스타일 활용 (다크모드 자동 호환)
  - primary 배경색 커스텀 적용
-->
<template>
  <!-- PrimeVue Menubar: 메뉴 트리를 드롭다운 형태로 렌더링 -->
  <Menubar :model="menubarItems" class="layout-topnav-menubar" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/store/auth'
import Menubar from 'primevue/menubar'

/** 사이드바 메뉴 트리 항목 타입 */
interface SidebarMenu {
  menuId: string
  menuName: string
  menuPath: string
  icon?: string | null
  children?: SidebarMenu[]
}

const router = useRouter()
const authStore = useAuthStore()

/**
 * authStore.menuTree를 PrimeVue MenuItem 형태로 변환
 * - 그룹 메뉴: label + icon + items(자식 배열) → 호버 시 드롭다운
 * - 단일 메뉴: label + icon + command → 클릭 시 탭 열기 + 이동
 * - 대시보드는 제외 (초기 화면으로만 사용)
 */
const menubarItems = computed(() => {
  const tree = (authStore.menuTree as SidebarMenu[]).filter(m => m.menuId !== 'dashboard')
  return tree.map(menu => convertMenuItem(menu))
})

/**
 * 메뉴 트리 항목을 PrimeVue MenuItem으로 재귀 변환
 * - children이 있으면 items 배열로 변환 (드롭다운)
 * - children이 없으면 command로 탭 열기 + 이동
 */
function convertMenuItem(menu: SidebarMenu): Record<string, unknown> {
  // 그룹 메뉴 (하위 있음) → 드롭다운
  if (menu.children && menu.children.length > 0) {
    return {
      label: menu.menuName,
      icon: menu.icon || 'ti ti-folder',
      items: menu.children.map(child => convertMenuItem(child))
    }
  }

  // 리프 메뉴 (하위 없음) → 클릭 시 탭 열기 + 이동
  return {
    label: menu.menuName,
    icon: menu.icon || 'ti ti-point',
    command: () => handleMenuClick(menu)
  }
}

/**
 * 메뉴 클릭 핸들러
 *
 * router.push만 호출하고 탭 생성은 router.afterEach에 위임한다(SSOT 원칙).
 * 직접 tabStore.openTab을 호출하면 fw_menu.menu_id와 router meta.menuId가 다른
 * 경우 같은 화면이 두 개의 탭으로 분리되는 버그가 발생한다.
 */
function handleMenuClick(menu: SidebarMenu): void {
  const menuPath = menu.menuPath || '/dashboard'
  router.push(menuPath)
}
</script>

<style scoped>
/* ─── Menubar 커스텀 스타일 ─── */
.layout-topnav-menubar {
  border-radius: 0;
  border-left: none;
  border-right: none;
  border-top: none;
  padding: 0 12px;
}
</style>
