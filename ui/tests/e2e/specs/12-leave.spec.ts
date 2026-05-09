import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-LEV', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/leave') })

  test('TC-LEV-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    const heading = await page.getByRole('heading', { level: 2 }).first().textContent()
    expect(heading).toContain(await L('LBL_PAGE_LEAVE', 'ko'))
  })
  test('TC-LEV-LIST-02-COLUMNS — 그리드 7 컬럼', async ({ page }) => {
    const headers = page.locator('table.p-datatable-table thead th .p-datatable-column-title')
    await expect(headers).toHaveCount(7)
    await expect(headers.first()).toHaveText(await L('COL_LEAVE_NO', 'ko'))
  })
  test('TC-LEV-APPLY-01-DIALOG-OPEN — [휴가 신청] → ApprovalSubmitDialog OPEN', async ({ page }) => {
    await page.locator('button', { hasText: await L('BTN_APPLY_LEAVE', 'ko') }).click()
    await expect(page.locator('.p-dialog .p-dialog-title')).toHaveText(await L('LBL_APPROVAL_SUBMIT_HEADER', 'ko'))
  })
  test('TC-LEV-APPLY-02-LEAVE-FORM — 다이얼로그에 휴가 유형 필드 표시', async ({ page }) => {
    await page.locator('button', { hasText: await L('BTN_APPLY_LEAVE', 'ko') }).click()
    await expect(page.locator('.p-dialog')).toContainText(await L('LBL_APPROVAL_LEAVE_TYPE_REQ', 'ko'))
  })
  test('TC-LEV-CANCEL-01 — 취소 버튼', async ({ page }) => {
    await page.locator('button', { hasText: await L('BTN_APPLY_LEAVE', 'ko') }).click()
    await page.locator('.p-dialog button', { hasText: await L('BTN_CANCEL', 'ko') }).click()
    await expect(page.locator('.p-dialog')).toBeHidden()
  })
})
