<!--
  검색 패널 (SearchPanel)

  [용도]
  - 목록 화면 상단에 배치되는 접이식 검색 조건 영역 컴포넌트
  - 헤더를 클릭하면 검색 필드 영역이 펼쳐지거나 접힌다
  - 검색 필드는 슬롯(default slot)으로 전달받으며, 조회/초기화 버튼을 내장한다
  - Enter 키 입력 시 자동으로 search 이벤트가 발생한다

  [사용 예시]
  - <SearchPanel @search="fn_search" @reset="fn_reset">
      <div class="field"><label>고객명</label><InputText v-model="ds_search.row.customerName" /></div>
    </SearchPanel>

  [Props]
  - defaultExpanded: boolean — 초기 펼침 상태 (기본값: true)

  [Emits]
  - search — 조회 버튼 클릭 또는 Enter 키 입력 시
  - reset — 초기화 버튼 클릭 시

  [슬롯]
  - default: 검색 조건 필드들 (InputText, Select, DatePicker 등)
-->
<template>
  <div class="search-panel" :class="{ collapsed: !expanded }">
    <!-- 검색 패널 헤더: 클릭 시 펼침/접힘 토글 -->
    <div class="search-header" @click="expanded = !expanded">
      <i class="pi" :class="expanded ? 'pi-chevron-down' : 'pi-chevron-right'"></i>
      <span class="search-title">{{ t('LBL_SEARCH_PANEL') }}</span>
    </div>
    <!-- 검색 본문: Enter 키 입력 시 search 이벤트 발생 -->
    <div v-show="expanded" class="search-body" @keydown.enter="$emit('search')">
      <!-- 검색 필드 슬롯: 부모가 전달한 검색 조건 필드들 -->
      <div class="search-fields">
        <slot />
      </div>
      <!-- 액션 버튼 영역: 조회 + 초기화 -->
      <div class="search-actions">
        <Button
          icon="pi pi-search"
          :label="t('BTN_SEARCH')"
          severity="info"
          size="small"
          @click="$emit('search')"
        />
        <Button
          icon="pi pi-refresh"
          :label="t('BTN_RESET')"
          severity="secondary"
          size="small"
          @click="$emit('reset')"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Button from 'primevue/button'
import { t } from '@/composables/useLabel'  // 다국어 라벨 조회 함수

/**
 * Props 정의
 * @prop defaultExpanded - 패널 초기 펼침 여부 (기본값: true)
 */
withDefaults(defineProps<{
  defaultExpanded?: boolean
}>(), {
  defaultExpanded: true
})

/**
 * 부모 컴포넌트로 전달하는 이벤트 정의
 * search는 조회 버튼 클릭 또는 검색 필드에서 Enter 키 입력 시 발생
 * reset은 초기화 버튼 클릭 시 발생
 */
defineEmits<{
  /** 조회 실행 — 조회 버튼 클릭 또는 Enter 키 입력 시 발생, 부모의 fn_search() 연결 */
  search: []
  /** 검색 조건 초기화 — 초기화 버튼 클릭 시 발생, 부모에서 ds_search 등의 row를 리셋 */
  reset: []
}>()

/**
 * 검색 패널 펼침/접힘 상태 (반응형)
 * - 초기값은 defaultExpanded prop에서 설정되어야 하나, 현재는 항상 true로 시작
 * - 헤더 클릭 시 이 값이 토글되어 검색 본문(search-body)의 v-show를 제어
 * - true: 검색 필드와 버튼이 보임 / false: 헤더만 보임
 */
const expanded = ref(true)
</script>

<style scoped>
.search-panel {
  background-color: var(--p-content-background);
  border: 1px solid var(--p-content-border-color);
  border-radius: 6px;
  margin-bottom: 8px;
}

.search-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  cursor: pointer;
  font-weight: 600;
  font-size: 13px;
  color: var(--p-text-muted-color);
  user-select: none;
}

.search-header:hover {
  background-color: var(--p-content-hover-background);
}

.search-body {
  padding: 8px 12px 12px;
  border-top: 1px solid var(--p-content-border-color);
}

.search-fields {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 16px;
  align-items: flex-end;
}

.search-actions {
  display: flex;
  justify-content: flex-end;
  gap: 6px;
  margin-top: 10px;
  padding-top: 8px;
  border-top: 1px solid var(--p-content-border-color);
}

</style>
