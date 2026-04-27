<template>
  <div class="widget-body widget-attendance">
    <header class="widget-header">
      <i class="pi pi-clock" />
      <span class="title">출퇴근</span>
    </header>
    <div v-if="loading" class="state loading">로딩...</div>
    <div v-else-if="!checkedIn" class="state not-checked">
      <button class="btn-checkin" @click="onCheckIn" :disabled="busy">
        <i class="pi pi-sign-in" />
        <span>출근하기</span>
      </button>
      <small class="hint">{{ todayLabel }}</small>
    </div>
    <div v-else class="state checked">
      <div class="row">
        <span class="label">출근</span>
        <span class="value">{{ formatTime(today?.checkInAt) }}</span>
      </div>
      <div class="row">
        <span class="label">퇴근</span>
        <span class="value">{{ today?.checkOutAt ? formatTime(today.checkOutAt) : '-' }}</span>
      </div>
      <div class="row big">
        <span class="label">근무</span>
        <span class="value">{{ workMinutesText }}</span>
      </div>
      <button v-if="!today?.checkOutAt" class="btn-checkout" @click="onCheckOut" :disabled="busy">
        <i class="pi pi-sign-out" /> 퇴근
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';

defineProps<{ widgetCode: string; config?: any }>();

const today = ref<any>(null);
const loading = ref(false);
const busy = ref(false);

const checkedIn = computed(() => !!today.value && !!today.value.checkInAt);

const todayLabel = computed(() => {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
});

const workMinutesText = computed(() => {
  const m = today.value?.workMinutes;
  if (!m && !today.value?.checkInAt) return '-';
  // checkOutAt 없으면 현재까지 경과
  if (!today.value?.checkOutAt && today.value?.checkInAt) {
    try {
      const start = new Date(today.value.checkInAt).getTime();
      const elapsed = Math.max(0, Math.floor((Date.now() - start) / 60000));
      return formatMinutes(elapsed);
    } catch { return '-'; }
  }
  return formatMinutes(m || 0);
});

function formatMinutes(min: number): string {
  const h = Math.floor(min / 60);
  const m = min % 60;
  return `${h}h ${m}m`;
}

function formatTime(iso?: string | null): string {
  if (!iso) return '-';
  try {
    const d = new Date(iso);
    return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
  } catch { return '-'; }
}

async function load() {
  loading.value = true;
  try {
    const res = await axios.post('/api/dataset/search', {
      serviceName: 'attendance/searchToday',
      datasets: { ds_search: {} }
    });
    const rows = res.data?.data?.ds_today?.rows || [];
    today.value = rows[0] ? normalize(rows[0]) : null;
  } catch (e) {
    console.warn('[WidgetAttendance] searchToday failed', e);
    today.value = null;
  } finally {
    loading.value = false;
  }
}

function normalize(r: any) {
  return {
    attendanceId: r.attendanceId ?? r.attendance_id,
    checkInAt:    r.checkInAt    ?? r.check_in_at,
    checkOutAt:   r.checkOutAt   ?? r.check_out_at,
    workMinutes:  r.workMinutes  ?? r.work_minutes,
    status:       r.status
  };
}

async function onCheckIn() {
  if (busy.value) return;
  busy.value = true;
  try {
    await axios.post('/api/dataset/search', {
      serviceName: 'attendance/checkIn',
      datasets: { ds_search: {} }
    });
    await load();
  } catch (e) {
    console.warn('[WidgetAttendance] checkIn failed', e);
  } finally {
    busy.value = false;
  }
}

async function onCheckOut() {
  if (busy.value) return;
  busy.value = true;
  try {
    await axios.post('/api/dataset/search', {
      serviceName: 'attendance/checkOut',
      datasets: { ds_search: {} }
    });
    await load();
  } catch (e) {
    console.warn('[WidgetAttendance] checkOut failed', e);
  } finally {
    busy.value = false;
  }
}

onMounted(load);
</script>

<style scoped>
.widget-attendance { display: flex; flex-direction: column; height: 100%; }
.widget-header { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.6rem; color: #475569; font-weight: 600; }
.state { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.state.loading { color: #94a3b8; font-size: 0.9rem; }
.state.not-checked { align-items: center; gap: 0.5rem; }
.btn-checkin {
  background: #3b82f6;
  color: white;
  border: 0;
  border-radius: 8px;
  padding: 0.65rem 1.5rem;
  font-size: 1rem;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  transition: background 0.2s;
}
.btn-checkin:hover { background: #2563eb; }
.btn-checkin:disabled { background: #93c5fd; cursor: not-allowed; }
.hint { color: #94a3b8; font-size: 0.8rem; }
.state.checked .row { display: flex; justify-content: space-between; padding: 0.15rem 0; font-size: 0.9rem; }
.state.checked .row.big { font-size: 1.1rem; font-weight: 700; color: #1e293b; padding-top: 0.4rem; border-top: 1px solid #f1f5f9; margin-top: 0.3rem; }
.state.checked .label { color: #64748b; }
.state.checked .value { color: #1e293b; }
.btn-checkout {
  margin-top: 0.5rem;
  background: transparent;
  color: #64748b;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  padding: 0.4rem;
  font-size: 0.85rem;
  cursor: pointer;
}
.btn-checkout:hover { background: #f1f5f9; }
</style>
