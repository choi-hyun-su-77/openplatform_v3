<template>
  <div class="widget-body widget-pending" @click="go">
    <header class="widget-header">
      <i class="pi pi-file-edit" />
      <span class="title">미결 결재</span>
    </header>
    <div class="metric-area">
      <span class="metric">{{ count }}</span>
      <span class="unit">건</span>
    </div>
    <span class="link">결재함으로 →</span>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useApproval } from '@/composables/useApproval';

defineProps<{ widgetCode: string; config?: any }>();

const router = useRouter();
const approval = useApproval();
const count = ref(0);

async function load() {
  try {
    count.value = await approval.countPending();
  } catch (e) {
    console.warn('[WidgetPendingApproval] failed', e);
    count.value = 0;
  }
}

function go() { router.push('/approval').catch(() => {}); }

onMounted(load);
</script>

<style scoped>
.widget-pending { display: flex; flex-direction: column; height: 100%; cursor: pointer; }
.widget-header { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.6rem; color: #475569; font-weight: 600; }
.metric-area { flex: 1; display: flex; align-items: center; gap: 0.4rem; }
.metric { font-size: 2.4rem; font-weight: 800; color: #ef4444; line-height: 1; }
.unit { color: #64748b; font-size: 1rem; align-self: flex-end; padding-bottom: 0.2rem; }
.link { font-size: 0.85rem; color: #3b82f6; }
</style>
