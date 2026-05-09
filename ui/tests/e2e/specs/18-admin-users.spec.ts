import { test, expect } from '../fixtures/auth.fixture'
import { UsersPage } from '../pages/admin/UsersPage'
import { L } from '../utils/labels'

test.describe('TC-ADM-USR — 사용자 관리', () => {
  test.beforeEach(async ({ page }) => {
    await new UsersPage(page).goto()
  })

  test('TC-ADM-USR-LIST-01-HAPPY — 페이지 진입 + 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_ADMIN_USERS', 'ko'))
  })

  test('TC-ADM-USR-LIST-02-COLUMNS — 8 컬럼 헤더 i18n', async ({ page }) => {
    const headers = page.locator('table.p-datatable-table thead th .p-datatable-column-title')
    await expect(headers).toHaveCount(8)
    await expect(headers.first()).toHaveText(await L('COL_USER_NO', 'ko'))
  })

  test('TC-ADM-USR-CREATE-01-DIALOG-OPEN — [추가] 클릭 → 새 사용자 다이얼로그', async ({ page }) => {
    const up = new UsersPage(page)
    await up.openCreate()
    await expect(page.locator('.p-dialog .p-dialog-title')).toHaveText(await L('LBL_USER_FORM_NEW', 'ko'))
  })

  test('TC-ADM-USR-CREATE-02-INVALID-EMPTY-NAME — 이름/사번 누락 시 toast', async ({ page }) => {
    const up = new UsersPage(page)
    await up.openCreate()
    await page.locator('.p-dialog button.p-button').last().click()
    await expect(page.locator('.p-toast-message-text')).toContainText(await L('MSG_USER_NAME_NO_REQ', 'ko'))
  })

  test('TC-ADM-USR-CREATE-03-CANCEL — 취소 시 다이얼로그 CLOSE', async ({ page }) => {
    const up = new UsersPage(page)
    await up.openCreate()
    await up.cancelDialog()
  })
})
