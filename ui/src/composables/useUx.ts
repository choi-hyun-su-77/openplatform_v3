/**
 * Phase 14 트랙 6 — UX (통합검색 / 즐겨찾기 / 알림설정) DataSet 호출 래퍼.
 *
 * 모든 메서드는 backend-core `/api/dataset/search` 의 serviceName=`ux/*` 에 매핑된다.
 *
 * 사용 예:
 *   const ux = useUx();
 *   const r = await ux.search('휴가', ['POST', 'DOC']);
 *   const favs = await ux.listFavorites();
 *   await ux.addFavorite({ targetType: 'POST', targetId: '123', label: '...', url: '/board?postId=123' });
 *   const pref = await ux.getNotifyPref();
 *   await ux.saveNotifyPref(pref.rows);
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

// ─── 타입 정의 ─────────────────────────────────────────────────────────────

export type SearchType = 'POST' | 'DOC' | 'EMP' | 'FILE';

export interface SearchPostRow {
  postId: number;
  boardType: string;
  deptId?: number;
  deptName?: string;
  title: string;
  createdBy: string;
  viewCount?: number;
  createdAt: string;
}

export interface SearchDocRow {
  docId: number;
  docTitle: string;
  formCode: string;
  drafterNo: string;
  drafterName: string;
  status: string;
  createdAt: string;
}

export interface SearchEmpRow {
  employeeId: number;
  employeeNo: string;
  employeeName: string;
  deptId: number;
  deptName: string;
  positionName: string;
  email?: string;
  phone?: string;
}

export interface SearchFileRow {
  fileId: number;
  folderId: number;
  fileName: string;
  folderName?: string;
  scope?: string;
  sizeBytes: number;
  uploaderNo: string;
  uploadedAt: string;
}

export interface SearchResult {
  posts: SearchPostRow[];
  docs: SearchDocRow[];
  employees: SearchEmpRow[];
  files: SearchFileRow[];
}

export interface FavoriteRow {
  favId: number;
  employeeNo: string;
  targetType: 'MENU' | 'POST' | 'DOC' | 'EMPLOYEE' | 'FILE';
  targetId: string;
  label?: string;
  url?: string;
  icon?: string;
  sortOrder: number;
  createdAt?: string;
}

export interface NotifyPrefRow {
  category: 'APPROVAL' | 'BOARD' | 'CALENDAR' | 'MENTION' | 'ROOM' | 'LEAVE';
  channel: 'PORTAL' | 'EMAIL' | 'MESSENGER';
  enabled: boolean;
}

export interface NotifyPrefMatrix {
  rows: NotifyPrefRow[];
  categories: string[];
  channels: string[];
}

// ─── composable ────────────────────────────────────────────────────────────

export function useUx() {
  return {
    /** 통합 검색 — types 미지정 시 4 도메인 모두. */
    async search(q: string, types?: SearchType[]): Promise<SearchResult> {
      if (!q || !q.trim()) {
        return { posts: [], docs: [], employees: [], files: [] };
      }
      const data = await call('ux/search', {
        ds_search: { q: q.trim(), types: types?.join(',') || '' }
      });
      return {
        posts:     data?.ds_posts?.rows     || [],
        docs:      data?.ds_docs?.rows      || [],
        employees: data?.ds_employees?.rows || [],
        files:     data?.ds_files?.rows     || []
      };
    },

    // ─── 즐겨찾기 ─────────────────────────────────────────────────────────

    async listFavorites(): Promise<FavoriteRow[]> {
      const data = await call('ux/listFavorites', { ds_search: {} });
      return data?.ds_favorites?.rows || [];
    },

    async addFavorite(payload: {
      targetType: 'MENU' | 'POST' | 'DOC' | 'EMPLOYEE' | 'FILE';
      targetId: string;
      label?: string;
      url?: string;
      icon?: string;
    }) {
      return call('ux/addFavorite', { ds_search: payload });
    },

    async removeFavorite(favId: number) {
      return call('ux/removeFavorite', { ds_search: { favId } });
    },

    /** 정렬 일괄 갱신 — favIds 순서가 새 sort_order. */
    async reorderFavorites(favIds: number[]) {
      return call('ux/reorder', { ds_search: { favIds } });
    },

    // ─── 알림 환경설정 ────────────────────────────────────────────────────

    async getNotifyPref(): Promise<NotifyPrefMatrix> {
      const data = await call('ux/getNotifyPref', { ds_search: {} });
      return {
        rows: data?.ds_notifyPref?.rows || [],
        categories: data?.ds_meta?.categories || ['APPROVAL', 'BOARD', 'CALENDAR', 'MENTION', 'ROOM', 'LEAVE'],
        channels: data?.ds_meta?.channels || ['PORTAL', 'EMAIL', 'MESSENGER']
      };
    },

    async saveNotifyPref(rows: NotifyPrefRow[]) {
      return call('ux/saveNotifyPref', {
        ds_notifyPref: { rows, totalCount: rows.length }
      });
    }
  };
}
