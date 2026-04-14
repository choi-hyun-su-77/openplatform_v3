/**
 * ============================================================================
 * useQuickActions.ts — SpeedDial 공용 액션 팩토리 + 항목 권한 필터
 * ============================================================================
 *
 * 【역할】
 *   AppActionSpeedDial(고정 우하단 FAB)과 AppContextSpeedDial(우클릭 팝업)이
 *   공통으로 사용하는 액션 프리셋과 권한 기반 필터링 유틸을 제공한다.
 *
 * 【프리셋 목록】
 *   - refresh    : 현재 화면 재조회 (fn_search 연동)
 *   - excel      : 엑셀 다운로드 (fn_export 연동)
 *   - print      : 브라우저 네이티브 인쇄
 *   - copyRow    : 선택된 행을 JSON으로 클립보드 복사
 *   - scrollTop  : 지정 컨테이너를 맨 위로 스크롤
 *
 * 【권한 연동】
 *   useItemPermission(menuId)로 조회한 itemId별 visible/enabled를 이용해
 *   액션 배열을 필터링한다. itemId가 fw_page_item에 등록되지 않은 경우는
 *   기본 허용(표시)이므로 추가 작업 없이도 동작한다.
 *
 * 【사용 예시】
 *   const { buildActions } = useQuickActions('customer-list')
 *   const quickActions = buildActions([
 *     { id: 'qa-excel',      preset: 'excel',     run: () => fn_export() },
 *     { id: 'qa-print',      preset: 'print' },
 *     { id: 'qa-refresh',    preset: 'refresh',   run: () => fn_search() },
 *     { id: 'qa-copy-row',   preset: 'copyRow',   args: { getRow: () => selectedRow.value } },
 *     { id: 'qa-scroll-top', preset: 'scrollTop', args: { selector: '.customer-table .p-datatable-wrapper' } },
 *   ])
 *
 * @module useQuickActions
 */
import { computed, type ComputedRef } from 'vue'
import { useItemPermission } from './useItemPermission'
import { useMessage } from './useMessage'
import { t } from './useLabel'

/** SpeedDial이 최종적으로 바인딩할 MenuItem 포맷 (PrimeVue 4) */
export interface QuickMenuItem {
  /** 항목 ID — 권한 체크/키 추적용 */
  id: string
  /** 표시 라벨 (이미 다국어 번역 완료) */
  label: string
  /** PrimeIcons 클래스 */
  icon: string
  /** 클릭 시 실행 함수 */
  command: () => void | Promise<void>
  /** 비활성 여부 (권한 enabled=false일 때 true) */
  disabled?: boolean
}

/** 지원되는 프리셋 이름 */
export type QuickActionPreset = 'refresh' | 'excel' | 'print' | 'copyRow' | 'scrollTop'

/** buildActions에 넘기는 설정 한 개 */
export interface QuickActionSpec {
  /** fw_page_item.item_id와 일치 — 권한 필터 기준 */
  id: string
  /** 프리셋 이름 */
  preset: QuickActionPreset
  /** refresh/excel 프리셋에서 사용할 실행 함수 */
  run?: () => void | Promise<void>
  /** 프리셋별 추가 인자 */
  args?: {
    /** copyRow 프리셋: 선택 행을 반환하는 getter */
    getRow?: () => Record<string, unknown> | null | undefined
    /** scrollTop 프리셋: 스크롤 대상 셀렉터 (미지정 시 window) */
    selector?: string
  }
  /** 라벨 오버라이드 (프리셋 기본 라벨 대체) */
  label?: string
  /** 아이콘 오버라이드 (프리셋 기본 아이콘 대체) */
  icon?: string
}

/**
 * 프리셋별 기본 라벨/아이콘 정의
 * 라벨은 fw_label에 등록된 키를 t()로 조회하고, 미등록이면 fallback 한글 사용
 */
const PRESET_META: Record<QuickActionPreset, { labelKey: string; labelKo: string; icon: string }> = {
  refresh:   { labelKey: 'BTN_REFRESH',    labelKo: '새로고침',       icon: 'pi pi-refresh' },
  excel:     { labelKey: 'BTN_EXCEL_DOWN', labelKo: '엑셀 다운로드',  icon: 'pi pi-file-excel' },
  print:     { labelKey: 'BTN_PRINT',      labelKo: '인쇄',           icon: 'pi pi-print' },
  copyRow:   { labelKey: 'BTN_COPY_ROW',   labelKo: '선택행 복사',    icon: 'pi pi-copy' },
  scrollTop: { labelKey: 'BTN_SCROLL_TOP', labelKo: '맨 위로',        icon: 'pi pi-arrow-up' },
}

/**
 * SpeedDial 공용 액션 훅
 *
 * @param menuId fw_menu.menu_id (예: 'customer-list') — 권한 조회 기준
 * @returns buildActions: spec 배열을 받아 QuickMenuItem[]를 ComputedRef로 반환
 */
export function useQuickActions(menuId: string) {
  const itemPerm = useItemPermission(menuId)
  const $msg = useMessage()

  /**
   * 프리셋 → 실행 함수 해석
   * refresh/excel은 사용자가 넘긴 run을, 나머지는 내장 동작을 사용한다.
   */
  function resolveCommand(spec: QuickActionSpec): () => void | Promise<void> {
    switch (spec.preset) {
      case 'refresh':
      case 'excel':
        // 페이지별 fn_search / fn_export를 그대로 주입
        return async () => { await spec.run?.() }

      case 'print':
        return () => { window.print() }

      case 'copyRow':
        return async () => {
          const row = spec.args?.getRow?.()
          if (!row) {
            $msg.warn(t('MSG_SELECT_ROW_FIRST', '먼저 행을 선택해주세요.'))
            return
          }
          const json = JSON.stringify(row, null, 2)
          try {
            if (navigator.clipboard?.writeText) {
              await navigator.clipboard.writeText(json)
            } else {
              // 레거시 폴백 — execCommand 경로
              const ta = document.createElement('textarea')
              ta.value = json
              document.body.appendChild(ta)
              ta.select()
              document.execCommand('copy')
              document.body.removeChild(ta)
            }
            $msg.success(t('MSG_COPY_SUCCESS', '클립보드에 복사되었습니다.'))
          } catch {
            $msg.warn(t('MSG_COPY_FAIL', '클립보드 복사에 실패했습니다.'))
          }
        }

      case 'scrollTop':
        return () => {
          const selector = spec.args?.selector
          const el = selector ? (document.querySelector(selector) as HTMLElement | null) : null
          if (el) {
            el.scrollTo({ top: 0, behavior: 'smooth' })
          } else {
            window.scrollTo({ top: 0, behavior: 'smooth' })
          }
        }
    }
  }

  /**
   * spec 배열 → QuickMenuItem[] (권한 필터링 포함)
   * visible=false 항목은 제거, enabled=false 항목은 disabled=true로 표시된다.
   */
  function buildActions(specs: QuickActionSpec[]): ComputedRef<QuickMenuItem[]> {
    return computed(() => {
      const result: QuickMenuItem[] = []
      for (const spec of specs) {
        const perm = itemPerm(spec.id)
        if (!perm.visible) continue   // 숨김 처리

        const meta = PRESET_META[spec.preset]
        const label = spec.label ?? t(meta.labelKey, meta.labelKo)
        const icon = spec.icon ?? meta.icon

        result.push({
          id: spec.id,
          label,
          icon,
          command: resolveCommand(spec),
          disabled: !perm.enabled,
        })
      }
      return result
    })
  }

  return { buildActions }
}
