/**
 * 근태 (Attendance) 도메인 — DataSet 서비스 호출 래퍼.
 *
 * backend-core 의 `attendance/*` 매핑에 1:1 대응.
 * 모든 메서드는 `/api/dataset/search` POST.
 */
import axios from 'axios';

const ENDPOINT = '/api/dataset/search';

interface DataSetEnvelope<T = any> {
  success: boolean;
  data?: T;
  message?: string;
}

async function call<T = any>(serviceName: string, datasets: Record<string, any>): Promise<T> {
  const res = await axios.post<DataSetEnvelope<T>>(ENDPOINT, { serviceName, datasets });
  return (res.data?.data ?? {}) as T;
}

export interface AttendanceRow {
  attendanceId?: number;
  employeeNo?: string;
  workDate?: string;       // 'yyyy-MM-dd'
  checkInAt?: string | null;
  checkOutAt?: string | null;
  workMinutes?: number | null;
  status?: 'NORMAL' | 'LATE' | 'EARLY' | 'ABSENT' | 'HOLIDAY' | 'LEAVE' | string;
  note?: string | null;
  employeeName?: string;   // searchTeamDaily
}

export function useAttendance() {
  return {
    /** 출근 — 오늘 row 가 없으면 INSERT, 있으면 check_in_at UPDATE (멱등) */
    async checkIn() {
      return call('attendance/checkIn', { ds_search: {} });
    },

    /** 퇴근 — work_minutes 자동 계산 */
    async checkOut() {
      return call('attendance/checkOut', { ds_search: {} });
    },

    /** 오늘 row (없으면 빈 배열) */
    async searchToday(): Promise<AttendanceRow | null> {
      const data = await call('attendance/searchToday', { ds_search: {} });
      const rows: AttendanceRow[] = data?.ds_today?.rows || [];
      return rows[0] || null;
    },

    /** 본인 월별 출근 (yearMonth='2026-04') */
    async searchMyMonth(yearMonth: string): Promise<AttendanceRow[]> {
      const data = await call('attendance/searchMyMonth', { ds_search: { yearMonth } });
      return data?.ds_month?.rows || [];
    },

    /** 부서장 — 팀원 일별 출근 */
    async searchTeamDaily(deptId: number, workDate: string): Promise<AttendanceRow[]> {
      const data = await call('attendance/searchTeamDaily', {
        ds_search: { deptId, workDate }
      });
      return data?.ds_team?.rows || [];
    }
  };
}
