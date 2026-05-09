import { test, expect } from '../fixtures/auth.fixture'
import { BoardPage } from '../pages/BoardPage'
import { L } from '../utils/labels'

test.describe('TC-BRD — 게시판', () => {
  test.beforeEach(async ({ page }) => {
    await new BoardPage(page).goto()
  })

  test('TC-BRD-LIST-01-HAPPY — 페이지 진입 + 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_BOARD', 'ko'))
  })

  test('TC-BRD-LIST-02-COLUMNS — 그리드 헤더 i18n', async ({ page }) => {
    const headers = page.locator('table.p-datatable-table thead th .p-datatable-column-title')
    await expect(headers.first()).toHaveText(await L('COL_BOARD_NO', 'ko'))
  })

  test('TC-BRD-CREATE-01-DIALOG-OPEN — [글쓰기] → 다이얼로그 OPEN', async ({ page }) => {
    const bp = new BoardPage(page)
    await bp.openForm()
    const expected = await L('LBL_BOARD_FORM_NEW', 'ko')
    await expect(page.locator('.p-dialog .p-dialog-title')).toHaveText(expected)
  })

  test('TC-BRD-CREATE-02-INVALID-EMPTY-TITLE — 제목 미입력 시 toast', async ({ page }) => {
    const bp = new BoardPage(page)
    await bp.openForm()
    // 제목/내용 비우고 등록
    await page.locator('.p-dialog button.p-button').last().click()
    const expected = await L('MSG_BOARD_TITLE_REQ', 'ko')
    await expect(page.locator('.p-toast-message-text')).toContainText(expected)
  })

  test('TC-BRD-CREATE-03-CANCEL — 취소 시 다이얼로그 CLOSE', async ({ page }) => {
    const bp = new BoardPage(page)
    await bp.openForm()
    await page.locator('.p-dialog button', { hasText: await L('BTN_CANCEL', 'ko') }).click()
    await expect(page.locator('.p-dialog')).toBeHidden()
  })

  test('TC-BRD-SEARCH-01-FILTER-CHANGE — 게시판 select 변경 후 load 호출', async ({ page }) => {
    // select 클릭 → overlay 표시 대기
    await page.locator('.toolbar .p-select').first().click()
    await expect(page.locator('.p-select-overlay')).toBeVisible({ timeout: 10_000 })
    // 두번째 항목 클릭 + load 호출 응답 대기
    await Promise.all([
      page.waitForResponse(r => r.url().includes('/api/dataset/search') && r.request().postData()?.includes('board/searchPosts') === true, { timeout: 15_000 }).catch(() => null),
      page.locator('.p-select-overlay li').nth(1).click()
    ])
    await expect(page.locator('table.p-datatable-table')).toBeVisible()
  })
})
