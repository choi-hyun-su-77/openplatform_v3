import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-DASH', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/dashboard') })

  test('TC-DASH-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_DASHBOARD', 'ko'))
  })
  test('TC-DASH-LIST-02-EDIT-BUTTON — 편집 버튼 표시', async ({ page }) => {
    await expect(page.locator('button.btn-edit')).toBeVisible()
  })
  test('TC-DASH-EDIT-01-TOGGLE — 편집 모드 진입 시 위젯 추가/저장/취소 버튼 표시', async ({ page }) => {
    await page.locator('button.btn-edit').click()
    await expect(page.locator('button.btn-add')).toBeVisible()
    await expect(page.locator('button.btn-save')).toBeVisible()
    await expect(page.locator('button.btn-cancel')).toBeVisible()
  })
  test('TC-DASH-EDIT-02-CANCEL — 취소 시 편집 모드 종료', async ({ page }) => {
    await page.locator('button.btn-edit').click()
    await page.locator('button.btn-cancel').click()
    await expect(page.locator('button.btn-edit')).toBeVisible()
  })
})
