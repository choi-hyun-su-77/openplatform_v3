import { test, expect } from '../fixtures/auth.fixture'

/**
 * TC-AUTH — 인증 / 대시보드 진입
 * fixture 가 dashboard 부터 시작하므로 케이스는 사이드바 / 라벨 API 검증.
 */

test.describe('TC-AUTH', () => {
  test('TC-AUTH-NAV-01-HAPPY — fixture 가 dashboard 정착', async ({ page }) => {
    await expect(page).toHaveURL(/\/dashboard$/)
  })

  test('TC-AUTH-SIDEBAR-01-MENUS-LOADED — 사이드바에 1개 이상의 menu-label', async ({ page }) => {
    const count = await page.locator('.layout-sidebar .menu-label').count()
    expect(count).toBeGreaterThan(0)
  })

  test('TC-AUTH-LABELS-01-API-200 — /api/labels?locale=ko 응답에 핵심 키가 포함', async ({ request }) => {
    const r = await request.get((process.env.E2E_CORE_URL || 'http://localhost:19090') + '/api/labels?locale=ko')
    expect(r.status()).toBe(200)
    const j = await r.json()
    expect(j.success).toBeTruthy()
    expect(j.data).toBeTruthy()
    expect(j.data['LBL_PAGE_APPROVAL']).toBe('전자결재')
    expect(j.data['MENU_ATTENDANCE']).toBe('근태')
    expect(j.data['BTN_SAVE']).toBe('저장')
  })
})
