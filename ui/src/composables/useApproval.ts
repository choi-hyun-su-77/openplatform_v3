/**
 * 결재 (Approval) 도메인 — DataSet 서비스 호출 래퍼.
 *
 * 모든 메서드는 backend-core `/api/dataset/search` 의 serviceName=`approval/*` 에 매핑된다.
 * Phase A 에서 신규 추가된 액션 (withdraw/resubmit/delegate/uploadAttachment/listAttachments
 * /countPending/searchHistory) 까지 전부 노출.
 *
 * 사용 예:
 *   const approval = useApproval();
 *   const inbox = await approval.searchInbox('PENDING');
 *   await approval.approve(lineId, docId, '확인 완료');
 */
import axios from 'axios';
import { useAuthStore } from '@/store/auth';

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

export function useApproval() {
  const authStore = useAuthStore();
  const myUserNo = () => authStore.user?.employeeNo || authStore.user?.userId || '';

  return {
    /** 결재함 조회 (boxType: DRAFT/MY_DOCS/PENDING/IN_PROGRESS/COMPLETED/REJECTED/RECEIVED/CC_BOX/DEPT_BOX) */
    async searchInbox(boxType: string, keyword = '') {
      const data = await call('approval/searchInbox', {
        ds_search: { boxType, userNo: myUserNo(), keyword }
      });
      return data?.ds_inbox?.rows || [];
    },

    /** 문서 상세 + 결재선 */
    async searchDetail(docId: number) {
      const data = await call('approval/searchDetail', {
        ds_search: { docId }
      });
      return {
        doc: data?.ds_doc?.rows?.[0] || null,
        line: data?.ds_line?.rows || []
      };
    },

    /** 양식 목록 (FORM_CODE) */
    async searchFormTemplates() {
      const data = await call('approval/searchFormTemplates', { ds_search: {} });
      return data?.ds_forms?.rows || [];
    },

    /** 상신 — ds_doc.rows[0] 에 docTitle/formCode/amount/content 등 포함 */
    async submitDocument(doc: Record<string, any>) {
      const data = await call('approval/submitDocument', {
        ds_doc: { rows: [doc] }
      });
      return data;
    },

    /** 승인 */
    async approve(lineId: number, docId: number, comment = '') {
      return call('approval/approve', {
        ds_search: { lineId, docId, comment }
      });
    },

    /** 반려 */
    async reject(lineId: number, docId: number, comment: string) {
      return call('approval/reject', {
        ds_search: { lineId, docId, comment }
      });
    },

    /** 회수 — 기안자 only, PENDING/IN_PROGRESS → DRAFT */
    async withdraw(docId: number) {
      return call('approval/withdraw', { ds_search: { docId } });
    },

    /** 재상신 — REJECTED 문서 복제 + 새 버전 */
    async resubmit(docId: number, patch: { docTitle?: string; content?: string; amount?: number }) {
      const data = await call('approval/resubmit', {
        ds_search: { docId, ...patch }
      });
      return data;
    },

    /** 대결 등록 */
    async delegate(payload: { delegateeNo: string; reason?: string; fromDate: string; toDate: string }) {
      return call('approval/delegate', { ds_search: payload });
    },

    /** 첨부 메타 등록 (presigned PUT 완료 후 호출) */
    async uploadAttachmentMeta(payload: {
      docId: number; objectKey: string; filename: string;
      sizeBytes: number; mimeType?: string;
    }) {
      return call('approval/uploadAttachment', { ds_search: payload });
    },

    /** 첨부 목록 */
    async listAttachments(docId: number) {
      const data = await call('approval/listAttachments', { ds_search: { docId } });
      return data?.ds_attachments?.rows || [];
    },

    /** 미결 카운트 (대시보드 위젯) */
    async countPending() {
      const data = await call('approval/countPending', { ds_search: {} });
      return data?.ds_count?.rows?.[0]?.count || 0;
    },

    /** 결재 이력 */
    async searchHistory(docId: number) {
      const data = await call('approval/searchHistory', { ds_search: { docId } });
      return data?.ds_history?.rows || [];
    },

    /** Presigned PUT URL 조회 (BFF) */
    async getPresignedPutUrl(objectName: string, expireSec = 600) {
      const r = await axios.get('/api/bff/storage/presigned', {
        params: { object: objectName, op: 'PUT', expire: expireSec }
      });
      return r.data?.url as string;
    },

    /** Presigned GET URL (다운로드) */
    async getPresignedGetUrl(objectName: string, expireSec = 600) {
      const r = await axios.get('/api/bff/storage/presigned', {
        params: { object: objectName, op: 'GET', expire: expireSec }
      });
      return r.data?.url as string;
    }
  };
}
