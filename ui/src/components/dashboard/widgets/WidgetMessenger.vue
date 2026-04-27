<template>
  <div class="widget-body widget-messenger" @click="go">
    <header class="widget-header">
      <i class="pi pi-send" />
      <span class="title">메신저</span>
    </header>
    <div class="metric-area">
      <span class="metric">{{ unread }}</span>
      <span class="unit">건</span>
    </div>
    <span class="hint">읽지 않은 DM</span>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';

defineProps<{ widgetCode: string; config?: any }>();

const router = useRouter();
const unread = ref(0);

async function load() {
  try {
    const res = await axios.get('/api/bff/messenger/unread');
    unread.value = res.data?.unreadCount || 0;
  } catch (e) {
    console.warn('[WidgetMessenger] failed', e);
    unread.value = 0;
  }
}

function go() { router.push('/messenger').catch(() => {}); }

onMounted(load);
</script>

<style scoped>
.widget-messenger { display: flex; flex-direction: column; height: 100%; cursor: pointer; }
.widget-header { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.6rem; color: #475569; font-weight: 600; }
.metric-area { flex: 1; display: flex; align-items: center; gap: 0.4rem; }
.metric { font-size: 2.4rem; font-weight: 800; color: #14b8a6; line-height: 1; }
.unit { color: #64748b; font-size: 1rem; align-self: flex-end; padding-bottom: 0.2rem; }
.hint { font-size: 0.8rem; color: #94a3b8; }
</style>
