<!--
  결재선 타임라인 — 문서 상세 다이얼로그의 "결재선" 탭에서 사용.

  Props:
    lines: Array<{ lineId, stepOrder, approverNo, approverName, role, status,
                   comment, actedAt }>

  PrimeVue Timeline 컴포넌트를 사용하여 step_order 순으로 결재자/상태/의견 표시.
  상태별 색상: PENDING=회색, APPROVED=초록, REJECTED=빨강, SKIPPED=노랑(전결).
-->
<template>
  <Timeline :value="sortedLines" align="left" class="approval-line-timeline">
    <template #marker="slotProps">
      <span class="status-marker" :class="`status-${slotProps.item.status?.toLowerCase()}`">
        <i :class="iconFor(slotProps.item.status)"></i>
      </span>
    </template>
    <template #content="slotProps">
      <div class="line-content">
        <div class="line-header">
          <strong>{{ slotProps.item.stepOrder }}. {{ slotProps.item.approverName }}</strong>
          <Tag :value="statusLabel(slotProps.item.status)" :severity="severityFor(slotProps.item.status)" />
        </div>
        <div class="line-meta">
          <span v-if="slotProps.item.role" class="role">{{ slotProps.item.role }}</span>
          <span v-if="slotProps.item.actedAt" class="acted-at">{{ formatDate(slotProps.item.actedAt) }}</span>
        </div>
        <div v-if="slotProps.item.comment" class="line-comment">
          <i class="pi pi-comment"></i> {{ slotProps.item.comment }}
        </div>
        <div v-if="slotProps.item.actedByNo && slotProps.item.actedByNo !== slotProps.item.approverNo" class="delegated">
          <i class="pi pi-user-edit"></i> 대결: {{ slotProps.item.actedByNo }}
        </div>
      </div>
    </template>
  </Timeline>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import Timeline from 'primevue/timeline';
import Tag from 'primevue/tag';

interface ApprovalLine {
  lineId: number | string;
  stepOrder: number;
  approverNo: string;
  approverName: string;
  role?: string;
  status: string;
  comment?: string | null;
  actedAt?: string | null;
  actedByNo?: string | null;
}

const props = defineProps<{ lines: ApprovalLine[] }>();

const sortedLines = computed(() =>
  [...(props.lines || [])].sort((a, b) => Number(a.stepOrder) - Number(b.stepOrder))
);

function iconFor(status: string): string {
  switch (status) {
    case 'APPROVED': return 'pi pi-check';
    case 'REJECTED': return 'pi pi-times';
    case 'SKIPPED':  return 'pi pi-forward';
    case 'PENDING':
    default:         return 'pi pi-clock';
  }
}

function statusLabel(status: string): string {
  switch (status) {
    case 'APPROVED': return '승인';
    case 'REJECTED': return '반려';
    case 'SKIPPED':  return '전결';
    case 'PENDING':
    default:         return '대기';
  }
}

function severityFor(status: string): 'success' | 'danger' | 'warn' | 'secondary' {
  switch (status) {
    case 'APPROVED': return 'success';
    case 'REJECTED': return 'danger';
    case 'SKIPPED':  return 'warn';
    default:         return 'secondary';
  }
}

function formatDate(iso: string): string {
  if (!iso) return '';
  try {
    const d = new Date(iso);
    return d.toLocaleString('ko-KR', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
  } catch {
    return iso;
  }
}
</script>

<style scoped>
.approval-line-timeline {
  padding: 1rem 0;
}
.status-marker {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  border-radius: 50%;
  color: #fff;
  background: #94a3b8;
}
.status-marker.status-approved { background: #10b981; }
.status-marker.status-rejected { background: #ef4444; }
.status-marker.status-skipped  { background: #f59e0b; }
.status-marker.status-pending  { background: #94a3b8; }

.line-content {
  padding: 0.25rem 0 1rem 0.5rem;
}
.line-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.25rem;
}
.line-meta {
  font-size: 0.85rem;
  color: #64748b;
  display: flex;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}
.line-meta .acted-at::before { content: '· '; }
.line-comment {
  background: #f1f5f9;
  border-radius: 0.375rem;
  padding: 0.5rem 0.75rem;
  font-size: 0.9rem;
  color: #334155;
  display: flex;
  gap: 0.5rem;
  align-items: flex-start;
}
.delegated {
  margin-top: 0.25rem;
  font-size: 0.85rem;
  color: #f59e0b;
}
</style>
