<!--
  ============================================================================
  AppContextSpeedDial.vue — 우클릭 컨텍스트 SpeedDial (공용)
  ============================================================================

  【역할】
    지정한 target 요소 위에서 우클릭하면 커서 위치에 원형 SpeedDial을 띄운다.
    브라우저 기본 컨텍스트 메뉴를 대체하는 페이지-컨텍스트형 빠른 액션 UI.

  【권한 제어】
    fw_page_item의 {menuId}.{itemIdProp}(기본 'speeddial-context')가
    visible=false면 컨텍스트 자체가 비활성되며, 우클릭 리스너도 등록하지 않는다.

  【동작】
    1. mounted 시 target 셀렉터로 DOM을 찾아 contextmenu 리스너 등록
    2. 우클릭 → preventDefault → 커서 좌표로 팝업 위치 결정 → 표시
    3. 표시 직후 FAB 버튼을 프로그래매틱 클릭하여 액션 목록을 자동 펼침
    4. 외부 클릭 / ESC / 액션 실행 → 자동 닫힘
    5. unmount 시 리스너 해제

  【사용 예시】
    <AppContextSpeedDial
      menu-id="customer-list"
      target=".customer-table"
      :items="quickActions"
    />
-->
<template>
  <!--
    권한 off면 아예 렌더 안 함 — 리스너도 없음 (마운트 훅이 early return)
    wrapper는 position: fixed로 뷰포트 기준 팝업 (절대좌표)
  -->
  <div
    v-if="dialVisible"
    ref="wrapRef"
    class="app-context-speeddial"
    :style="{ left: posX + 'px', top: posY + 'px' }"
    @click.stop
    @contextmenu.prevent
  >
    <SpeedDial
      :model="wrappedItems"
      direction="up"
      showIcon="pi pi-bars"
      hideIcon="pi pi-times"
      buttonClass="p-button-primary"
      :tooltipOptions="{ position: 'left', event: 'hover' }"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, unref, watch } from 'vue'
import SpeedDial from 'primevue/speeddial'
import { useItemPermission } from '@/composables/useItemPermission'
import type { QuickMenuItem } from '@/composables/useQuickActions'

/** 컴포넌트 props 정의 */
const props = withDefaults(defineProps<{
  /** fw_menu.menu_id — 권한 조회 기준 */
  menuId: string
  /** 우클릭 대상 CSS 셀렉터 (예: '.customer-table') */
  target: string
  /** QuickMenuItem 배열 또는 ComputedRef */
  items: QuickMenuItem[] | { value: QuickMenuItem[] }
  /** 컨텍스트 활성 권한 확인용 item_id */
  itemIdProp?: string
}>(), {
  itemIdProp: 'speeddial-context',
})

/** 항목 권한 조회 */
const itemPerm = useItemPermission(props.menuId)
/** 컨텍스트 기능 자체 활성 여부 (speeddial-context의 visible) */
const contextEnabled = computed(() => itemPerm(props.itemIdProp).visible)

/** 팝업 표시 상태 */
const dialVisible = ref(false)
/** 팝업 X 좌표 (viewport 기준) */
const posX = ref(0)
/** 팝업 Y 좌표 (viewport 기준) */
const posY = ref(0)
/** 팝업 wrapper DOM — 외부 클릭 판정용 */
const wrapRef = ref<HTMLElement | null>(null)

/**
 * 실제 렌더될 액션 배열
 * ComputedRef 또는 일반 배열 모두 지원
 */
const displayItems = computed<QuickMenuItem[]>(() => {
  const raw = unref(props.items as any)
  return Array.isArray(raw) ? raw : []
})

/** 팝업 닫기 — 외부 클릭/ESC/액션 실행 후 호출 */
function closeDial() {
  dialVisible.value = false
}

/**
 * 우클릭 핸들러 — target 요소 위에서 호출됨
 *
 * 1. 기본 브라우저 컨텍스트 메뉴 차단
 * 2. 액션이 하나도 없으면 무시 (권한으로 전부 필터된 경우)
 * 3. viewport 좌표로 팝업 위치 지정 (position: fixed)
 * 4. nextTick 후 SpeedDial 내부 FAB을 프로그래매틱 클릭하여 자동 펼침
 */
async function handleContextMenu(evt: MouseEvent) {
  evt.preventDefault()
  if (displayItems.value.length === 0) return
  posX.value = evt.clientX
  posY.value = evt.clientY
  dialVisible.value = true
  await nextTick()
  const fab = wrapRef.value?.querySelector('.p-speeddial-button') as HTMLElement | null
  fab?.click()
}

/** 외부 클릭 감지 — wrapper 바깥 클릭이면 닫음 */
function handleGlobalClick(e: MouseEvent) {
  if (!dialVisible.value) return
  const wrap = wrapRef.value
  if (wrap && !wrap.contains(e.target as Node)) closeDial()
}

/** ESC 키 감지 — 닫음 */
function handleEsc(e: KeyboardEvent) {
  if (e.key === 'Escape') closeDial()
}

/** target DOM 참조 저장 — unmount 시 리스너 해제용 */
let targetEl: HTMLElement | null = null

/**
 * target 요소에 contextmenu 리스너 연결
 * 권한 off면 연결하지 않는다.
 */
function attachTarget() {
  if (!contextEnabled.value) return
  targetEl = document.querySelector(props.target) as HTMLElement | null
  if (targetEl) {
    targetEl.addEventListener('contextmenu', handleContextMenu)
  }
}

/** target에서 리스너 해제 */
function detachTarget() {
  if (targetEl) {
    targetEl.removeEventListener('contextmenu', handleContextMenu)
    targetEl = null
  }
}

/**
 * 마운트 — 리스너 등록
 * target 요소가 async으로 렌더될 수 있으므로 한 tick 기다린다.
 */
onMounted(async () => {
  await nextTick()
  attachTarget()
  document.addEventListener('click', handleGlobalClick)
  document.addEventListener('keydown', handleEsc)
})

/** 언마운트 — 리스너 해제 (메모리 누수 방지) */
onBeforeUnmount(() => {
  detachTarget()
  document.removeEventListener('click', handleGlobalClick)
  document.removeEventListener('keydown', handleEsc)
})

/**
 * 권한이 동적으로 바뀌는 경우(로그인 변경 등)에 대비하여
 * contextEnabled 감시 → off 전환 시 즉시 해제, on 전환 시 재연결
 */
watch(contextEnabled, (enabled) => {
  if (enabled) {
    if (!targetEl) attachTarget()
  } else {
    detachTarget()
    closeDial()
  }
})

/**
 * 액션 command 래핑 — 실행 후 wrapper 자동 닫힘
 *
 * PrimeVue SpeedDial은 액션 실행 후 내부 FAB 상태만 토글하므로
 * 외부 wrapper(dialVisible)는 별도로 닫아줘야 한다.
 * items가 computed일 수 있어 원본은 건드리지 않고 복사본을 만든다.
 */
const wrappedItems = computed<QuickMenuItem[]>(() =>
  displayItems.value.map((it) => ({
    ...it,
    command: async () => {
      await it.command()
      closeDial()
    },
  }))
)
</script>

<style scoped>
/*
  viewport 기준 fixed — transform: translate(-50%, -100%)로
  FAB의 아래쪽 중앙이 커서 위치에 오도록 정렬한다.
  z-index 60 — 팝오버보다 살짝 위, 토스트 아래
*/
.app-context-speeddial {
  position: fixed;
  z-index: 60;
  transform: translate(-50%, -100%);
}

/* FAB 56x56, 은은한 그림자 */
.app-context-speeddial :deep(.p-speeddial-button) {
  width: 56px;
  height: 56px;
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2);
}

/* 액션 버튼 48x48 */
.app-context-speeddial :deep(.p-speeddial-item .p-button) {
  width: 48px;
  height: 48px;
}

/* 액션 리스트 여백 */
.app-context-speeddial :deep(.p-speeddial-list) {
  padding-bottom: 0.5rem;
  gap: 0.25rem;
}

/* 인쇄 시 숨김 */
@media print {
  .app-context-speeddial { display: none !important; }
}
</style>
