# TC-ROOM, TC-DLB, TC-WLG

## TC-ROOM — 회의실 예약 (`/room`)

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-ROOM-LIST-01-HAPPY | 헤딩 i18n | "회의실 예약" |
| TC-ROOM-LIST-02-FILTER-SEARCH | 검색 placeholder i18n | PH_ROOM_SEARCH |
| TC-ROOM-LIST-03-MIN-CAPACITY-LABEL | 최소 인원 라벨 | LBL_ROOM_MIN_CAPACITY |
| TC-ROOM-BOOK-01-RESERVE-DISABLED | 회의실 미선택 시 [예약하기] disabled | `button.reserve-btn` disabled |

spec: `ui/tests/e2e/specs/13-room.spec.ts`

## TC-DLB — 자료실 (`/datalib`)

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-DLB-LIST-01-FOLDER-PANE | 폴더 패널 i18n | "폴더" |
| TC-DLB-LIST-02-TREE-VISIBLE | 폴더 트리 표시 | `.folder-tree` visible |

spec: `ui/tests/e2e/specs/14-datalib.spec.ts`

## TC-WLG — 업무일지 (`/worklog`)

| ID | 시나리오 | 기대 |
|---|---|---|
| TC-WLG-LIST-01-HAPPY | 헤딩 i18n | "업무일지" 포함 |
| TC-WLG-LIST-02-CALENDAR-PANE | 캘린더 패널 i18n | "캘린더" |

spec: `ui/tests/e2e/specs/15-worklog.spec.ts`
