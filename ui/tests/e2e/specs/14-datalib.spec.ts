import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-DLB', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/datalib') })

  test('TC-DLB-LIST-01-FOLDER-PANE — 폴더 패널 i18n', async ({ page }) => {
    await expect(page.locator('.folder-pane h3')).toHaveText(await L('LBL_DATALIB_FOLDERS', 'ko'))
  })
  test('TC-DLB-LIST-02-TREE-VISIBLE — 폴더 트리 표시', async ({ page }) => {
    await expect(page.locator('.folder-tree')).toBeVisible({ timeout: 10_000 })
  })
})
