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
      <h2>{{ t('LBL_PAGE_APPROVAL') }}</h2>
      <div class="header-actions">
        <Button :label="t('BTN_NEW_DOC')" icon="pi pi-plus" @click="onNew" severity="primary" />
        <Button :label="t('BTN_REFRESH')" icon="pi pi-refresh" text @click="reload" />
      </div>
    </div>

    <div class="approval-layout">
      <aside class="inbox-nav">
        <div class="nav-title">{{ t('LBL_APPROVAL_BOXES') }}</div>
        <ul>
          <li
            v-for="b in boxes"
            :key="b.code"
            :class="{ active: b.code === activeBox }"
            @click="selectBox(b.code)"
          >
            <i :class="b.icon" />
            <span>{{ t('BOX_' + b.code) }}</span>
            <span v-if="b.code === activeBox" class="count">{{ documents.length }}</span>
          </li>
        </ul>
      </aside>

      <section class="inbox-list">
        <div class="search-bar">
          <InputText v-model="keyword" :placeholder="t('PH_APPROVAL_SEARCH')" @keyup.enter="reload" />
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
            <div class="empty">{{ t('LBL_APPROVAL_INBOX_EMPTY') }}</div>
          </template>
          <Column field="docId" :header="t('COL_APPROVAL_NO')" style="width:80px" />
          <Column field="docTitle" :header="t('COL_APPROVAL_TITLE')">
            <template #body="{ data }">
              <strong>{{ data.docTitle }}</strong>
              <Tag v-if="data.formCode" :value="formCodeLabel(data.formCode)" severity="secondary" class="ml-2" />
            </template>
          </Column>
          <Column field="drafterName" :header="t('COL_APPROVAL_DRAFTER')" style="width:120px" />
          <Column field="drafterDept" :header="t('COL_APPROVAL_DEPT')" style="width:140px" />
          <Column field="status" :header="t('COL_APPROVAL_STATUS')" style="width:110px">
            <template #body="{ data }">
              <Tag :value="statusLabel(data.status)" :severity="statusSeverity(data.status)" />
            </template>
          </Column>
          <Column field="createdAt" :header="t('COL_APPROVAL_DRAFT_AT')" style="width:160px">
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
import { useLabel } from '@/composables/useLabel';

const approval = useApproval();
const { t } = useLabel();

// box code 는 STATUS-prefix 가 아닌 BOX_DRAFT/BOX_PENDING 등으로 t() 호출 (CC_BOX/DEPT_BOX 는 BOX_CC/BOX_DEPT)
const boxes = [
  { code: 'DRAFT',       icon: 'pi pi-pencil'   },
  { code: 'MY_DOCS',     icon: 'pi pi-folder'   },
  { code: 'PENDING',     icon: 'pi pi-clock'    },
  { code: 'IN_PROGRESS', icon: 'pi pi-sync'     },
  { code: 'COMPLETED',   icon: 'pi pi-check'    },
  { code: 'REJECTED',    icon: 'pi pi-times'    },
  { code: 'RECEIVED',    icon: 'pi pi-inbox'    },
  { code: 'CC_BOX',      icon: 'pi pi-eye'      },
  { code: 'DEPT_BOX',    icon: 'pi pi-building' }
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
  return t('STATUS_APP_DOC_' + s, s);
}
function statusSeverity(s: string): any {
  return ({
    DRAFT: 'secondary', PENDING: 'info', IN_PROGRESS: 'warn',
    APPROVED: 'success', REJECTED: 'danger'
  } as Record<string, string>)[s] || 'secondary';
}
function formCodeLabel(c: string): string {
  return t('FORM_' + c, c);
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
