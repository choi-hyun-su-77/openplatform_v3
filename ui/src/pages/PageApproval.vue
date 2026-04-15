<!--
  전자결재 — 9-box 결재함 + DataTable + 상세 다이얼로그.

  데이터 흐름:
    9-box nav 클릭 → useApproval().searchInbox(boxType) → DataTable 갱신
    행 클릭 → ApprovalDetailDialog open (docId 전달)
    상신 버튼 → ApprovalSubmitDialog (Phase A 후속에서 추가)
-->
<template>
  <div class="page approval-page">
    <div class="page-header">
      <h2>전자결재</h2>
      <div class="header-actions">
        <Button label="새 문서 상신" icon="pi pi-plus" @click="onNew" severity="primary" />
        <Button label="새로고침" icon="pi pi-refresh" text @click="reload" />
      </div>
    </div>

    <div class="approval-layout">
      <aside class="inbox-nav">
        <div class="nav-title">결재함</div>
        <ul>
          <li
            v-for="b in boxes"
            :key="b.code"
            :class="{ active: b.code === activeBox }"
            @click="selectBox(b.code)"
          >
            <i :class="b.icon" />
            <span>{{ b.label }}</span>
            <span v-if="b.code === activeBox" class="count">{{ documents.length }}</span>
          </li>
        </ul>
      </aside>

      <section class="inbox-list">
        <div class="search-bar">
          <InputText v-model="keyword" placeholder="제목·기안자 검색" @keyup.enter="reload" />
          <Button icon="pi pi-search" @click="reload" text />
        </div>

        <DataTable
          :value="documents"
          :loading="loading"
          paginator
          :rows="20"
          :rowsPerPageOptions="[10, 20, 50]"
          :rowHover="true"
          dataKey="docId"
          @row-click="onRowClick"
          stripedRows
          class="approval-table"
        >
          <template #empty>
            <div class="empty">결재함이 비어 있습니다</div>
          </template>
          <Column field="docId" header="번호" style="width:80px" />
          <Column field="docTitle" header="제목">
            <template #body="{ data }">
              <strong>{{ data.docTitle }}</strong>
              <Tag v-if="data.formCode" :value="formCodeLabel(data.formCode)" severity="secondary" class="ml-2" />
            </template>
          </Column>
          <Column field="drafterName" header="기안자" style="width:120px" />
          <Column field="drafterDept" header="부서" style="width:140px" />
          <Column field="status" header="상태" style="width:110px">
            <template #body="{ data }">
              <Tag :value="statusLabel(data.status)" :severity="statusSeverity(data.status)" />
            </template>
          </Column>
          <Column field="createdAt" header="기안일" style="width:160px">
            <template #body="{ data }">{{ formatDate(data.createdAt) }}</template>
          </Column>
        </DataTable>
      </section>
    </div>

    <ApprovalDetailDialog
      v-model:visible="detailVisible"
      :doc-id="selectedDocId"
      @changed="reload"
    />

    <ApprovalSubmitDialog
      v-model:visible="submitVisible"
      @submitted="onSubmitted"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Button from 'primevue/button';
import Tag from 'primevue/tag';
import InputText from 'primevue/inputtext';
import ApprovalDetailDialog from '@/components/approval/ApprovalDetailDialog.vue';
import ApprovalSubmitDialog from '@/components/approval/ApprovalSubmitDialog.vue';
import { useApproval } from '@/composables/useApproval';

const approval = useApproval();

const boxes = [
  { code: 'DRAFT',       label: '임시저장', icon: 'pi pi-pencil'   },
  { code: 'MY_DOCS',     label: '기안함',   icon: 'pi pi-folder'   },
  { code: 'PENDING',     label: '대기함',   icon: 'pi pi-clock'    },
  { code: 'IN_PROGRESS', label: '진행함',   icon: 'pi pi-sync'     },
  { code: 'COMPLETED',   label: '완료함',   icon: 'pi pi-check'    },
  { code: 'REJECTED',    label: '반려함',   icon: 'pi pi-times'    },
  { code: 'RECEIVED',    label: '수신함',   icon: 'pi pi-inbox'    },
  { code: 'CC_BOX',      label: '참조함',   icon: 'pi pi-eye'      },
  { code: 'DEPT_BOX',    label: '부서함',   icon: 'pi pi-building' }
];

const activeBox = ref('PENDING');
const documents = ref<any[]>([]);
const loading = ref(false);
const keyword = ref('');

const detailVisible = ref(false);
const selectedDocId = ref<number | null>(null);
const submitVisible = ref(false);

async function selectBox(code: string) {
  activeBox.value = code;
  await reload();
}

async function reload() {
  loading.value = true;
  try {
    documents.value = await approval.searchInbox(activeBox.value, keyword.value);
  } catch (e) {
    console.error('inbox load failed', e);
    documents.value = [];
  } finally {
    loading.value = false;
  }
}

function onRowClick(e: any) {
  selectedDocId.value = e.data.docId;
  detailVisible.value = true;
}

function onNew() {
  submitVisible.value = true;
}

async function onSubmitted(_docId: number) {
  // 새 문서가 PENDING 상태로 들어가므로 기안함으로 이동 후 새로고침
  activeBox.value = 'MY_DOCS';
  await reload();
}

onMounted(() => selectBox('PENDING'));

// ---- helpers (DetailDialog 와 동일)
function statusLabel(s: string): string {
  return ({
    DRAFT: '임시', PENDING: '대기', IN_PROGRESS: '진행',
    APPROVED: '완료', REJECTED: '반려'
  } as Record<string, string>)[s] || s;
}
function statusSeverity(s: string): any {
  return ({
    DRAFT: 'secondary', PENDING: 'info', IN_PROGRESS: 'warn',
    APPROVED: 'success', REJECTED: 'danger'
  } as Record<string, string>)[s] || 'secondary';
}
function formCodeLabel(c: string): string {
  return ({
    LEAVE: '휴가', EXPENSE: '지출', PURCHASE: '구매',
    BIZTRIP: '출장', CONTRACT: '계약', HR: '인사', IT: 'IT'
  } as Record<string, string>)[c] || c;
}
function formatDate(iso: string): string {
  if (!iso) return '';
  try {
    return new Date(iso).toLocaleString('ko-KR', {
      month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit'
    });
  } catch { return iso; }
}
</script>

<style scoped>
.approval-page { padding: 1.25rem 1.5rem; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.25rem;
}
.page-header h2 { margin: 0; }
.header-actions { display: flex; gap: 0.5rem; }

.approval-layout {
  display: grid;
  grid-template-columns: 220px 1fr;
  gap: 1rem;
}

.inbox-nav {
  background: #fff;
  border-radius: 0.625rem;
  padding: 0.75rem 0.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}
.nav-title {
  font-weight: 600;
  color: #475569;
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid #e2e8f0;
  margin-bottom: 0.5rem;
}
.inbox-nav ul { list-style: none; padding: 0; margin: 0; }
.inbox-nav li {
  padding: 0.625rem 0.875rem;
  cursor: pointer;
  border-radius: 0.375rem;
  display: flex;
  align-items: center;
  gap: 0.625rem;
  font-size: 0.9rem;
  color: #475569;
  transition: background 0.15s;
}
.inbox-nav li i { font-size: 0.95rem; color: #94a3b8; }
.inbox-nav li:hover { background: #f1f5f9; }
.inbox-nav li.active {
  background: #3b82f6;
  color: #fff;
}
.inbox-nav li.active i { color: #fff; }
.inbox-nav li .count {
  margin-left: auto;
  background: rgba(255,255,255,0.25);
  border-radius: 1rem;
  padding: 0.05rem 0.5rem;
  font-size: 0.75rem;
}

.inbox-list {
  background: #fff;
  border-radius: 0.625rem;
  padding: 1rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}
.search-bar {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}
.search-bar :deep(.p-inputtext) { flex: 1; }

.empty {
  padding: 2rem;
  text-align: center;
  color: #94a3b8;
}
.ml-2 { margin-left: 0.5rem; }
:deep(.p-datatable .p-datatable-tbody > tr) { cursor: pointer; }
</style>
