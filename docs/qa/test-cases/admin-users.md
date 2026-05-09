# TC-ADM-USR — 사용자 관리

| 항목 | 값 |
|---|---|
| spec | `ui/tests/e2e/specs/18-admin-users.spec.ts` |
| 화면 | `ui/src/pages/admin/PageUsers.vue` |
| API | `admin/userList`, `admin/userSave`, `admin/userToggleActive`, `admin/userResetPwd` |
| 권한 | ROLE_ADMIN 한정 |

## 케이스

| ID | 시나리오 | 기대 | 상태 |
|---|---|---|---|
| TC-ADM-USR-LIST-01-HAPPY | 페이지 진입 + 헤딩 | h2 = "사용자 관리" | ⏳ |
| TC-ADM-USR-LIST-02-COLUMNS | 그리드 헤더 i18n (8개) | 8 컬럼, 첫 컬럼 = "사번" | ⏳ |
| TC-ADM-USR-CREATE-01-DIALOG-OPEN | [추가] | 다이얼로그 헤더 = "사용자 추가" | ⏳ |
| TC-ADM-USR-CREATE-02-INVALID-EMPTY-NAME | 이름/사번 미입력 | toast = MSG_USER_NAME_NO_REQ | ⏳ |
| TC-ADM-USR-CREATE-03-CANCEL | 취소 | hidden | ⏳ |

## 추가 진행 후보

- TC-ADM-USR-CREATE-04-HAPPY — 이름/사번/부서/직책 입력 → 저장 → toast MSG_SAVE_DONE → 행 추가
- TC-ADM-USR-EDIT-01-HAPPY — 행 클릭 → 다이얼로그 헤더 LBL_USER_FORM_EDIT → 부서 변경 → 저장
- TC-ADM-USR-TOGGLE-01-CONFIRM — power-off 버튼 → confirm 메시지 = MSG_USER_TOGGLE_CONFIRM
- TC-ADM-USR-RESET-PWD-01-NO-KC — keycloakUserId 없는 사용자에 대해 → toast MSG_USER_KC_NOT_SET
- TC-ADM-USR-RESET-PWD-02-HAPPY — keycloakUserId 있는 사용자 → 임시 비밀번호 toast
