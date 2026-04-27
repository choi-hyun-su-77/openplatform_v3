# screens/03_master_detail.md — 형태 3: 마스터-디테일 분할

> Phase 3.3 산출물. 모범: `[code: ui/src/pages/PageDataLibrary.vue]`

## 1. 화면 정의

좌측 = 계층(Tree) 또는 list sidebar, 우측 = 컨텍스트 컨텐츠 (목록·편집기·미리보기). 좌측 선택 → 우측 자동 갱신.

```
┌────────────┬──────────────────────────┐
│ Tree       │ Right pane (DataTable    │
│ ├ Folder1  │   또는 Detail/Editor)    │
│ │ ├ Sub    │                          │
│ │ └ Item   │ [Action buttons]         │
└────────────┴──────────────────────────┘
```

사용 시나리오: 자료실(폴더 → 파일), 조직도(부서 → 직원), 메일(메일함 → 메일 → 본문), 업무일지(캘린더 → 일자 편집기).

## 2. UI 컴포넌트 매핑

| 역할 | 컴포넌트 | 핵심 prop / event |
|---|---|---|
| 좌측 트리 | `Tree` | `:value`, `:selectionMode="single"`, `v-model:selectionKeys`, `@nodeSelect` |
| 좌측 검색 | `InputText` (debounce) | `v-model` |
| 우측 표 | `DataTable` | `:value`, `:rows`, `paginator?` |
| 우측 폼 | `InputText`/`Textarea`/`DatePicker` | — |
| 컨텍스트 메뉴 | `ContextMenu` | `:model`, `@show` |
| 그리드 | CSS `grid-template-columns: 280px 1fr` | — |

## 3. 백엔드 API 요구사항

| 메서드 | 경로 | 요청 | 응답 |
|---|---|---|---|
| POST | `/api/dataset/search` | `{ serviceName: "__domain-kebab__/searchTree" }` | `{ ds_tree: { rows: [...] } }` (parent_id, label, type) |
| POST | `/api/dataset/search` | `{ serviceName: "__domain-kebab__/searchByNode", datasets: { ds_search: { nodeId } } }` | `{ ds_items: { rows: [...] } }` |
| POST | `/api/dataset/save` | `{ serviceName: "__domain-kebab__/save", datasets: { ds_data: [{ _rowType, ... }] } }` | `{ saved: n }` |

## 4. 화면 파일 작성 가이드

```vue
<template>
  <div class="page master-detail">
    <aside class="left">
      <InputText v-model="searchKey" placeholder="검색" />
      <Tree :value="treeNodes" v-model:selectionKeys="selectedKeys" selectionMode="single" @nodeSelect="onSelect" />
    </aside>
    <main class="right">
      <DataTable :value="items" row-hover @row-click="openItem">
        <Column field="title" header="제목" />
        <Column field="updatedAt" header="수정일" />
      </DataTable>
    </main>
  </div>
</template>
<style scoped>
.master-detail { display: grid; grid-template-columns: 280px 1fr; height: 100%; }
</style>
```

## 5. 4표

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/pages/PageDataLibrary.vue]` | `ui/src/pages/Page__DomainPascal__.vue` | `__DomainPascal__`, `__domain-kebab__` | grid template + Tree + DataTable |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `ui/src/pages/Page__DomainPascal__.vue` | 마스터-디테일 페이지 | `templates/screen_types/03_master_detail/Page.vue.tmpl` |
| (선택) `ui/src/components/__domain-kebab__/__DomainPascal__Item.vue` | 우측 detail 컴포넌트 | (형태 2 SOP 위임) |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/router/index.ts` | children 배열 | route entry |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 페이지 명 | Vue |
| `__domain-kebab__` | serviceName / route path | Vue + router |

## 6. 부모-자식·라우터 연동

- 좌측 Tree 선택: `selectedKeys` reactive → watch → 우측 `searchByNode` 호출
- 우측 DataTable 행 클릭: 자식 detail 컴포넌트(형태 2) 열기
- 좌측 검색 키워드: 300ms debounce → tree filter

## 7. 모범 워크스루 — `PageDataLibrary.vue` 따라가기

1. CSS `grid-template-columns: 240px 1fr`.
2. 좌측 `<Tree>` 가 `datalib/searchFolderTree` 로 부서 폴더 트리 로드.
3. 폴더 선택 → `selectedFolder.value = node.key` → watch → `datalib/searchFiles` 로 우측 `<DataTable>` 갱신.
4. ContextMenu: 우클릭 → "신규 폴더 / 파일 업로드 / 삭제".
5. 파일 업로드: BFF `/api/bff/storage/presignedPut` → 직접 MinIO PUT → 메타데이터 `datalib/saveFile`.
