<template>
  <div class="email-list">
    <div v-if="loading" class="loading"><i class="pi pi-spin pi-spinner" /> 로딩 중...</div>
    <div v-else-if="emails.length === 0" class="empty">메일이 없습니다</div>
    <div v-for="e in emails" :key="e.id"
         :class="['email-row', { unread: !isRead(e), active: e.id === selectedId }]"
         @click="$emit('select', e)">
      <div class="email-from">{{ fromDisplay(e) }}</div>
      <div class="email-subject">
        {{ e.subject || '(제목 없음)' }}
        <i v-if="e.hasAttachment" class="pi pi-paperclip" style="font-size:0.75rem;margin-left:4px" />
      </div>
      <div class="email-preview">{{ e.preview || '' }}</div>
      <div class="email-date">{{ formatDate(e.receivedAt) }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{ emails: any[]; loading?: boolean; selectedId?: string }>();
defineEmits<{ select: [email: any] }>();

function isRead(e: any): boolean {
  return e.keywords && (e.keywords['$seen'] || e.keywords['\\Seen']);
}

function fromDisplay(e: any): string {
  if (!e.from || !e.from.length) return '(unknown)';
  const f = e.from[0];
  return f.name || f.email || '(unknown)';
}

function formatDate(dt: string): string {
  if (!dt) return '';
  const d = new Date(dt);
  const now = new Date();
  if (d.toDateString() === now.toDateString()) {
    return d.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' });
  }
  return d.toLocaleDateString('ko-KR', { month: 'short', day: 'numeric' });
}
</script>

<style scoped>
.email-list { display: flex; flex-direction: column; overflow-y: auto; }
.email-row {
  display: grid; grid-template-columns: 140px 1fr auto; grid-template-rows: auto auto;
  gap: 0 0.75rem; padding: 0.6rem 0.75rem; cursor: pointer;
  border-bottom: 1px solid var(--p-content-border-color);
}
.email-row:hover { background: var(--p-content-hover-background); }
.email-row.active { background: var(--p-highlight-background); }
.email-row.unread .email-from, .email-row.unread .email-subject { font-weight: 700; }
.email-from { font-size: 0.85rem; grid-row: 1; grid-column: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.email-subject { font-size: 0.9rem; grid-row: 1; grid-column: 2; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.email-preview { font-size: 0.8rem; color: var(--p-text-muted-color); grid-row: 2; grid-column: 1 / 3; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.email-date { font-size: 0.8rem; color: var(--p-text-muted-color); grid-row: 1; grid-column: 3; white-space: nowrap; }
.loading, .empty { padding: 2rem; text-align: center; color: var(--p-text-muted-color); }
</style>
