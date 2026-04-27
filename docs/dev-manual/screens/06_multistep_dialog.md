# screens/06_multistep_dialog.md — 형태 6: 다단계 입력 다이얼로그

> Phase 3.6 산출물. 모범: `[code: ui/src/components/approval/ApprovalSubmitDialog.vue]`

## 1. 화면 정의

`form_code` 프리셋(LEAVE/EXPENSE/PURCHASE/TRIP)에 따라 필드 분기, 단계 표시(기본정보 → 첨부 → 결재선) + 신청 버튼.

```
┌─ Dialog (신규 문서 신청) ───────────────┐
├─ Step Indicator (1 → 2 → 3) ─────────────┤
├─ Step 1: 제목/기간/사유 ──────────────────┤
├─ Step 2: 첨부 ───────────────────────────┤
├─ Step 3: 결재선 ─────────────────────────┤
├─ Footer (이전 / 다음 / 신청) ─────────────┤
└──────────────────────────────────────────┘
```

사용 시나리오: 결재 신청 (휴가/지출/구매/출장), 다단계 폼.

## 2. UI 컴포넌트 매핑

| 역할 | 컴포넌트 | 핵심 prop / event |
|---|---|---|
| 모달 | `Dialog` | `v-model:visible` |
| 폼 | `InputText`/`InputNumber`/`Textarea`/`DatePicker`/`Dropdown` | — |
| 첨부 | `FileUploadPanel` (custom) — MinIO presigned PUT 사용 | — |
| 결재선 | `Dropdown` (`empNo` 선택) + `Tag` (라인 미리보기) | — |
| 단계 | `Stepper` (옵션) 또는 v-show | — |
| 액션 | `Button` (이전/다음/신청) | — |

## 3. 백엔드 API 요구사항

| 메서드 | 경로 | 요청 | 응답 |
|---|---|---|---|
| POST | `/api/dataset/search` | `{ serviceName: "approval/searchFormTemplates", datasets: { ds_search: { formCode } } }` | `{ ds_template: { rows: [{ formCode, fieldsJson }] } }` |
| POST | `/api/dataset/save` | `{ serviceName: "approval/submitDocument", datasets: { ds_data: { formCode, title, content, period, attachments, approvalLine } } }` | `{ docId }` |

## 4. 화면 파일 작성 가이드

```vue
<template>
  <Dialog v-model:visible="visible" :modal="true">
    <template #header>{{ title }}</template>
    <div v-show="step===1">
      <InputText v-model="form.title" placeholder="제목" />
      <DatePicker v-model="form.startDt" />
      <DatePicker v-model="form.endDt" />
      <Textarea v-model="form.reason" :rows="4" />
    </div>
    <div v-show="step===2"><FileUploadPanel v-model:files="form.attachments" /></div>
    <div v-show="step===3">
      <Dropdown v-for="(line, i) in form.line" :key="i" v-model="line.approver" :options="empOptions" optionLabel="name" />
    </div>
    <template #footer>
      <Button label="이전" @click="step--" :disabled="step===1" />
      <Button label="다음" @click="step++" v-if="step<3" />
      <Button label="신청" @click="submit" v-if="step===3" />
    </template>
  </Dialog>
</template>
<script setup lang="ts">
const props = defineProps<{ initialFormCode?: string }>()
const emit = defineEmits(['submitted'])
const visible = defineModel<boolean>('visible')
const step = ref(1)
const form = ref({ formCode: props.initialFormCode, title: '', startDt: null, endDt: null, reason: '', attachments: [], line: [{}] })
const submit = async () => {
  const res = await axios.post('/api/dataset/save', {
    serviceName: 'approval/submitDocument',
    datasets: { ds_data: form.value }
  })
  emit('submitted', res.data.data.docId)
  visible.value = false
}
</script>
```

## 5. 4표

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/components/approval/ApprovalSubmitDialog.vue]` | `ui/src/components/__domain-kebab__/__DomainPascal__SubmitDialog.vue` | `__DomainPascal__`, `__domain-kebab__`, `__form_code__` | step 폼 패턴 복제 |
| `[code: ui/src/components/common/FileUploadPanel.vue]` | (재사용) | — | MinIO presigned PUT |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `ui/src/components/__domain-kebab__/__DomainPascal__SubmitDialog.vue` | 다단계 신청 다이얼로그 | `templates/screen_types/06_multistep/Dialog.vue.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| 부모 페이지 (예: `Page__DomainPascal__.vue`) | template/script | 자식 import + `@submitted` 핸들러 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 컴포넌트 명 | Vue |
| `__form_code__` | (예: `LEAVE`) | initialFormCode prop |
| `__domain-kebab__` | serviceName | API |

## 6. 부모-자식·라우터 연동

- 부모: `<__DomainPascal__SubmitDialog v-model:visible :initial-form-code @submitted="onSubmitted">`
- 자식: `defineProps<{ initialFormCode }>()` + `defineEmits(['submitted'])`
- submit 후 docId emit → 부모는 list reload 또는 detail 다이얼로그 오픈

## 7. 모범 워크스루 — `ApprovalSubmitDialog.vue` 따라가기

1. `<Dropdown v-model="form.formCode">` (LEAVE/EXPENSE/PURCHASE/TRIP) 선택 → 필드 표시 분기.
2. Step 1: 기본정보 (제목/기간/사유). Step 2: 첨부 — `<FileUploadPanel>` 가 MinIO presigned PUT 사용.
3. Step 3: 결재선 — DMN 자동 추천 + 사용자 변경 가능. `<Dropdown :options="empOptions" optionLabel="name">`.
4. 신청: `axios.post('/api/dataset/save', { serviceName: 'approval/submitDocument', datasets: { ds_data: form } })` → docId.
5. emit('submitted', docId) → 부모 PageApproval inbox/outbox reload.
