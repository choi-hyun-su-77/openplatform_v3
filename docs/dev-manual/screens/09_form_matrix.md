# screens/09_form_matrix.md — 형태 9: 폼 매트릭스 (설정)

> Phase 3.9 산출물. 모범: `[code: ui/src/pages/PageNotifySettings.vue]`

## 1. 화면 정의

DataTable 의 셀이 폼 컨트롤(toggle/select/text)인 매트릭스, 변경은 in-place 누적 → 배치 저장.

```
┌─ Header (기본값/저장) ────────────────────┐
├─ DataTable (Matrix) ──────────────────────┤
│ 카테고리 │ 포탈(ON/OFF) │ 이메일           │
│ 결재     │ [ON]         │ [OFF]            │
│ 게시판   │ [ON]         │ [ON]             │
│ 회의실   │ [OFF]        │ [ON]             │
└──────────────────────────────────────────┘
```

사용 시나리오: 알림 채널 설정, 권한 매트릭스, 코드 마스터 목록.

## 2. UI 컴포넌트 매핑

| 역할 | 컴포넌트 | 핵심 prop / event |
|---|---|---|
| 표 | `DataTable` | `:value`, `dataKey` |
| 컬럼 (셀이 컨트롤) | `Column` + `#body` slot | — |
| 토글 | `ToggleButton` | `v-model`, `onLabel`/`offLabel` |
| 선택 | `Select` | `:options`, `v-model` |
| 텍스트 | `InputText` | `v-model` |
| 액션 | `Button` (저장/기본값) | — |

## 3. 백엔드 API 요구사항

| 메서드 | 경로 | 요청 | 응답 |
|---|---|---|---|
| POST | `/api/dataset/search` | `{ serviceName: "__domain-kebab__/searchMatrix" }` | `{ ds_matrix: { rows: [{ key, channel1, channel2, ... }] } }` |
| POST | `/api/dataset/save` | `{ serviceName: "__domain-kebab__/saveMatrix", datasets: { ds_data: [{ _rowType: 'U', key, channel1, channel2 }] } }` | `{ saved: n }` |
| POST | `/api/dataset/save` | `{ serviceName: "__domain-kebab__/resetDefault" }` | `{ ok: true }` |

## 4. 화면 파일 작성 가이드

```vue
<template>
  <div class="page">
    <header>
      <Button label="기본값" severity="secondary" @click="resetDefault" />
      <Button label="저장" @click="save" />
    </header>
    <DataTable :value="rows" dataKey="key" row-hover>
      <Column field="key" header="카테고리" />
      <Column header="포탈">
        <template #body="slot"><ToggleButton v-model="slot.data.portal" /></template>
      </Column>
      <Column header="이메일">
        <template #body="slot"><ToggleButton v-model="slot.data.email" /></template>
      </Column>
    </DataTable>
  </div>
</template>
<script setup lang="ts">
const rows = ref([])
const load = async () => {
  const res = await axios.post('/api/dataset/search', { serviceName: '__domain-kebab__/searchMatrix' })
  rows.value = res.data.data.ds_matrix.rows
}
const save = async () => {
  await axios.post('/api/dataset/save', {
    serviceName: '__domain-kebab__/saveMatrix',
    datasets: { ds_data: rows.value.map(r => ({ _rowType: 'U', ...r })) }
  })
  await load()
}
const resetDefault = async () => {
  await axios.post('/api/dataset/save', { serviceName: '__domain-kebab__/resetDefault' })
  await load()
}
onMounted(load)
</script>
```

## 5. 4표

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/pages/PageNotifySettings.vue]` | `ui/src/pages/Page__DomainPascal__.vue` | `__DomainPascal__`, `__domain-kebab__` | matrix DataTable + ToggleButton 패턴 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `ui/src/pages/Page__DomainPascal__.vue` | 매트릭스 페이지 | `templates/screen_types/09_matrix/Page.vue.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/router/index.ts` | children 배열 | route entry |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 페이지 명 | Vue |
| `__domain-kebab__` | serviceName | API |

## 6. 부모-자식·라우터 연동

- 자식 다이얼로그 없음 (in-place 편집)
- 라우터 path 단순(`/notify-settings`)

## 7. 모범 워크스루 — `PageNotifySettings.vue` 따라가기

1. `onMounted`: `notification/searchMatrix` → 카테고리×채널 매트릭스 row 로드.
2. 각 셀에 `<ToggleButton v-model="slot.data.portal">` → 즉시 로컬 mutate (저장 안함).
3. 저장 버튼: 모든 row 를 `_rowType: 'U'` 로 묶어 `notification/saveMatrix` 1회 호출.
4. 기본값 버튼: `notification/resetDefault` 호출 후 reload.
