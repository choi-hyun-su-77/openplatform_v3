/**
 * 업무일지 (Work Report) 도메인 — DataSet 서비스 호출 래퍼.
 *
 * Phase 14 트랙 4. backend-core 의 `worklog/*` 매핑(saveDaily/searchMyWeek/
 * searchMonth/searchTeamDaily/searchTeamWeekly) 에 1:1 대응한다.
 *
 * 모든 메서드는 `/api/dataset/search` 또는 `/api/dataset/save` POST.
 * (saveDaily 만 /save 이고 나머지는 /search.)
 */
import axios from 'axios';

const ENDPOINT_SEARCH = '/api/dataset/search';
const ENDPOINT_SAVE = '/api/dataset/save';

interface DataSetEnvelope<T = any> {
  success: boolean;
  data?: T;
  message?: string;
}

async function callSearch<T = any>(serviceName: string, datasets: Record<string, any>): Promise<T> {
  const res = await axios.post<DataSetEnvelope<T>>(ENDPOINT_SEARCH, { serviceName, datasets });
  return (res.data?.data ?? {}) as T;
}

async function callSave<T = any>(serviceName: string, datasets: Record<string, any>): Promise<T> {
  const res = await axios.post<DataSetEnvelope<T>>(ENDPOINT_SAVE, { serviceName, datasets });
  return (res.data?.data ?? {}) as T;
}

export type WorkLogMood = 'GOOD' | 'NORMAL' | 'BAD';

export interface DailyReport {
  reportId?: number | null;
  employeeNo?: string;
  reportDate: string;             // 'YYYY-MM-DD'
  doneToday?: string | null;
  planTomorrow?: string | null;
  issue?: string | null;
  mood?: WorkLogMood | null;
  hoursWorked?: number | null;
  createdAt?: string;
  updatedAt?: string;
}

export interface TeamWeeklyRow {
  employeeNo: string;
  employeeName: string;
  deptId?: number;
  /** mon..sun: 해당 요일의 일지 (없으면 null). UI 셀 클릭 시 read-only 다이얼로그에 펼침. */
  mon: DailyReport | null;
  tue: DailyReport | null;
  wed: DailyReport | null;
  thu: DailyReport | null;
  fri: DailyReport | null;
  sat: DailyReport | null;
  sun: DailyReport | null;
}

/** 입력 날짜를 ISO 주(월요일 시작)으로 보정한다. */
export function toMondayOfWeek(date: Date): Date {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  // JS: Sunday=0..Saturday=6. ISO: Monday=1..Sunday=7.
  // 월요일까지 뒤로 이동.
  const day = d.getDay();
  const offset = day === 0 ? 6 : day - 1;
  d.setDate(d.getDate() - offset);
  return d;
}

export function ymd(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${dd}`;
}

export function ymOf(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  return `${y}-${m}`;
}

export function useWorkLog() {
  return {
    /** upsert — 같은 (employee_no, report_date) 가 있으면 update */
    async saveDaily(payload: DailyReport) {
      return callSave('worklog/saveDaily', { ds_search: payload });
    },

    /** 본인 주간 — weekStart='YYYY-MM-DD' (월요일이 아니어도 backend 가 보정) */
    async searchMyWeek(weekStart: string): Promise<DailyReport[]> {
      const data = await callSearch('worklog/searchMyWeek', {
        ds_search: { weekStart }
      });
      return data?.ds_week?.rows || [];
    },

    /** 본인 월별 — yearMonth='YYYY-MM' */
    async searchMonth(yearMonth: string): Promise<{
      rows: DailyReport[];
      writtenDates: string[];
    }> {
      const data = await callSearch('worklog/searchMonth', {
        ds_search: { yearMonth }
      });
      const rows: DailyReport[] = data?.ds_month?.rows || [];
      const dates: { reportDate: string }[] = data?.ds_dates?.rows || [];
      return {
        rows,
        writtenDates: dates.map(d => String(d.reportDate).substring(0, 10))
      };
    },

    /** 부서장 — 팀원 일별 (deptId 미지정 시 본인 부서로 자동) */
    async searchTeamDaily(reportDate: string, deptId?: number) {
      const data = await callSearch('worklog/searchTeamDaily', {
        ds_search: { reportDate, deptId }
      });
      return data?.ds_team?.rows || [];
    },

    /** 부서장 — 팀원 주간 (5칸 매트릭스: 행=직원, 열=요일) */
    async searchTeamWeekly(weekStart: string, deptId?: number): Promise<TeamWeeklyRow[]> {
      const data = await callSearch('worklog/searchTeamWeekly', {
        ds_search: { weekStart, deptId }
      });
      return data?.ds_team?.rows || [];
    }
  };
}
