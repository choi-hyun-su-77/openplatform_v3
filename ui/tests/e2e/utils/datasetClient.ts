import type { APIRequestContext, BrowserContext } from '@playwright/test'

/**
 * /api/dataset/* 직접 호출 헬퍼.
 *
 * spec 의 beforeAll/afterAll 에서 테스트 데이터 생성/정리에 사용.
 * 인증 토큰은 페이지의 keycloak.token 을 사용 — context.request 가 storageState 의 쿠키/스토리지를 공유하지 않으므로
 * page.evaluate 로 토큰을 추출하여 Authorization 헤더에 부착한다.
 */

const CORE_BASE = process.env.E2E_CORE_URL || 'http://localhost:19090'
const BFF_BASE = process.env.E2E_BFF_URL || 'http://localhost:19091'

export async function getKeycloakToken(context: BrowserContext): Promise<string> {
  const page = context.pages()[0] || (await context.newPage())
  const token = await page.evaluate(() => {
    const t = (window as any).__kc?.token
    if (t) return t
    // keycloak-js 내부 storage
    return localStorage.getItem('kc-token') || ''
  })
  return token || ''
}

export interface DataSetOptions {
  serviceName: string
  datasets?: Record<string, any>
}

export async function dataSetSearch(request: APIRequestContext, opts: DataSetOptions, token?: string) {
  const r = await request.post(CORE_BASE + '/api/dataset/search', {
    headers: token ? { Authorization: 'Bearer ' + token } : undefined,
    data: { serviceName: opts.serviceName, datasets: opts.datasets || {} }
  })
  if (!r.ok()) throw new Error(`dataset/search ${opts.serviceName} ${r.status()} ${await r.text()}`)
  return r.json()
}

export async function dataSetSave(request: APIRequestContext, opts: DataSetOptions, token?: string) {
  const r = await request.post(CORE_BASE + '/api/dataset/save', {
    headers: token ? { Authorization: 'Bearer ' + token } : undefined,
    data: { serviceName: opts.serviceName, datasets: opts.datasets || {} }
  })
  if (!r.ok()) throw new Error(`dataset/save ${opts.serviceName} ${r.status()} ${await r.text()}`)
  return r.json()
}

export const E2E_PREFIX = '_e2e_'

export { CORE_BASE, BFF_BASE }
