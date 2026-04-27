/**
 * 휴가/연차 (Leave) 도메인 — DataSet 서비스 호출 래퍼.
 *
 * backend-core 의 `leave/*` 매핑에 1:1 대응.
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

export interface LeaveBalanceRow {
  balanceId?: number;
  employeeNo?: string;
  year?: number;
  totalDays?: number;
  usedDays?: number;
  carryOver?: number;
  remaining?: number;
}

export interface LeaveRequestRow {
  requestId?: number;
  docId?: number;
  employeeNo?: string;
  leaveType?: 'ANNUAL' | 'HALF_AM' | 'HALF_PM' | 'SICK' | 'FAMILY' | 'UNPAID' | string;
  fromDate?: string;
  toDate?: string;
  days?: number;
  reason?: string;
  status?: 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELLED' | string;
  createdAt?: string;
  docTitle?: string;
  docStatus?: string;
}

export interface LeaveCalendarRow {
  requestId?: number;
  employeeNo?: string;
  employeeName?: string;
  leaveType?: string;
  fromDate?: string;
  toDate?: string;
  days?: number;
  status?: string;
}

export function useLeave() {
  return {
    /** 본인 연차 잔여 (year, default = 현재년도) */
    async searchBalance(year?: number): Promise<LeaveBalanceRow | null> {
      const data = await call('leave/searchBalance', {
        ds_search: { year: year || new Date().getFullYear() }
      });
      const rows: LeaveBalanceRow[] = data?.ds_balance?.rows || [];
      return rows[0] || null;
    },

    /** 본인 휴가 신청 이력 (year) */
    async searchMyHistory(year?: number): Promise<LeaveRequestRow[]> {
      const data = await call('leave/searchMyHistory', {
        ds_search: { year: year || new Date().getFullYear() }
      });
      return data?.ds_history?.rows || [];
    },

    /** 부서 팀 캘린더 (from~to 사이의 APPROVED 휴가) */
    async searchTeamCalendar(deptId: number, from: string, to: string): Promise<LeaveCalendarRow[]> {
      const data = await call('leave/searchTeamCalendar', {
        ds_search: { deptId, from, to }
      });
      return data?.ds_calendar?.rows || [];
    },

    /**
     * 결재 상신 후 직접 호출 (테스트용 — 일반적으론 ApprovalService.submitDocument 가 자동 호출).
     */
    async applyFromDoc(payload: {
      docId: number;
      leaveType: string;
      fromDate: string;
      toDate: string;
      days?: number;
      reason?: string;
    }) {
      return call('leave/applyFromDoc', { ds_search: payload });
    },

    /** 승인 콜백 트리거 (테스트/관리자용) — 일반적으론 ApprovalCompleteDelegate 가 호출 */
    async onDocApproved(docId: number) {
      return call('leave/onDocApproved', { ds_search: { docId } });
    }
  };
}
