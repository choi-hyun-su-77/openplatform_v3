import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-ORG', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/org') })

  test('TC-ORG-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_ORG', 'ko'))
  })
  test('TC-ORG-LIST-02-TREE — 부서 트리 렌더링', async ({ page }) => {
    await expect(page.locator('.dept-tree .p-tree')).toBeVisible({ timeout: 10_000 })
  })
  test('TC-ORG-SEARCH-01-PLACEHOLDER — i18n 검색 placeholder', async ({ page }) => {
    const expected = await L('PH_USER_SEARCH', 'ko')
    // layout header 의 통합검색 input 도 .search-input 이라 부정합 — employee-list 영역으로 한정
    await expect(page.locator('.employee-list .search-input')).toHaveAttribute('placeholder', expected, { timeout: 10_000 })
  })
})
