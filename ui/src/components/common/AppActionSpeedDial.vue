<!--
  ============================================================================
  AppActionSpeedDial.vue — 고정 우하단 FAB SpeedDial (공용)
  ============================================================================

  【역할】
    페이지 우하단에 고정 floating action button을 표시한다.
    useQuickActions로 만든 QuickMenuItem[]을 받아 circle 방향으로 펼친다.

  【권한 제어】
    fw_page_item의 {menuId}.{itemIdProp}(기본 'speeddial-fab')가 visible=false로
    설정되면 FAB 자체가 렌더되지 않는다.
    개별 액션 권한은 이미 useQuickActions.buildActions에서 필터링되어 들어온다.

  【사용 예시】
    const permission = $initForm('customer-list')
    const { buildActions } = useQuickActions('customer-list')
    const quickActions = buildActions([
      { id: 'qa-excel',      preset: 'excel',   run: fn_export },
      { id: 'qa-refresh',    preset: 'refresh', run: fn_search },
      { id: 'qa-print',      preset: 'print' },
      { id: 'qa-copy-row',   preset: 'copyRow', args: { getRow: () => selectedRow.value } },
      { id: 'qa-scroll-top', preset: 'scrollTop', args: { selector: '.customer-table .p-datatable-wrapper' } },
    ])

    <AppActionSpeedDial menu-id="customer-list" :items="quickActions" />

  【Props】
    menuId    — 권한 조회 기준 (fw_menu.menu_id)
    items     — QuickMenuItem[] (ComputedRef 또는 일반 배열)
    itemIdProp — FAB 표시 권한 확인에 사용할 item_id (기본 'speeddial-fab')
    direction — SpeedDial 펼침 방향 (기본 'up')
    mask      — dim 오버레이 표시 여부 (기본 false)
-->
<template>
  <!--
    FAB 자체 권한(visible)이 false면 렌더하지 않는다.
    액션이 하나도 없으면 표시 의미가 없으므로 함께 감춘다.
  -->
  <div
    v-if="fabVisible && displayItems.length > 0"
    class="app-action-speeddial"
  >
    <SpeedDial
      :model="displayItems"
      :direction="direction"
      :mask="mask"
      showIcon="pi pi-bars"
      hideIcon="pi pi-times"
      buttonClass="p-button-primary"
      :tooltipOptions="{ position: 'left', event: 'hover' }"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, unref } from 'vue'
import SpeedDial from 'primevue/speeddial'
import { useItemPermission } from '@/composables/useItemPermission'
import type { QuickMenuItem } from '@/composables/useQuickActions'

/** 컴포넌트 props 정의 */
const props = withDefaults(defineProps<{
  /** fw_menu.menu_id — 권한 조회 기준 */
  menuId: string
  /** buildActions가 반환한 ComputedRef<QuickMenuItem[]> 또는 일반 배열 */
  items: QuickMenuItem[] | { value: QuickMenuItem[] }
  /** FAB 자체 권한 확인용 item_id */
  itemIdProp?: string
  /** 펼침 방향 */
  direction?: 'up' | 'down' | 'left' | 'right' | 'up-left' | 'up-right' | 'down-left' | 'down-right'
  /** dim 오버레이 */
  mask?: boolean
}>(), {
  itemIdProp: 'speeddial-fab',
  direction: 'up',
  mask: false,
})

/** 항목 권한 조회 함수 */
const itemPerm = useItemPermission(props.menuId)

/** FAB 자체 표시 여부 (speeddial-fab의 visible) */
const fabVisible = computed(() => itemPerm(props.itemIdProp).visible)

/**
 * 실제 렌더될 MenuItem 배열
 *
 * props.items는 ComputedRef 또는 일반 배열일 수 있어 unref로 정규화한다.
 * PrimeVue SpeedDial은 label/icon/command/disabled만 참조하므로 그대로 전달.
 */
const displayItems = computed<QuickMenuItem[]>(() => {
  const raw = unref(props.items as any)
  return Array.isArray(raw) ? raw : []
})
</script>

<style scoped>
/*
  우하단 고정 floating — 다른 팝오버/토스트와 겹치지 않도록 z-index 50
  bottom/right 여백은 글로벌 레이아웃의 푸터/탭바 높이와 어긋나지 않게 조절
*/
.app-action-speeddial {
  position: fixed;
  right: 2rem;
  bottom: 2rem;
  z-index: 50;
}

/* FAB 버튼 크기 및 그림자 — 56x56 원형 */
.app-action-speeddial :deep(.p-speeddial-button) {
  width: 56px;
  height: 56px;
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2);
}

/* 펼쳐진 액션 버튼 — 48x48 원형 */
.app-action-speeddial :deep(.p-speeddial-item .p-button) {
  width: 48px;
  height: 48px;
}

/* 확장 리스트 여백 */
.app-action-speeddial :deep(.p-speeddial-list) {
  padding-bottom: 0.5rem;
  gap: 0.25rem;
}

/* 인쇄 시 FAB 숨김 — 인쇄 결과에 버튼이 찍히지 않도록 */
@media print {
  .app-action-speeddial { display: none !important; }
}
</style>
