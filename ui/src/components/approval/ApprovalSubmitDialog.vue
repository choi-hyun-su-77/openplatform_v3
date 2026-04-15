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
                placeholder="양식을 선택하세요" class="w-full" @change="updatePreview" />

      <label>제목 *</label>
      <InputText v-model="form.docTitle" placeholder="문서 제목" class="w-full" />

      <label>금액</label>
      <InputNumber v-model="form.amount" placeholder="0" :min="0" :step="100000"
                   showButtons buttonLayout="horizontal" mode="currency" currency="KRW"
                   class="w-full" @input="updatePreview" />

      <label>본문</label>
      <Textarea v-model="form.content" rows="8" autoResize placeholder="결재 본문을 입력하세요" class="w-full" />
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
import { ref, watch, onMounted } from 'vue';
import Dialog from 'primevue/dialog';
import Dropdown from 'primevue/dropdown';
import InputText from 'primevue/inputtext';
import InputNumber from 'primevue/inputnumber';
import Textarea from 'primevue/textarea';
import Button from 'primevue/button';
import Tag from 'primevue/tag';
import axios from 'axios';
import { useApproval } from '@/composables/useApproval';
import { useAuthStore } from '@/store/auth';

const props = defineProps<{ visible: boolean }>();
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
  submitting.value = true;
  try {
    const result = await approval.submitDocument({
      docTitle: form.value.docTitle,
      formCode: form.value.formCode,
      amount: form.value.amount,
      content: form.value.content,
      drafterNo: auth.user?.employeeNo || '',
      drafterName: auth.user?.userName || '',
      drafterDept: auth.user?.deptName || '',
      status: 'PENDING'
    });
    const docId = (result as any).docId;
    alert(`상신 완료. 문서번호 ${docId} (결재자 ${(result as any).approvers}명)`);
    emit('submitted', docId);
    emit('update:visible', false);
    // reset
    form.value = { formCode: '', docTitle: '', amount: null, content: '' };
    previewApprovers.value = [];
  } catch (e: any) {
    alert('상신 실패: ' + (e?.response?.data?.message || e.message));
  } finally {
    submitting.value = false;
  }
}

watch(() => props.visible, (v) => {
  if (v) loadForms();
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
