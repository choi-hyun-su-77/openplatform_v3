import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-ADM-MENU', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/admin/menus') })

  test('TC-ADM-MENU-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_ADMIN_MENUS', 'ko'))
  })
  test('TC-ADM-MENU-LIST-02-TREE — 트리 표시', async ({ page }) => {
    await expect(page.locator('.tree-panel .p-tree')).toBeVisible({ timeout: 10_000 })
  })
  test('TC-ADM-MENU-LIST-03-MATRIX-HEADER — 권한 매트릭스 라벨', async ({ page }) => {
    await expect(page.locator('.right-panel h3').last()).toHaveText(await L('LBL_MENU_PERM_MATRIX', 'ko'))
  })
  test('TC-ADM-MENU-CREATE-01-NEW-FORM — [새 메뉴] → 새 메뉴 폼', async ({ page }) => {
    await page.locator('button', { hasText: await L('BTN_NEW_MENU', 'ko') }).click()
    await expect(page.locator('.right-panel h3').first()).toContainText(await L('LBL_MENU_NEW', 'ko'))
  })
  test('TC-ADM-MENU-CREATE-02-VALIDATION — 필수값 누락 시 toast', async ({ page }) => {
    await page.locator('button', { hasText: await L('BTN_NEW_MENU', 'ko') }).click()
    await page.locator('.actions button', { hasText: await L('BTN_SAVE', 'ko') }).click()
    await expect(page.locator('.p-toast-message-text')).toContainText(await L('MSG_MENU_REQ', 'ko'))
  })
})
