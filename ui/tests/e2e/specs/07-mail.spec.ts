import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-MAIL', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/mail') })

  test('TC-MAIL-LIST-01-COMPOSE-BTN — i18n 작성 버튼', async ({ page }) => {
    await expect(page.locator('button.compose-btn')).toContainText(await L('BTN_COMPOSE_MAIL', 'ko'))
  })
  test('TC-MAIL-COMPOSE-01-DIALOG-OPEN — [새 메일] 클릭 → ComposeDialog OPEN', async ({ page }) => {
    await page.locator('button.compose-btn').click()
    await expect(page.locator('.p-dialog .p-dialog-title')).toBeVisible({ timeout: 10_000 })
  })
  test('TC-MAIL-COMPOSE-02-CANCEL — 다이얼로그 esc 닫기', async ({ page }) => {
    await page.locator('button.compose-btn').click()
    await page.keyboard.press('Escape')
    await expect(page.locator('.p-dialog')).toBeHidden({ timeout: 5_000 })
  })
})
