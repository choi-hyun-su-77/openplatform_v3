/**
 * ============================================================================
 * useMessage.ts — 메시지/확인 다이얼로그/한글 조사 처리 컴포저블
 * ============================================================================
 *
 * 【역할】
 *   DB에 저장된 메시지(fw_message)를 ID로 조회하여 토스트/확인 다이얼로그를 표시한다.
 *   메시지 텍스트에 {key} 형태의 파라미터 치환을 지원하며,
 *   한글 조사 자동 처리(은/는, 을/를 등)를 위한 particle() 함수를 제공한다.
 *
 * 【제공 기능】
 *   - info/success/warn/error: 직접 문자열 토스트 표시
 *   - byId: DB 메시지 ID로 토스트 표시 (severity는 DB의 message_type에서 결정)
 *   - textOf: 메시지 ID의 텍스트만 반환 (검증 메시지 등에 사용)
 *   - confirmDialog: 문자열 메시지로 확인 다이얼로그 표시
 *   - confirmById: DB 메시지 ID로 확인 다이얼로그 표시
 *   - msg/msgText: MSG_ 접두사 자동 감지 (ID이면 DB 조회, 아니면 직접 표시)
 *   - particle: 한글 종성에 따른 조사 자동 선택 ("고객" + "을/를" → "고객을")
 *
 * 【메시지 캐시】
 *   앱 시작 시 /api/messages에서 전체 메시지를 로드하여 Map에 캐시.
 *   이후에는 네트워크 호출 없이 캐시에서 즉시 조회.
 *
 * 【사용 예시】
 *   const $msg = useMessage()
 *   $msg.byId('MSG_SAVE_SUCCESS')                        // DB 메시지 토스트
 *   $msg.byId('MSG_DELETE_CONFIRM', { name: '홍길동' })   // 파라미터 치환
 *   $msg.confirmById('MSG_CONFIRM_DELETE', () => { ... }) // 확인 다이얼로그
 *   $msg.warn('직접 작성한 경고 메시지')                    // 직접 문자열 토스트
 *   $msg.particle('고객', '을/를')                         // → '고객을'
 */

import { useToast } from 'primevue/usetoast'
import { useConfirm } from 'primevue/useconfirm'
import axios from 'axios'
import { getCurrentLocale, useLocale, type SupportedLocale } from './useLocale'

/**
 * DB 메시지 항목
 */
interface MessageEntry {
  /** 메시지 텍스트 (파라미터 치환 전) */
  text: string
  /** 메시지 유형 (info, success, warn, error, confirm) — 토스트 severity 결정 */
  type: string
}

/** locale별 메시지 캐시 — Map<locale, Map<messageId, MessageEntry>> */
const messageCache = new Map<SupportedLocale, Map<string, MessageEntry>>()
/** 진행 중인 로드 Promise (locale별, 중복 로딩 방지) */
const loadingPromises = new Map<SupportedLocale, Promise<void>>()

/**
 * 서버에서 특정 locale의 전체 메시지를 로드하여 캐시에 저장.
 *
 * @param locale - 로케일 (생략 시 현재 활성 로케일)
 */
async function loadMessages(locale?: SupportedLocale): Promise<void> {
  const loc = locale || getCurrentLocale()
  if (messageCache.has(loc)) return
  if (loadingPromises.has(loc)) return loadingPromises.get(loc)

  const promise = (async () => {
    try {
      const response = await axios.get(`/api/i18n/${loc}`, { params: { type: 'MSG' } })
      const map = new Map<string, MessageEntry>()
      if (response.data.success && Array.isArray(response.data.data)) {
        for (const msg of response.data.data) {
          map.set(msg.msgKey || msg.messageId, {
            text: msg.message || msg.messageText || '',
            type: msg.msgType || msg.messageType || 'MSG'
          })
        }
      }
      messageCache.set(loc, map)
    } catch (e) {
      console.warn('Messages endpoint unavailable, using empty cache:', (e as any)?.message || e)
      // 빈 캐시 설정 → 재시도 방지
      messageCache.set(loc, new Map<string, MessageEntry>())
    } finally {
      loadingPromises.delete(loc)
    }
  })()

  loadingPromises.set(loc, promise)
  return promise
}

// useLocale 변경 시 새 locale의 메시지 자동 로드
const { onLocaleChange: _onLocaleChangeMsg } = useLocale()
_onLocaleChangeMsg(async (newLocale) => {
  await loadMessages(newLocale)
})

/**
 * 캐시에서 현재 locale의 메시지를 조회하고 파라미터를 치환.
 * 미발견 시 'ko' 로케일로 폴백.
 *
 * @param messageId - 메시지 ID (예: 'MSG_SAVE_SUCCESS')
 * @param params - 치환 파라미터 (예: { name: '홍길동' } → "{name}" → "홍길동")
 * @returns 치환된 MessageEntry 또는 null(미발견)
 */
function resolveMessage(messageId: string, params?: Record<string, unknown>): MessageEntry | null {
  const loc = getCurrentLocale()
  let entry = messageCache.get(loc)?.get(messageId)
  // 폴백: 현재 locale에 없으면 'ko'에서 조회
  if (!entry && loc !== 'ko') {
    entry = messageCache.get('ko')?.get(messageId)
  }
  if (!entry) return null
  let text = entry.text
  // {key} 패턴을 파라미터 값으로 치환
  if (params) {
    for (const [key, value] of Object.entries(params)) {
      text = text.replace(new RegExp(`\\{${key}\\}`, 'g'), String(value))
    }
  }
  return { text, type: entry.type }
}

/**
 * MSG_ 접두사로 시작하는지 판별 (DB 메시지 ID 여부)
 *
 * @param str - 판별할 문자열
 * @returns true면 DB 메시지 ID
 */
function isMessageId(str: string): boolean {
  return str.startsWith('MSG_')
}

/**
 * 메시지 캐시 초기화 (전체 또는 특정 locale).
 * 메시지 관리 화면에서 저장 후 호출.
 *
 * @param locale - 비우면 모든 locale 캐시 초기화
 */
export function clearMessageCache(locale?: SupportedLocale): void {
  if (locale) {
    messageCache.delete(locale)
  } else {
    messageCache.clear()
  }
}

/**
 * 메시지 컴포저블
 *
 * @returns 토스트/확인 다이얼로그/한글 조사 유틸리티 함수 모음
 */
export function useMessage() {
  /** PrimeVue 토스트 서비스 */
  const toast = useToast()
  /** PrimeVue 확인 다이얼로그 서비스 */
  const confirm = useConfirm()

  // 컴포저블 최초 사용 시 메시지 선행 로드 (캐시 미스 방지)
  loadMessages()

  /** 메시지 유형별 토스트 제목 매핑 */
  const severityTitleMap: Record<string, string> = {
    info: '알림',
    success: '완료',
    warn: '경고',
    error: '오류',
    confirm: '확인'
  }

  /** 메시지 유형별 토스트 표시 시간(ms) 매핑 */
  const severityLifeMap: Record<string, number> = {
    info: 3000,
    success: 3000,
    warn: 5000,
    error: 5000
  }

  /**
   * severity에 따른 PrimeVue 토스트 표시 (내부용)
   *
   * @param severity - 메시지 유형 (info/success/warn/error/confirm)
   * @param message - 표시할 메시지 텍스트
   * @param title - 토스트 제목 (생략 시 severity별 기본 제목)
   */
  function showToast(severity: string, message: string, title?: string) {
    // confirm 타입은 토스트에서 info로 대체
    const toastSeverity = severity === 'confirm' ? 'info' : severity
    toast.add({
      severity: toastSeverity as 'info' | 'success' | 'warn' | 'error',
      summary: title || severityTitleMap[severity] || '알림',
      detail: message,
      life: severityLifeMap[toastSeverity] || 3000
    })
  }

  /**
   * 정보 토스트 (파란색)
   * @param message - 메시지 텍스트
   * @param title - 제목 (기본: '알림')
   */
  function info(message: string, title = '알림') {
    toast.add({ severity: 'info', summary: title, detail: message, life: 3000 })
  }

  /**
   * 성공 토스트 (초록색)
   * @param message - 메시지 텍스트
   * @param title - 제목 (기본: '완료')
   */
  function success(message: string, title = '완료') {
    toast.add({ severity: 'success', summary: title, detail: message, life: 3000 })
  }

  /**
   * 경고 토스트 (노란색)
   * @param message - 메시지 텍스트
   * @param title - 제목 (기본: '경고')
   */
  function warn(message: string, title = '경고') {
    toast.add({ severity: 'warn', summary: title, detail: message, life: 5000 })
  }

  /**
   * 에러 토스트 (빨간색)
   * @param message - 메시지 텍스트
   * @param title - 제목 (기본: '오류')
   */
  function error(message: string, title = '오류') {
    toast.add({ severity: 'error', summary: title, detail: message, life: 5000 })
  }

  /**
   * DB 메시지 ID로 토스트 표시
   * severity는 DB의 message_type 필드에서 자동 결정
   *
   * @param messageId - 메시지 ID (예: 'MSG_SAVE_SUCCESS')
   * @param params - 파라미터 치환 객체 (예: { count: 5 })
   */
  function byId(messageId: string, params?: Record<string, unknown>): void {
    const entry = resolveMessage(messageId, params)
    if (entry) {
      showToast(entry.type, entry.text)
    } else {
      // 캐시에서 찾지 못한 경우 경고로 표시
      warn(`메시지를 찾을 수 없습니다: ${messageId}`)
    }
  }

  /**
   * 메시지 ID의 텍스트만 반환 (토스트 표시 없음)
   * 검증 메시지, 확인 다이얼로그 등에서 텍스트만 필요할 때 사용
   *
   * @param messageId - 메시지 ID
   * @param params - 파라미터 치환 객체
   * @returns 메시지 텍스트 (미발견 시 messageId 자체 반환)
   */
  function textOf(messageId: string, params?: Record<string, unknown>): string {
    const entry = resolveMessage(messageId, params)
    return entry ? entry.text : messageId
  }

  /**
   * 확인 다이얼로그 표시 (직접 문자열 메시지)
   * PrimeVue ConfirmDialog 사용
   *
   * @param options - 다이얼로그 옵션
   *   - message: 표시할 메시지
   *   - header: 제목 (기본: '확인')
   *   - icon: 아이콘 (기본: 'pi pi-exclamation-triangle')
   *   - accept: 확인 클릭 시 콜백
   *   - reject: 취소 클릭 시 콜백
   */
  function confirmDialog(options: {
    message: string
    header?: string
    icon?: string
    accept: () => void
    reject?: () => void
  }) {
    confirm.require({
      message: options.message,
      header: options.header || '확인',
      icon: options.icon || 'pi pi-exclamation-triangle',
      acceptLabel: '예',
      rejectLabel: '아니오',
      accept: options.accept,
      reject: options.reject
    })
  }

  /**
   * DB 메시지 ID로 확인 다이얼로그 표시
   *
   * 오버로드:
   * 1. confirmById(messageId, accept, reject?)          — 파라미터 없이
   * 2. confirmById(messageId, params, accept, reject?)  — 파라미터 치환 포함
   *
   * @param messageId - 메시지 ID (예: 'MSG_CONFIRM_DELETE')
   * @param paramsOrAccept - 파라미터 객체 또는 accept 콜백
   * @param acceptOrReject - accept 콜백 또는 reject 콜백
   * @param rejectFn - reject 콜백
   */
  function confirmById(
    messageId: string,
    paramsOrAccept?: Record<string, unknown> | (() => void),
    acceptOrReject?: (() => void) | (() => void),
    rejectFn?: () => void
  ) {
    let params: Record<string, unknown> | undefined
    let accept: (() => void) | undefined
    let reject: (() => void) | undefined

    // 두 번째 인자가 함수이면 파라미터 없는 호출, 객체이면 파라미터 치환 호출
    if (typeof paramsOrAccept === 'function') {
      accept = paramsOrAccept
      reject = acceptOrReject as (() => void) | undefined
    } else {
      params = paramsOrAccept
      accept = acceptOrReject as (() => void) | undefined
      reject = rejectFn
    }

    const text = textOf(messageId, params)
    confirm.require({
      message: text,
      header: '확인',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: '예',
      rejectLabel: '아니오',
      accept: accept || (() => {}),
      reject
    })
  }

  /**
   * 자동 감지 토스트 — MSG_ 접두사이면 DB 조회, 아니면 직접 표시
   *
   * @param messageOrId - 메시지 ID 또는 직접 텍스트
   * @param params - 파라미터 치환 객체 (MSG_ ID인 경우에만 유효)
   */
  function msg(messageOrId: string, params?: Record<string, unknown>): void {
    if (isMessageId(messageOrId)) {
      byId(messageOrId, params)
    } else {
      info(messageOrId)
    }
  }

  /**
   * 자동 감지 텍스트 반환 — MSG_ 접두사이면 DB에서 텍스트 조회, 아니면 그대로 반환
   *
   * @param messageOrId - 메시지 ID 또는 직접 텍스트
   * @param params - 파라미터 치환 객체
   * @returns 최종 텍스트 문자열
   */
  function msgText(messageOrId: string, params?: Record<string, unknown>): string {
    if (isMessageId(messageOrId)) {
      return textOf(messageOrId, params)
    }
    return messageOrId
  }

  /**
   * 한글 종성(받침)에 따른 조사 자동 선택
   *
   * 한글 유니코드 범위(AC00~D7A3)에서 종성 유무를 판별하여
   * 올바른 조사를 자동으로 붙여준다.
   *
   * @param word - 조사를 붙일 단어 (예: '고객', '주문')
   * @param particlePair - 조사 쌍 (예: '은/는', '을/를', '이/가', '과/와', '으로/로')
   * @returns 단어 + 올바른 조사 (예: '고객을', '주문은')
   *
   * @example
   * particle('고객', '을/를')  // → '고객을' (받침 있음 → '을')
   * particle('주문', '은/는')  // → '주문은' (받침 있음 → '은')
   * particle('카드', '을/를')  // → '카드를' (받침 없음 → '를')
   */
  function particle(word: string, particlePair: string): string {
    if (!word || word.length === 0) return word + particlePair

    // 마지막 글자의 유니코드 값
    const lastChar = word.charCodeAt(word.length - 1)

    // 한글 범위(가~힣)가 아니면 조사 쌍을 그대로 붙임
    if (lastChar < 0xac00 || lastChar > 0xd7a3) return word + particlePair

    // 종성(받침) 유무 판별: (코드 - 0xAC00) % 28 === 0이면 받침 없음
    const hasJongsung = (lastChar - 0xac00) % 28 !== 0

    // 지원하는 조사 쌍 매핑: [받침 있을 때, 받침 없을 때]
    const pairs: Record<string, [string, string]> = {
      '은/는': ['은', '는'],
      '을/를': ['을', '를'],
      '이/가': ['이', '가'],
      '과/와': ['과', '와'],
      '으로/로': ['으로', '로']
    }
    const pair = pairs[particlePair]
    if (!pair) return word + particlePair

    // 종성 유무에 따라 적절한 조사 선택
    return word + (hasJongsung ? pair[0] : pair[1])
  }

  return {
    /** 정보 토스트 (파란색) — 직접 문자열 메시지 표시, life: 3000ms */
    info,
    /** 성공 토스트 (초록색) — 직접 문자열 메시지 표시, life: 3000ms */
    success,
    /** 경고 토스트 (노란색) — 직접 문자열 메시지 표시, life: 5000ms */
    warn,
    /** 에러 토스트 (빨간색) — 직접 문자열 메시지 표시, life: 5000ms */
    error,
    /** 확인 다이얼로그 — 직접 문자열 메시지, accept/reject 콜백 지정 */
    confirmDialog,
    /** DB 메시지 ID로 토스트 표시 — severity는 DB의 message_type에서 자동 결정 */
    byId,
    /** DB 메시지 ID의 텍스트만 반환 (토스트 미표시) — 검증 메시지 등에 사용 */
    textOf,
    /** DB 메시지 ID로 확인 다이얼로그 표시 — 파라미터 치환 지원 */
    confirmById,
    /** 자동 감지 토스트 — MSG_ 접두사이면 DB 조회, 아니면 직접 표시 */
    msg,
    /** 자동 감지 텍스트 반환 — MSG_ 접두사이면 DB 텍스트 조회, 아니면 그대로 반환 */
    msgText,
    /** 한글 조사 자동 선택 — 종성(받침) 유무에 따라 올바른 조사 부착 (예: '고객을', '주문은') */
    particle,
    /** 메시지 캐시 수동 로드 — 앱 시작 시 자동 호출되나, 메시지 관리 후 갱신 시 사용 */
    loadMessages
  }
}
