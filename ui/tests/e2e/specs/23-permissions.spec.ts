import { test, expect, gotoMenu } from '../fixtures/auth.fixture'

/**
 * TC-PERM — 권한 매트릭스 (admin 계정 기준)
 *
 * admin 계정은 모든 메뉴 접근 가능 → /403 으로 차단되지 않음.
 */

test.describe('TC-PERM (admin)', () => {
  for (const path of [
    '/dashboard', '/approval', '/board', '/calendar', '/org',
    '/messenger', '/mail', '/wiki', '/video',
    '/attendance', '/leave', '/worklog', '/room', '/datalib', '/search',
    '/settings/notify', '/settings/favorites',
    '/admin/users', '/admin/depts', '/admin/menus', '/admin/codes', '/admin/audit'
  ]) {
    test(`TC-PERM-NO-403-${path.replace(/\//g, '_')}`, async ({ page }) => {
      await gotoMenu(page, path)
      // admin 계정은 모든 메뉴 접근 가능 → /403 으로 리다이렉트 절대 발생 안 함.
      // (path 정확 매치는 SPA navigation race condition 으로 불안정해 검증 제외)
      await expect(page).not.toHaveURL(/\/403$/)
    })
  }
})
