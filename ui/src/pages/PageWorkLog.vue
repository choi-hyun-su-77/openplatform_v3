<!--
  PageWorkLog.vue — 업무일지 페이지. Phase 14 트랙 4 §6.4.

  레이아웃 (그리드 280px 1fr):
    좌측 — PrimeVue Calendar inline (mini). 작성된 날짜는 dot 표시.
    우측 — DailyEditor (오늘 한 일 / 내일 할 일 / 이슈 / 기분 / 시간 + 저장 버튼).

  상단 토글 (부서장만 표시):
    [ 본인 뷰 / 팀 뷰 ]
    팀 뷰: DataTable (행=직원, 열=월~금 5칸 + 보기 버튼).
    셀 클릭 → 해당 일지 readonly 다이얼로그.

  부서장 판정 (UI 측):
    1) auth.user.roles 에 ROLE_ADMIN 또는 ROLE_MGR 포함, 또는
    2) usePermission('worklog').canUpdate (메뉴 권한 — 트랙 8 등록 후 작동)
       의 단순 진단으로 보조 ; 정밀 권한은 backend gate(BusinessException) 가 최종.
-->
<template>
  <div class="page worklog-page">
    <div class="page-header">
      <h2><i class="pi pi-pencil" /> 업무일지</h2>
      <div class="header-actions">
        <SelectButton
          v-if="canTeamView"
          v-model="viewMode"
          :options="viewModes"
          optionLabel="label"
          optionValue="value"
          :allowEmpty="false"
        />
        <Button label="새로고침" icon="pi pi-refresh" text @click="reload" />
      </div>
    </div>

    <!-- 본인 뷰 -->
    <div v-if="viewMode === 'MINE'" class="my-grid">
      <aside class="cal-pane">
        <h3 class="pane-title">캘린더</h3>
        <DatePicker
          v-model="selectedDate"
          inline
          :manualInput="false"
          dateFormat="yy-mm-dd"
          @month-change="onMonthChange"
          @date-select="onDateSelect"
        >
          <template #date="slotProps">
            <span :class="['cal-day', { 'has-report': isWritten(slotProps.date) }]">
              {{ slotProps.date.day }}
            </span>
          </template>
        </DatePicker>
        <div class="cal-legend">
          <span class="dot dot-on" /> 작성됨
          <span class="dot dot-off ml" /> 미작성
        </div>
        <div class="week-summary">
          <h4>이번 주 ({{ ymdLabel(weekStartDate) }} ~ {{ ymdLabel(weekEndDate) }})</h4>
          <div class="week-list">
            <div
              v-for="(d, idx) in weekDays"
              :key="idx"
              :class="['week-cell', { current: ymd(d) === ymd(selectedDate) }]"
              @click="selectedDate = new Date(d)"
            >
              <div class="wd">{{ ['월','화','수','목','금','토','일'][idx] }}</div>
              <div class="wn">{{ d.getDate() }}</div>
              <div class="wo">
                <i v-if="weekHasReport(idx)" class="pi pi-check-circle" />
                <i v-else class="pi pi-minus-circle off" />
              </div>
            </div>
          </div>
        </div>
      </aside>
      <main class="editor-pane">
        <DailyEditor
          :date="ymd(selectedDate)"
          :initial="currentDayReport"
          @saved="onSaved"
        />
      </main>
    </div>

    <!-- 팀 뷰 -->
    <div v-else class="team-view">
      <div class="team-toolbar">
        <div class="week-nav">
          <Button icon="pi pi-chevron-left" text @click="shiftWeek(-1)" />
          <strong>{{ ymdLabel(weekStartDate) }} ~ {{ ymdLabel(weekEndDate) }}</strong>
          <Button icon="pi pi-chevron-right" text @click="shiftWeek(1)" />
          <Button label="이번 주" text @click="goToCurrentWeek" />
        </div>
      </div>
      <DataTable
        :value="teamRows"
        :loading="teamLoading"
        :rowHover="true"
        responsiveLayout="scroll"
        class="team-table"
      >
        <Column field="employeeName" header="직원" frozen style="width:140px">
          <template #body="{ data }">
            <div class="emp-cell">
              <strong>{{ data.employeeName }}</strong>
              <small>{{ data.employeeNo }}</small>
            </div>
          </template>
        </Column>
        <Column
          v-for="(d, idx) in weekDays.slice(0, 5)"
          :key="idx"
          :header="dayHeaderLabel(d, idx)"
          :style="{ minWidth: '180px' }"
        >
          <template #body="{ data }">
            <div
              :class="['day-cell', { empty: !data[weekDayKey(idx)] }]"
              @click="data[weekDayKey(idx)] && openCell(data, weekDayKey(idx))"
            >
              <template v-if="data[weekDayKey(idx)]">
                <div class="day-line">
                  <Tag
                    v-if="data[weekDayKey(idx)].mood"
                    :value="moodLabel(data[weekDayKey(idx)].mood)"
                    :severity="moodSeverity(data[weekDayKey(idx)].mood)"
                  />
                  <span v-if="data[weekDayKey(idx)].hoursWorked != null" class="hrs">
                    {{ data[weekDayKey(idx)].hoursWorked }}h
                  </span>
                </div>
                <div class="day-snippet">{{ snippet(data[weekDayKey(idx)].doneToday) }}</div>
              </template>
              <template v-else>
                <span class="empty-mark">-</span>
              </template>
            </div>
          </template>
        </Column>
      </DataTable>
    </div>

    <!-- 팀 셀 클릭 시 readonly 다이얼로그 -->
    <Dialog
      v-model:visible="cellDialogVisible"
      :header="cellDialogHeader"
      modal
      :style="{ width: '640px' }"
    >
      <DailyEditor
        v-if="cellDialogVisible"
        :date="cellDialogDate"
        :employeeNo="cellDialogEmpNo"
        :employeeName="cellDialogEmpName"
        :readonly="true"
        :initial="cellDialogReport"
      />
      <template #footer>
        <Button label="닫기" @click="cellDialogVisible = false" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import Button from 'primevue/button';
import DatePicker from 'primevue/datepicker';
import SelectButton from 'primevue/selectbutton';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Tag from 'primevue/tag';
import Dialog from 'primevue/dialog';
import DailyEditor from '@/components/worklog/DailyEditor.vue';
import {
  useWorkLog,
  toMondayOfWeek,
  ymd as ymdUtil,
  ymOf,
  type DailyReport,
  type TeamWeeklyRow
} from '@/composables/useWorkLog';
import { useAuthStore } from '@/store/auth';
import { usePermission } from '@/composables/usePermission';

const auth = useAuthStore();
const worklog = useWorkLog();
const perm = usePermission('worklog');

const viewModes = [
  { value: 'MINE', label: '본인' },
  { value: 'TEAM', label: '팀' }
];
const viewMode = ref<'MINE' | 'TEAM'>('MINE');

// 부서장 / ADMIN 토글 노출 여부
const canTeamView = computed(() => {
  const roles = auth.user?.roles || [];
  if (roles.includes('ROLE_ADMIN') || roles.includes('ROLE_MGR')) return true;
  // position_level 임계치 (BackEnd 와 동일한 가드 정책 30 이하)
  if ((auth.user?.positionLevel ?? 999) <= 30) return true;
  // 메뉴 권한 fallback (canUpdate 가 있어도 실제 backend 가 최종 거부 가능)
  return !!perm.value.canUpdate && roles.length > 0 && roles.some(r => r !== 'ROLE_USER');
});

// ============================================================
// 본인 뷰 상태
// ============================================================
const today = new Date();
today.setHours(0, 0, 0, 0);
const selectedDate = ref<Date>(new Date(today));
const writtenDates = ref<Set<string>>(new Set());        // 'YYYY-MM-DD'
const monthRows = ref<DailyReport[]>([]);                // 현재 표시 월
const myWeekRows = ref<DailyReport[]>([]);

const weekStartDate = computed(() => toMondayOfWeek(selectedDate.value));
const weekEndDate = computed(() => {
  const d = new Date(weekStartDate.value);
  d.setDate(d.getDate() + 6);
  return d;
});
const weekDays = computed(() => {
  const arr: Date[] = [];
  for (let i = 0; i < 7; i++) {
    const d = new Date(weekStartDate.value);
    d.setDate(d.getDate() + i);
    arr.push(d);
  }
  return arr;
});

const currentDayReport = computed<DailyReport | null>(() => {
  const target = ymdUtil(selectedDate.value);
  const found = monthRows.value.find(r =>
    String(r.reportDate || '').substring(0, 10) === target
  );
  if (found) return found;
  const found2 = myWeekRows.value.find(r =>
    String(r.reportDate || '').substring(0, 10) === target
  );
  return found2 || null;
});

function ymd(d: Date | undefined | null): string {
  if (!d) return '';
  return ymdUtil(d);
}
function ymdLabel(d: Date) {
  return `${d.getMonth() + 1}/${d.getDate()}`;
}

function isWritten(d: { day: number; month: number; year: number }) {
  // PrimeVue Calendar slot 의 month 는 0-base
  const m = String(d.month + 1).padStart(2, '0');
  const dd = String(d.day).padStart(2, '0');
  const key = `${d.year}-${m}-${dd}`;
  return writtenDates.value.has(key);
}

function weekHasReport(idx: number): boolean {
  const d = weekDays.value[idx];
  if (!d) return false;
  return writtenDates.value.has(ymd(d));
}

// ============================================================
// 팀 뷰 상태
// ============================================================
const teamRows = ref<TeamWeeklyRow[]>([]);
const teamLoading = ref(false);

function weekDayKey(idx: number): keyof TeamWeeklyRow {
  return (['mon','tue','wed','thu','fri','sat','sun'][idx] as keyof TeamWeeklyRow);
}
function dayHeaderLabel(d: Date, idx: number) {
  return `${['월','화','수','목','금'][idx]} ${d.getMonth() + 1}/${d.getDate()}`;
}
function snippet(s: string | null | undefined): string {
  if (!s) return '';
  return s.length > 40 ? s.substring(0, 40) + '…' : s;
}
function moodLabel(m: string) {
  return m === 'GOOD' ? '좋음' : m === 'NORMAL' ? '보통' : m === 'BAD' ? '나쁨' : m;
}
function moodSeverity(m: string): any {
  return m === 'GOOD' ? 'success' : m === 'BAD' ? 'danger' : 'secondary';
}

const cellDialogVisible = ref(false);
const cellDialogReport = ref<DailyReport | null>(null);
const cellDialogDate = ref('');
const cellDialogEmpNo = ref('');
const cellDialogEmpName = ref('');
const cellDialogHeader = computed(() =>
  `${cellDialogEmpName.value} (${cellDialogEmpNo.value}) — ${cellDialogDate.value}`
);

function openCell(row: any, dayKey: string) {
  const cell = row[dayKey];
  if (!cell) return;
  cellDialogReport.value = cell as DailyReport;
  cellDialogDate.value = String(cell.reportDate || '').substring(0, 10);
  cellDialogEmpNo.value = row.employeeNo;
  cellDialogEmpName.value = row.employeeName;
  cellDialogVisible.value = true;
}

// ============================================================
// 데이터 로딩
// ============================================================
async function loadMyMonth() {
  try {
    const ym = ymOf(selectedDate.value);
    const r = await worklog.searchMonth(ym);
    monthRows.value = r.rows;
    writtenDates.value = new Set(r.writtenDates);
  } catch (e) {
    console.warn('searchMonth failed', e);
  }
}

async function loadMyWeek() {
  try {
    const ws = ymd(weekStartDate.value);
    myWeekRows.value = await worklog.searchMyWeek(ws);
  } catch (e) {
    console.warn('searchMyWeek failed', e);
  }
}

async function loadTeam() {
  teamLoading.value = true;
  try {
    const ws = ymd(weekStartDate.value);
    teamRows.value = await worklog.searchTeamWeekly(ws);
  } catch (e: any) {
    console.warn('searchTeamWeekly failed', e);
    teamRows.value = [];
  } finally {
    teamLoading.value = false;
  }
}

async function reload() {
  if (viewMode.value === 'MINE') {
    await Promise.all([loadMyMonth(), loadMyWeek()]);
  } else {
    await loadTeam();
  }
}

function onMonthChange(_: { month: number; year: number }) {
  // selectedDate 가 변하면 watch 가 자동 호출하지만, month 만 바꾼 경우 명시 호출
  loadMyMonth();
}

function onDateSelect(d: Date) {
  selectedDate.value = d;
}

function onSaved(report: DailyReport) {
  const target = String(report.reportDate || '').substring(0, 10);
  if (target) writtenDates.value.add(target);
  // 월/주 데이터 갱신 (silent)
  loadMyMonth();
  loadMyWeek();
}

function shiftWeek(delta: number) {
  const d = new Date(selectedDate.value);
  d.setDate(d.getDate() + delta * 7);
  selectedDate.value = d;
}
function goToCurrentWeek() {
  const t = new Date();
  t.setHours(0, 0, 0, 0);
  selectedDate.value = t;
}

// ============================================================
// watch & lifecycle
// ============================================================
watch(viewMode, (v) => {
  if (v === 'TEAM') loadTeam();
  else { loadMyMonth(); loadMyWeek(); }
});

watch(selectedDate, () => {
  if (viewMode.value === 'MINE') {
    loadMyWeek();
    // 월이 바뀌면 month 도 재로딩
    loadMyMonth();
  } else {
    loadTeam();
  }
});

onMounted(reload);
</script>

<style scoped>
.worklog-page { padding: 1.5rem; max-width: 1400px; }
.page-header {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 1.25rem;
}
.page-header h2 {
  margin: 0; display: flex; align-items: center; gap: 0.5rem;
  color: #1e293b;
}
.header-actions { display: flex; align-items: center; gap: 0.5rem; }

.my-grid {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 1.25rem;
}
.cal-pane {
  background: var(--p-content-background, #fff);
  border: 1px solid var(--p-content-border-color, #e2e8f0);
  border-radius: 10px;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.pane-title {
  margin: 0;
  font-size: 0.95rem;
  color: #334155;
}
.cal-day {
  display: inline-flex;
  position: relative;
  width: 24px;
  height: 24px;
  align-items: center;
  justify-content: center;
}
.cal-day.has-report::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 50%;
  transform: translateX(-50%);
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: var(--p-primary-color, #3b82f6);
}
.cal-legend {
  display: flex;
  align-items: center;
  font-size: 0.75rem;
  color: #64748b;
  gap: 0.25rem;
}
.cal-legend .dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  margin-right: 4px;
}
.cal-legend .dot.dot-on { background: var(--p-primary-color, #3b82f6); }
.cal-legend .dot.dot-off { background: #cbd5e1; }
.cal-legend .ml { margin-left: 0.75rem; }

.week-summary { border-top: 1px solid #f1f5f9; padding-top: 0.75rem; }
.week-summary h4 { margin: 0 0 0.5rem 0; font-size: 0.85rem; color: #475569; }
.week-list {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
}
.week-cell {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 4px 0;
  border: 1px solid #f1f5f9;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.75rem;
}
.week-cell.current {
  background: #eff6ff;
  border-color: var(--p-primary-color, #3b82f6);
}
.week-cell .wd { color: #64748b; font-size: 0.7rem; }
.week-cell .wn { font-weight: 600; color: #1e293b; }
.week-cell .wo i { color: var(--p-primary-color, #3b82f6); font-size: 0.85rem; }
.week-cell .wo i.off { color: #cbd5e1; }

.editor-pane {
  display: flex;
  flex-direction: column;
}

/* 팀 뷰 */
.team-view {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.team-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.week-nav {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.team-table { border: 1px solid var(--p-content-border-color, #e2e8f0); border-radius: 10px; }
.emp-cell { display: flex; flex-direction: column; }
.emp-cell strong { color: #1e293b; }
.emp-cell small { color: #94a3b8; font-size: 0.75rem; }

.day-cell {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 6px 4px;
  border-radius: 6px;
  cursor: pointer;
  min-height: 60px;
}
.day-cell:hover { background: #f8fafc; }
.day-cell.empty { cursor: default; color: #cbd5e1; }
.day-cell.empty:hover { background: transparent; }
.day-line { display: flex; align-items: center; gap: 0.4rem; flex-wrap: wrap; }
.day-line .hrs { font-size: 0.75rem; color: #64748b; }
.day-snippet { font-size: 0.8rem; color: #334155; line-height: 1.3; }
.empty-mark { color: #cbd5e1; }
</style>
