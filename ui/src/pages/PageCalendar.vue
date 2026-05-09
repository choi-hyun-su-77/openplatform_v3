<template>
  <div class="page">
    <h2>{{ t('LBL_PAGE_CALENDAR') }}</h2>
    <div class="filters">
      <SelectButton v-model="scope" :options="scopes" optionLabel="label" optionValue="value" @change="load" />
      <Button :label="t('BTN_NEW_EVENT')" icon="pi pi-plus" size="small" @click="openNewEvent()" />
    </div>
    <FullCalendar ref="calRef" :options="calendarOptions" />

    <CalendarEventDialog v-model:visible="dialogVisible" :eventData="dialogData"
                         @saved="load" @deleted="load" />
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
import Button from 'primevue/button';
import CalendarEventDialog from '@/components/calendar/CalendarEventDialog.vue';
import { useAuthStore } from '@/store/auth';
import { useMessage } from '@/composables/useMessage';
import { useLabel } from '@/composables/useLabel';
import { getCurrentLocale } from '@/composables/useLocale';

const authStore = useAuthStore();
const { error } = useMessage();
const { t } = useLabel();
const calRef = ref<InstanceType<typeof FullCalendar> | null>(null);

const scopes = computed(() => [
  { label: t('LBL_CAL_SCOPE_ALL'), value: 'ALL' },
  { label: t('LBL_CAL_SCOPE_PERSONAL'), value: 'PERSONAL' },
  { label: t('LBL_CAL_SCOPE_DEPT'), value: 'DEPT' },
  { label: t('LBL_CAL_SCOPE_COMPANY'), value: 'COMPANY' }
]);
const scope = ref('ALL');
const events = ref<any[]>([]);
const holidays = ref<any[]>([]);
const dialogVisible = ref(false);
const dialogData = ref<any>(null);

const allEvents = computed(() => {
  const mapped = events.value.map(e => ({
    id: String(e.eventId),
    title: e.title,
    start: e.startDt,
    end: e.endDt,
    allDay: e.allDay,
    color: e.color,
    extendedProps: { ...e }
  }));
  const hols = holidays.value.map(h => ({
    id: 'h-' + h.holidayId,
    title: h.holidayName,
    start: h.holidayDate,
    allDay: true,
    display: 'background',
    color: '#fecaca'
  }));
  return [...mapped, ...hols];
});

const calendarOptions = computed(() => ({
  plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
  initialView: 'dayGridMonth',
  headerToolbar: {
    left: 'prev,next today',
    center: 'title',
    right: 'dayGridMonth,timeGridWeek,timeGridDay'
  },
  locale: getCurrentLocale(),
  events: allEvents.value,
  editable: true,
  selectable: true,
  selectMirror: true,
  dateClick: handleDateClick,
  eventClick: handleEventClick,
  eventDrop: handleEventDrop,
  eventResize: handleEventResize,
  select: handleDateSelect
}));

function openNewEvent(dateInfo?: any) {
  dialogData.value = dateInfo || null;
  dialogVisible.value = true;
}

function handleDateClick(info: any) {
  openNewEvent({ start: info.dateStr, allDay: info.allDay });
}

function handleDateSelect(info: any) {
  openNewEvent({ start: info.startStr, end: info.endStr, allDay: info.allDay });
}

function handleEventClick(info: any) {
  if (String(info.event.id).startsWith('h-')) return; // 공휴일 무시
  dialogData.value = {
    eventId: Number(info.event.id),
    title: info.event.title,
    start: info.event.startStr,
    end: info.event.endStr,
    allDay: info.event.allDay,
    color: info.event.backgroundColor,
    ...(info.event.extendedProps || {})
  };
  dialogVisible.value = true;
}

async function handleEventDrop(info: any) {
  await updateEventTimes(info);
}

async function handleEventResize(info: any) {
  await updateEventTimes(info);
}

async function updateEventTimes(info: any) {
  const eventId = Number(info.event.id);
  if (isNaN(eventId)) { info.revert(); return; }
  try {
    await axios.post('/api/dataset/save', {
      serviceName: 'calendar/saveEvents',
      datasets: {
        ds_events: {
          rows: [{
            _rowType: 'U',
            eventId,
            title: info.event.title,
            startDt: info.event.startStr,
            endDt: info.event.endStr || info.event.startStr,
            allDay: info.event.allDay
          }]
        }
      }
    });
  } catch (e) {
    error(t('MSG_CAL_MOVE_FAILED'));
    info.revert();
  }
}

async function load() {
  if (!authStore.user) { await authStore.loadUserInfo(); }
  const ownerId = authStore.user?.employeeId;
  const deptId = authStore.user?.deptId;
  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth() - 1, 1).toISOString();
  const end = new Date(now.getFullYear(), now.getMonth() + 2, 0).toISOString();
  const req: any = { startDt: start, endDt: end, ownerId };
  if (deptId) req.deptId = deptId;
  if (scope.value !== 'ALL') req.eventType = scope.value;
  try {
    const res = await axios.post('/api/dataset/search', {
      serviceName: 'calendar/searchEvents',
      datasets: { ds_search: req }
    });
    events.value = res.data?.data?.ds_events?.rows || [];
  } catch (e) {
    console.warn('calendar load failed', e);
  }
}

async function loadHolidays() {
  try {
    const res = await axios.post('/api/dataset/search', {
      serviceName: 'calendar/searchHolidays',
      datasets: { ds_search: { year: new Date().getFullYear() } }
    });
    holidays.value = res.data?.data?.ds_holidays?.rows || [];
  } catch (e) {
    console.warn('holidays load failed', e);
  }
}

onMounted(() => {
  load();
  loadHolidays();
});
</script>

<style scoped>
.page { padding: 1.5rem; }
.filters { display: flex; gap: 0.75rem; margin-bottom: 1rem; align-items: center; }
</style>
