# TC-ATT, TC-LEV — 근태 / 휴가

## TC-ATT — 근태

| 항목 | 값 |
|---|---|
| spec | `ui/tests/e2e/specs/11-attendance.spec.ts` |
| 화면 | `PageAttendance.vue` + `MonthlyCalendar.vue` |

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-ATT-LIST-01-HAPPY | 헤딩 i18n | "근태" |
| TC-ATT-LIST-02-CHECK-CARD | 출퇴근 카드 | `.check-card` visible |
| TC-ATT-LIST-03-MONTHLY | 월별 통계 카드 | `.month-card` visible |
| TC-ATT-LIST-04-SUMMARY | 5종 통계 항목 | `.month-summary > div` count = 5 |

## TC-LEV — 휴가

| 항목 | 값 |
|---|---|
| spec | `ui/tests/e2e/specs/12-leave.spec.ts` |
| 화면 | `PageLeave.vue` + `LeaveBalanceCard.vue` |
| 다이얼로그 | `ApprovalSubmitDialog.vue` (LEAVE 양식) |

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-LEV-LIST-01-HAPPY | 헤딩 i18n | "연차 / 휴가" |
| TC-LEV-LIST-02-COLUMNS | 그리드 7 컬럼 | 첫 컬럼 = "번호" |
| TC-LEV-APPLY-01-DIALOG-OPEN | [휴가 신청] | "결재 상신" |
| TC-LEV-APPLY-02-LEAVE-FORM | 다이얼로그에 휴가 유형 필드 표시 | 폼에 LBL_APPROVAL_LEAVE_TYPE_REQ 노출 |
| TC-LEV-CANCEL-01 | 취소 버튼 | dialog hidden |
