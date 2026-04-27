<template>
  <div class="widget-body widget-worklog">
    <header class="widget-header">
      <i class="pi pi-list-check" />
      <span class="title">팀 업무일지</span>
      <small v-if="!isManager" class="muted">(부서장 전용)</small>
    </header>
    <div v-if="!isManager" class="state empty">
      부서장만 사용 가능한 위젯입니다.
    </div>
    <div v-else-if="loading" class="state loading">로딩...</div>
    <table v-else-if="rows.length" class="tbl">
      <thead>
        <tr>
          <th>이름</th>
          <th>완료</th>
          <th>이슈</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="r in rows" :key="(r.employeeNo || r.employee_no) + ((r.reportDate || r.report_date) || '')">
          <td class="name">{{ r.employeeName || r.employee_name || r.employeeNo || r.employee_no }}</td>
          <td class="done">{{ summarize(r.doneToday || r.done_today) }}</td>
          <td class="issue">{{ summarize(r.issue) }}</td>
        </tr>
      </tbody>
    </table>
    <div v-else class="state empty">오늘 작성된 업무일지가 없습니다.</div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useAuthStore } from '@/store/auth';

defineProps<{ widgetCode: string; config?: any }>();

const auth = useAuthStore();
const rows = ref<any[]>([]);
const loading = ref(false);

const isManager = computed(() => {
  const roles = auth.user?.roles || [];
  return roles.some(r => /MANAGER|MGR|ADMIN|DEPT_HEAD/.test(r));
});

async function load() {
  if (!isManager.value) return;
  loading.value = true;
  try {
    if (!auth.user) await auth.loadUserInfo();
    const deptId = auth.user?.deptId;
    const today = new Date().toISOString().slice(0, 10);
    // 1차: searchTeamDaily(reportDate, deptId)  — 트랙 4 의 일별 service
    let list: any[] = [];
    try {
      const r1 = await axios.post('/api/dataset/search', {
        serviceName: 'worklog/searchTeamDaily',
        datasets: { ds_search: { reportDate: today, deptId } }
      });
      list = r1.data?.data?.ds_team?.rows || [];
    } catch (err1) {
      // 2차 폴백: searchTeamWeekly(weekStart, deptId) — weekly 매트릭스 응답에서 오늘만 추출
      console.warn('[WidgetTeamWorklog] searchTeamDaily failed, fallback weekly', err1);
      const r2 = await axios.post('/api/dataset/search', {
        serviceName: 'worklog/searchTeamWeekly',
        datasets: { ds_search: { weekStart: today, deptId } }
      });
      list = r2.data?.data?.ds_team?.rows || [];
    }
    rows.value = (list || []).slice(0, 5);
  } catch (e) {
    console.warn('[WidgetTeamWorklog] failed', e);
    rows.value = [];
  } finally {
    loading.value = false;
  }
}

function summarize(text?: string): string {
  if (!text) return '-';
  const t = String(text).trim();
  return t.length > 30 ? t.slice(0, 30) + '…' : t;
}

onMounted(load);
</script>

<style scoped>
.widget-worklog { display: flex; flex-direction: column; height: 100%; }
.widget-header { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.6rem; color: #475569; font-weight: 600; }
.muted { color: #94a3b8; font-size: 0.75rem; font-weight: normal; margin-left: auto; }
.state { flex: 1; display: flex; align-items: center; justify-content: center; color: #94a3b8; font-size: 0.9rem; }
.tbl { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
.tbl th, .tbl td { text-align: left; padding: 0.3rem 0.4rem; border-bottom: 1px solid #f1f5f9; }
.tbl th { color: #64748b; font-weight: 600; background: #f8fafc; }
.tbl .name { width: 5rem; color: #1e293b; font-weight: 600; }
.tbl .done { color: #1e293b; }
.tbl .issue { color: #ef4444; max-width: 12rem; }
</style>
