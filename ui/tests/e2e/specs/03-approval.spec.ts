import { test, expect } from '../fixtures/auth.fixture'
import { ApprovalPage } from '../pages/ApprovalPage'
import { L } from '../utils/labels'

test.describe('TC-APP — 결재', () => {
  test.beforeEach(async ({ page }) => {
    await new ApprovalPage(page).goto()
  })

  test('TC-APP-LIST-01-HAPPY — 페이지 진입 + 헤딩이 i18n 라벨', async ({ page }) => {
    const heading = page.getByRole('heading', { level: 2 }).first()
    await expect(heading).toHaveText(await L('LBL_PAGE_APPROVAL', 'ko'))
  })

  test('TC-APP-LIST-02-9BOX — 9-box 사이드 nav 표시', async ({ page }) => {
    const items = page.locator('.inbox-nav li')
    await expect(items).toHaveCount(9)
  })

  test('TC-APP-LIST-03-COLUMNS — 그리드 헤더가 i18n', async ({ page }) => {
    const headers = page.locator('table.p-datatable-table thead th .p-datatable-column-title')
    await expect(headers.first()).toHaveText(await L('COL_APPROVAL_NO', 'ko'))
  })

  test('TC-APP-CREATE-01-DIALOG-OPEN — [상신] 클릭 → 다이얼로그 OPEN', async ({ page }) => {
    const ap = new ApprovalPage(page)
    await ap.openNewDoc()
    await expect(page.locator('.p-dialog .p-dialog-title')).toHaveText(await L('LBL_APPROVAL_SUBMIT_HEADER', 'ko'))
  })

  test('TC-APP-CREATE-02-CANCEL — [취소] 클릭 → 다이얼로그 CLOSE', async ({ page }) => {
    const ap = new ApprovalPage(page)
    await ap.openNewDoc()
    await page.locator('.p-dialog button', { hasText: await L('BTN_CANCEL', 'ko') }).click()
    await expect(page.locator('.p-dialog')).toBeHidden()
  })

  test('TC-APP-CREATE-03-INVALID-NO-FORM — 양식 미선택 시 alert', async ({ page }) => {
    const ap = new ApprovalPage(page)
    await ap.openNewDoc()
    page.on('dialog', async (d) => {
      expect(d.message()).toBe(await L('MSG_APPROVAL_FORM_REQ', 'ko'))
      await d.accept()
    })
    await page.locator('.p-dialog button.p-button').last().click()
  })

  test('TC-APP-BOX-01-SWITCH — 박스 전환 시 active 클래스 갱신', async ({ page }) => {
    await page.locator('.inbox-nav li').nth(2).click() // PENDING (3rd)
    await expect(page.locator('.inbox-nav li.active')).toHaveCount(1)
  })
})
