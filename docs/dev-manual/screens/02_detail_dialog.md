# screens/02_detail_dialog.md — 형태 2: 단건 상세/편집 다이얼로그

> Phase 3.2 산출물. 모범: `[code: ui/src/components/approval/ApprovalDetailDialog.vue]`

## 1. 화면 정의

목록의 행 클릭 또는 상세 보기 트리거로 모달 오버레이가 열리고, 읽기 전용 상세 + 편집 폼 + 액션 버튼(저장/승인/반려/삭제)을 제공.

```
┌─ Dialog Header ────────────────────────────┐
├─ TabView (상세/편집/첨부) ─────────────────┤
├─ Detail (Timeline 결재선 / 메타 / 본문) ──┤
├─ Footer (액션 버튼들) ──────────────────────┤
└────────────────────────────────────────────┘
```

사용 시나리오: 결재 상세, 게시글 상세, 직원 상세, 일정 편집.

## 2. UI 컴포넌트 매핑

| 역할 | 컴포넌트 | 핵심 prop / event |
|---|---|---|
| 모달 | `Dialog` | `v-model:visible`, `:modal`, `:style` |
| 탭 | `TabView` / `TabPanel` | `:active-index` |
| 결재선/이력 | `Timeline` | `:value`, custom `#content` slot |
| 구분 | `Divider` | — |
| 단일 입력 | `InputText` | `v-model`, `:placeholder` |
| 멀티 입력 | `Textarea` | `v-model`, `:rows` |
| 날짜 | `DatePicker` | `v-model`, `showTime?` |
| 액션 | `Button` | `:label`, `:severity`, `@click` |
| 상태 | `Tag` | `:value`, `:severity` |

## 3. 백엔드 API 요구사항

| 메서드 | 경로 | 요청 | 응답 |
|---|---|---|---|
| POST | `/api/dataset/search` | `{ serviceName: "__domain-kebab__/searchDetail", datasets: { ds_data: { id } } }` | `{ ds_detail: { rows: [{...}] }, ds_history: { rows: [...] } }` |
| POST | `/api/dataset/save` | `{ serviceName: "__domain-kebab__/save", datasets: { ds_data: [{ _rowType: "U", id, title, content }] } }` | `{ saved: n }` |
| POST | `/api/dataset/save` (액션) | `{ serviceName: "__domain-kebab__/approve", datasets: { ds_data: { id, comment } } }` | `{ ok: true }` |

## 4. 화면 파일 작성 가이드

```vue
<!-- ui/src/components/__domain-kebab__/__DomainPascal__DetailDialog.vue -->
<template>
  <Dialog v-model:visible="visible" :modal="true" :style="{ width: '720px' }">
    <template #header>{{ t('LBL___DOMAIN_UPPER___DETAIL') }}</template>
    <TabView v-model:active-index="tabIndex">
      <TabPanel header="상세">
        <Timeline :value="historyRows">
          <template #content="{ item }">{{ item.actor }} — {{ item.action }}</template>
        </Timeline>
        <Divider />
        <p><b>제목:</b> {{ detail.title }}</p>
        <Textarea v-model="detail.content" :rows="6" :readonly="!editable" />
      </TabPanel>
      <TabPanel header="첨부">…</TabPanel>
    </TabView>
    <template #footer>
      <Button label="취소" severity="secondary" @click="visible = false" />
      <Button label="저장" @click="save" v-if="editable" />
      <Button label="승인" severity="success" @click="approve" v-if="canApprove" />
      <Button label="반려" severity="danger" @click="reject" v-if="canApprove" />
    </template>
  </Dialog>
</template>
<script setup lang="ts">
import { ref, watch } from 'vue'
import axios from 'axios'
import Dialog from 'primevue/dialog'
import TabView from 'primevue/tabview'
import TabPanel from 'primevue/tabpanel'
import Timeline from 'primevue/timeline'
import Divider from 'primevue/divider'
import Textarea from 'primevue/textarea'
import Button from 'primevue/button'

const props = defineProps<{ id?: string | null }>()
const emit = defineEmits(['saved'])
const visible = defineModel<boolean>('visible', { default: false })
const tabIndex = ref(0)
const detail = ref<any>({}); const historyRows = ref<any[]>([]); const editable = ref(true); const canApprove = ref(false)

const load = async () => {
  if (!props.id) { detail.value = {}; return }
  const res = await axios.post('/api/dataset/search', {
    serviceName: '__domain-kebab__/searchDetail',
    datasets: { ds_data: { id: props.id } }
  })
  detail.value = res.data.data.ds_detail.rows[0]
  historyRows.value = res.data.data.ds_history?.rows ?? []
}
const save = async () => {
  await axios.post('/api/dataset/save', {
    serviceName: '__domain-kebab__/save',
    datasets: { ds_data: [{ _rowType: 'U', ...detail.value }] }
  })
  emit('saved'); visible.value = false
}
const approve = async () => { await axios.post('/api/dataset/save', { serviceName: '__domain-kebab__/approve', datasets: { ds_data: { id: props.id } } }); emit('saved'); visible.value = false }
const reject = async () => { await axios.post('/api/dataset/save', { serviceName: '__domain-kebab__/reject', datasets: { ds_data: { id: props.id } } }); emit('saved'); visible.value = false }

watch(() => visible.value, (v) => { if (v) load() })
</script>
```

## 5. 4표

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/components/approval/ApprovalDetailDialog.vue]` | `ui/src/components/__domain-kebab__/__DomainPascal__DetailDialog.vue` | `__DomainPascal__`, `__domain-kebab__`, `__DOMAIN_UPPER__` | Tab/Timeline/Action 표준 골격 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `ui/src/components/__domain-kebab__/__DomainPascal__DetailDialog.vue` | 상세 다이얼로그 | `templates/screen_types/02_detail/Dialog.vue.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/pages/Page__DomainPascal__.vue` | template/script | 자식 import + `<__DomainPascal__DetailDialog>` 사용 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 컴포넌트 명 | template/script |
| `__domain-kebab__` | serviceName / 폴더 | API 호출 |
| `__DOMAIN_UPPER__` | i18n 키 | 라벨 |

## 6. 부모-자식·라우터 연동

- 부모: `<__DomainPascal__DetailDialog v-model:visible :id @saved>`
- 자식: `defineProps<{ id }>()` + `defineEmits(['saved'])` + `defineModel<boolean>('visible')`
- watch(visible) → load(); save 후 `emit('saved')` → 부모 `load()` 재호출

## 7. 모범 워크스루 — `ApprovalDetailDialog.vue` 따라가기

1. `<Dialog>` 안에 `<TabView>` 4 탭 (상세 / 결재선 / 첨부 / 이력).
2. 결재선 탭은 `<Timeline>` 으로 결재자 순서 + 상태(승인/반려/대기).
3. `axios.post('/api/dataset/search', { serviceName: 'approval/searchDetail', datasets: { ds_data: { docId } } })` → `detail.value = res.data.data.ds_detail.rows[0]`.
4. 액션 버튼: 승인/반려/회수 — 각각 `approval/approve`, `approval/reject`, `approval/withdraw` serviceName 호출.
5. 저장 후 `emit('saved')` → 부모 PageApproval 의 inbox/outbox 가 재로드.
