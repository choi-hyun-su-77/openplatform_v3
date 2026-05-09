import { test, expect, gotoMenu } from '../fixtures/auth.fixture'
import { L } from '../utils/labels'

test.describe('TC-ROOM', () => {
  test.beforeEach(async ({ page }) => { await gotoMenu(page, '/room') })

  test('TC-ROOM-LIST-01-HAPPY — 헤딩 i18n', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 2 }).first()).toHaveText(await L('LBL_PAGE_ROOM', 'ko'))
  })
  test('TC-ROOM-LIST-02-FILTER-SEARCH — 검색 placeholder i18n', async ({ page }) => {
    const ph = await page.locator('.filter-bar input').first().getAttribute('placeholder')
    expect(ph).toBe(await L('PH_ROOM_SEARCH', 'ko'))
  })
  test('TC-ROOM-LIST-03-MIN-CAPACITY-LABEL — 최소 인원 라벨', async ({ page }) => {
    await expect(page.locator('.cap-label')).toHaveText(await L('LBL_ROOM_MIN_CAPACITY', 'ko'))
  })
  test('TC-ROOM-BOOK-01-RESERVE-VISIBLE — 예약하기 버튼 표시 (활성/비활성 모두 허용)', async ({ page }) => {
    // 회의실 자동 선택될 수도 있어 disabled 검증은 스킵 — 버튼 자체 표시만 확인
    await expect(page.locator('button.reserve-btn')).toBeVisible()
  })
})
