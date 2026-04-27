<template>
  <div class="widget-body widget-events">
    <header class="widget-header">
      <i class="pi pi-calendar" />
      <span class="title">오늘 일정</span>
      <span class="count" v-if="events.length">{{ events.length }}</span>
    </header>
    <div v-if="loading" class="state loading">로딩...</div>
    <ul v-else-if="events.length" class="event-list">
      <li v-for="ev in events" :key="ev.eventId" @click="go">
        <span class="time">{{ formatTime(ev.startDt) }}</span>
        <span class="evtitle">{{ ev.title }}</span>
      </li>
    </ul>
    <div v-else class="state empty">오늘 등록된 일정이 없습니다.</div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import { useAuthStore } from '@/store/auth';

defineProps<{ widgetCode: string; config?: any }>();

const router = useRouter();
const auth = useAuthStore();
const events = ref<any[]>([]);
const loading = ref(false);

async function load() {
  loading.value = true;
  try {
    if (!auth.user) await auth.loadUserInfo();
    const employeeId = auth.user?.employeeId;
    const res = await axios.post('/api/dataset/search', {
      serviceName: 'calendar/searchToday',
      datasets: { ds_search: { ownerId: employeeId } }
    });
    events.value = res.data?.data?.ds_todayEvents?.rows || [];
  } catch (e) {
    console.warn('[WidgetTodayEvents] failed', e);
    events.value = [];
  } finally {
    loading.value = false;
  }
}

function formatTime(iso?: string) {
  if (!iso) return '';
  try {
    const d = new Date(iso);
    return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
  } catch { return ''; }
}

function go() { router.push('/calendar').catch(() => {}); }

onMounted(load);
</script>

<style scoped>
.widget-events { display: flex; flex-direction: column; height: 100%; }
.widget-header { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.6rem; color: #475569; font-weight: 600; }
.count { margin-left: auto; background: #3b82f6; color: white; border-radius: 999px; padding: 0 0.45rem; font-size: 0.7rem; font-weight: 700; }
.state { flex: 1; display: flex; align-items: center; justify-content: center; color: #94a3b8; font-size: 0.9rem; }
.event-list { flex: 1; overflow-y: auto; list-style: none; padding: 0; margin: 0; }
.event-list li {
  padding: 0.35rem 0.2rem;
  display: flex;
  gap: 0.6rem;
  border-bottom: 1px solid #f1f5f9;
  cursor: pointer;
  font-size: 0.88rem;
}
.event-list li:hover { background: #f8fafc; }
.event-list .time { color: #3b82f6; font-weight: 600; min-width: 3rem; }
.event-list .evtitle { color: #1e293b; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
</style>
