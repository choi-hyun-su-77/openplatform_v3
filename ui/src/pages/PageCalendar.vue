<template>
  <div class="page">
    <h2>캘린더</h2>
    <div class="filters">
      <SelectButton v-model="scope" :options="scopes" optionLabel="label" optionValue="value" @change="load" />
    </div>
    <FullCalendar :options="calendarOptions" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import FullCalendar from '@fullcalendar/vue3';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import SelectButton from 'primevue/selectbutton';
import { useAuthStore } from '@/store/auth';

const authStore = useAuthStore();

const scopes = [
  { label: '전체', value: 'ALL' },
  { label: '개인', value: 'PERSONAL' },
  { label: '부서', value: 'DEPT' },
  { label: '회사', value: 'COMPANY' }
];
const scope = ref('ALL');
const events = ref<any[]>([]);

const calendarOptions = computed(() => ({
  plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
  initialView: 'dayGridMonth',
  headerToolbar: {
    left: 'prev,next today',
    center: 'title',
    right: 'dayGridMonth,timeGridWeek,timeGridDay'
  },
  locale: 'ko',
  events: events.value.map(e => ({
    id: e.eventId,
    title: e.title,
    start: e.startDt,
    end: e.endDt,
    allDay: e.allDay,
    color: e.color
  })),
  editable: true
}));

async function load() {
  if (!authStore.user) { await authStore.loadUserInfo(); }
  const ownerId = authStore.user?.employeeId;
  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth() - 1, 1).toISOString();
  const end = new Date(now.getFullYear(), now.getMonth() + 2, 0).toISOString();
  const req: any = { startDt: start, endDt: end, ownerId };
  if (scope.value !== 'ALL') req.eventType = scope.value;
  const res = await axios.post('/api/dataset/search', {
    serviceName: 'calendar/searchEvents',
    datasets: { ds_search: req }
  });
  events.value = res.data?.data?.ds_events?.rows || [];
}

onMounted(load);
</script>

<style scoped>
.page { padding: 1.5rem; }
.filters { margin-bottom: 1rem; }
</style>
