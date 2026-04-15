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
    <Button v-if="canApprove" label="승인" icon="pi pi-check" severity="success"
            @click="onApprove" :loading="busy" />
    <Button v-if="canApprove" label="반려" icon="pi pi-times" severity="danger"
            @click="onReject" :loading="busy" />
    <Button v-if="canWithdraw" label="회수" icon="pi pi-undo" severity="secondary"
            @click="onWithdraw" :loading="busy" />
    <Button v-if="canResubmit" label="재상신" icon="pi pi-refresh" severity="warn"
            @click="onResubmit" :loading="busy" />
    <Button label="대결 등록" icon="pi pi-user-edit" severity="contrast"
            @click="showDelegate = true" />

    <!-- 코멘트 입력 다이얼로그 -->
    <Dialog v-model:visible="showCommentDialog" :header="commentTitle" modal :style="{ width: '420px' }">
      <Textarea v-model="commentText" rows="4" autoResize placeholder="의견을 입력하세요" class="w-full" />
      <template #footer>
        <Button label="취소" text @click="showCommentDialog = false" />
        <Button label="확인" @click="confirmComment" :loading="busy" />
      </template>
    </Dialog>

    <!-- 대결 등록 다이얼로그 -->
    <Dialog v-model:visible="showDelegate" header="대결(위임) 등록" modal :style="{ width: '480px' }">
      <div class="form-grid">
        <label>대리 결재자 사번</label>
        <InputText v-model="delegate.delegateeNo" placeholder="예: E0010" />
        <label>사유</label>
        <InputText v-model="delegate.reason" placeholder="휴가 / 출장 등" />
        <label>시작일</label>
        <InputText v-model="delegate.fromDate" type="date" />
        <label>종료일</label>
        <InputText v-model="delegate.toDate" type="date" />
      </div>
      <template #footer>
        <Button label="취소" text @click="showDelegate = false" />
        <Button label="등록" @click="confirmDelegate" :loading="busy" />
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
const commentTitle = computed(() => commentMode.value === 'approve' ? '승인 의견' : '반려 사유');

function onApprove() { commentMode.value = 'approve'; commentText.value = ''; showCommentDialog.value = true; }
function onReject()  { commentMode.value = 'reject';  commentText.value = ''; showCommentDialog.value = true; }

async function confirmComment() {
  if (!props.doc || !props.line) return;
  if (commentMode.value === 'reject' && !commentText.value.trim()) {
    alert('반려 사유를 입력하세요');
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
    alert((commentMode.value === 'approve' ? '승인' : '반려') + ' 실패: ' + (e?.response?.data?.message || e.message));
  } finally {
    busy.value = false;
  }
}

async function onWithdraw() {
  if (!props.doc) return;
  if (!confirm('이 문서를 회수하시겠습니까? DRAFT 상태로 되돌아갑니다.')) return;
  busy.value = true;
  try {
    await approval.withdraw(props.doc.docId);
    emit('changed');
  } catch (e: any) {
    alert('회수 실패: ' + (e?.response?.data?.message || e.message));
  } finally {
    busy.value = false;
  }
}

async function onResubmit() {
  if (!props.doc) return;
  if (!confirm('반려된 문서를 재상신하시겠습니까? 새 문서 버전이 생성됩니다.')) return;
  busy.value = true;
  try {
    const r = await approval.resubmit(props.doc.docId, {});
    alert('재상신 완료. 신규 docId=' + (r as any).newDocId);
    emit('changed');
  } catch (e: any) {
    alert('재상신 실패: ' + (e?.response?.data?.message || e.message));
  } finally {
    busy.value = false;
  }
}

// 대결 등록
const showDelegate = ref(false);
const delegate = ref({ delegateeNo: '', reason: '', fromDate: '', toDate: '' });

async function confirmDelegate() {
  if (!delegate.value.delegateeNo || !delegate.value.fromDate || !delegate.value.toDate) {
    alert('대리자 / 시작일 / 종료일은 필수입니다');
    return;
  }
  busy.value = true;
  try {
    await approval.delegate(delegate.value);
    alert('대결 등록 완료');
    showDelegate.value = false;
    delegate.value = { delegateeNo: '', reason: '', fromDate: '', toDate: '' };
  } catch (e: any) {
    alert('대결 등록 실패: ' + (e?.response?.data?.message || e.message));
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
