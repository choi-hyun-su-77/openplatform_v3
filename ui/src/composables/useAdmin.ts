/**
 * 시스템 관리자 (Admin) 도메인 — DataSet 서비스 호출 래퍼.
 *
 * 모든 메서드는 `serviceName=admin/*` 로 backend-core `/api/dataset/search` 또는 `/api/dataset/save` 에 매핑된다.
 * backend 측 ROLE_ADMIN 가드가 적용되며, 비ROLE_ADMIN 호출 시 403 응답.
 *
 * 사용 예:
 *   const admin = useAdmin();
 *   const { rows } = await admin.userList({ keyword: 'kim' });
 *   await admin.userSave({ employeeNo: 'E0099', employeeName: '신규' });
 */
import axios from 'axios'

const SEARCH = '/api/dataset/search'
const SAVE = '/api/dataset/save'

interface DataSetEnvelope<T = any> {
  success: boolean
  data?: T
  message?: string
}

async function search<T = any>(serviceName: string, datasets: Record<string, any>): Promise<T> {
  const res = await axios.post<DataSetEnvelope<T>>(SEARCH, { serviceName, datasets })
  return (res.data?.data ?? {}) as T
}

async function save<T = any>(serviceName: string, datasets: Record<string, any>): Promise<T> {
  const res = await axios.post<DataSetEnvelope<T>>(SAVE, { serviceName, datasets })
  return (res.data?.data ?? {}) as T
}

export interface AdminUser {
  employeeId?: number
  employeeNo: string
  employeeName: string
  deptId?: number
  deptName?: string
  positionId?: number
  positionName?: string
  email?: string
  phone?: string
  keycloakUserId?: string
  status?: string
  hireDate?: string
  roles?: string[]
}

export interface AdminDept {
  deptId?: number
  deptCode: string
  deptName: string
  parentDeptId?: number | null
  deptLevel?: number
  sortOrder?: number
  useYn?: string
  children?: AdminDept[]
}

export interface AdminMenu {
  menuId: string
  menuName: string
  menuPath?: string
  parentMenuId?: string | null
  menuLevel?: number
  sortOrder?: number
  icon?: string
  useYn?: string
}

export interface AdminPermission {
  roleId: string
  menuId: string
  canRead?: boolean
  canCreate?: boolean
  canUpdate?: boolean
  canDelete?: boolean
  canExport?: boolean
  canPrint?: boolean
}

export interface AdminCode {
  groupCd: string
  code: string
  codeName: string
  sortOrder?: number
  useYn?: string
}

export interface AdminAuditRow {
  auditId: number
  actorNo: string
  actorName: string
  action: string
  targetType?: string
  targetId?: string
  beforeJson?: any
  afterJson?: any
  ipAddr?: string
  actedAt: string
}

export function useAdmin() {
  return {
    // ─── 사용자 ──────────────────────────────────────────────────
    async userList(params: { keyword?: string; deptId?: number; status?: string; page?: number; size?: number } = {}) {
      const data = await search('admin/userList', { ds_search: params })
      return {
        rows: (data?.ds_users?.rows || []) as AdminUser[],
        total: data?.ds_users?.totalCount || 0
      }
    },
    async userSave(user: AdminUser) {
      return save('admin/userSave', { ds_user: { rows: [user] } })
    },
    async userToggleActive(employeeId: number) {
      return save('admin/userToggleActive', { ds_search: { employeeId } })
    },
    async userResetPwd(employeeId: number) {
      return save('admin/userResetPwd', { ds_search: { employeeId } })
    },

    // ─── 부서 ────────────────────────────────────────────────────
    async deptTree() {
      const data = await search('admin/deptTree', { ds_search: {} })
      return {
        tree: (data?.ds_deptTree?.rows || []) as AdminDept[],
        flat: (data?.ds_deptList?.rows || []) as AdminDept[]
      }
    },
    async deptSave(dept: AdminDept & { _rowType?: string }) {
      return save('admin/deptSave', { ds_dept: { rows: [dept] } })
    },
    async deptDelete(deptId: number) {
      return save('admin/deptSave', { ds_dept: { rows: [{ deptId, _rowType: 'D' }] } })
    },

    // ─── 메뉴 / 권한 ─────────────────────────────────────────────
    async menuList() {
      const data = await search('admin/menuList', { ds_search: {} })
      return {
        flat: (data?.ds_menus?.rows || []) as AdminMenu[],
        tree: (data?.ds_menuTree?.rows || []) as any[],
        roles: (data?.ds_roles?.rows || []) as { roleId: string; roleName: string }[],
        permissions: (data?.ds_permissions?.rows || []) as AdminPermission[]
      }
    },
    async menuSave(menu: AdminMenu) {
      return save('admin/menuSave', { ds_menu: { rows: [menu] } })
    },
    async menuDelete(menuId: string) {
      return save('admin/menuDelete', { ds_search: { menuId } })
    },
    async permSave(rows: (AdminPermission & { _rowType?: string })[]) {
      return save('admin/permSave', { ds_permissions: { rows } })
    },

    // ─── 공통코드 ────────────────────────────────────────────────
    async codeGroupList() {
      const data = await search('admin/codeGroupList', { ds_search: {} })
      return (data?.ds_groups?.rows || []) as { groupCd: string; codeCount: number }[]
    },
    async codeList(groupCd?: string) {
      const data = await search('admin/codeList', { ds_search: { groupCd } })
      return (data?.ds_codes?.rows || []) as AdminCode[]
    },
    async codeSave(rows: (AdminCode & { _rowType?: string })[]) {
      return save('admin/codeSave', { ds_codes: { rows } })
    },
    async codeDelete(groupCd: string, code: string) {
      return save('admin/codeDelete', { ds_search: { groupCd, code } })
    },

    // ─── 감사 로그 ───────────────────────────────────────────────
    async auditSearch(params: {
      actorNo?: string
      action?: string
      fromDate?: string
      toDate?: string
      page?: number
      size?: number
    } = {}) {
      const data = await search('admin/auditSearch', { ds_search: params })
      return {
        rows: (data?.ds_audit?.rows || []) as AdminAuditRow[],
        total: data?.ds_audit?.totalCount || 0
      }
    }
  }
}
