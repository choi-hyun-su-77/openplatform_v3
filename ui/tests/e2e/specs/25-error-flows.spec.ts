import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-ERR', () => {
  test('TC-ERR-403-PAGE-RENDER — /403 진입 시 페이지 라벨 i18n', async ({ page }) => {
    await page.goto('/403')
    await expect(page.locator('.forbidden-page h2')).toHaveText(await L('LBL_FORBIDDEN', 'ko'))
    await expect(page.locator('.forbidden-page p')).toContainText(await L('LBL_FORBIDDEN_DETAIL', 'ko'))
  })
  test('TC-ERR-403-BTN-DASHBOARD — [대시보드로 이동] 버튼 클릭 → /dashboard', async ({ page }) => {
    await page.goto('/403')
    await page.locator('.forbidden-page button', { hasText: await L('BTN_GO_DASHBOARD', 'ko') }).click()
    await expect(page).toHaveURL(/\/dashboard$/)
  })
  test('TC-ERR-NETWORK-01-INVALID-DATASET — 잘못된 serviceName 호출 시 4xx/5xx 응답', async ({ request, page }) => {
    // 토큰 부착 안 함 — backend-core 에서 401 또는 400 반환
    const r = await request.post('http://localhost:19090/api/dataset/search', {
      data: { serviceName: 'nonexistent/none', datasets: {} }
    })
    expect([400, 401, 403, 404, 500]).toContain(r.status())
  })
})
