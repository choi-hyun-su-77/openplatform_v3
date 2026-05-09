# TC-APP — 결재

| 항목 | 값 |
|---|---|
| spec 파일 | `ui/tests/e2e/specs/03-approval.spec.ts` |
| 화면 | `PageApproval.vue` |
| 다이얼로그 | `ApprovalSubmitDialog.vue`, `ApprovalDetailDialog.vue`, `ApprovalActionBar.vue`, `ApprovalLineTimeline.vue` |
| 라우트 | `/approval` |
| API | `approval/searchInbox`, `approval/searchDetail`, `approval/submitDocument`, `approval/approve`, `approval/reject`, `approval/withdraw`, `approval/resubmit`, `approval/delegate` |

## 케이스

| ID | 시나리오 | 사전조건 | 절차 | 기대 | 상태 |
|---|---|---|---|---|---|
| TC-APP-LIST-01-HAPPY | 페이지 진입 + 헤딩 i18n | 로그인 | /approval | h2 = "전자결재" (ko) | ⏳ |
| TC-APP-LIST-02-9BOX | 9-box 사이드 nav 표시 | 로그인 | /approval | `.inbox-nav li` 9개 | ⏳ |
| TC-APP-LIST-03-COLUMNS | 그리드 헤더 i18n | 로그인 | /approval | 첫 컬럼 헤더 = "번호" | ⏳ |
| TC-APP-CREATE-01-DIALOG-OPEN | [상신] 클릭 → 다이얼로그 OPEN | 로그인 | [새 문서 상신] 클릭 | `.p-dialog .p-dialog-title` = "결재 상신" | ⏳ |
| TC-APP-CREATE-02-CANCEL | [취소] 클릭 → 다이얼로그 CLOSE | 다이얼로그 OPEN | [취소] 클릭 | `.p-dialog` hidden | ⏳ |
| TC-APP-CREATE-03-INVALID-NO-FORM | 양식 미선택 시 alert | 다이얼로그 OPEN | [상신] 클릭 (양식 미선택) | window.alert 메시지 = MSG_APPROVAL_FORM_REQ ko | ⏳ |
| TC-APP-BOX-01-SWITCH | 박스 전환 시 active 갱신 | 로그인 | 3번째 box li 클릭 | `.inbox-nav li.active` count=1 | ⏳ |

## 추가 진행 후보 (목표 ~25 케이스)

- TC-APP-CREATE-04-LEAVE-SUBMIT — LEAVE 양식 → 시작/종료일 → 결재선 미리보기 3명 → 상신
- TC-APP-CREATE-05-INVALID-DATE-ORDER — toDate < fromDate → MSG_APPROVAL_DATE_ORDER alert
- TC-APP-DETAIL-01-OPEN — 행 클릭 → ApprovalDetailDialog open
- TC-APP-DETAIL-02-APPROVE — 승인 버튼 → 코멘트 입력 → confirm → 상태 IN_PROGRESS
- TC-APP-DETAIL-03-REJECT-EMPTY-REASON — 반려 사유 미입력 → MSG_APPROVAL_REJECT_REASON_REQ
- TC-APP-DETAIL-04-WITHDRAW-CONFIRM — 회수 confirm 다이얼로그 메시지 = MSG_APPROVAL_WITHDRAW_CONFIRM
- TC-APP-DETAIL-05-DELEGATE-FORM — 대결 등록 폼 → 필수값 → MSG_APPROVAL_DELEGATE_REQ
- TC-APP-LINE-01-STATUS-LABELS — STATUS_APP_LINE_PENDING/APPROVED/REJECTED/SKIPPED 4언어 회귀
- TC-APP-FORM-01-CODE-LABEL — formCodeLabel 의 t('FORM_'+code) 회귀
- TC-APP-PERM-01-NO-CREATE-FOR-USER — ROLE_USER 일 때 [상신] 비표시 (별도 storageState)
