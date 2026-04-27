# screens/01_list_with_search.md — 형태 1: 다건 목록 (List with Search & Filter)

> Phase 3.1 산출물. 모범: `[code: ui/src/pages/PageBoard.vue]`

## 1. 화면 정의

다건 레코드를 조회·검색·페이지네이션하고, 행 클릭 시 상세 다이얼로그 또는 라우트 이동으로 진입하는 화면.

```
┌─ Title + Action Buttons ──────────────────────┐
├─ Toolbar (Search + Filter + Add) ─────────────┤
├─ DataTable ───────────────────────────────────┤
│ ID | Title | Author | Date | Status (Tag)     │
│ ...                                            │
│ Paginator                                      │
└──────────────────────────────────────────────┘
```

사용 시나리오: 게시판 목록, 결재 인박스, 휴가 신청 이력, 사용자 관리, 통합검색 결과.

## 2. UI 컴포넌트 매핑

| 역할 | 컴포넌트 | 핵심 prop / event |
|---|---|---|
| 표 | `DataTable` | `:value`, `:rows`, `:lazy`, `:totalRecords`, `@page`, `@row-click` |
| 컬럼 | `Column` | `field`, `header`, `sortable`, `:body` slot |
| 페이지네이터 | `Paginator` (DataTable 내장) | `paginator`, `:rows`, `:rowsPerPageOptions` |
| 검색 | `InputText` (`v-model` + debounce) | `placeholder`, `@update:modelValue` |
| 필터 | `Select` | `:options`, `optionLabel`, `optionValue` |
| 신규 | `Button` (`label="+ 추가"`) | `@click` |
| 상태 라벨 | `Tag` | `:value`, `:severity` |
| 툴바 | `CrudToolbar` (custom) | search/add 슬롯 |

## 3. 백엔드 API 요구사항

| 메서드 | 경로 | 요청 | 응답 |
|---|---|---|---|
| POST | `/api/dataset/search` | `{ serviceName: "__domain-kebab__/searchList", datasets: { ds_search: { keyword, status, ... } } }` | `{ ds_list: { rows: [...], totalCount } }` |
| POST | `/api/dataset/save` | `{ serviceName: "__domain-kebab__/save", datasets: { ds_data: [{ _rowType: "I"|"U"|"D", ... }] } }` | `{ saved: n }` |

## 4. 화면 파일 작성 가이드

```vue
<!-- ui/src/pages/Page__DomainPascal__.vue -->
<template>
  <div class="page">
    <h2>{{ t('LBL___DOMAIN_UPPER___TITLE') }}</h2>
    <CrudToolbar
      v-model:keyword="keyword"
      @search="load"
      @add="openCreate"
    />
    <DataTable
      :value="rows"
      :rows="20"
      :lazy="true"
      :total-records="total"
      paginator
      row-hover
      @page="onPage"
      @row-click="openDetail"
    >
      <Column field="id" header="ID" />
      <Column field="title" header="제목" />
      <Column field="status" header="상태">
        <template #body="slot"><Tag :value="slot.data.status" /></template>
      </Column>
    </DataTable>
    <__DomainPascal__DetailDialog v-model:visible="detailVisible" :id="selectedId" @saved="load" />
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import axios from 'axios'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Tag from 'primevue/tag'
import CrudToolbar from '@/components/common/CrudToolbar.vue'
import __DomainPascal__DetailDialog from '@/components/__domain-kebab__/__DomainPascal__DetailDialog.vue'

const rows = ref([]); const total = ref(0); const keyword = ref('')
const detailVisible = ref(false); const selectedId = ref<string | null>(null)

const load = async () => {
  const res = await axios.post('/api/dataset/search', {
    serviceName: '__domain-kebab__/searchList',
    datasets: { ds_search: { keyword: keyword.value } }
  })
  rows.value = res.data.data.ds_list.rows
  total.value = res.data.data.ds_list.totalCount
}
const openDetail = (e: any) => { selectedId.value = e.data.id; detailVisible.value = true }
const openCreate = () => { selectedId.value = null; detailVisible.value = true }
const onPage = (_: any) => load()
onMounted(load)
</script>
```

## 5. 4표

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/pages/PageBoard.vue]` | `ui/src/pages/Page__DomainPascal__.vue` | `__DomainPascal__`, `__domain-kebab__`, `__DOMAIN_UPPER__` | template / script / style 모두 치환 |
| `[code: ui/src/components/board/BoardDetailDialog.vue]` (선택) | `ui/src/components/__domain-kebab__/__DomainPascal__DetailDialog.vue` | `__DomainPascal__`, `__domain-kebab__` | 형태 2 SOP 위임 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `ui/src/pages/Page__DomainPascal__.vue` | 목록 페이지 | `templates/screen_types/01_list/Page.vue.tmpl` |
| `ui/src/components/__domain-kebab__/__DomainPascal__DetailDialog.vue` | 상세 다이얼로그 | (형태 2 SOP) |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/router/index.ts` | children 배열 | route entry 추가 |
| `ui/src/components/common/CrudToolbar.vue` | (변경 없음, import 만) | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | (예: `Notice`) | 컴포넌트 이름, import |
| `__domain-kebab__` | (예: `notice`) | path / serviceName |
| `__DOMAIN_UPPER__` | (예: `NOTICE`) | i18n key |
| `__domainKorean__` | (예: `공지사항`) | UI 라벨 |

## 6. 부모-자식·라우터 연동

- 부모 → 자식 다이얼로그: `v-model:visible` + `:id` props
- 자식 → 부모: `@saved` emit → 부모가 `load()` 호출
- 라우터: `meta.menuId='__domain-kebab__'`

## 7. 모범 워크스루 — `PageBoard.vue` 따라가기

1. `<template>` — `<h2>` + `<CrudToolbar>` + `<DataTable>` (paginator, lazy, row-hover) + 자식 `<BoardDetailDialog>`.
2. `<script setup>` — `axios.post('/api/dataset/search', { serviceName: 'board/searchPosts', datasets: { ds_search: { keyword } } })` → `rows.value = res.data.data.ds_posts.rows`.
3. 행 클릭: `openDetail(e)` → `selectedId.value = e.data.post_id; detailVisible.value = true`.
4. `<BoardDetailDialog @saved>` 가 저장 후 `emit('saved')` → 부모 `load()` 재호출.
5. 라우터: `[code: ui/src/router/index.ts]` 의 `{ path: 'board', name: 'board', component: () => import('@/pages/PageBoard.vue'), meta: { menuId: 'board' } }`.
