<!--
  기본 레이아웃 (LayoutDefault)

  [용도]
  - 로그인 후 모든 인증된 페이지의 최상위 레이아웃 컴포넌트
  - 2가지 레이아웃 모드 지원 (useTheme.layoutMode로 전환):
    1. sidebar 모드 (기본): Sidebar(전체 메뉴) + Header + TabBar + Content
    2. topnav 모드 (옵션): Header + TopNav(드롭다운 메뉴) + TabBar + Content (사이드바 없음)

  [sidebar 모드 구조]
  +---------------------------+
  | Sidebar | Header          |
  | (전체)  |-----------------|
  |         | TabBar          |
  |         |-----------------|
  |         | router-view     |
  |         | (keep-alive)    |
  +---------------------------+

  [topnav 모드 구조 — 사이드바 없음, 화면 100% 활용]
  +-------------------------------------------+
  | Header                                    |
  |-------------------------------------------|
  | TopNav (드롭다운 메뉴바)                     |
  |-------------------------------------------|
  | TabBar                                    |
  |-------------------------------------------|
  | router-view (keep-alive, 전체 폭)          |
  +-------------------------------------------+

  [상태]
  - sidebarCollapsed: 사이드바 접힘 여부 (sidebar 모드에서만 사용)
  - layoutMode: 'sidebar' | 'topnav' (useTheme에서 관리, localStorage 저장)
-->
<template>
  <div class="layout-wrapper" :class="{ 'topnav-mode': isTopNav }">

    <!-- ===== topnav 모드: 헤더 + 드롭다운 메뉴바 + TabBar + Content ===== -->
    <template v-if="isTopNav">
      <!-- 전체 폭 헤더 (사이드바 토글 버튼 숨김 처리 — topnav에서는 불필요) -->
      <LayoutHeader @toggle-sidebar="() => {}" />
      <!-- 상단 드롭다운 메뉴 바: PrimeVue Menubar로 호버 드롭다운 -->
      <LayoutTopNav />
      <!-- 탭 바 -->
      <LayoutTabBar />
      <!-- 본문 콘텐츠 (전체 폭 — 사이드바 없음) -->
      <div class="layout-content">
        <router-view v-slot="{ Component, route }">
          <keep-alive :include="tabStore.cachedComponentNames">
            <component :is="Component" :key="route.path" />
          </keep-alive>
        </router-view>
      </div>
    </template>

    <!-- ===== sidebar 모드 (기본): 기존 레이아웃 ===== -->
    <template v-else>
      <!-- 좌측 사이드바: 전체 메뉴 트리 -->
      <LayoutSidebar :collapsed="sidebarCollapsed" @toggle="sidebarCollapsed = !sidebarCollapsed" />
      <!-- 메인 영역: 사이드바 접힘에 따라 margin-left 조정 -->
      <div class="layout-main" :class="{ 'sidebar-collapsed': sidebarCollapsed }">
        <LayoutHeader @toggle-sidebar="sidebarCollapsed = !sidebarCollapsed" />
        <LayoutTabBar />
        <div class="layout-content">
          <router-view v-slot="{ Component, route }">
            <keep-alive :include="tabStore.cachedComponentNames">
              <component :is="Component" :key="route.path" />
            </keep-alive>
          </router-view>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import LayoutHeader from './LayoutHeader.vue'
import LayoutSidebar from './LayoutSidebar.vue'
import LayoutTabBar from './LayoutTabBar.vue'
import LayoutTopNav from './LayoutTopNav.vue'
import { useTabStore } from '@/store/tab'
import { useTheme } from '@/composables/useTheme'
import { useMessage } from '@/composables/useMessage'

/** 사이드바 접힘 상태 (sidebar 모드에서만 사용) */
const sidebarCollapsed = ref(false)
/** 탭 스토어 — cachedComponentNames를 keep-alive :include에 바인딩 */
const tabStore = useTabStore()
/** 테마/레이아웃 설정 */
const { layoutMode } = useTheme()

/** topnav 모드 여부 (computed) */
const isTopNav = computed(() => layoutMode.value === 'topnav')

/** 글로벌 에러 toast 리스너 */
const { error: showError } = useMessage()
function onGlobalError(e: Event) {
  const detail = (e as CustomEvent).detail
  if (detail?.message) showError(detail.message)
}

/** 컴포넌트 마운트 시 탭 스토어 초기화 */
onMounted(() => {
  tabStore.initTabs()
  window.addEventListener('global-error-toast', onGlobalError)
})
onUnmounted(() => {
  window.removeEventListener('global-error-toast', onGlobalError)
})
</script>

<style scoped>
/* ===== 공통 ===== */
.layout-wrapper {
  display: flex;
  height: 100vh;
  overflow: hidden;
}

/* ===== sidebar 모드 ===== */
.layout-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin-left: var(--sidebar-width);
  transition: margin-left 0.3s ease;
  overflow: hidden;
  min-width: 0;  /* flex item이 자식의 min-content를 강제하지 않도록 */
  min-height: 0;
}

.layout-main.sidebar-collapsed {
  margin-left: 60px;
}

.layout-content {
  flex: 1;
  padding: 16px;
  overflow-y: auto;
  background-color: var(--page-ground);
  /* 핵심: flex item이 자식 컨텐츠 크기를 강제하지 않도록 min-height/min-width 0.
     이게 없으면 페이지 컨텐츠가 길 때 layout-content가 flex 잔여 공간이 아니라
     자식 컨텐츠 크기로 늘어나 layout-wrapper가 viewport 밖으로 흘러 이중 스크롤이
     발생한다(html 페이지 스크롤 + layout-content 자체 스크롤). */
  min-height: 0;
  min-width: 0;
}

/* ===== topnav 모드 — 세로 배치, 사이드바 없음 ===== */
.layout-wrapper.topnav-mode {
  flex-direction: column;
}
</style>
