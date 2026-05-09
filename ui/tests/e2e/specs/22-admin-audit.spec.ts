import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-ADM-AUDIT', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/admin/audit') })

  test('TC-ADM-AUDIT-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_ADMIN_AUDIT', 'ko'))
  })
  test('TC-ADM-AUDIT-LIST-02-COLUMNS — 그리드 8 컬럼', async ({ page }) => {
    const headers = page.locator('table.p-datatable-table thead th .p-datatable-column-title')
    await expect(headers).toHaveCount(8)
    await expect(headers.first()).toHaveText(await L('COL_AUDIT_ID', 'ko'))
  })
  test('TC-ADM-AUDIT-LIST-03-PLACEHOLDERS — 검색 input placeholder i18n', async ({ page }) => {
    const ph0 = await page.locator('.toolbar input').nth(0).getAttribute('placeholder')
    expect(ph0).toBe(await L('PH_AUDIT_ACTOR', 'ko'))
    const ph1 = await page.locator('.toolbar input').nth(1).getAttribute('placeholder')
    expect(ph1).toBe(await L('PH_AUDIT_ACTION', 'ko'))
  })
  test('TC-ADM-AUDIT-RESET-01-VISIBLE — [초기화] 버튼 i18n 노출', async ({ page }) => {
    await expect(page.locator('button', { hasText: await L('BTN_RESET', 'ko') })).toBeVisible()
  })
})
