/**
 * E2E 어서션에서 화면의 한국어 라벨을 직접 검증하는 대신,
 * cm_i18n_message 의 ko 라벨을 가져와 비교한다.
 * 이렇게 하면 영문/중문/일문 토글에서도 동일 spec 으로 검증할 수 있다.
 */

const cache = new Map<string, Map<string, string>>()
const CORE_BASE = process.env.E2E_CORE_URL || 'http://localhost:19090'

export async function loadLabels(locale: 'ko' | 'en' | 'zh' | 'ja' = 'ko'): Promise<Map<string, string>> {
  if (cache.has(locale)) return cache.get(locale)!
  const res = await fetch(CORE_BASE + '/api/labels?locale=' + locale)
  const j: any = await res.json()
  const m = new Map<string, string>()
  if (j?.data) {
    for (const [k, v] of Object.entries(j.data)) m.set(k, String(v))
  }
  cache.set(locale, m)
  return m
}

export async function L(key: string, locale: 'ko' | 'en' | 'zh' | 'ja' = 'ko'): Promise<string> {
  const m = await loadLabels(locale)
  return m.get(key) || key
}
