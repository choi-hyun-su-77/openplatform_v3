<!--
  PageLeave.vue — 본인 휴가/연차 페이지.

  레이아웃:
    상단 — LeaveBalanceCard (잔여/사용/총)
    중단 — "휴가 신청" 버튼 → ApprovalSubmitDialog (form_code='LEAVE' 프리셋)
    하단 — DataTable: 휴가 신청 이력 (year)

  ApprovalSubmitDialog 가 LEAVE 프리셋 분기를 가지므로 단순히 visible/initialFormCode 만 전달.
-->
<template>
  <div class="page leave-page">
    <div class="page-header">
      <h2><i class="pi pi-calendar-plus" /> 연차 / 휴가</h2>
      <div class="header-actions">
        <Button label="휴가 신청" icon="pi pi-plus" severity="primary" @click="openSubmit" />
        <Button label="새로고침" icon="pi pi-refresh" text @click="reload" />
      </div>
    </div>

    <section class="top-row">
      <LeaveBalanceCard :balance="balance" />
      <div class="year-picker-wrap">
        <label>조회 연도</label>
        <Dropdown v-model="year" :options="yearOptions" class="year-picker" />
      </div>
    </section>

    <section class="history-card">
      <h3>휴가 신청 이력</h3>
      <DataTable
        :value="history"
        :loading="loading"
        paginator
        :rows="20"
        :rowsPerPageOptions="[10, 20, 50]"
        dataKey="requestId"
        stripedRows
        :rowHover="true"
      >
        <template #empty>
          <div class="empty">등록된 휴가 신청이 없습니다</div>
        </template>
        <Column field="requestId" header="번호" style="width:80px" />
        <Column field="leaveType" header="유형" style="width:120px">
          <template #body="{ data }">
            <Tag :value="leaveTypeLabel(data.leaveType)" :severity="leaveTypeSeverity(data.leaveType)" />
          </template>
        </Column>
        <Column header="기간" style="width:200px">
          <template #body="{ data }">
            {{ formatDate(data.fromDate) }} ~ {{ formatDate(data.toDate) }}
          </template>
        </Column>
        <Column field="days" header="일수" style="width:80px">
          <template #body="{ data }">{{ formatDays(data.days) }}일</template>
        </Column>
        <Column field="reason" header="사유">
          <template #body="{ data }">
            <span class="reason">{{ data.reason || '-' }}</span>
          </template>
        </Column>
        <Column field="status" header="상태" style="width:110px">
          <template #body="{ data }">
            <Tag :value="statusLabel(data.status)" :severity="statusSeverity(data.status)" />
          </template>
        </Column>
        <Column field="createdAt" header="신청일" style="width:160px">
          <template #body="{ data }">{{ formatDateTime(data.createdAt) }}</template>
        </Column>
      </DataTable>
    </section>

    <ApprovalSubmitDialog
      v-model:visible="submitVisible"
      :initial-form-code="'LEAVE'"
      @submitted="onSubmitted"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Button from 'primevue/button';
import Tag from 'primevue/tag';
import Dropdown from 'primevue/dropdown';
import LeaveBalanceCard from '@/components/leave/LeaveBalanceCard.vue';
import ApprovalSubmitDialog from '@/components/approval/ApprovalSubmitDialog.vue';
import { useLeave, type LeaveBalanceRow, type LeaveRequestRow } from '@/composables/useLeave';

const leave = useLeave();

const year = ref<number>(new Date().getFullYear());
const yearOptions = computed(() => {
  const now = new Date().getFullYear();
  return [now - 1, now, now + 1];
});

const balance = ref<LeaveBalanceRow | null>(null);
const history = ref<LeaveRequestRow[]>([]);
const loading = ref(false);

const submitVisible = ref(false);

async function loadBalance() {
  try {
    balance.value = await leave.searchBalance(year.value);
  } catch (e) {
    console.warn('searchBalance failed', e);
    balance.value = null;
  }
}
async function loadHistory() {
  loading.value = true;
  try {
    history.value = await leave.searchMyHistory(year.value);
  } catch (e) {
    console.warn('searchMyHistory failed', e);
    history.value = [];
  } finally {
    loading.value = false;
  }
}
async function reload() {
  await Promise.all([loadBalance(), loadHistory()]);
}

function openSubmit() {
  submitVisible.value = true;
}
async function onSubmitted(_docId: number) {
  await reload();
}

function leaveTypeLabel(t: string) {
  switch (t) {
    case 'ANNUAL':  return '연차';
    case 'HALF_AM': return '오전반차';
    case 'HALF_PM': return '오후반차';
    case 'SICK':    return '병가';
    case 'FAMILY':  return '경조사';
    case 'UNPAID':  return '무급휴가';
    default: return t;
  }
}
function leaveTypeSeverity(t: string): any {
  switch (t) {
    case 'ANNUAL':  return 'info';
    case 'HALF_AM':
    case 'HALF_PM': return 'secondary';
    case 'SICK':    return 'warn';
    case 'FAMILY':  return 'help';
    case 'UNPAID':  return 'contrast';
    default: return 'secondary';
  }
}

function statusLabel(s: string) {
  switch (s) {
    case 'PENDING':   return '결재중';
    case 'APPROVED':  return '승인';
    case 'REJECTED':  return '반려';
    case 'CANCELLED': return '취소';
    default: return s;
  }
}
function statusSeverity(s: string): any {
  switch (s) {
    case 'PENDING':   return 'warn';
    case 'APPROVED':  return 'success';
    case 'REJECTED':  return 'danger';
    case 'CANCELLED': return 'secondary';
    default: return 'secondary';
  }
}
function formatDate(raw: any) {
  if (!raw) return '-';
  const s = String(raw);
  return s.length >= 10 ? s.substring(0, 10) : s;
}
function formatDateTime(raw: any) {
  if (!raw) return '-';
  const s = String(raw);
  if (s.length < 16) return s;
  return s.substring(0, 16).replace('T', ' ');
}
function formatDays(d: any) {
  const n = Number(d);
  if (Number.isNaN(n)) return '-';
  return Number.isInteger(n) ? String(n) : n.toFixed(1);
}

watch(year, reload);
onMounted(reload);
</script>

<style scoped>
.leave-page { padding: 1.5rem; max-width: 1200px; }
.page-header {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 1.25rem;
}
.page-header h2 { margin: 0; display: flex; align-items: center; gap: 0.5rem; color: #1e293b; }
.header-actions { display: flex; align-items: center; gap: 0.5rem; }

.top-row {
  display: flex;
  gap: 1rem;
  align-items: stretch;
  margin-bottom: 1.5rem;
}
.top-row > :first-child { flex: 1 1 auto; }
.year-picker-wrap {
  display: flex; flex-direction: column; gap: 0.4rem;
  padding: 1.25rem;
  background: var(--p-content-background, #fff);
  border: 1px solid var(--p-content-border-color, #e2e8f0);
  border-radius: 10px;
  min-width: 160px;
}
.year-picker-wrap label { font-size: 0.78rem; color: #64748b; }

.history-card {
  background: var(--p-content-background, #fff);
  border: 1px solid var(--p-content-border-color, #e2e8f0);
  border-radius: 10px;
  padding: 1.25rem;
}
.history-card h3 { margin: 0 0 0.75rem 0; font-size: 1rem; color: #334155; }
.empty { color: #94a3b8; font-size: 0.875rem; padding: 1rem; text-align: center; }
.reason { color: #475569; font-size: 0.875rem; }
</style>
