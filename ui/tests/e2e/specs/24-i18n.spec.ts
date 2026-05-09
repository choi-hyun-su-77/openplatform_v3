import { test, expect } from '@playwright/test'
import { L, loadLabels } from '../utils/labels'

/**
 * TC-I18N — 4 언어 토글 회귀 (백엔드 API 레벨)
 *
 * UI 토글 검증은 별도(웹 토글 위젯 의존)이며, 본 스펙은 cm_i18n_message 의 4 언어 데이터가
 * 정상적으로 응답되는지 회귀한다. 핵심 키 4 종을 4 언어 모두에서 비교.
 */

test.describe('TC-I18N', () => {
  for (const locale of ['ko', 'en', 'zh', 'ja'] as const) {
    test(`TC-I18N-API-01-${locale.toUpperCase()} — /api/labels?locale=${locale} 응답`, async () => {
      const m = await loadLabels(locale)
      expect(m.size).toBeGreaterThan(400)
      // 핵심 키 6 종이 비어있지 않은 문자열로 응답
      for (const k of ['LBL_PAGE_APPROVAL', 'MENU_ATTENDANCE', 'COL_USER_NO', 'BTN_CHECK_IN', 'STATUS_APP_DOC_PENDING', 'MSG_SAVE_DONE']) {
        expect(m.get(k), `${locale}/${k}`).toBeTruthy()
      }
    })
  }

  test('TC-I18N-LANGS-01-DISTINCT — ko/en/zh/ja 의 LBL_PAGE_APPROVAL 이 모두 다른 값', async () => {
    const langs = ['ko', 'en', 'zh', 'ja'] as const
    const values = await Promise.all(langs.map((l) => L('LBL_PAGE_APPROVAL', l)))
    const set = new Set(values)
    expect(set.size).toBe(4)
  })
})
