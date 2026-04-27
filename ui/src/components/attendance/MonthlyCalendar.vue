<!--
  MonthlyCalendar.vue — 월별 출근 시각화 (5x6 미니 캘린더).

  Props:
    yearMonth   'yyyy-MM'
    rows        AttendanceRow[]
    onSelectDate? (date: 'yyyy-MM-dd') => void

  색상 규칙:
    NORMAL  → 초록 #22c55e
    LATE    → 노랑 #facc15
    EARLY   → 노랑 #facc15
    ABSENT  → 빨강 #ef4444
    HOLIDAY → 회색 #cbd5e1
    LEAVE   → 파랑 #3b82f6
    (없음)  → 흰색 / 토일 #f1f5f9
-->
<template>
  <div class="monthly-calendar">
    <header class="calendar-header">
      <Button icon="pi pi-chevron-left" text rounded @click="prevMonth" aria-label="이전달" />
      <div class="title">{{ headerLabel }}</div>
      <Button icon="pi pi-chevron-right" text rounded @click="nextMonth" aria-label="다음달" />
    </header>

    <div class="weekdays">
      <span v-for="d in weekdayLabels" :key="d" :class="{ sat: d === '토', sun: d === '일' }">
        {{ d }}
      </span>
    </div>

    <div class="grid">
      <div
        v-for="(cell, idx) in cells"
        :key="idx"
        class="cell"
        :class="cellClass(cell)"
        :title="cellTitle(cell)"
        @click="cell.date && emit('selectDate', cell.date)"
      >
        <span v-if="cell.day" class="day">{{ cell.day }}</span>
      </div>
    </div>

    <footer class="legend">
      <span><i class="dot dot-normal" /> 정상</span>
      <span><i class="dot dot-late" /> 지각</span>
      <span><i class="dot dot-absent" /> 결근</span>
      <span><i class="dot dot-leave" /> 휴가</span>
      <span><i class="dot dot-holiday" /> 공휴일</span>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import Button from 'primevue/button';
import type { AttendanceRow } from '@/composables/useAttendance';

const props = defineProps<{
  yearMonth: string;             // 'yyyy-MM'
  rows: AttendanceRow[];
}>();

const emit = defineEmits<{
  (e: 'update:yearMonth', v: string): void;
  (e: 'selectDate', date: string): void;
}>();

const weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

interface Cell {
  day: number | null;
  date: string | null;
  status: string | null;
  workMinutes: number | null;
  isHoliday?: boolean;
  dow?: number;
}

const headerLabel = computed(() => {
  const [y, m] = props.yearMonth.split('-').map(Number);
  return `${y}년 ${m}월`;
});

function buildCells(): Cell[] {
  const [y, m] = props.yearMonth.split('-').map(Number);
  const first = new Date(y, m - 1, 1);
  const lastDay = new Date(y, m, 0).getDate();
  const startDow = first.getDay(); // 0=Sun

  // map 'yyyy-MM-dd' → row
  const map = new Map<string, AttendanceRow>();
  for (const r of props.rows || []) {
    if (r.workDate) {
      const key = String(r.workDate).slice(0, 10);
      map.set(key, r);
    }
  }

  const out: Cell[] = [];
  // leading blanks
  for (let i = 0; i < startDow; i++) {
    out.push({ day: null, date: null, status: null, workMinutes: null });
  }
  for (let d = 1; d <= lastDay; d++) {
    const mm = String(m).padStart(2, '0');
    const dd = String(d).padStart(2, '0');
    const date = `${y}-${mm}-${dd}`;
    const row = map.get(date);
    const dow = new Date(y, m - 1, d).getDay();
    out.push({
      day: d,
      date,
      status: row?.status ?? null,
      workMinutes: row?.workMinutes ?? null,
      dow
    });
  }
  // trailing blanks (총 6주 = 42칸)
  while (out.length % 7 !== 0) {
    out.push({ day: null, date: null, status: null, workMinutes: null });
  }
  while (out.length < 42) {
    out.push({ day: null, date: null, status: null, workMinutes: null });
  }
  return out;
}

const cells = computed(() => buildCells());

function cellClass(cell: Cell) {
  if (!cell.day) return ['empty'];
  const cls: string[] = [];
  if (cell.dow === 0) cls.push('sun');
  if (cell.dow === 6) cls.push('sat');
  switch (cell.status) {
    case 'NORMAL':  cls.push('s-normal'); break;
    case 'LATE':
    case 'EARLY':   cls.push('s-late');   break;
    case 'ABSENT':  cls.push('s-absent'); break;
    case 'LEAVE':   cls.push('s-leave');  break;
    case 'HOLIDAY': cls.push('s-holiday');break;
    default: break;
  }
  return cls;
}

function cellTitle(cell: Cell) {
  if (!cell.day) return '';
  const parts: string[] = [cell.date || ''];
  if (cell.status) parts.push(cell.status);
  if (cell.workMinutes != null) {
    const h = Math.floor(cell.workMinutes / 60);
    const m = cell.workMinutes % 60;
    parts.push(`${h}h ${m}m`);
  }
  return parts.join(' / ');
}

function shiftMonth(delta: number) {
  const [y, m] = props.yearMonth.split('-').map(Number);
  const d = new Date(y, m - 1 + delta, 1);
  const ny = d.getFullYear();
  const nm = String(d.getMonth() + 1).padStart(2, '0');
  emit('update:yearMonth', `${ny}-${nm}`);
}
function prevMonth() { shiftMonth(-1); }
function nextMonth() { shiftMonth(+1); }
</script>

<style scoped>
.monthly-calendar {
  background: var(--p-content-background, #fff);
  border: 1px solid var(--p-content-border-color, #e2e8f0);
  border-radius: 8px;
  padding: 1rem;
}
.calendar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}
.calendar-header .title {
  font-size: 1.05rem;
  font-weight: 600;
  color: #334155;
}
.weekdays {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
  margin-bottom: 4px;
}
.weekdays span {
  text-align: center;
  font-size: 0.78rem;
  color: #64748b;
  padding: 4px 0;
}
.weekdays .sun { color: #ef4444; }
.weekdays .sat { color: #2563eb; }

.grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
}
.cell {
  position: relative;
  aspect-ratio: 1 / 1;
  border-radius: 6px;
  background: #f8fafc;
  display: flex;
  align-items: flex-start;
  justify-content: flex-end;
  padding: 4px 6px;
  font-size: 0.78rem;
  color: #475569;
  cursor: pointer;
  transition: transform 0.1s;
}
.cell:hover { transform: scale(1.04); }
.cell.empty { background: transparent; cursor: default; pointer-events: none; }
.cell.sun { color: #ef4444; }
.cell.sat { color: #2563eb; }
.cell .day { font-weight: 500; }

.cell.s-normal  { background: #dcfce7; color: #166534; }
.cell.s-late    { background: #fef9c3; color: #854d0e; }
.cell.s-absent  { background: #fee2e2; color: #991b1b; }
.cell.s-leave   { background: #dbeafe; color: #1e40af; }
.cell.s-holiday { background: #e2e8f0; color: #475569; }

.legend {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  margin-top: 0.75rem;
  padding-top: 0.5rem;
  border-top: 1px solid #f1f5f9;
  font-size: 0.78rem;
  color: #64748b;
}
.legend span { display: inline-flex; align-items: center; gap: 4px; }
.dot {
  display: inline-block;
  width: 10px; height: 10px;
  border-radius: 3px;
}
.dot-normal  { background: #22c55e; }
.dot-late    { background: #facc15; }
.dot-absent  { background: #ef4444; }
.dot-leave   { background: #3b82f6; }
.dot-holiday { background: #94a3b8; }
</style>
