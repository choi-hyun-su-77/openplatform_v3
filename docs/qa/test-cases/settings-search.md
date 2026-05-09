# TC-SCH, TC-NOT, TC-FAV — 검색 / 알림설정 / 즐겨찾기

## TC-SCH — 통합검색 (`/search`)

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-SCH-LIST-01-PLACEHOLDER | 검색 placeholder i18n | PH_GLOBAL_SEARCH |
| TC-SCH-LIST-02-FILTER-LABELS | 4 도메인 라벨 표시 | POST/DOC/EMP/FILE 모두 |
| TC-SCH-LIST-03-SEARCH-BUTTON | 검색 버튼 i18n | BTN_SEARCH |

spec: `ui/tests/e2e/specs/16-search.spec.ts`

## TC-NOT — 알림설정 (`/settings/notify`)

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-NOT-LIST-01-HAPPY | 헤딩 i18n | "알림 설정" |
| TC-NOT-LIST-02-NOTE | 안내 문구 i18n | LBL_NOTIFY_NOTE 포함 |
| TC-NOT-LIST-03-RESET-BTN | [기본값으로] 버튼 i18n | BTN_RESET_DEFAULT |

spec: `ui/tests/e2e/specs/17-settings.spec.ts` (describe 1)

## TC-FAV — 즐겨찾기 (`/settings/favorites`)

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-FAV-LIST-01-HAPPY | 헤딩 i18n | "즐겨찾기 관리" |
| TC-FAV-LIST-02-ADD-BTN | [추가] 버튼 i18n | BTN_ADD |

spec: `ui/tests/e2e/specs/17-settings.spec.ts` (describe 2)
