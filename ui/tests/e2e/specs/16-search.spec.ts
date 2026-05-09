import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-SCH', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/search') })

  test('TC-SCH-LIST-01-PLACEHOLDER — i18n 검색 placeholder', async ({ page }) => {
    const ph = await page.locator('.search-toolbar input').first().getAttribute('placeholder')
    expect(ph).toBe(await L('PH_GLOBAL_SEARCH', 'ko'))
  })
  test('TC-SCH-LIST-02-FILTER-LABELS — 도메인 4종 라벨 표시', async ({ page }) => {
    for (const k of ['LBL_SEARCH_POST', 'LBL_SEARCH_DOC', 'LBL_SEARCH_EMP', 'LBL_SEARCH_FILE']) {
      await expect(page.locator('.filter-group')).toContainText(await L(k, 'ko'))
    }
  })
  test('TC-SCH-LIST-03-SEARCH-BUTTON — 검색 버튼 i18n', async ({ page }) => {
    await expect(page.locator('.search-toolbar button').first()).toContainText(await L('BTN_SEARCH', 'ko'))
  })
})
