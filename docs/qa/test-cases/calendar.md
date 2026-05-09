# TC-CAL — 캘린더

| 항목 | 값 |
|---|---|
| spec | `ui/tests/e2e/specs/05-calendar.spec.ts` |
| 화면 | `PageCalendar.vue` + FullCalendar |
| 다이얼로그 | `CalendarEventDialog.vue` |

## 케이스

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-CAL-LIST-01-HAPPY | 헤딩 i18n | "캘린더" |
| TC-CAL-LIST-02-FULLCAL-RENDERED | FullCalendar 마운트 | `.fc` visible |
| TC-CAL-CREATE-01-DIALOG-OPEN | [일정 추가] | dialog title = "새 일정" |
| TC-CAL-CREATE-02-CANCEL | 취소 | dialog hidden |
| TC-CAL-FILTER-01-SELECT | 범위 SelectButton | 4개 옵션 |
