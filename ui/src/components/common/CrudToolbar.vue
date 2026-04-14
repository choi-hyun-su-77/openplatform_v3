<!--
  CRUD 툴바 (CrudToolbar)

  [용도]
  - 목록/폼 화면 상단에 배치되는 공통 버튼 툴바 컴포넌트
  - 조회, 추가, 삭제, 저장, 엑셀, 인쇄 버튼을 권한(permission)에 따라 자동으로 표시/숨김
  - 모든 CRUD 화면에서 동일한 버튼 레이아웃을 유지하기 위해 사용

  [사용 예시]
  - <CrudToolbar :permission="permission" :searching="loading.value"
      @search="fn_search" @add="fn_add" @delete="fn_delete" @save="fn_save" />

  [Props]
  - permission: MenuPermission — 메뉴별 권한 객체 (canRead, canCreate, canUpdate, canDelete, canExport, canPrint)
  - saving: boolean — 저장 버튼 로딩 상태 (기본값: false)
  - searching: boolean — 조회 버튼 로딩 상태 (기본값: false)

  [Emits]
  - search — 조회 버튼 클릭 시
  - add — 추가 버튼 클릭 시
  - save — 저장 버튼 클릭 시
  - delete — 삭제 버튼 클릭 시
  - export — 엑셀 다운로드 버튼 클릭 시
  - print — 인쇄 버튼 클릭 시

  [슬롯]
  - left: 툴바 왼쪽 영역 (제목, 건수 표시 등)
  - before: 기본 버튼들 앞에 추가할 커스텀 버튼
  - after: 기본 버튼들 뒤에 추가할 커스텀 버튼
-->
<template>
  <!-- 툴바 컨테이너: 좌측(슬롯) / 우측(버튼 그룹) 레이아웃 -->
  <div class="crud-toolbar">
    <!-- 좌측 영역: 타이틀, 데이터 건수 등 커스텀 콘텐츠 -->
    <div class="toolbar-left">
      <slot name="left" />
    </div>
    <!-- 우측 영역: CRUD 버튼 그룹 (권한별 조건부 렌더링) -->
    <div class="toolbar-right">
      <!-- before 슬롯: 기본 버튼 앞에 추가할 커스텀 버튼 -->
      <slot name="before" />
      <!-- 조회 버튼: canRead 권한 필요 -->
      <Button
        v-if="permission.canRead"
        icon="pi pi-search"
        :label="t('BTN_SEARCH')"
        severity="info"
        size="small"
        :loading="searching"
        @click="$emit('search')"
      />
      <!-- 추가 버튼: canCreate 권한 필요 -->
      <Button
        v-if="permission.canCreate"
        icon="pi pi-plus"
        :label="t('BTN_ADD')"
        severity="success"
        size="small"
        @click="$emit('add')"
      />
      <!-- 삭제 버튼: canDelete 권한 필요 -->
      <Button
        v-if="permission.canDelete"
        icon="pi pi-trash"
        :label="t('BTN_DELETE')"
        severity="danger"
        size="small"
        @click="$emit('delete')"
      />
      <!-- 저장 버튼: canUpdate 또는 canCreate 권한 중 하나라도 있으면 표시 -->
      <Button
        v-if="permission.canUpdate || permission.canCreate"
        icon="pi pi-save"
        :label="t('BTN_SAVE')"
        severity="warn"
        size="small"
        :loading="saving"
        @click="$emit('save')"
      />
      <!-- 엑셀 다운로드 버튼: canExport 권한 필요 -->
      <Button
        v-if="permission.canExport"
        icon="pi pi-file-excel"
        :label="t('BTN_EXCEL')"
        severity="secondary"
        size="small"
        @click="$emit('export')"
      />
      <!-- 인쇄 버튼: canPrint 권한 필요 -->
      <Button
        v-if="permission.canPrint"
        icon="pi pi-print"
        :label="t('BTN_PRINT')"
        severity="secondary"
        size="small"
        @click="$emit('print')"
      />
      <!-- after 슬롯: 기본 버튼 뒤에 추가할 커스텀 버튼 -->
      <slot name="after" />
    </div>
  </div>
</template>

<script setup lang="ts">
import Button from 'primevue/button'
import { t } from '@/composables/useLabel'       // 다국어 라벨 조회 함수
import type { MenuPermission } from '@/composables/usePermission' // 메뉴별 권한 타입

/**
 * Props 정의
 * @prop permission - 현재 메뉴의 CRUD 권한 객체 (usePermission에서 반환)
 * @prop saving - 저장 중 로딩 표시 여부
 * @prop searching - 조회 중 로딩 표시 여부
 */
withDefaults(defineProps<{
  permission: MenuPermission
  saving?: boolean
  searching?: boolean
}>(), {
  saving: false,
  searching: false
})

/**
 * 부모 컴포넌트로 전달하는 이벤트 정의
 * 각 이벤트는 해당 버튼 클릭 시 발생하며, 인자 없이 호출된다.
 * 부모 화면의 fn_search, fn_save 등 로컬 함수에 연결하여 사용한다.
 */
defineEmits<{
  /** 조회 버튼 클릭 — 부모의 fn_search() 호출용 */
  search: []
  /** 추가 버튼 클릭 — 부모의 fn_add() (ds.addRow) 호출용 */
  add: []
  /** 저장 버튼 클릭 — 부모의 fn_save() ($transaction save) 호출용 */
  save: []
  /** 삭제 버튼 클릭 — 부모의 fn_delete() ($deleteRow) 호출용 */
  delete: []
  /** 엑셀 다운로드 버튼 클릭 — 부모의 $exportExcel() 호출용 */
  export: []
  /** 인쇄 버튼 클릭 — 부모의 인쇄 로직 호출용 */
  print: []
}>()
</script>

<style scoped>
.crud-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid var(--p-content-border-color);
  margin-bottom: 8px;
  flex-shrink: 0;
}

.toolbar-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.toolbar-right {
  display: flex;
  align-items: center;
  gap: 6px;
}
</style>
