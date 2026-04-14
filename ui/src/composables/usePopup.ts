/**
 * ============================================================================
 * usePopup.ts — 팝업(모달/모달리스) 관리 컴포저블
 * ============================================================================
 *
 * 【역할】
 *   동적 컴포넌트 기반의 팝업을 스택으로 관리한다.
 *   모달(modal)과 모달리스(modeless) 모드를 지원하며,
 *   팝업 오픈 시 Promise를 반환하여 닫힐 때 결과값을 받을 수 있다.
 *
 * 【아키텍처】
 *   - popupStack: 전역 ref 배열 — 열린 팝업을 스택으로 관리 (중첩 팝업 지원)
 *   - open(): 팝업을 스택에 추가하고 Promise 반환
 *   - close(): 최상위 팝업을 닫고 결과값으로 Promise resolve
 *
 * 【사용 예시 — 팝업 호출 측】
 *   const { open } = usePopup()
 *
 *   const result = await open({
 *     id: 'customerSearch',
 *     component: PopupCustomerSearch,
 *     title: '고객 검색',
 *     width: '800px',
 *     params: { customerType: 'VIP' }
 *   })
 *   // result = 팝업에서 close()로 전달한 값
 *
 * 【사용 예시 — 팝업 내부 컴포넌트】
 *   const { getParams, close } = usePopupContext()
 *   const params = getParams(props)          // 전달받은 파라미터
 *   close(props, selectedCustomer)           // 결과값과 함께 닫기
 */

import { ref, markRaw, type Component } from 'vue'

/**
 * 팝업 오픈 설정
 */
interface PopupConfig {
  /** 팝업 식별자 (중복 방지 및 스택 조회용) */
  id: string
  /** 팝업에 렌더링할 Vue 컴포넌트 */
  component: Component
  /** 팝업 제목 (다이얼로그 헤더) */
  title?: string
  /** 팝업 너비 (CSS 값, 기본: '700px') */
  width?: string
  /** 팝업 높이 (CSS 값, 기본: 'auto') */
  height?: string
  /** 모달 여부 (true=모달(기본), false=모달리스) */
  modal?: boolean
  /** 팝업 컴포넌트에 전달할 파라미터 */
  params?: Record<string, unknown>
  /** 팝업 닫힐 때 호출되는 콜백 */
  onClose?: (result: unknown) => void
}

/**
 * 팝업 스택 항목 (내부용)
 */
interface PopupInstance {
  /** 팝업 식별자 */
  id: string
  /** 렌더링할 컴포넌트 (markRaw 처리됨) */
  component: Component
  /** 팝업 제목 */
  title: string
  /** 팝업 너비 */
  width: string
  /** 팝업 높이 */
  height: string
  /** 모달 여부 */
  modal: boolean
  /** 팝업 컴포넌트에 전달된 파라미터 */
  params: Record<string, unknown>
  /** 표시 여부 */
  visible: boolean
  /** 팝업 닫기 함수 — close() 호출 시 result를 받아 Promise를 resolve */
  resolve: (value: unknown) => void
}

/**
 * 전역 팝업 스택 — 열린 팝업을 순서대로 관리 (중첩 팝업 지원)
 * LayoutDefault에서 이 스택을 순회하며 팝업 다이얼로그를 렌더링
 */
const popupStack = ref<PopupInstance[]>([])

/**
 * 팝업 스택 접근자 (레이아웃 컴포넌트에서 사용)
 *
 * @returns 전역 팝업 스택 Ref
 */
export function getPopupStack() {
  return popupStack
}

/**
 * 팝업 관리 컴포저블 (팝업 호출 측에서 사용)
 *
 * @returns { open, close }
 */
export function usePopup() {
  /**
   * 팝업 열기
   *
   * 동작 흐름:
   * 1. PopupInstance를 생성하여 popupStack에 추가
   * 2. Promise를 반환 — 팝업이 닫힐 때 resolve됨
   * 3. 컴포넌트를 markRaw()로 감싸서 Vue 반응형 시스템의 불필요한 추적 방지
   *
   * @param config - 팝업 설정
   * @returns 팝업 닫힐 때 resolve되는 Promise (result값 포함)
   */
  function open(config: PopupConfig): Promise<unknown> {
    return new Promise((resolve) => {
      const instance: PopupInstance = {
        id: config.id,
        component: markRaw(config.component),  // 반응형 추적 방지
        title: config.title || '',
        width: config.width || '700px',
        height: config.height || 'auto',
        modal: config.modal !== false,  // 기본값 true (모달)
        params: config.params || {},
        visible: true,
        resolve: (result: unknown) => {
          // 스택에서 해당 팝업 제거
          const idx = popupStack.value.findIndex(p => p.id === config.id)
          if (idx >= 0) popupStack.value.splice(idx, 1)
          // onClose 콜백 실행
          if (config.onClose) config.onClose(result)
          // Promise resolve
          resolve(result)
        }
      }
      popupStack.value.push(instance)
    })
  }

  /**
   * 최상위 팝업 닫기 (팝업 내부에서 호출)
   *
   * @param result - 팝업 결과값 (호출 측의 Promise에 전달)
   */
  function close(result?: unknown) {
    // 스택의 마지막(최상위) 팝업을 닫음
    const current = popupStack.value[popupStack.value.length - 1]
    if (current) {
      current.resolve(result || null)
    }
  }

  return {
    /** 팝업 열기 — 스택에 추가하고 닫힐 때까지 대기하는 Promise 반환 */
    open,
    /** 최상위 팝업 닫기 — result를 호출 측 Promise에 전달 */
    close
  }
}

/**
 * 팝업 내부 컴포넌트용 헬퍼 컴포저블
 * 팝업 컴포넌트에서 전달받은 파라미터 접근 및 닫기 기능 제공
 *
 * @returns { getParams, close }
 *
 * @example
 * // 팝업 내부 컴포넌트
 * const { getParams, close } = usePopupContext()
 * const params = getParams(props)              // 전달받은 파라미터 조회
 * close(props, { customerId: '001' })          // 결과값과 함께 팝업 닫기
 */
export function usePopupContext() {
  return {
    /**
     * 팝업 컴포넌트에 전달된 파라미터를 props에서 추출
     *
     * @param props - 팝업 컴포넌트의 props
     * @returns 파라미터 객체
     */
    getParams: (props: Record<string, unknown>): Record<string, unknown> => {
      return (props.popupParams as Record<string, unknown>) || {}
    },
    /**
     * 팝업 닫기 (결과값 전달)
     *
     * @param props - 팝업 컴포넌트의 props (onPopupClose 콜백 포함)
     * @param result - 호출 측에 전달할 결과값
     */
    close: (props: Record<string, unknown>, result?: unknown) => {
      const onClose = props.onPopupClose as ((result: unknown) => void) | undefined
      if (onClose) onClose(result)
    }
  }
}
