import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-NOT — 알림설정', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/settings/notify') })

  test('TC-NOT-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_NOTIFY_SETTINGS', 'ko'))
  })
  test('TC-NOT-LIST-02-NOTE — 안내 문구 i18n', async ({ page }) => {
    await expect(page.locator('p.note')).toContainText(await L('LBL_NOTIFY_NOTE', 'ko'))
  })
  test('TC-NOT-LIST-03-RESET-BTN — [기본값으로] 버튼 i18n', async ({ page }) => {
    await expect(page.locator('.header-actions button').first()).toContainText(await L('BTN_RESET_DEFAULT', 'ko'))
  })
})

test.describe('TC-FAV — 즐겨찾기', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/settings/favorites') })

  test('TC-FAV-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_FAVORITES_TITLE', 'ko'))
  })
  test('TC-FAV-LIST-02-ADD-BTN — [추가] 버튼 i18n', async ({ page }) => {
    await expect(page.locator('.page-header button').first()).toContainText(await L('BTN_ADD', 'ko'))
  })
})
