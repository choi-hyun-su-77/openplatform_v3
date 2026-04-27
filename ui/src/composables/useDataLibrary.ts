/**
 * 자료실 (Document Library) 도메인 — DataSet 서비스 호출 래퍼.
 *
 * 모든 메서드는 backend-core `/api/dataset/search` 의 serviceName=`datalib/*` 에 매핑된다.
 * Phase 14 트랙 3 — 폴더 트리 / 파일 / presigned 다운로드.
 *
 * 사용 예:
 *   const lib = useDataLibrary();
 *   const folders = await lib.listFolders();      // 권한 필터링된 트리
 *   const files   = await lib.listFiles(1);
 *   const meta    = await storage.uploadFile(file, `datalib/${folderId}/`);
 *   await lib.uploadMeta({ folderId, fileName: meta.filename, ... });
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

export interface FolderRow {
  folderId: number;
  parentId: number | null;
  folderName: string;
  scope: 'COMPANY' | 'DEPT' | 'PERSONAL';
  ownerDeptId?: number | null;
  ownerNo?: string | null;
  createdAt?: string;
}

export interface FileRow {
  fileId: number;
  folderId: number;
  fileName: string;
  objectKey: string;
  sizeBytes: number;
  mimeType?: string;
  tags?: string;
  uploaderNo: string;
  uploaderName?: string;
  uploadedAt: string;
  downloadCount: number;
}

export interface FolderTreeNode extends FolderRow {
  children: FolderTreeNode[];
}

/** flat 폴더 배열을 PrimeVue Tree 호환 트리로 재구성. */
export function buildFolderTree(rows: FolderRow[]): FolderTreeNode[] {
  const map = new Map<number, FolderTreeNode>();
  rows.forEach(r => map.set(r.folderId, { ...r, children: [] }));
  const roots: FolderTreeNode[] = [];
  map.forEach(node => {
    if (node.parentId != null && map.has(node.parentId)) {
      map.get(node.parentId)!.children.push(node);
    } else {
      roots.push(node);
    }
  });
  // scope 우선순위: COMPANY → DEPT → PERSONAL, 동일 scope 내 이름 정렬
  const scopeOrder: Record<string, number> = { COMPANY: 0, DEPT: 1, PERSONAL: 2 };
  const sortRec = (nodes: FolderTreeNode[]) => {
    nodes.sort((a, b) => {
      const so = scopeOrder[a.scope] - scopeOrder[b.scope];
      return so !== 0 ? so : a.folderName.localeCompare(b.folderName);
    });
    nodes.forEach(n => sortRec(n.children));
  };
  sortRec(roots);
  return roots;
}

export function useDataLibrary() {
  return {
    /** 권한 필터링된 폴더 전체 (flat). */
    async listFolders(): Promise<FolderRow[]> {
      const data = await call('datalib/listFolders', { ds_search: {} });
      return data?.ds_folders?.rows || [];
    },

    /** 폴더 내 파일 목록 (옵션 keyword/tag). */
    async listFiles(folderId: number, keyword = '', tag = ''): Promise<FileRow[]> {
      const data = await call('datalib/listFiles', {
        ds_search: { folderId, keyword, tag }
      });
      return data?.ds_files?.rows || [];
    },

    async createFolder(payload: {
      parentId: number | null;
      folderName: string;
      scope?: 'COMPANY' | 'DEPT' | 'PERSONAL';
    }) {
      return call('datalib/createFolder', { ds_search: payload });
    },

    async renameFolder(folderId: number, folderName: string) {
      return call('datalib/renameFolder', { ds_search: { folderId, folderName } });
    },

    async deleteFolder(folderId: number) {
      return call('datalib/deleteFolder', { ds_search: { folderId } });
    },

    /** UI 가 BFF presigned PUT 으로 업로드 완료 후 호출. */
    async uploadMeta(payload: {
      folderId: number;
      fileName: string;
      objectKey: string;
      sizeBytes: number;
      mimeType?: string;
      tags?: string;
    }) {
      return call('datalib/uploadMeta', { ds_search: payload });
    },

    /** 통합 검색 — 사용자 접근 가능 폴더 한정. */
    async searchFiles(keyword = '', tag = ''): Promise<FileRow[]> {
      const data = await call('datalib/searchFiles', {
        ds_search: { keyword, tag }
      });
      return data?.ds_files?.rows || [];
    },

    /** presigned GET URL (다운로드 카운트 자동 증가). */
    async getDownloadUrl(fileId: number): Promise<{ url: string; fileName: string }> {
      const data = await call('datalib/getDownloadUrl', { ds_search: { fileId } });
      return { url: (data as any).url, fileName: (data as any).fileName };
    },

    async deleteFile(fileId: number) {
      return call('datalib/deleteFile', { ds_search: { fileId } });
    },

    async moveFile(fileId: number, targetFolderId: number) {
      return call('datalib/moveFile', { ds_search: { fileId, targetFolderId } });
    }
  };
}
