import { test as setup, expect } from '@playwright/test'
import path from 'node:path'
import fs from 'node:fs'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

/**
 * 인증 글로벌 셋업.
 *
 * Keycloak admin/admin 계정으로 PKCE 흐름을 통해 1회 로그인하고,
 * accessToken 을 keycloak-js 가 사용하는 storage 에 시드한 뒤
 * tests/e2e/.auth/user.json 에 페이지의 storageState 를 저장한다.
 *
 * directAccessGrantsEnabled=false 운영 정책 하에서도 동작하도록
 * 실제 브라우저 로그인 폼을 거친다.
 *
 * 이미 .auth/user.json 이 있고 5분 이내에 갱신됐으면 스킵 (캐시 재사용).
 */

const AUTH_FILE = path.join(__dirname, '.auth', 'user.json')
const KC_USER = process.env.E2E_KC_USER || 'admin'
const KC_PASSWORD = process.env.E2E_KC_PASSWORD || 'admin'
const BASE_URL = process.env.E2E_BASE_URL || 'http://localhost:25174'
const CACHE_TTL_MS = 5 * 60 * 1000

setup('authenticate keycloak', async ({ page }) => {
  // 캐시가 신선하면 스킵
  if (fs.existsSync(AUTH_FILE)) {
    const stat = fs.statSync(AUTH_FILE)
    if (Date.now() - stat.mtimeMs < CACHE_TTL_MS) {
      console.log(`[setup] storageState cache fresh (${Math.round((Date.now() - stat.mtimeMs) / 1000)}s old) — skip login`)
      return
    }
  }

  await page.goto(BASE_URL + '/dashboard', { waitUntil: 'domcontentloaded' })

  // 1) Keycloak silent SSO check 가 login_required 면 /login 으로 redirect 됨.
  //    PageLogin 의 [Keycloak으로 로그인] 버튼을 클릭하여 명시적 로그인 흐름 시작.
  await page.waitForLoadState('networkidle')
  if (/\/login/.test(page.url())) {
    const loginBtn = page.locator('button', { hasText: /Keycloak/i })
    if (await loginBtn.count()) {
      await loginBtn.first().click()
    }
  }

  // 2) Keycloak 로그인 폼 대기 → 자격 입력 → 제출
  await page.waitForURL(url => url.toString().includes('/realms/openplatform-v3/protocol/openid-connect/auth'), { timeout: 30_000 })
  await page.fill('#username', KC_USER)
  await page.fill('#password', KC_PASSWORD)
  await Promise.all([
    page.waitForURL(url => url.toString().startsWith(BASE_URL), { timeout: 30_000 }),
    page.click('#kc-login')
  ])

  // 3) 대시보드 로드 대기
  await expect(page.locator('.layout-sidebar')).toBeVisible({ timeout: 30_000 })

  // storageState 저장
  fs.mkdirSync(path.dirname(AUTH_FILE), { recursive: true })
  await page.context().storageState({ path: AUTH_FILE })
  console.log(`[setup] storageState saved → ${AUTH_FILE}`)
})
