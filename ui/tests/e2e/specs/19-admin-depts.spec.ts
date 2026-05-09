import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-ADM-DEPT', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/admin/depts') })

  test('TC-ADM-DEPT-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_ADMIN_DEPTS', 'ko'))
  })
  test('TC-ADM-DEPT-LIST-02-TREE — 트리 표시', async ({ page }) => {
    await expect(page.locator('.tree-panel .p-tree')).toBeVisible({ timeout: 10_000 })
  })
  test('TC-ADM-DEPT-CREATE-01-NEW-FORM — [루트 추가] → 새 부서 폼', async ({ page }) => {
    await page.locator('button', { hasText: await L('BTN_ADD_ROOT', 'ko') }).click()
    await expect(page.locator('.edit-panel h3')).toContainText(await L('LBL_DEPT_NEW', 'ko'))
  })
  test('TC-ADM-DEPT-CREATE-02-VALIDATION — 필수값 누락 시 toast', async ({ page }) => {
    await page.locator('button', { hasText: await L('BTN_ADD_ROOT', 'ko') }).click()
    await page.locator('button', { hasText: await L('BTN_SAVE', 'ko') }).click()
    await expect(page.locator('.p-toast-message-text')).toContainText(await L('MSG_DEPT_REQ', 'ko'))
  })
})
