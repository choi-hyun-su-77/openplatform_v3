import { test as base, expect, type BrowserContext, type Page } from '@playwright/test'

const KC_USER = process.env.E2E_KC_USER || 'admin'
const KC_PASSWORD = process.env.E2E_KC_PASSWORD || 'admin'
const BASE = process.env.E2E_BASE_URL || 'http://localhost:25174'

/**
 * 인증 fixture — worker-scoped 컨텍스트 공유.
 *
 * 워커 시작 시 KC 로그인 1회. 매 test 에 새 page 발급.
 * page 는 dashboard 부터 시작하여 SPA 내 navigation (sidebar 클릭) 으로 안정화.
 *
 * 추가 helper: `gotoMenu(page, path)` — full reload 대신 sidebar 클릭으로 이동 (router 의
 * Pinia store 초기화 race condition 회피).
 */
type WorkerFixtures = {
  authenticatedContext: BrowserContext
}

export const test = base.extend<{}, WorkerFixtures>({
  authenticatedContext: [
    async ({ browser }, use) => {
      const context = await browser.newContext({
        baseURL: BASE,
        locale: 'ko-KR',
        timezoneId: 'Asia/Seoul'
      })
      const page = await context.newPage()
      await ensureLoggedIn(page)
      await page.close()
      await use(context)
      await context.close()
    },
    { scope: 'worker' }
  ],
  page: async ({ authenticatedContext }, use) => {
    const page = await authenticatedContext.newPage()
    // 매 test 의 page 는 dashboard 부터 시작 — SPA navigation 의 출발점.
    await page.goto(BASE + '/dashboard', { waitUntil: 'domcontentloaded' })
    await page.waitForSelector('.layout-sidebar', { timeout: 30_000 })
    await use(page)
    await page.close()
  }
})

export { expect }

async function ensureLoggedIn(page: Page): Promise<void> {
  await page.goto(BASE + '/login', { waitUntil: 'domcontentloaded' })
  await page.waitForLoadState('networkidle').catch(() => {})

  if (/\/dashboard(\?|$)/.test(page.url())) {
    await page.waitForSelector('.layout-sidebar', { timeout: 15_000 })
    return
  }

  const loginBtn = page.locator('button:has-text("Keycloak")')
  await expect(loginBtn).toBeVisible({ timeout: 10_000 })
  await Promise.all([
    page.waitForURL(
      (u: any) => u.toString().includes('openid-connect/auth') || u.toString().startsWith(BASE + '/dashboard'),
      { timeout: 30_000 }
    ),
    loginBtn.click()
  ])

  if (page.url().includes('openid-connect/auth')) {
    await page.fill('#username', KC_USER)
    await page.fill('#password', KC_PASSWORD)
    await Promise.all([
      page.waitForURL((u: any) => u.toString().startsWith(BASE), { timeout: 30_000 }),
      page.click('#kc-login')
    ])
  }

  await page.waitForURL(BASE + '/dashboard', { timeout: 30_000 }).catch(() => {})
  await page.waitForSelector('.layout-sidebar', { timeout: 30_000 })
}

/**
 * SPA 내 navigation — sidebar 메뉴 클릭으로 path 이동.
 *
 * full page.goto 는 Pinia store 초기화 race condition (auth 미로드 → /login → /dashboard) 으로 불안정하므로,
 * 모든 spec 은 본 helper 로 이동한다. 자식 메뉴는 부모 그룹을 자동 expand.
 */
const PATH_TO_KO: Record<string, { label: RegExp; parent?: RegExp }> = {
  '/dashboard': { label: /^대시보드$/ },
  '/approval':  { label: /^전자결재$/ },
  '/board':     { label: /^게시판$/ },
  '/calendar':  { label: /^캘린더$/ },
  '/org':       { label: /^조직도$/ },
  '/messenger': { label: /^메신저$/ },
  '/mail':      { label: /^메일$/ },
  '/wiki':      { label: /^위키$/ },
  '/video':     { label: /^화상회의$/ },
  '/search':    { label: /^통합검색$/ },
  '/attendance': { label: /^근태$/, parent: /^내 업무$/ },
  '/leave':      { label: /^연차\/휴가$/, parent: /^내 업무$/ },
  '/worklog':    { label: /^업무일지$/, parent: /^내 업무$/ },
  '/room':       { label: /^회의실예약$/, parent: /^업무$/ },
  '/datalib':    { label: /^자료실$/, parent: /^업무$/ },
  '/settings/notify':    { label: /^알림설정$/, parent: /^설정$/ },
  '/settings/favorites': { label: /^즐겨찾기$/, parent: /^설정$/ },
  '/admin/users': { label: /^사용자관리$/, parent: /^시스템관리$/ },
  '/admin/depts': { label: /^조직관리$/, parent: /^시스템관리$/ },
  '/admin/menus': { label: /^메뉴관리$/, parent: /^시스템관리$/ },
  '/admin/codes': { label: /^공통코드$/, parent: /^시스템관리$/ },
  '/admin/audit': { label: /^감사로그$/, parent: /^시스템관리$/ }
}

export async function gotoMenu(page: Page, path: string): Promise<void> {
  await page.waitForSelector('.layout-sidebar', { timeout: 10_000 })

  const cur = new URL(page.url()).pathname
  if (cur === path) return

  const m = PATH_TO_KO[path]
  if (!m) {
    // fallback: full reload
    await page.goto(BASE + path, { waitUntil: 'domcontentloaded' })
    await page.waitForLoadState('networkidle').catch(() => {})
    return
  }

  if (m.parent) {
    const parentItem = page.locator('.menu-parent', { has: page.locator('.menu-label', { hasText: m.parent }) }).first()
    if ((await parentItem.count()) > 0) {
      const expandedDown = await parentItem.locator('.menu-arrow.pi-chevron-down').count()
      if (expandedDown === 0) {
        await parentItem.click().catch(() => {})
      }
    }
  }

  const target = page.locator('.menu-label', { hasText: m.label }).first()
  await expect(target).toBeVisible({ timeout: 10_000 })
  await Promise.all([
    page.waitForURL(BASE + path, { timeout: 15_000 }),
    target.click()
  ])
  await page.waitForLoadState('networkidle').catch(() => {})
}
