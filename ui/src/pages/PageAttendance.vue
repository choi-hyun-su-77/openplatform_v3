<!--
  PageAttendance.vue — 본인 근태 페이지.

  레이아웃:
    상단 — 큰 출근/퇴근 버튼 + 현재 시각 + 오늘 상태 + 누적 근무시간
    하단 — 월별 출근 미니 캘린더 (MonthlyCalendar)

  데이터 흐름:
    onMounted → searchToday + searchMyMonth(현재 yearMonth)
    출근/퇴근 클릭 → checkIn/checkOut → 두 데이터 새로고침
-->
<template>
  <div class="page attendance-page">
    <div class="page-header">
      <h2><i class="pi pi-clock" /> 근태</h2>
      <div class="header-actions">
        <Button label="새로고침" icon="pi pi-refresh" text @click="reload" />
      </div>
    </div>

    <section class="check-card">
      <div class="left">
        <div class="time-now">{{ nowLabel }}</div>
        <div class="date-now">{{ todayLabel }}</div>
        <div class="status-row" v-if="todayRow">
          <Tag :value="statusLabel(todayRow.status || 'NORMAL')" :severity="statusSeverity(todayRow.status || 'NORMAL')" />
          <span v-if="todayRow.checkInAt" class="t-info">
            출근 <strong>{{ formatTime(todayRow.checkInAt) }}</strong>
          </span>
          <span v-if="todayRow.checkOutAt" class="t-info">
            퇴근 <strong>{{ formatTime(todayRow.checkOutAt) }}</strong>
          </span>
          <span v-if="todayRow.workMinutes != null" class="t-info">
            근무 <strong>{{ formatMinutes(todayRow.workMinutes) }}</strong>
          </span>
        </div>
        <div v-else class="status-row">
          <Tag value="미출근" severity="secondary" />
        </div>
      </div>
      <div class="right">
        <Button
          v-if="!hasCheckedIn"
          label="출근"
          icon="pi pi-sign-in"
          severity="success"
          size="large"
          class="big-btn"
          :loading="busy"
          @click="onCheckIn"
        />
        <Button
          v-else-if="!hasCheckedOut"
          label="퇴근"
          icon="pi pi-sign-out"
          severity="info"
          size="large"
          class="big-btn"
          :loading="busy"
          @click="onCheckOut"
        />
        <Button
          v-else
          label="완료"
          icon="pi pi-check"
          size="large"
          class="big-btn"
          disabled
        />
      </div>
    </section>

    <section class="month-card">
      <h3>이번 달 출근 현황</h3>
      <MonthlyCalendar
        v-model:yearMonth="yearMonth"
        :rows="monthRows"
        @selectDate="(d) => console.log('cell click', d)"
      />
      <div class="month-summary">
        <div><span>출근일</span><strong>{{ stats.workDays }}일</strong></div>
        <div><span>총 근무시간</span><strong>{{ formatMinutes(stats.totalMinutes) }}</strong></div>
        <div><span>평균 근무</span><strong>{{ stats.workDays ? formatMinutes(Math.round(stats.totalMinutes / stats.workDays)) : '-' }}</strong></div>
        <div><span>지각</span><strong>{{ stats.lateDays }}일</strong></div>
        <div><span>휴가</span><strong>{{ stats.leaveDays }}일</strong></div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue';
import Button from 'primevue/button';
import Tag from 'primevue/tag';
import MonthlyCalendar from '@/components/attendance/MonthlyCalendar.vue';
import { useAttendance, type AttendanceRow } from '@/composables/useAttendance';

const attendance = useAttendance();

const todayRow = ref<AttendanceRow | null>(null);
const monthRows = ref<AttendanceRow[]>([]);
const busy = ref(false);

const now = ref(new Date());
let timer: any = null;

function pad2(n: number) { return String(n).padStart(2, '0'); }
function ymd(d: Date) {
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`;
}
function ym(d: Date) {
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}`;
}

const yearMonth = ref(ym(new Date()));
const todayLabel = computed(() => {
  const d = now.value;
  const w = ['일', '월', '화', '수', '목', '금', '토'][d.getDay()];
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())} (${w})`;
});
const nowLabel = computed(() => {
  const d = now.value;
  return `${pad2(d.getHours())}:${pad2(d.getMinutes())}:${pad2(d.getSeconds())}`;
});

const hasCheckedIn = computed(() => !!todayRow.value?.checkInAt);
const hasCheckedOut = computed(() => !!todayRow.value?.checkOutAt);

const stats = computed(() => {
  const workDays = monthRows.value.filter(r => r.checkInAt).length;
  const totalMinutes = monthRows.value.reduce((s, r) => s + (r.workMinutes || 0), 0);
  const lateDays = monthRows.value.filter(r => r.status === 'LATE').length;
  const leaveDays = monthRows.value.filter(r => r.status === 'LEAVE').length;
  return { workDays, totalMinutes, lateDays, leaveDays };
});

function statusLabel(s: string) {
  switch (s) {
    case 'NORMAL':  return '정상';
    case 'LATE':    return '지각';
    case 'EARLY':   return '조퇴';
    case 'ABSENT':  return '결근';
    case 'HOLIDAY': return '공휴일';
    case 'LEAVE':   return '휴가';
    default: return s;
  }
}
function statusSeverity(s: string): any {
  switch (s) {
    case 'NORMAL':  return 'success';
    case 'LATE':
    case 'EARLY':   return 'warn';
    case 'ABSENT':  return 'danger';
    case 'LEAVE':   return 'info';
    case 'HOLIDAY': return 'secondary';
    default: return 'secondary';
  }
}

function formatTime(raw: string | null | undefined) {
  if (!raw) return '';
  const d = new Date(raw);
  if (Number.isNaN(d.getTime())) return raw;
  return `${pad2(d.getHours())}:${pad2(d.getMinutes())}`;
}
function formatMinutes(m: number | null | undefined) {
  if (m == null || Number.isNaN(m)) return '-';
  const h = Math.floor(m / 60);
  const mm = m % 60;
  return `${h}h ${pad2(mm)}m`;
}

async function loadToday() {
  try {
    todayRow.value = await attendance.searchToday();
  } catch (e) {
    console.warn('searchToday failed', e);
    todayRow.value = null;
  }
}
async function loadMonth() {
  try {
    monthRows.value = await attendance.searchMyMonth(yearMonth.value);
  } catch (e) {
    console.warn('searchMyMonth failed', e);
    monthRows.value = [];
  }
}
async function reload() {
  await Promise.all([loadToday(), loadMonth()]);
}

async function onCheckIn() {
  busy.value = true;
  try {
    const res: any = await attendance.checkIn();
    if (res?.success === false && res?.message) {
      alert(res.message);
    }
    await reload();
  } catch (e: any) {
    alert('출근 실패: ' + (e?.response?.data?.message || e.message));
  } finally {
    busy.value = false;
  }
}
async function onCheckOut() {
  busy.value = true;
  try {
    await attendance.checkOut();
    await reload();
  } catch (e: any) {
    alert('퇴근 실패: ' + (e?.response?.data?.message || e.message));
  } finally {
    busy.value = false;
  }
}

watch(yearMonth, loadMonth);

onMounted(() => {
  reload();
  timer = setInterval(() => { now.value = new Date(); }, 1000);
});
onUnmounted(() => { if (timer) clearInterval(timer); });
</script>

<style scoped>
.attendance-page { padding: 1.5rem; max-width: 1200px; }
.page-header {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 1.25rem;
}
.page-header h2 {
  margin: 0; display: flex; align-items: center; gap: 0.5rem;
  color: #1e293b;
}

.check-card {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, #eff6ff 0%, #f8fafc 100%);
  border: 1px solid var(--p-content-border-color, #e2e8f0);
  border-radius: 12px;
  padding: 1.5rem 2rem;
  margin-bottom: 1.5rem;
}
.check-card .left { display: flex; flex-direction: column; gap: 0.4rem; }
.check-card .time-now {
  font-size: 2.6rem; font-weight: 700; color: #1e40af; line-height: 1;
  font-variant-numeric: tabular-nums;
}
.check-card .date-now { color: #64748b; font-size: 0.95rem; }
.check-card .status-row {
  display: flex; align-items: center; gap: 0.625rem; flex-wrap: wrap;
  margin-top: 0.5rem; font-size: 0.875rem; color: #475569;
}
.check-card .status-row .t-info strong { color: #1e293b; }
.check-card .right .big-btn { min-width: 160px; min-height: 56px; font-size: 1.1rem; }
.check-card .big-btn :deep(.p-button-icon) { font-size: 1.2rem; }

.month-card {
  background: var(--p-content-background, #fff);
  border: 1px solid var(--p-content-border-color, #e2e8f0);
  border-radius: 10px;
  padding: 1.25rem;
}
.month-card h3 {
  margin: 0 0 1rem 0; font-size: 1rem; color: #334155;
}
.month-summary {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 0.75rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #f1f5f9;
}
.month-summary > div {
  display: flex; flex-direction: column; gap: 4px;
  padding: 0.5rem 0.75rem;
  background: #f8fafc;
  border-radius: 6px;
}
.month-summary > div span { font-size: 0.78rem; color: #64748b; }
.month-summary > div strong { font-size: 1.05rem; color: #1e293b; }
</style>
