import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-ATT', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/attendance') })

  test('TC-ATT-LIST-01-HAPPY — 헤딩에 근태 라벨 포함', async ({ page }) => {
    const heading = await page.getByRole('heading', { level: 2 }).first().textContent()
    expect(heading).toContain(await L('LBL_PAGE_ATTENDANCE', 'ko'))
  })
  test('TC-ATT-LIST-02-CHECK-CARD — 출퇴근 카드 표시', async ({ page }) => {
    await expect(page.locator('.check-card')).toBeVisible()
  })
  test('TC-ATT-LIST-03-MONTHLY — 월별 통계 카드', async ({ page }) => {
    await expect(page.locator('.month-card')).toBeVisible()
  })
  test('TC-ATT-LIST-04-SUMMARY — 5종 통계 항목', async ({ page }) => {
    const items = page.locator('.month-summary > div')
    await expect(items).toHaveCount(5)
  })
})
