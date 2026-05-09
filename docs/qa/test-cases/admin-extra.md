# TC-ADM-DEPT/MENU/CODE/AUDIT, TC-ERR

## TC-ADM-DEPT — 조직관리

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-ADM-DEPT-LIST-01-HAPPY | 헤딩 i18n | "조직 관리" |
| TC-ADM-DEPT-LIST-02-TREE | 트리 표시 | `.tree-panel .p-tree` visible |
| TC-ADM-DEPT-CREATE-01-NEW-FORM | [루트 추가] | LBL_DEPT_NEW |
| TC-ADM-DEPT-CREATE-02-VALIDATION | 필수값 누락 toast | MSG_DEPT_REQ |

spec: `ui/tests/e2e/specs/19-admin-depts.spec.ts`

## TC-ADM-MENU — 메뉴 / 권한 관리

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-ADM-MENU-LIST-01-HAPPY | 헤딩 i18n | "메뉴 / 권한 관리" |
| TC-ADM-MENU-LIST-02-TREE | 트리 표시 | `.tree-panel .p-tree` visible |
| TC-ADM-MENU-LIST-03-MATRIX-HEADER | 권한 매트릭스 라벨 | LBL_MENU_PERM_MATRIX |
| TC-ADM-MENU-CREATE-01-NEW-FORM | [새 메뉴] | LBL_MENU_NEW |
| TC-ADM-MENU-CREATE-02-VALIDATION | 필수값 누락 toast | MSG_MENU_REQ |

spec: `ui/tests/e2e/specs/20-admin-menus.spec.ts`

## TC-ADM-CODE — 공통코드

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-ADM-CODE-LIST-01-HAPPY | 헤딩 i18n | "공통코드 관리" |
| TC-ADM-CODE-LIST-02-COLUMNS | 그리드 6 컬럼 | 첫 컬럼 = "그룹" |
| TC-ADM-CODE-NEW-GROUP-01-DIALOG-OPEN | [그룹 추가] | LBL_CODE_NEW_GROUP |
| TC-ADM-CODE-NEW-GROUP-02-VALIDATION | 필수값 누락 toast | MSG_CODE_ALL_REQ |
| TC-ADM-CODE-NEW-GROUP-03-CANCEL | 취소 | dialog hidden |

spec: `ui/tests/e2e/specs/21-admin-codes.spec.ts`

## TC-ADM-AUDIT — 감사로그

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-ADM-AUDIT-LIST-01-HAPPY | 헤딩 i18n | "감사 로그" |
| TC-ADM-AUDIT-LIST-02-COLUMNS | 그리드 8 컬럼 | 첫 컬럼 = "ID" |
| TC-ADM-AUDIT-LIST-03-PLACEHOLDERS | 검색 input placeholder i18n | PH_AUDIT_ACTOR/ACTION |
| TC-ADM-AUDIT-RESET-01-CLICK | [초기화] 버튼 동작 | networkidle 도달 |

spec: `ui/tests/e2e/specs/22-admin-audit.spec.ts`

## TC-ERR — 에러 흐름

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-ERR-403-PAGE-RENDER | /403 진입 | LBL_FORBIDDEN + LBL_FORBIDDEN_DETAIL |
| TC-ERR-403-BTN-DASHBOARD | [대시보드로 이동] | URL = /dashboard |
| TC-ERR-NETWORK-01-INVALID-DATASET | 잘못된 serviceName | 4xx/5xx 응답 |

spec: `ui/tests/e2e/specs/25-error-flows.spec.ts`
