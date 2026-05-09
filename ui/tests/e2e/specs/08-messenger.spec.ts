import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-MSG', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/messenger') })

  test('TC-MSG-LIST-01-HAPPY — 헤딩에 메신저 라벨 포함', async ({ page }) => {
    const heading = await page.getByRole('heading', { level: 2 }).first().textContent()
    expect(heading).toContain(await L('LBL_PAGE_MESSENGER', 'ko'))
  })
})
