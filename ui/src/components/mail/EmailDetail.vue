<template>
  <div class="email-detail" v-if="email">
    <div class="detail-header">
      <h3>{{ email.subject || '(제목 없음)' }}</h3>
      <div class="detail-meta">
        <span><strong>보낸 사람:</strong> {{ fromDisplay }}</span>
        <span><strong>받는 사람:</strong> {{ toDisplay }}</span>
        <span class="detail-date">{{ formatDate(email.receivedAt || email.sentAt) }}</span>
      </div>
      <div class="detail-actions">
        <Button icon="pi pi-reply" label="답장" size="small" severity="secondary" @click="$emit('reply', email)" />
        <Button icon="pi pi-forward" label="전달" size="small" severity="secondary" @click="$emit('forward', email)" />
      </div>
    </div>
    <Divider />
    <div class="detail-body" v-if="htmlContent" v-html="htmlContent"></div>
    <div class="detail-body plain" v-else-if="textContent">{{ textContent }}</div>
    <div class="detail-body empty" v-else>(본문 없음)</div>
    <!-- 첨부 -->
    <div v-if="email.attachments && email.attachments.length" class="attach-section">
      <Divider />
      <h5>첨부 파일 ({{ email.attachments.length }})</h5>
      <div v-for="a in email.attachments" :key="a.blobId" class="attach-item">
        <i class="pi pi-paperclip" /> {{ a.name || a.blobId }} <small>({{ formatSize(a.size) }})</small>
      </div>
    </div>
  </div>
  <div v-else class="no-selection">메일을 선택하세요</div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import Button from 'primevue/button';
import Divider from 'primevue/divider';

const props = defineProps<{ email: any }>();
defineEmits<{ reply: [email: any]; forward: [email: any] }>();

const fromDisplay = computed(() => {
  if (!props.email?.from?.length) return '-';
  const f = props.email.from[0];
  return f.name ? `${f.name} <${f.email}>` : f.email;
});

const toDisplay = computed(() => {
  if (!props.email?.to?.length) return '-';
  return props.email.to.map((t: any) => t.name || t.email).join(', ');
});

const htmlContent = computed(() => {
  const bv = props.email?.bodyValues;
  const htmlParts = props.email?.htmlBody;
  if (bv && htmlParts?.length) {
    const partId = htmlParts[0].partId;
    return bv[partId]?.value || null;
  }
  return null;
});

const textContent = computed(() => {
  const bv = props.email?.bodyValues;
  const textParts = props.email?.textBody;
  if (bv && textParts?.length) {
    const partId = textParts[0].partId;
    return bv[partId]?.value || null;
  }
  return null;
});

function formatDate(dt: string) {
  if (!dt) return '';
  return new Date(dt).toLocaleDateString('ko-KR', {
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit'
  });
}

function formatSize(bytes: number) {
  if (!bytes) return '0 B';
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
  return (bytes / 1048576).toFixed(1) + ' MB';
}
</script>

<style scoped>
.email-detail { padding: 1rem; overflow-y: auto; }
.detail-header h3 { margin: 0 0 0.5rem; }
.detail-meta { display: flex; flex-direction: column; gap: 0.25rem; font-size: 0.85rem; color: var(--p-text-muted-color); }
.detail-date { font-size: 0.8rem; }
.detail-actions { display: flex; gap: 0.5rem; margin-top: 0.5rem; }
.detail-body { line-height: 1.7; font-size: 0.95rem; min-height: 200px; }
.detail-body.plain { white-space: pre-wrap; }
.detail-body.empty { color: var(--p-text-muted-color); }
.attach-section h5 { margin: 0 0 0.5rem; }
.attach-item { display: flex; align-items: center; gap: 0.5rem; font-size: 0.9rem; padding: 0.25rem 0; }
.no-selection { display: flex; align-items: center; justify-content: center; height: 100%; color: var(--p-text-muted-color); font-size: 1rem; }
</style>
