/**
 * ============================================================================
 * usePermission.ts — 메뉴 권한 기반 버튼 제어 컴포저블
 * ============================================================================
 *
 * 【역할】
 *   현재 로그인 사용자의 역할(role)에 따른 메뉴별 권한을 조회하여
 *   CrudToolbar의 버튼 표시/숨김을 제어한다.
 *   authStore에 저장된 메뉴 권한 목록에서 menuId로 해당 메뉴의 권한을 찾는다.
 *
 * 【권한 항목】
 *   canRead   — 조회 권한
 *   canCreate — 등록(추가) 권한
 *   canUpdate — 수정(저장) 권한
 *   canDelete — 삭제 권한
 *   canExport — 엑셀 내보내기 권한
 *   canPrint  — 인쇄 권한
 *
 * 【DB 구조】
 *   fw_menu 테이블 — 메뉴 정의
 *   rel_role_menu 테이블 — 역할별 메뉴 권한 매핑
 *
 * 【사용 예시】
 *   const permission = usePermission('customer-list')
 *
 *   // 템플릿에서:
 *   <Button v-if="permission.value.canCreate" label="추가" />
 *   <Button v-if="permission.value.canDelete" label="삭제" />
 *
 *   // useFramework 경유:
 *   const permission = $initForm('customer-list')
 */

import { computed } from 'vue'
import { useAuthStore } from '@/store/auth'

/**
 * 메뉴별 권한 인터페이스
 */
export interface MenuPermission {
  /** 조회 가능 여부 */
  canRead: boolean
  /** 등록(추가) 가능 여부 */
  canCreate: boolean
  /** 수정(저장) 가능 여부 */
  canUpdate: boolean
  /** 삭제 가능 여부 */
  canDelete: boolean
  /** 엑셀 내보내기 가능 여부 */
  canExport: boolean
  /** 인쇄 가능 여부 */
  canPrint: boolean
}

/**
 * 메뉴 권한 컴포저블
 *
 * authStore의 menus 배열에서 menuId와 일치하는 항목을 찾아
 * 해당 메뉴의 권한을 ComputedRef로 반환한다.
 *
 * 메뉴를 찾지 못하면 모든 권한을 true로 반환 (개발 편의를 위한 기본값).
 *
 * @param menuId - 메뉴 ID (예: 'customer-list') — fw_menu.menu_id와 일치
 * @returns ComputedRef<MenuPermission>
 */
export function usePermission(menuId: string) {
  /** 인증 스토어에서 현재 사용자의 메뉴 권한 목록 참조 */
  const authStore = useAuthStore()

  const permission = computed<MenuPermission>(() => {
    // authStore.menus에서 menuId로 해당 메뉴의 권한 정보 조회
    const menu = authStore.menus.find((m: any) => m.menuId === menuId)
    if (!menu) {
      // 메뉴 미발견 시 모든 권한 허용 (개발 중 또는 권한 데이터 미설정 시)
      return {
        canRead: true,
        canCreate: true,
        canUpdate: true,
        canDelete: true,
        canExport: true,
        canPrint: true
      }
    }
    // DB에서 가져온 권한 값 반환 (null이면 false로 대체)
    return {
      canRead: menu.canRead ?? false,
      canCreate: menu.canCreate ?? false,
      canUpdate: menu.canUpdate ?? false,
      canDelete: menu.canDelete ?? false,
      canExport: menu.canExport ?? false,
      canPrint: menu.canPrint ?? false
    }
  })

  return permission
}
