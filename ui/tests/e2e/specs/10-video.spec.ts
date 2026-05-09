import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-VID', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/video') })

  test('TC-VID-LIST-01-HAPPY — 헤딩에 화상회의 라벨 포함', async ({ page }) => {
    const heading = await page.getByRole('heading', { level: 2 }).first().textContent()
    expect(heading).toContain(await L('LBL_PAGE_VIDEO', 'ko'))
  })
})
