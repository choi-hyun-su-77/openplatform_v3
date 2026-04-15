<!--
  결재 문서 상세 다이얼로그.

  Props:
    visible: boolean (v-model)
    docId: number | null

  내용:
    - 4탭 (TabView): 내용 / 결재선 / 첨부 / 이력
    - 헤더에 status Tag, 작성자/부서/일시
    - footer 에 ApprovalActionBar (current user 기준 동적 버튼)

  Emits:
    update:visible
    changed — 액션(승인/반려/회수 등) 발생 시 부모가 리스트 새로고침
-->
<template>
  <Dialog
    :visible="visible"
    @update:visible="(v: boolean) => emit('update:visible', v)"
    :header="dialogHeader"
    modal
    :style="{ width: '880px', maxWidth: '95vw' }"
    :closable="true"
    :draggable="false"
  >
    <div v-if="loading" class="loading">불러오는 중...</div>

    <div v-else-if="doc" class="detail-body">
      <div class="meta-bar">
        <Tag :value="statusLabel(doc.status)" :severity="statusSeverity(doc.status)" />
        <span class="meta-item"><i class="pi pi-user"></i> {{ doc.drafterName }} ({{ doc.drafterNo }})</span>
        <span class="meta-item" v-if="doc.drafterDept"><i class="pi pi-building"></i> {{ doc.drafterDept }}</span>
        <span class="meta-item"><i class="pi pi-tag"></i> {{ formCodeLabel(doc.formCode) }}</span>
        <span class="meta-item" v-if="doc.amount != null"><i class="pi pi-won"></i> {{ formatAmount(doc.amount) }}</span>
        <span class="meta-item"><i class="pi pi-clock"></i> {{ formatDate(doc.createdAt) }}</span>
      </div>

      <TabView>
        <TabPanel header="내용" value="content">
          <h3 class="doc-title">{{ doc.docTitle }}</h3>
          <div class="doc-content" v-html="renderedContent"></div>
        </TabPanel>
        <TabPanel header="결재선" value="line">
          <ApprovalLineTimeline :lines="lines" />
        </TabPanel>
        <TabPanel header="첨부" value="attach">
          <ApprovalAttachmentList
            :doc-id="doc.docId"
            :editable="canEditAttachments"
            @changed="reload"
          />
        </TabPanel>
        <TabPanel header="이력" value="history">
          <div v-if="!history.length" class="empty">이력이 없습니다</div>
          <ul v-else class="history-list">
            <li v-for="h in history" :key="h.historyId">
              <Tag :value="actionLabel(h.action)" :severity="actionSeverity(h.action)" />
              <span class="actor">{{ h.actorName || h.actorNo }}</span>
              <span class="when">{{ formatDate(h.actedAt) }}</span>
              <span v-if="h.comment" class="hist-comment">— {{ h.comment }}</span>
            </li>
          </ul>
        </TabPanel>
      </TabView>
    </div>

    <div v-else class="empty">문서 정보가 없습니다</div>

    <template #footer>
      <ApprovalActionBar
        v-if="doc"
        :doc="doc"
        :line="myCurrentLine"
        @changed="onActionChanged"
      />
    </template>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import Dialog from 'primevue/dialog';
import TabView from 'primevue/tabview';
import TabPanel from 'primevue/tabpanel';
import Tag from 'primevue/tag';
import ApprovalLineTimeline from './ApprovalLineTimeline.vue';
import ApprovalActionBar from './ApprovalActionBar.vue';
import ApprovalAttachmentList from './ApprovalAttachmentList.vue';
import { useApproval } from '@/composables/useApproval';
import { useAuthStore } from '@/store/auth';

const props = defineProps<{ visible: boolean; docId: number | null }>();
const emit = defineEmits<{
  (e: 'update:visible', v: boolean): void;
  (e: 'changed'): void;
}>();

const approval = useApproval();
const auth = useAuthStore();

const doc = ref<any>(null);
const lines = ref<any[]>([]);
const history = ref<any[]>([]);
const loading = ref(false);

const myUserNo = computed(() => auth.user?.employeeNo || auth.user?.userId || '');

const myCurrentLine = computed(() => {
  // 현재 로그인 사용자 + PENDING + step_order 가장 작은 라인
  const myPending = lines.value.filter(
    l => l.approverNo === myUserNo.value && l.status === 'PENDING'
  );
  if (!myPending.length) return null;
  return myPending.reduce((a, b) => (Number(a.stepOrder) <= Number(b.stepOrder) ? a : b));
});

const canEditAttachments = computed(() =>
  doc.value &&
  doc.value.drafterNo === myUserNo.value &&
  (doc.value.status === 'DRAFT' || doc.value.status === 'REJECTED')
);

const dialogHeader = computed(() => doc.value ? `결재 문서 #${doc.value.docId}` : '결재 문서');

const renderedContent = computed(() => {
  // 본문이 HTML 이거나 마크다운이거나 plain text. 지금은 단순 변환.
  const c = doc.value?.content || '';
  if (!c) return '<p class="empty">본문 없음</p>';
  // <p>, <br>, <strong> 등은 그대로. 줄바꿈만 br 변환.
  return c.replace(/\n/g, '<br>');
});

async function reload() {
  if (!props.docId) return;
  loading.value = true;
  try {
    const result = await approval.searchDetail(props.docId);
    doc.value = result.doc;
    lines.value = result.line;
    history.value = await approval.searchHistory(props.docId);
  } catch (e) {
    console.error('detail load failed', e);
  } finally {
    loading.value = false;
  }
}

watch(() => [props.visible, props.docId], async ([v, id]) => {
  if (v && id) await reload();
});

function onActionChanged() {
  emit('changed');
  reload();
}

// ---- helpers
function statusLabel(s: string): string {
  return ({
    DRAFT: '임시저장', PENDING: '대기', IN_PROGRESS: '진행중',
    APPROVED: '승인완료', REJECTED: '반려'
  } as Record<string, string>)[s] || s;
}
function statusSeverity(s: string): any {
  return ({
    DRAFT: 'secondary', PENDING: 'info', IN_PROGRESS: 'warn',
    APPROVED: 'success', REJECTED: 'danger'
  } as Record<string, string>)[s] || 'secondary';
}
function actionLabel(a: string): string {
  return ({
    SUBMIT: '상신', APPROVE: '승인', REJECT: '반려',
    WITHDRAW: '회수', RESUBMIT: '재상신', DELEGATE: '대결'
  } as Record<string, string>)[a] || a;
}
function actionSeverity(a: string): any {
  return ({
    SUBMIT: 'info', APPROVE: 'success', REJECT: 'danger',
    WITHDRAW: 'secondary', RESUBMIT: 'warn', DELEGATE: 'contrast'
  } as Record<string, string>)[a] || 'secondary';
}
function formCodeLabel(c: string): string {
  return ({
    LEAVE: '휴가신청서', EXPENSE: '지출결의서', PURCHASE: '구매요청서',
    BIZTRIP: '출장신청서', CONTRACT: '계약검토서', HR: '인사품의서', IT: 'IT자산신청'
  } as Record<string, string>)[c] || c;
}
function formatAmount(n: number): string {
  return Number(n).toLocaleString('ko-KR') + '원';
}
function formatDate(iso: string): string {
  if (!iso) return '';
  try {
    return new Date(iso).toLocaleString('ko-KR', {
      year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit'
    });
  } catch { return iso; }
}
</script>

<style scoped>
.loading, .empty {
  padding: 2rem;
  text-align: center;
  color: #94a3b8;
}
.detail-body { padding: 0.5rem 0; }
.meta-bar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem 1rem;
  background: #f8fafc;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
  font-size: 0.9rem;
}
.meta-item {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  color: #475569;
}
.doc-title {
  margin: 0 0 1rem 0;
  font-size: 1.25rem;
  color: #1e293b;
}
.doc-content {
  line-height: 1.7;
  color: #334155;
  min-height: 200px;
  padding: 1rem;
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 0.5rem;
}
.history-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.history-list li {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.6rem 0.5rem;
  border-bottom: 1px solid #f1f5f9;
  font-size: 0.9rem;
}
.actor { font-weight: 500; }
.when { color: #94a3b8; }
.hist-comment { color: #64748b; }
</style>
