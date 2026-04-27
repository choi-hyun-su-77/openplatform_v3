# Chapter 1.8 — Frontend Conventions (Vue 3 / TypeScript)

**Project**: openplatform_v3  
**UI Root**: `ui/` (Vue 3 + TypeScript + PrimeVue)  
**Framework**: DataSet 중심 설계 (vue-spring-fw 정적 복사)  
**Date**: 2026-04-27

---

## 1. 단일파일 Vue 컴포넌트 (SFC) 구조 순서

`<script setup lang="ts">` 내부의 코드 작성 순서는 **항상 아래 순서 준수**. 이를 통해 일관된 코드 가독성과 유지보수성을 확보한다.

### 1.1 표준 순서

```typescript
// <script setup lang="ts">

// (a) Types & Interfaces — 타입 정의
interface FormState {
  formCode: string;
  docTitle: string;
}

// (b) Composables & API 호출
import { useApproval } from '@/composables/useApproval';
const approval = useApproval();

// (c) Props & Emits
const props = defineProps<{ visible: boolean; docId: number | null }>();
const emit = defineEmits<{ (e: 'update:visible', v: boolean): void }>();

// (d) Reactive State — ref/reactive/computed
const form = ref<FormState>({ formCode: '', docTitle: '' });
const loading = ref(false);

// (e) Actions & Handlers — 함수 정의
async function onSubmit() {
  loading.value = true;
  try {
    await approval.submitDocument(form.value);
  } finally {
    loading.value = false;
  }
}

// (f) Lifecycle & Watchers — onMounted, watch 등
watch(() => props.docId, async (id) => {
  if (id) await reload();
});
```

**이유**: 타입 정의 → composable 호출 → 상태 → 액션 → 라이프사이클 순서로 의존성 명확화.

### 1.2 Template → Style 순서

```vue
<template>
  <div class="container">
    <h2>{{ title }}</h2>
    <Button :loading="loading" @click="onSubmit" label="저장" />
  </div>
</template>

<script setup lang="ts">
// 위 1.1 순서 준수
</script>

<style scoped>
.container { padding: 1rem; }
</style>
```

---

## 2. 컴포넌트 네이밍 규칙

### 2.1 파일 위치별 프리픽스

| 종류 | 프리픽스 | 예시 | 위치 |
|---|---|---|---|
| 페이지 | `Page` | `PageApproval.vue` | `ui/src/pages/` |
| 레이아웃 | `Layout` | `LayoutDefault.vue` | `ui/src/components/layout/` |
| Widget | `Widget` | `WidgetPendingApproval.vue` | `ui/src/components/dashboard/widgets/` |
| Dialog | `<Domain>Dialog` | `ApprovalSubmitDialog.vue` | `ui/src/components/<domain>/` |
| 렌더링만 | `<Domain><Name>` | `ApprovalLineTimeline.vue` | `ui/src/components/<domain>/` |

**PrimeVue 컴포넌트**: 프리픽스 없음 (Dialog, Button, DataTable 등 그대로 사용).

**CLAUDE.md의 Cm 프리픽스는 본 프로젝트에 미적용.**

### 2.2 Composable (23개 목록)

**핵심 (데이터/상태)**:
- `useDataSet` — 행 변경 추적 (C/U/D), 유효성 검증
- `useDataSetPaging` — 페이징 조회
- `useTransaction` — API 단일 진입점
- `useApproval` — 결재 도메인 래퍼
- `useMessage` — 토스트 + 확인 다이얼로그 + 한글 조사
- `usePermission` — 메뉴 권한 (CRUD 레벨)
- `useItemPermission` — 항목별 권한 (컴포넌트 레벨)

**i18n**:
- `useLabel` — 다국어 라벨 (t 함수)
- `useLocale` — 로케일 변경

**도메인 (10개+)**:
- `useApproval`, `useLeave`, `useRoom`, `useAttendance`, `useWorkLog`, `useAdmin`, `useDataLibrary`, `useCodes`, `useCombo`

**UI 유틸**:
- `useStorage`, `usePopup`, `useTheme`, `useNotificationSse`, `useQuickActions`, `useWidget`, `useUx`

---

## 3. Pinia Store 패턴

**Composition API 스타일** (defineStore('name', () => { ... })):

```typescript
// store/auth.ts
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useAuthStore = defineStore('auth', () => {
  const accessToken = ref<string | null>(null);
  const user = ref<UserInfo | null>(null);

  const isAuthenticated = computed(() => !!accessToken.value);

  async function login() {
    // ...
  }

  return { accessToken, user, isAuthenticated, login };
});
```

---

## 4. API 호출 규약 — DataSet 단일 진입점

모든 백엔드 호출: `/api/dataset/search` 또는 `/api/dataset/save` (2개 엔드포인트만 사용).

### 4.1 호출 방식 (우선순위)

**(1) 도메인 Composable 래퍼 (권장)**
```typescript
const approval = useApproval();
const inbox = await approval.searchInbox('PENDING');
```

**(2) useTransaction() 직접 호출**
```typescript
const { transaction } = useTransaction();
const result = await transaction({
  serviceName: 'approval/searchInbox',
  datasets: { ds_search: { boxType: 'PENDING', userNo: 'E0032' } },
  out: { ds_inbox: ds_list }
});
```

**(3) axios 직접 호출 (금지)**
❌ 하면 안됨 (interceptor 우회, 에러 처리 중복).

### 4.2 인터셉터 기능

- Authorization 헤더 자동 추가 (Keycloak JWT)
- 401 → 로그인 페이지
- 403/5xx → 글로벌 토스트 에러
- 네트워크 타임아웃 감시

---

## 5. 상수 & Enum 관리

### 5.1 3가지 패턴

**Case A: 도메인별 인라인 (권장)**
```typescript
const DOC_STATUS = {
  DRAFT: '임시저장',
  PENDING: '대기',
  APPROVED: '승인완료'
} as const;
```

**Case B: 중앙 types 파일**
```typescript
// ui/src/types/approval.ts
export enum ApprovalStatus { DRAFT, PENDING, APPROVED, REJECTED }
```

**Case C: 백엔드 공유 코드 (useCodes)**
```typescript
const codes = useCodes();
const formCodes = await codes.getByGroup('FORM_CODE');
```

---

## 6. 에러 처리

```typescript
const $msg = useMessage();

try {
  await approval.submitDocument(form.value);
  $msg.success('상신 완료');
} catch (error: any) {
  $msg.error(error?.response?.data?.message || '실패');
}
```

**인터셉터가 401/403/5xx를 자동 처리하므로 추가 catch 불필요.**

---

## 7. i18n (다국어) — ko/en/ja/zh-CN

```typescript
// 라벨 조회
const { t } = useLabel();
const label = t('LBL_CUSTOMER_NAME');

// 메시지 (파라미터 + 조사 자동)
const $msg = useMessage();
$msg.byId('MSG_DELETE_CONFIRM', { name: '고객명' });
// → "'고객명'을 삭제하시겠습니까?" (한글 조사 자동)

// 조사 수동 처리
$msg.particle('고객', '을/를');  // → '고객을'
```

---

## 8. 권한 체크

### 메뉴 레벨 (페이지)
```typescript
const permission = usePermission('approval-list');
<Button v-if="permission.canCreate" label="상신" />
```

### 항목 레벨 (컴포넌트)
```typescript
const itemPerm = useItemPermission('approval-list');
const isVisible = computed(() => itemPerm.value[itemId]?.visible ?? true);
```

### 라우터 가드
```typescript
router.beforeEach((to, from, next) => {
  if (to.meta.requiredPermission) {
    const perm = usePermission(to.meta.requiredPermission);
    if (!perm.value.canRead) {
      next({ name: '403' });
    } else {
      next();
    }
  }
});
```

---

## 9. ApprovalSubmitDialog.vue 종합 예시

```typescript
<script setup lang="ts">
// (a) Types
interface FormState { formCode: string; docTitle: string; amount: number | null }

// (b) Composables
const approval = useApproval();
const $msg = useMessage();
const auth = useAuthStore();

// (c) Props
const props = defineProps<{ visible: boolean; initialFormCode?: string }>();
const emit = defineEmits<{ (e: 'update:visible', v: boolean): void }>();

// (d) State
const form = ref<FormState>({ formCode: '', docTitle: '', amount: null });
const submitting = ref(false);

// (e) Actions
async function onSubmit() {
  if (!form.value.formCode) { $msg.warn('양식을 선택하세요'); return; }
  submitting.value = true;
  try {
    const result = await approval.submitDocument({
      ...form.value,
      drafterNo: auth.user?.employeeNo || '',
      drafterName: auth.user?.userName || ''
    });
    $msg.success(`상신 완료 (문서: ${result.docId})`);
    emit('submitted', result.docId);
    emit('update:visible', false);
  } catch (e: any) {
    $msg.error(e?.response?.data?.message || '상신 실패');
  } finally {
    submitting.value = false;
  }
}

// (f) Lifecycle
onMounted(() => {
  if (props.initialFormCode) form.value.formCode = props.initialFormCode;
});
</script>
```

---

## 10. 주의 사항 & 안티패턴

| 금지 사항 | 올바른 방식 |
|---|---|
| axios 직접 호출 | useTransaction() 또는 composable |
| DataSet 외부 상태 | useDataSet + getChangedRows() |
| hardcoded URL | /api/... 절대 경로 |
| computed 안 async | watch 또는 함수 액션 |
| 글로벌 변수 | Pinia store |

---

## 참조

- `ui/src/composables/useApproval.ts` — 결재 래퍼
- `ui/src/composables/useDataSet.ts` — 행 변경 추적 핵심
- `ui/src/components/approval/ApprovalSubmitDialog.vue` — SFC 패턴
- `docs/approval.md` — 결재 도메인 상세
- `CLAUDE.md` — 프로젝트 규칙

---

## 이 챕터가 다루지 않은 인접 주제

1. 라우팅 & 네비게이션 (`router/index.ts`)
2. 공통 컴포넌트 세트 (`components/common/`)
3. Keycloak SSO 통합 (`keycloak.ts`)
4. 테마 & 스타일 (PrimeVue Aura + Tailwind)
5. 성능 최적화 & 테스트

