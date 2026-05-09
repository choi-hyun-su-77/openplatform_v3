<!--
  결재 액션 바 — 문서 상세 다이얼로그 하단에 표시.

  Props:
    doc:  { docId, drafterNo, status, ... }
    line: 현재 사용자가 결재해야 하는 line (없으면 null)

  Buttons (동적 노출):
    - 승인 / 반려 — 사용자가 current approver 일 때
    - 회수      — 사용자가 drafter + status in [PENDING, IN_PROGRESS]
    - 재상신    — 사용자가 drafter + status = REJECTED
    - 대결 등록 — 항상 (개인 부재 등록용)

  Emits:
    'changed' — 액션 성공 후 부모가 다이얼로그를 새로고침할 수 있도록 알림
-->
<template>
  <div class="action-bar">
    <Button v-if="canApprove" :label="t('BTN_APPROVE')" icon="pi pi-check" severity="success"
            @click="onApprove" :loading="busy" />
    <Button v-if="canApprove" :label="t('BTN_REJECT')" icon="pi pi-times" severity="danger"
            @click="onReject" :loading="busy" />
    <Button v-if="canWithdraw" :label="t('BTN_WITHDRAW')" icon="pi pi-undo" severity="secondary"
            @click="onWithdraw" :loading="busy" />
    <Button v-if="canResubmit" :label="t('BTN_RESUBMIT')" icon="pi pi-refresh" severity="warn"
            @click="onResubmit" :loading="busy" />
    <Button :label="t('BTN_DELEGATE')" icon="pi pi-user-edit" severity="contrast"
            @click="showDelegate = true" />

    <!-- 코멘트 입력 다이얼로그 -->
    <Dialog v-model:visible="showCommentDialog" :header="commentTitle" modal :style="{ width: '420px' }">
      <Textarea v-model="commentText" rows="4" autoResize :placeholder="t('PH_COMMENT')" class="w-full" />
      <template #footer>
        <Button :label="t('BTN_CANCEL')" text @click="showCommentDialog = false" />
        <Button :label="t('BTN_CONFIRM')" @click="confirmComment" :loading="busy" />
      </template>
    </Dialog>

    <!-- 대결 등록 다이얼로그 -->
    <Dialog v-model:visible="showDelegate" :header="t('LBL_APPROVAL_DELEGATE_HEADER')" modal :style="{ width: '480px' }">
      <div class="form-grid">
        <label>{{ t('LBL_APPROVAL_DELEGATEE_NO') }}</label>
        <InputText v-model="delegate.delegateeNo" :placeholder="t('PH_DELEGATEE_NO')" />
        <label>{{ t('LBL_APPROVAL_REASON') }}</label>
        <InputText v-model="delegate.reason" :placeholder="t('PH_DELEGATE_REASON')" />
        <label>{{ t('LBL_APPROVAL_FROM_DATE') }}</label>
        <InputText v-model="delegate.fromDate" type="date" />
        <label>{{ t('LBL_APPROVAL_TO_DATE') }}</label>
        <InputText v-model="delegate.toDate" type="date" />
      </div>
      <template #footer>
        <Button :label="t('BTN_CANCEL')" text @click="showDelegate = false" />
        <Button :label="t('BTN_REGISTER')" @click="confirmDelegate" :loading="busy" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import Button from 'primevue/button';
import Dialog from 'primevue/dialog';
import Textarea from 'primevue/textarea';
import InputText from 'primevue/inputtext';
import { useAuthStore } from '@/store/auth';
import { useApproval } from '@/composables/useApproval';
import { useLabel } from '@/composables/useLabel';

const { t } = useLabel();

interface Doc {
  docId: number;
  drafterNo: string;
  status: string;
  docTitle?: string;
}

interface Line {
  lineId: number;
  approverNo: string;
  status: string;
}

const props = defineProps<{
  doc: Doc | null;
  line?: Line | null;  // 현재 사용자의 PENDING 라인 (없으면 결재 권한 없음)
}>();

const emit = defineEmits<{ (e: 'changed'): void }>();

const auth = useAuthStore();
const approval = useApproval();
const busy = ref(false);

const myUserNo = computed(() => auth.user?.employeeNo || auth.user?.userId || '');
const isDrafter = computed(() => props.doc?.drafterNo === myUserNo.value);

const canApprove = computed(() => !!props.line && props.line.status === 'PENDING' && props.line.approverNo === myUserNo.value);
const canWithdraw = computed(() =>
  isDrafter.value && props.doc &&
  (props.doc.status === 'PENDING' || props.doc.status === 'IN_PROGRESS')
);
const canResubmit = computed(() =>
  isDrafter.value && props.doc?.status === 'REJECTED'
);

// 코멘트 다이얼로그 상태
const showCommentDialog = ref(false);
const commentText = ref('');
const commentMode = ref<'approve' | 'reject'>('approve');
const commentTitle = computed(() => commentMode.value === 'approve' ? t('LBL_APPROVAL_COMMENT_APPROVE') : t('LBL_APPROVAL_COMMENT_REJECT'));

function onApprove() { commentMode.value = 'approve'; commentText.value = ''; showCommentDialog.value = true; }
function onReject()  { commentMode.value = 'reject';  commentText.value = ''; showCommentDialog.value = true; }

async function confirmComment() {
  if (!props.doc || !props.line) return;
  if (commentMode.value === 'reject' && !commentText.value.trim()) {
    alert(t('MSG_APPROVAL_REJECT_REASON_REQ'));
    return;
  }
  busy.value = true;
  try {
    if (commentMode.value === 'approve') {
      await approval.approve(props.line.lineId, props.doc.docId, commentText.value);
    } else {
      await approval.reject(props.line.lineId, props.doc.docId, commentText.value);
    }
    showCommentDialog.value = false;
    emit('changed');
  } catch (e: any) {
    const failMsg = commentMode.value === 'approve' ? t('MSG_APPROVAL_APPROVE_FAILED') : t('MSG_APPROVAL_REJECT_FAILED');
    alert(failMsg + ': ' + (e?.response?.data?.message || e.message));
  } finally {
    busy.value = false;
  }
}

async function onWithdraw() {
  if (!props.doc) return;
  if (!confirm(t('MSG_APPROVAL_WITHDRAW_CONFIRM'))) return;
  busy.value = true;
  try {
    await approval.withdraw(props.doc.docId);
    emit('changed');
  } catch (e: any) {
    alert(t('MSG_APPROVAL_WITHDRAW_FAILED') + ': ' + (e?.response?.data?.message || e.message));
  } finally {
    busy.value = false;
  }
}

async function onResubmit() {
  if (!props.doc) return;
  if (!confirm(t('MSG_APPROVAL_RESUBMIT_CONFIRM'))) return;
  busy.value = true;
  try {
    const r = await approval.resubmit(props.doc.docId, {});
    alert(t('MSG_APPROVAL_RESUBMIT_DONE').replace('{id}', String((r as any).newDocId)));
    emit('changed');
  } catch (e: any) {
    alert(t('MSG_APPROVAL_RESUBMIT_FAILED') + ': ' + (e?.response?.data?.message || e.message));
  } finally {
    busy.value = false;
  }
}

// 대결 등록
const showDelegate = ref(false);
const delegate = ref({ delegateeNo: '', reason: '', fromDate: '', toDate: '' });

async function confirmDelegate() {
  if (!delegate.value.delegateeNo || !delegate.value.fromDate || !delegate.value.toDate) {
    alert(t('MSG_APPROVAL_DELEGATE_REQ'));
    return;
  }
  busy.value = true;
  try {
    await approval.delegate(delegate.value);
    alert(t('MSG_APPROVAL_DELEGATE_DONE'));
    showDelegate.value = false;
    delegate.value = { delegateeNo: '', reason: '', fromDate: '', toDate: '' };
  } catch (e: any) {
    alert(t('MSG_APPROVAL_DELEGATE_FAILED') + ': ' + (e?.response?.data?.message || e.message));
  } finally {
    busy.value = false;
  }
}
</script>

<style scoped>
.action-bar {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
  padding: 1rem;
  border-top: 1px solid #e2e8f0;
  background: #f8fafc;
}
.form-grid {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 0.75rem;
  align-items: center;
}
.form-grid label {
  font-weight: 500;
  color: #475569;
}
.w-full { width: 100%; }
</style>
