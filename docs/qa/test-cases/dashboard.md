# TC-DASH — 대시보드

| 항목 | 값 |
|---|---|
| spec | `ui/tests/e2e/specs/02-dashboard.spec.ts` |
| 화면 | `PageDashboard.vue` |

## 케이스

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-DASH-LIST-01-HAPPY | 헤딩 i18n | h2 = "대시보드" |
| TC-DASH-LIST-02-EDIT-BUTTON | 편집 버튼 표시 | `.btn-edit` visible |
| TC-DASH-EDIT-01-TOGGLE | 편집 모드 진입 시 위젯 추가/저장/취소 버튼 표시 | `.btn-add/.btn-save/.btn-cancel` 모두 visible |
| TC-DASH-EDIT-02-CANCEL | 취소 시 편집 모드 종료 | `.btn-edit` 다시 visible |
