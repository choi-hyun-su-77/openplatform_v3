/**
 * ============================================================================
 * primevueLocale.ts — PrimeVue 컴포넌트 locale 동적 적용
 * ============================================================================
 *
 * 【역할】
 *   PrimeVue Calendar/DatePicker의 요일/월 이름, dayNames, monthNames 등
 *   컴포넌트 내장 라벨을 4언어(ko/en/zh/ja)로 동적 적용한다.
 *   useLocale의 setLocale 호출 시 자동으로 PrimeVue 설정도 갱신된다.
 *
 * 【사용법】
 *   main.ts에서 PrimeVue 옵션의 locale을 PRIMEVUE_LOCALE_KO로 초기화하고,
 *   useLocale.onLocaleChange 콜백에 applyPrimeVueLocale을 등록한다.
 *
 * 【지원】
 *   - dayNames / dayNamesShort / dayNamesMin
 *   - monthNames / monthNamesShort
 *   - today / clear / weekHeader
 *   - 기타 PrimeVue 기본 라벨 (대부분 컴포넌트에 자동 적용)
 */

import type { App } from 'vue'

/** PrimeVue locale 객체 타입 */
interface PrimeVueLocaleConfig {
  startsWith?: string
  contains?: string
  notContains?: string
  endsWith?: string
  equals?: string
  notEquals?: string
  noFilter?: string
  lt?: string
  lte?: string
  gt?: string
  gte?: string
  dateIs?: string
  dateIsNot?: string
  dateBefore?: string
  dateAfter?: string
  clear?: string
  apply?: string
  matchAll?: string
  matchAny?: string
  addRule?: string
  removeRule?: string
  accept?: string
  reject?: string
  choose?: string
  upload?: string
  cancel?: string
  completed?: string
  pending?: string
  fileSizeTypes?: string[]
  dayNames?: string[]
  dayNamesShort?: string[]
  dayNamesMin?: string[]
  monthNames?: string[]
  monthNamesShort?: string[]
  chooseYear?: string
  chooseMonth?: string
  chooseDate?: string
  prevDecade?: string
  nextDecade?: string
  prevYear?: string
  nextYear?: string
  prevMonth?: string
  nextMonth?: string
  prevHour?: string
  nextHour?: string
  prevMinute?: string
  nextMinute?: string
  prevSecond?: string
  nextSecond?: string
  am?: string
  pm?: string
  today?: string
  weekHeader?: string
  firstDayOfWeek?: number
  dateFormat?: string
}

/** 한국어 로케일 */
export const PRIMEVUE_LOCALE_KO: PrimeVueLocaleConfig = {
  accept: '예',
  reject: '아니오',
  choose: '선택',
  upload: '업로드',
  cancel: '취소',
  clear: '지우기',
  apply: '적용',
  today: '오늘',
  dayNames: ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'],
  dayNamesShort: ['일', '월', '화', '수', '목', '금', '토'],
  dayNamesMin: ['일', '월', '화', '수', '목', '금', '토'],
  monthNames: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
  monthNamesShort: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
  chooseYear: '연도 선택',
  chooseMonth: '월 선택',
  chooseDate: '날짜 선택',
  weekHeader: '주',
  firstDayOfWeek: 0,
  dateFormat: 'yy-mm-dd',
  am: '오전',
  pm: '오후'
}

/** 영어 로케일 (PrimeVue 기본값과 동일) */
export const PRIMEVUE_LOCALE_EN: PrimeVueLocaleConfig = {
  accept: 'Yes',
  reject: 'No',
  choose: 'Choose',
  upload: 'Upload',
  cancel: 'Cancel',
  clear: 'Clear',
  apply: 'Apply',
  today: 'Today',
  dayNames: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  dayNamesShort: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
  dayNamesMin: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
  monthNames: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  monthNamesShort: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  chooseYear: 'Choose Year',
  chooseMonth: 'Choose Month',
  chooseDate: 'Choose Date',
  weekHeader: 'Wk',
  firstDayOfWeek: 0,
  dateFormat: 'yy-mm-dd',
  am: 'AM',
  pm: 'PM'
}

/** 중국어 간체 로케일 */
export const PRIMEVUE_LOCALE_ZH: PrimeVueLocaleConfig = {
  accept: '是',
  reject: '否',
  choose: '选择',
  upload: '上传',
  cancel: '取消',
  clear: '清除',
  apply: '应用',
  today: '今天',
  dayNames: ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'],
  dayNamesShort: ['周日', '周一', '周二', '周三', '周四', '周五', '周六'],
  dayNamesMin: ['日', '一', '二', '三', '四', '五', '六'],
  monthNames: ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'],
  monthNamesShort: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
  chooseYear: '选择年份',
  chooseMonth: '选择月份',
  chooseDate: '选择日期',
  weekHeader: '周',
  firstDayOfWeek: 0,
  dateFormat: 'yy-mm-dd',
  am: '上午',
  pm: '下午'
}

/** 일본어 로케일 */
export const PRIMEVUE_LOCALE_JA: PrimeVueLocaleConfig = {
  accept: 'はい',
  reject: 'いいえ',
  choose: '選択',
  upload: 'アップロード',
  cancel: 'キャンセル',
  clear: 'クリア',
  apply: '適用',
  today: '今日',
  dayNames: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
  dayNamesShort: ['日', '月', '火', '水', '木', '金', '土'],
  dayNamesMin: ['日', '月', '火', '水', '木', '金', '土'],
  monthNames: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
  monthNamesShort: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
  chooseYear: '年を選択',
  chooseMonth: '月を選択',
  chooseDate: '日付を選択',
  weekHeader: '週',
  firstDayOfWeek: 0,
  dateFormat: 'yy-mm-dd',
  am: '午前',
  pm: '午後'
}

/** locale → PrimeVue locale config 매핑 */
export const PRIMEVUE_LOCALE_MAP: Record<string, PrimeVueLocaleConfig> = {
  ko: PRIMEVUE_LOCALE_KO,
  en: PRIMEVUE_LOCALE_EN,
  zh: PRIMEVUE_LOCALE_ZH,
  ja: PRIMEVUE_LOCALE_JA
}

/** locale에 맞는 PrimeVue locale config 반환 (미지원이면 ko) */
export function getPrimeVueLocale(locale: string): PrimeVueLocaleConfig {
  return PRIMEVUE_LOCALE_MAP[locale] || PRIMEVUE_LOCALE_KO
}

/**
 * Vue 앱이 마운트된 후 PrimeVue locale을 동적으로 갱신한다.
 *
 * Vue3 + PrimeVue v4에서는 app.config.globalProperties.$primevue.config.locale을
 * 직접 수정하면 모든 PrimeVue 컴포넌트에 즉시 반영된다.
 */
export function applyPrimeVueLocale(app: App, locale: string): void {
  const cfg = (app.config.globalProperties.$primevue?.config) as { locale?: PrimeVueLocaleConfig } | undefined
  if (cfg && cfg.locale) {
    Object.assign(cfg.locale, getPrimeVueLocale(locale))
  }
}
