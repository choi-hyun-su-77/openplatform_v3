import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-ADM-CODE', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/admin/codes') })

  test('TC-ADM-CODE-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_ADMIN_CODES', 'ko'))
  })
  test('TC-ADM-CODE-LIST-02-COLUMNS — 그리드 6 컬럼', async ({ page }) => {
    const headers = page.locator('table.p-datatable-table thead th .p-datatable-column-title')
    await expect(headers).toHaveCount(6)
    await expect(headers.first()).toHaveText(await L('COL_CODE_GROUP', 'ko'))
  })
  test('TC-ADM-CODE-NEW-GROUP-01-DIALOG-OPEN — [그룹 추가] → 다이얼로그', async ({ page }) => {
    await page.locator('button', { hasText: await L('BTN_ADD_GROUP', 'ko') }).click()
    await expect(page.locator('.p-dialog .p-dialog-title')).toHaveText(await L('LBL_CODE_NEW_GROUP', 'ko'))
  })
  test('TC-ADM-CODE-NEW-GROUP-02-VALIDATION — 필수값 누락 시 toast', async ({ page }) => {
    await page.locator('button', { hasText: await L('BTN_ADD_GROUP', 'ko') }).click()
    await page.locator('.p-dialog button', { hasText: await L('BTN_ADD', 'ko') }).click()
    await expect(page.locator('.p-toast-message-text')).toContainText(await L('MSG_CODE_ALL_REQ', 'ko'))
  })
  test('TC-ADM-CODE-NEW-GROUP-03-CANCEL — 취소', async ({ page }) => {
    await page.locator('button', { hasText: await L('BTN_ADD_GROUP', 'ko') }).click()
    await page.locator('.p-dialog button', { hasText: await L('BTN_CANCEL', 'ko') }).click()
    await expect(page.locator('.p-dialog')).toBeHidden()
  })
})
