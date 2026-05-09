import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-CAL', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/calendar') })

  test('TC-CAL-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_CALENDAR', 'ko'))
  })
  test('TC-CAL-LIST-02-FULLCAL-RENDERED — FullCalendar 마운트', async ({ page }) => {
    await expect(page.locator('.fc')).toBeVisible({ timeout: 15_000 })
  })
  test('TC-CAL-CREATE-01-DIALOG-OPEN — [일정 추가] → CalendarEventDialog OPEN', async ({ page }) => {
    await page.locator('.filters button', { hasText: await L('BTN_NEW_EVENT', 'ko') }).click()
    await expect(page.locator('.p-dialog .p-dialog-title')).toHaveText(await L('LBL_CAL_EVENT_NEW', 'ko'))
  })
  test('TC-CAL-CREATE-02-CANCEL — 취소 시 다이얼로그 close', async ({ page }) => {
    await page.locator('.filters button', { hasText: await L('BTN_NEW_EVENT', 'ko') }).click()
    await page.locator('.p-dialog button', { hasText: await L('BTN_CANCEL', 'ko') }).click()
    await expect(page.locator('.p-dialog')).toBeHidden()
  })
  test('TC-CAL-FILTER-01-SELECT — 범위 SelectButton 클릭 가능', async ({ page }) => {
    const opts = page.locator('.p-selectbutton .p-togglebutton')
    await expect(opts).toHaveCount(4)
  })
})
