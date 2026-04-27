<!--
  결재 상신 다이얼로그 — 양식 선택 → 폼 → 결재선 미리보기 → 상신.

  Props:
    visible (v-model)

  Emits:
    update:visible
    submitted (docId) — 상신 성공 시 부모가 리스트 새로고침
-->
<template>
  <Dialog
    :visible="visible"
    @update:visible="(v: boolean) => emit('update:visible', v)"
    header="결재 상신"
    modal
    :style="{ width: '760px', maxWidth: '95vw' }"
    :draggable="false"
  >
    <div class="form-grid">
      <label>양식 *</label>
      <Dropdown v-model="form.formCode" :options="formOptions" optionLabel="label" optionValue="value"
                placeholder="양식을 선택하세요" class="w-full" @change="onFormChange" />

      <label>제목 *</label>
      <InputText v-model="form.docTitle" placeholder="문서 제목" class="w-full" />

      <!-- LEAVE 양식 전용 필드 (Phase 14 트랙 1) -->
      <template v-if="isLeave">
        <label>휴가 유형 *</label>
        <Dropdown v-model="leaveForm.leaveType" :options="leaveTypeOptions"
                  optionLabel="label" optionValue="value"
                  placeholder="유형을 선택하세요" class="w-full" @change="recalcDays" />

        <label>시작일 *</label>
        <DatePicker v-model="leaveForm.fromDate" dateFormat="yy-mm-dd"
                    showIcon class="w-full" @update:modelValue="recalcDays" />

        <label>종료일 *</label>
        <DatePicker v-model="leaveForm.toDate" dateFormat="yy-mm-dd"
                    showIcon class="w-full" @update:modelValue="recalcDays" />

        <label>일수</label>
        <div class="leave-days-row">
          <InputNumber v-model="leaveForm.days" :min="0" :max="365" :step="0.5"
                       :minFractionDigits="1" :maxFractionDigits="1"
                       showButtons buttonLayout="horizontal" class="w-half" />
          <small class="hint">반차(0.5)는 자동 적용. 영업일 = 주말/공휴일 제외 (UI 측은 주말만 자동 제외).</small>
        </div>

        <label>사유</label>
        <Textarea v-model="leaveForm.reason" rows="3" autoResize placeholder="휴가 사유" class="w-full" />
      </template>

      <!-- 비-LEAVE 양식: 금액/본문 -->
      <template v-else>
        <label>금액</label>
        <InputNumber v-model="form.amount" placeholder="0" :min="0" :step="100000"
                     showButtons buttonLayout="horizontal" mode="currency" currency="KRW"
                     class="w-full" @input="updatePreview" />

        <label>본문</label>
        <Textarea v-model="form.content" rows="8" autoResize placeholder="결재 본문을 입력하세요" class="w-full" />
      </template>
    </div>

    <div class="approver-preview">
      <h4><i class="pi pi-users"></i> 결재선 미리보기</h4>
      <div v-if="loadingPreview" class="empty">불러오는 중...</div>
      <div v-else-if="!previewApprovers.length" class="empty">양식과 금액을 선택하면 결재선이 자동으로 표시됩니다</div>
      <ol v-else>
        <li v-for="(a, i) in previewApprovers" :key="i">
          <Tag :value="`${i + 1}단계`" severity="info" />
          <strong>{{ a.approverName }}</strong>
          <span class="role">{{ a.positionName }}</span>
        </li>
      </ol>
    </div>

    <template #footer>
      <Button label="취소" text @click="emit('update:visible', false)" />
      <Button label="상신" icon="pi pi-send" :loading="submitting" @click="onSubmit" />
    </template>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, watch, computed, onMounted } from 'vue';
import Dialog from 'primevue/dialog';
import Dropdown from 'primevue/dropdown';
import InputText from 'primevue/inputtext';
import InputNumber from 'primevue/inputnumber';
import Textarea from 'primevue/textarea';
import Button from 'primevue/button';
import Tag from 'primevue/tag';
import DatePicker from 'primevue/datepicker';
import axios from 'axios';
import { useApproval } from '@/composables/useApproval';
import { useAuthStore } from '@/store/auth';

const props = defineProps<{
  visible: boolean;
  /** LEAVE 등으로 양식을 사전 지정. PageLeave 에서 'LEAVE' 전달. */
  initialFormCode?: string;
}>();
const emit = defineEmits<{
  (e: 'update:visible', v: boolean): void;
  (e: 'submitted', docId: number): void;
}>();

const approval = useApproval();
const auth = useAuthStore();

interface FormState {
  formCode: string;
  docTitle: string;
  amount: number | null;
  content: string;
}

const form = ref<FormState>({ formCode: '', docTitle: '', amount: null, content: '' });

interface LeaveFormState {
  leaveType: string;
  fromDate: Date | null;
  toDate: Date | null;
  days: number;
  reason: string;
}
const leaveForm = ref<LeaveFormState>({
  leaveType: 'ANNUAL',
  fromDate: null,
  toDate: null,
  days: 0,
  reason: ''
});

const leaveTypeOptions = [
  { label: '연차', value: 'ANNUAL' },
  { label: '오전반차', value: 'HALF_AM' },
  { label: '오후반차', value: 'HALF_PM' },
  { label: '병가', value: 'SICK' },
  { label: '경조사', value: 'FAMILY' },
  { label: '무급휴가', value: 'UNPAID' }
];

const isLeave = computed(() => form.value.formCode === 'LEAVE');

const formOptions = ref<{ label: string; value: string }[]>([]);
const previewApprovers = ref<any[]>([]);
const loadingPreview = ref(false);
const submitting = ref(false);

async function loadForms() {
  try {
    const rows = await approval.searchFormTemplates();
    formOptions.value = rows.map((r: any) => ({
      label: r.formName || r.codeName || r.formCode,
      value: r.formCode || r.code
    }));
  } catch (e) {
    console.error('form templates failed', e);
    formOptions.value = [
      { label: '휴가신청서', value: 'LEAVE' },
      { label: '지출결의서', value: 'EXPENSE' },
      { label: '구매요청서', value: 'PURCHASE' },
      { label: '출장신청서', value: 'BIZTRIP' }
    ];
  }
}

let previewTimer: any = null;
function updatePreview() {
  if (previewTimer) clearTimeout(previewTimer);
  previewTimer = setTimeout(async () => {
    if (!form.value.formCode) {
      previewApprovers.value = [];
      return;
    }
    loadingPreview.value = true;
    try {
      const r = await axios.post('/api/dataset/search', {
        serviceName: 'approval/previewApprovers',
        datasets: { ds_search: { formCode: form.value.formCode, amount: form.value.amount || 0 } }
      });
      previewApprovers.value = r.data?.data?.ds_approvers?.rows || [];
    } catch (e) {
      previewApprovers.value = [];
    } finally {
      loadingPreview.value = false;
    }
  }, 300);
}

async function onSubmit() {
  if (!form.value.formCode) { alert('양식을 선택하세요'); return; }
  if (!form.value.docTitle.trim()) { alert('제목을 입력하세요'); return; }

  // LEAVE 추가 검증 / payload 구성
  const extra: Record<string, any> = {};
  if (isLeave.value) {
    if (!leaveForm.value.leaveType) { alert('휴가 유형을 선택하세요'); return; }
    if (!leaveForm.value.fromDate || !leaveForm.value.toDate) {
      alert('시작일/종료일을 선택하세요');
      return;
    }
    if (leaveForm.value.toDate < leaveForm.value.fromDate) {
      alert('종료일은 시작일 이후여야 합니다');
      return;
    }
    if (leaveForm.value.days <= 0) {
      alert('일수가 0입니다. 날짜를 다시 확인하세요');
      return;
    }
    extra.leaveType = leaveForm.value.leaveType;
    extra.fromDate = formatDate(leaveForm.value.fromDate);
    extra.toDate = formatDate(leaveForm.value.toDate);
    extra.days = leaveForm.value.days;
    extra.reason = leaveForm.value.reason;
  }

  submitting.value = true;
  try {
    const result = await approval.submitDocument({
      docTitle: form.value.docTitle,
      formCode: form.value.formCode,
      amount: form.value.amount,
      content: isLeave.value
        ? `[휴가신청] ${extra.leaveType} ${extra.fromDate}~${extra.toDate} (${extra.days}일)\n${leaveForm.value.reason || ''}`
        : form.value.content,
      drafterNo: auth.user?.employeeNo || '',
      drafterName: auth.user?.userName || '',
      drafterDept: auth.user?.deptName || '',
      status: 'PENDING',
      ...extra
    });
    const docId = (result as any).docId;
    alert(`상신 완료. 문서번호 ${docId} (결재자 ${(result as any).approvers}명)`);
    emit('submitted', docId);
    emit('update:visible', false);
    resetForms();
  } catch (e: any) {
    alert('상신 실패: ' + (e?.response?.data?.message || e.message));
  } finally {
    submitting.value = false;
  }
}

function resetForms() {
  form.value = { formCode: '', docTitle: '', amount: null, content: '' };
  leaveForm.value = { leaveType: 'ANNUAL', fromDate: null, toDate: null, days: 0, reason: '' };
  previewApprovers.value = [];
}

function onFormChange() {
  // 양식 변경 시 결재선 미리보기 재계산
  updatePreview();
  // LEAVE 로 진입 시 days 자동 계산 한번
  if (isLeave.value) recalcDays();
}

function recalcDays() {
  if (!isLeave.value) return;
  const t = leaveForm.value.leaveType;
  if (t === 'HALF_AM' || t === 'HALF_PM') {
    leaveForm.value.days = 0.5;
    return;
  }
  const f = leaveForm.value.fromDate;
  const to = leaveForm.value.toDate;
  if (!f || !to) {
    leaveForm.value.days = 0;
    return;
  }
  // 시작 > 종료면 0 (검증은 onSubmit 에서)
  if (to < f) {
    leaveForm.value.days = 0;
    return;
  }
  // UI 측은 주말만 자동 제외 (공휴일은 백엔드 calculateDays 에서 정밀 계산)
  let days = 0;
  const cur = new Date(f.getFullYear(), f.getMonth(), f.getDate());
  const end = new Date(to.getFullYear(), to.getMonth(), to.getDate());
  while (cur.getTime() <= end.getTime()) {
    const dow = cur.getDay();
    if (dow !== 0 && dow !== 6) days += 1;
    cur.setDate(cur.getDate() + 1);
  }
  leaveForm.value.days = days;
}

function formatDate(d: Date) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${dd}`;
}

watch(() => props.visible, (v) => {
  if (v) {
    loadForms();
    // 사전 지정 양식 적용
    if (props.initialFormCode) {
      form.value.formCode = props.initialFormCode;
      if (props.initialFormCode === 'LEAVE' && !form.value.docTitle) {
        form.value.docTitle = '휴가신청서';
      }
      updatePreview();
      if (isLeave.value) recalcDays();
    }
  }
});
onMounted(loadForms);
</script>

<style scoped>
.form-grid {
  display: grid;
  grid-template-columns: 90px 1fr;
  gap: 0.875rem 1rem;
  align-items: center;
  padding: 0.5rem 0;
}
.form-grid label {
  font-weight: 500;
  color: #475569;
  text-align: right;
}
.w-full { width: 100%; }
.w-half { width: 50%; min-width: 140px; }
.leave-days-row { display: flex; align-items: center; gap: 0.625rem; flex-wrap: wrap; }
.leave-days-row .hint { color: #94a3b8; font-size: 0.78rem; }

.approver-preview {
  margin-top: 1.25rem;
  padding: 1rem;
  background: #f8fafc;
  border-radius: 0.5rem;
}
.approver-preview h4 {
  margin: 0 0 0.75rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #475569;
}
.approver-preview ol {
  margin: 0;
  padding-left: 1.25rem;
  list-style: none;
}
.approver-preview li {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  padding: 0.4rem 0;
}
.approver-preview .role {
  color: #94a3b8;
  font-size: 0.85rem;
}
.empty { color: #94a3b8; font-size: 0.875rem; padding: 0.25rem 0; }
</style>
