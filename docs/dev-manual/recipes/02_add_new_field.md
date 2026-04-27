# recipes/02_add_new_field.md — 기존 도메인에 컬럼/필드 1개 추가

> Phase 5.2 산출물. 가상 시나리오: `bd_post` 테이블에 `view_count` (조회수) 컬럼 추가 + 화면 노출.

## 변경 파일 표

| 계층 | 파일 | 변경 |
|---|---|---|
| **영속 계층** | `backend-core/src/main/resources/db/migration/V{N+1}__board_view_count.sql` | `ALTER TABLE bd_post ADD COLUMN view_count INT DEFAULT 0` |
| **데이터 액세스** | `backend-core/src/main/resources/mapper/board/BoardMapper.xml` | `selectPostList` SELECT 절에 `view_count` 추가, `selectPostDetail` 동일, `incrementViewCount(@Param postId)` 메서드 추가 |
| **데이터 액세스** | `backend-core/.../board/mapper/BoardMapper.java` | `int incrementViewCount(String postId)` 시그니처 추가 |
| **비즈** | `backend-core/.../board/BoardService.java` | `searchDetail` 호출 시 `boardMapper.incrementViewCount(postId)` 추가 (조회 시 +1) |
| **화면 입력 폼** | (해당 없음 — 사용자 입력 필드 아님, 자동 카운트) | — |
| **화면 목록 컬럼** | `ui/src/pages/PageBoard.vue` | `<Column field="view_count" header="조회수" />` 추가 |
| **화면 상세** | `ui/src/components/board/BoardDetailDialog.vue` | 헤더 영역에 `<Tag>{{ detail.view_count }} 조회</Tag>` |
| **검색 조건** | (해당 없음) | — |
| **다국어 라벨** | (선택) `V{N+2}__i18n_view_count.sql` | `LBL_BOARD_VIEW_COUNT` 4 locale |
| **테스트** | (코드베이스에 자동 테스트 없음 — 수동 시나리오) | — |

## 단계 절차

### Step 1 — DDL 마이그레이션

```sql
-- V18__board_view_count.sql
ALTER TABLE platform_v3.bd_post ADD COLUMN IF NOT EXISTS view_count INT DEFAULT 0;
```

### Step 2 — Mapper

`BoardMapper.java`:
```java
int incrementViewCount(@Param("postId") String postId);
```

`BoardMapper.xml`:
```xml
<update id="incrementViewCount">
  UPDATE platform_v3.bd_post SET view_count = view_count + 1 WHERE post_id = #{postId}
</update>
```

`selectPostList`/`selectPostDetail` SELECT 절에 `view_count` 추가.

### Step 3 — Service

`BoardService.searchDetail` 호출 시:
```java
@Transactional
public Map<String,Object> searchDetail(Map<String,Object> ds, String user) {
    String postId = (String) ((Map<?,?>) ds.get("ds_data")).get("postId");
    boardMapper.incrementViewCount(postId);
    var detail = boardMapper.selectPostDetail(postId);
    return Map.of("ds_detail", Map.of("rows", List.of(detail)));
}
```

### Step 4 — UI 목록 컬럼

`PageBoard.vue` template 의 DataTable 에 추가:
```vue
<Column field="view_count" header="조회수" sortable />
```

### Step 5 — UI 상세 표시

`BoardDetailDialog.vue` template 헤더:
```vue
<Tag :value="`${detail.view_count} 조회`" severity="info" />
```

### Step 6 — i18n (선택)

`V{N+2}__i18n_view_count.sql`:
```sql
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message)
VALUES
  ('LBL_BOARD_VIEW_COUNT','ko','LABEL','조회수'),
  ('LBL_BOARD_VIEW_COUNT','en','LABEL','Views'),
  ('LBL_BOARD_VIEW_COUNT','zh','LABEL','浏览量'),
  ('LBL_BOARD_VIEW_COUNT','ja','LABEL','閲覧数')
ON CONFLICT DO NOTHING;
```

### Step 7 — 검증

1. `SELECT view_count FROM bd_post LIMIT 1;` → 0 또는 기존값
2. UI 게시글 클릭 → 상세 다이얼로그 노출 + 조회수 +1
3. 목록 갱신 시 조회수 컬럼 노출
4. 다단계 이전 호출 시에도 정상 (`view_count` 누락 없음)

## 자기검증 체크

- [ ] DDL 이 IDEMPOTENT (`IF NOT EXISTS`)
- [ ] Mapper SELECT 절 모든 위치 동기 (list + detail)
- [ ] Service write 호출 `@Transactional` 안에 있음
- [ ] UI 목록 + 상세 모두 노출
- [ ] 다국어 키 추가 (선택)
