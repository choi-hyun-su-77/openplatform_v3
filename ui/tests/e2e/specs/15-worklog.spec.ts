import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-WLG', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/worklog') })

  test('TC-WLG-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    const heading = await page.getByRole('heading', { level: 2 }).first().textContent()
    expect(heading).toContain(await L('LBL_PAGE_WORKLOG', 'ko'))
  })
  test('TC-WLG-LIST-02-CALENDAR-PANE — 캘린더 패널 i18n', async ({ page }) => {
    await expect(page.locator('.cal-pane .pane-title')).toHaveText(await L('LBL_WORKLOG_CALENDAR', 'ko'))
  })
})
