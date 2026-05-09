# TC-BRD — 게시판

| 항목 | 값 |
|---|---|
| spec | `ui/tests/e2e/specs/04-board.spec.ts` |
| 화면 | `PageBoard.vue` |
| 다이얼로그 | `BoardFormDialog.vue`, `BoardDetailDialog.vue` |
| API | `board/searchPosts`, `board/searchDetail`, `board/savePosts`, `board/uploadAttachment` |

## 케이스

| ID | 시나리오 | 기대 | 상태 |
|---|---|---|---|
| TC-BRD-LIST-01-HAPPY | 페이지 진입 + 헤딩 | h2 = "게시판" | ⏳ |
| TC-BRD-LIST-02-COLUMNS | 그리드 헤더 i18n | 첫 컬럼 = "번호" | ⏳ |
| TC-BRD-CREATE-01-DIALOG-OPEN | [글쓰기] | 다이얼로그 헤더 = "새 글 작성" | ⏳ |
| TC-BRD-CREATE-02-INVALID-EMPTY-TITLE | 제목 미입력 등록 | toast 메시지 = MSG_BOARD_TITLE_REQ | ⏳ |
| TC-BRD-CREATE-03-CANCEL | 취소 | 다이얼로그 hidden | ⏳ |
| TC-BRD-SEARCH-01-FILTER-CHANGE | 분류 select 변경 → load | DataTable 재렌더 | ⏳ |

## 추가 진행 후보

- TC-BRD-CREATE-04-HAPPY — 제목/내용 입력 → 저장 → toast = MSG_BOARD_SAVE_DONE → 행 삽입
- TC-BRD-CREATE-05-PIN — `상단 고정` 체크 → 저장 → 첫 행에 pin 아이콘
- TC-BRD-EDIT-01-HAPPY — 행 클릭 → 상세 → [수정] → 제목 변경 → 저장 → MSG_BOARD_UPDATE_DONE
- TC-BRD-DETAIL-01-COMMENT-ADD — 상세에서 댓글 등록 → MSG_COMMENT_ADDED
- TC-BRD-DETAIL-02-DELETE — 삭제 confirm → 목록에서 제거
