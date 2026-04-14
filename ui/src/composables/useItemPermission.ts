/**
 * ============================================================================
 * useItemPermission.ts — 화면 항목(컴포넌트) 권한 컴포저블
 * ============================================================================
 *
 * 【역할】
 *   authStore에 저장된 itemPermissions에서 menuId별 항목 권한을 조회한다.
 *   해당 menuId에 등록된 항목이 없으면 모든 항목을 visible+enabled로 반환한다 (기본 허용).
 *
 * 【권한 항목】
 *   visible — 항목 표시 여부 (v-if / v-show에 바인딩)
 *   enabled — 항목 활성 여부 (:disabled에 바인딩)
 *
 * 【DB 구조】
 *   fw_page_item 테이블       — 화면별 항목 정의 (BUTTON/COLUMN/FIELD/PANEL)
 *   rel_role_page_item 테이블 — 역할별 항목 권한 매핑 (can_visible, can_enabled)
 *
 * 【사용 예시】
 *   const itemPerm = useItemPermission('customer-list')
 *
 *   // 템플릿에서:
 *   <Button v-if="itemPerm('btn_approve').visible"
 *           :disabled="!itemPerm('btn_approve').enabled"
 *           label="승인" />
 *
 *   <Column v-if="itemPerm('col_secret').visible"
 *           field="secret" header="비밀 컬럼" />
 *
 * 【기본 허용 정책】
 *   - authStore.itemPermissions가 없으면 → 기본 허용 (visible=true, enabled=true)
 *   - 해당 menuId에 항목이 등록되지 않으면 → 기본 허용
 *   - 등록된 항목 중 해당 itemId가 없으면 → 기본 허용
 *   - 즉, 명시적으로 제한 설정한 항목만 제어된다
 *
 * @module useItemPermission
 */
import { useAuthStore } from '@/store/auth'

/**
 * 항목 권한 인터페이스
 *
 * @property visible — 항목 표시 여부 (true=표시, false=숨김)
 * @property enabled — 항목 활성 여부 (true=활성, false=비활성/disabled)
 */
export interface ItemPermission {
  /** 항목 표시 여부 */
  visible: boolean
  /** 항목 활성 여부 */
  enabled: boolean
}

/** 기본 권한: 모두 허용 (항목이 등록되지 않은 경우 사용) */
const DEFAULT_PERMISSION: ItemPermission = { visible: true, enabled: true }

/**
 * 화면 항목 권한 컴포저블
 *
 * <p>menuId를 기준으로 authStore.itemPermissions에서 항목 권한을 조회하는
 * 함수를 반환한다. 반환된 함수에 itemId를 전달하면 해당 항목의
 * visible/enabled 권한을 반환한다.</p>
 *
 * @param menuId 메뉴 ID (예: 'customer-list', 'order-form')
 * @returns (itemId: string) => ItemPermission — 항목 ID로 권한 조회하는 함수
 *
 * @example
 * ```typescript
 * const itemPerm = useItemPermission('customer-list')
 *
 * // 버튼 권한 체크
 * const approveBtn = itemPerm('btn_approve')
 * // approveBtn.visible → true/false
 * // approveBtn.enabled → true/false
 * ```
 */
export function useItemPermission(menuId: string) {
  /** 인증 스토어에서 전역 항목 권한 맵 참조 */
  const authStore = useAuthStore()

  /**
   * 항목 ID로 권한 조회
   *
   * @param itemId 항목 ID (예: 'btn_approve', 'col_secret')
   * @returns ItemPermission — { visible, enabled }
   */
  return (itemId: string): ItemPermission => {
    // authStore.itemPermissions가 없거나 해당 메뉴에 항목이 없으면 기본 허용
    // authStore에 itemPermissions가 아직 추가되지 않은 경우를 대비하여 안전하게 접근
    const store = authStore as unknown as Record<string, unknown>
    const items = store.itemPermissions as
      Record<string, Record<string, { canVisible?: boolean; canEnabled?: boolean }>> | undefined
    if (!items) return DEFAULT_PERMISSION

    // 해당 메뉴의 항목 권한 맵 조회
    const menuItems = items[menuId]
    if (!menuItems) return DEFAULT_PERMISSION

    // 해당 항목의 권한 조회
    const perm = menuItems[itemId]
    if (!perm) return DEFAULT_PERMISSION

    return {
      visible: perm.canVisible ?? true,   // 미설정이면 기본 표시
      enabled: perm.canEnabled ?? true,   // 미설정이면 기본 활성
    }
  }
}
