<!--
  레이아웃 탭 바 (LayoutTabBar)

  [용도]
  - LayoutHeader와 layout-content 사이에 위치하는 메뉴 탭 바 컴포넌트
  - 열린 페이지들을 탭 형태로 표시하여 빠른 전환을 제공한다
  - 대시보드 탭은 항상 고정되며 닫을 수 없다

  [기능]
  - 탭 클릭: 해당 페이지로 전환 (tabStore.switchTab + router.push)
  - 탭 닫기: X 버튼 클릭 시 탭 제거 (활성 탭이면 인접 탭으로 자동 전환)
  - 우클릭 컨텍스트 메뉴: 닫기 / 다른 탭 닫기 / 우측 닫기 / 모두 닫기
  - 마우스 휠 스크롤: 탭이 많아 overflow 시 좌우 스크롤 지원

  [스타일]
  - 높이: 36px (CSS 변수 --tabbar-height)
  - 활성 탭: primary 색상 하단 보더 (3px)
  - 다크모드: PrimeVue CSS 변수 기반 자동 호환

  [의존성]
  - useTabStore: 탭 상태 관리 (열기/닫기/전환/컨텍스트 메뉴 동작)
  - useRouter: 탭 전환 시 라우터 경로 변경
  - PrimeVue ContextMenu: 우클릭 메뉴 렌더링
-->
<template>
  <div class="layout-tabbar">
    <!-- 탭 스크롤 영역: overflow 시 마우스 휠로 좌우 스크롤 가능 -->
    <div
      class="tabbar-scroll"
      ref="scrollContainer"
      @wheel.prevent="onWheel"
    >
      <!-- 개별 탭 항목: tabs 배열을 순회하며 렌더링 -->
      <div
        v-for="tab in tabStore.tabs"
        :key="tab.menuId"
        class="tab-item"
        :class="{ active: tab.menuId === tabStore.activeMenuId }"
        @click="onTabClick(tab.menuId)"
        @contextmenu.prevent="onContextMenu($event, tab)"
      >
        <!-- 탭 아이콘: icon이 있으면 표시 -->
        <i v-if="tab.icon" :class="tab.icon" class="tab-icon"></i>
        <!-- 탭 제목 텍스트 -->
        <span class="tab-title">{{ tab.title }}</span>
        <!-- 닫기 버튼: closable=true인 탭만 표시 -->
        <i
          v-if="tab.closable"
          class="pi pi-times tab-close"
          @click.stop="onTabClose(tab.menuId)"
        ></i>
      </div>
    </div>

    <!-- 우측 고정 영역: 탭 일괄 관리 드롭다운 버튼 -->
    <div class="tabbar-actions">
      <!-- ▼ 드롭다운 버튼: 클릭 시 탭 일괄 관리 메뉴 표시 -->
      <button
        class="tabbar-dropdown-btn"
        @click="onDropdownClick"
        v-tooltip.bottom="'탭 관리'"
      >
        <i class="pi pi-chevron-down"></i>
      </button>
    </div>

    <!-- 우클릭 컨텍스트 메뉴: PrimeVue ContextMenu 활용 -->
    <ContextMenu ref="contextMenuRef" :model="contextMenuItems" />
    <!-- 드롭다운 메뉴: 탭 일괄 관리용 (우측 ▼ 버튼) -->
    <Menu ref="dropdownMenuRef" :model="dropdownMenuItems" :popup="true" />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useTabStore, type TabItem } from '@/store/tab'
import ContextMenu from 'primevue/contextmenu'
import Menu from 'primevue/menu'

/** 라우터 인스턴스 (탭 전환 시 경로 이동용) */
const router = useRouter()
/** 탭 스토어 (탭 상태 및 액션) */
const tabStore = useTabStore()

/** 스크롤 컨테이너 ref (마우스 휠 스크롤 대상) */
const scrollContainer = ref<HTMLDivElement | null>(null)
/** PrimeVue ContextMenu 컴포넌트 ref */
const contextMenuRef = ref<InstanceType<typeof ContextMenu> | null>(null)
/** PrimeVue Menu 컴포넌트 ref (우측 드롭다운) */
const dropdownMenuRef = ref<InstanceType<typeof Menu> | null>(null)
/** 우클릭 대상 탭의 menuId (컨텍스트 메뉴 동작 시 사용) */
const contextTargetMenuId = ref<string>('')

/**
 * 컨텍스트 메뉴 항목 정의
 * - 닫기: 우클릭한 탭 닫기
 * - 다른 탭 닫기: 우클릭한 탭 외 모든 closable 탭 닫기
 * - 우측 탭 닫기: 우클릭한 탭 오른쪽의 closable 탭 닫기
 * - 모두 닫기: closable 탭 전부 닫기
 */
const contextMenuItems = ref([
  {
    label: '닫기',
    icon: 'pi pi-times',
    /** 우클릭 대상 탭 닫기 */
    command: () => {
      const path = tabStore.closeTab(contextTargetMenuId.value)
      if (path) router.push(path)
    }
  },
  {
    label: '다른 탭 닫기',
    icon: 'pi pi-times-circle',
    /** 대상 탭 외 모두 닫기 — 대상 탭으로 전환 */
    command: () => {
      tabStore.closeOthers(contextTargetMenuId.value)
      const tab = tabStore.tabs.find(t => t.menuId === contextTargetMenuId.value)
      if (tab) router.push(tab.path)
    }
  },
  {
    label: '우측 탭 닫기',
    icon: 'pi pi-angle-double-right',
    /** 대상 탭 우측의 closable 탭 모두 닫기 */
    command: () => {
      tabStore.closeRight(contextTargetMenuId.value)
      // 활성 탭이 변경되었을 수 있으므로 이동
      const activeTab = tabStore.activeTab
      if (activeTab) router.push(activeTab.path)
    }
  },
  {
    separator: true
  },
  {
    label: '모두 닫기',
    icon: 'pi pi-trash',
    /** closable 탭 전부 닫기 — 대시보드로 이동 */
    command: () => {
      const path = tabStore.closeAll()
      router.push(path)
    }
  }
])

/**
 * 드롭다운 메뉴 항목 정의 (우측 ▼ 버튼)
 * - 현재 탭 외 모두 닫기: 활성 탭만 남김
 * - 우측 탭 닫기: 활성 탭 기준 오른쪽 closable 탭 닫기
 * - 모두 닫기: closable 탭 전부 닫기 (대시보드만 남음)
 */
const dropdownMenuItems = ref([
  {
    label: '현재 탭 외 닫기',
    icon: 'pi pi-minus-circle',
    /** 활성 탭 외 모두 닫기 */
    command: () => {
      tabStore.closeOthers(tabStore.activeMenuId)
      const activeTab = tabStore.activeTab
      if (activeTab) router.push(activeTab.path)
    }
  },
  {
    label: '우측 탭 닫기',
    icon: 'pi pi-angle-double-right',
    /** 활성 탭 오른쪽의 closable 탭 모두 닫기 */
    command: () => {
      tabStore.closeRight(tabStore.activeMenuId)
      const activeTab = tabStore.activeTab
      if (activeTab) router.push(activeTab.path)
    }
  },
  {
    separator: true
  },
  {
    label: '모두 닫기',
    icon: 'pi pi-times-circle',
    /** closable 탭 전부 닫기 — 대시보드로 이동 */
    command: () => {
      const path = tabStore.closeAll()
      router.push(path)
    }
  }
])

/**
 * 드롭다운 버튼 클릭 핸들러
 * - PrimeVue Menu를 팝업으로 표시
 */
function onDropdownClick(event: Event): void {
  dropdownMenuRef.value?.toggle(event)
}

/**
 * 탭 클릭 핸들러
 * - tabStore에서 해당 탭을 활성화하고 라우터로 이동한다
 * @param menuId - 클릭한 탭의 menuId
 */
function onTabClick(menuId: string): void {
  const path = tabStore.switchTab(menuId)
  if (path) {
    router.push(path)
  }
}

/**
 * 탭 닫기 핸들러
 * - closable 탭을 닫고, 활성 탭이 변경되면 해당 경로로 이동
 * @param menuId - 닫을 탭의 menuId
 */
function onTabClose(menuId: string): void {
  const path = tabStore.closeTab(menuId)
  if (path) {
    router.push(path)
  }
}

/**
 * 우클릭 컨텍스트 메뉴 표시 핸들러
 * - 클릭 대상 탭의 menuId를 저장하고 PrimeVue ContextMenu를 표시한다
 * @param event - 마우스 이벤트 (위치 계산용)
 * @param tab - 우클릭 대상 탭 객체
 */
function onContextMenu(event: MouseEvent, tab: TabItem): void {
  contextTargetMenuId.value = tab.menuId
  contextMenuRef.value?.show(event)
}

/**
 * 마우스 휠 스크롤 핸들러
 * - 탭이 많아 overflow 발생 시 수직 휠 입력을 수평 스크롤로 변환
 * @param event - WheelEvent (deltaY를 수평 스크롤에 적용)
 */
function onWheel(event: WheelEvent): void {
  if (scrollContainer.value) {
    // 수직 휠 입력(deltaY)을 수평 스크롤(scrollLeft)로 변환
    scrollContainer.value.scrollLeft += event.deltaY
  }
}
</script>

<style scoped>
/* ─── 탭 바 컨테이너 ─── */
.layout-tabbar {
  height: var(--tabbar-height, 36px);
  display: flex;
  align-items: center;
  background-color: var(--p-content-background);
  border-bottom: 1px solid var(--p-content-border-color);
  flex-shrink: 0;
  padding: 0 4px;
  user-select: none;
}

/* ─── 스크롤 영역: 탭이 넘치면 가로 스크롤 ─── */
.tabbar-scroll {
  display: flex;
  align-items: center;
  overflow-x: auto;
  overflow-y: hidden;
  flex: 1;
  gap: 2px;
  /* 스크롤바 숨기기 (Chrome/Firefox) */
  scrollbar-width: none;
}
.tabbar-scroll::-webkit-scrollbar {
  display: none;
}

/* ─── 개별 탭 항목 ─── */
.tab-item {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 0 10px;
  height: 28px;
  border-radius: 4px;
  cursor: pointer;
  white-space: nowrap;
  font-size: 12px;
  color: var(--p-text-muted-color);
  transition: background-color 0.15s, color 0.15s;
  flex-shrink: 0;
  position: relative;
}

/* 호버 효과 */
.tab-item:hover {
  background-color: var(--p-content-hover-background);
  color: var(--p-text-color);
}

/* 활성 탭: primary 색상 텍스트 + 하단 보더 */
.tab-item.active {
  color: var(--p-primary-color);
  background-color: color-mix(in srgb, var(--p-primary-color) 8%, transparent);
}

/* 활성 탭 하단 인디케이터 (3px primary 보더) */
.tab-item.active::after {
  content: '';
  position: absolute;
  bottom: -4px;
  left: 4px;
  right: 4px;
  height: 3px;
  background-color: var(--p-primary-color);
  border-radius: 2px 2px 0 0;
}

/* ─── 탭 아이콘 ─── */
.tab-icon {
  font-size: 12px;
  flex-shrink: 0;
}

/* ─── 탭 제목 ─── */
.tab-title {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* ─── 닫기 버튼 (X) ─── */
.tab-close {
  font-size: 10px;
  padding: 2px;
  border-radius: 3px;
  flex-shrink: 0;
  opacity: 0.5;
  transition: opacity 0.15s, background-color 0.15s;
}

/* 닫기 버튼 호버: 배경 + 불투명도 증가 */
.tab-close:hover {
  opacity: 1;
  background-color: var(--p-content-hover-background);
}

/* ─── 우측 고정 영역: 드롭다운 버튼 ─── */
.tabbar-actions {
  display: flex;
  align-items: center;
  flex-shrink: 0;
  margin-left: 4px;
  padding-left: 4px;
  border-left: 1px solid var(--p-content-border-color);
}

/* 드롭다운 버튼: 탭 일괄 관리 */
.tabbar-dropdown-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  border: none;
  border-radius: 4px;
  background: transparent;
  color: var(--p-text-muted-color);
  cursor: pointer;
  font-size: 11px;
  transition: background-color 0.15s, color 0.15s;
}

.tabbar-dropdown-btn:hover {
  background-color: var(--p-content-hover-background);
  color: var(--p-text-color);
}
</style>
