# recipes/01_add_new_domain.md — 새 도메인 추가 전 과정

> Phase 5.1 산출물. 백엔드 패턴 SOP + 화면 형태 SOP + 메뉴 절차를 하나로 엮은 가장 자주 펼치는 문서.
> 가상 도메인: **`notice`** (공지사항) — 도메인 어휘는 코드베이스 한국어 명에서 차용.

## 사전 정보

- 도메인: `notice` (공지사항)
- 백엔드 패턴: 단순 CRUD → **Pattern A**
- 화면 형태: 다건 조회 + 상세 → **형태 1 + 형태 2**
- 권한: ROLE_USER 읽기, ROLE_ADMIN 쓰기

## 결정 1 — 백엔드 패턴 선택

→ `[doc: scaffolds/00_decision_tree.md]`

| 질문 | 답 | 결과 |
|---|---|---|
| 외부 시스템 호출? | 아니오 | (계속) |
| 워크플로/state machine? | 아니오 | (계속) |
| Read-only 다중 도메인 집계? | 아니오 (단일 도메인 CRUD) | **Pattern A** |

→ `[doc: scaffolds/01_pattern_a_crud_mybatis.md]` 따라감.

## 결정 2 — 화면 형태 선택

→ `[doc: screens/00_screen_decision.md]`

| 사용자 의도 | 형태 |
|---|---|
| 다건 조회·검색 | **형태 1** (다건 목록) → `[doc: screens/01_list_with_search.md]` |
| 단건 보기/편집 | **형태 2** (상세 다이얼로그) → `[doc: screens/02_detail_dialog.md]` |

## 결정 3 — 메뉴 위치

→ `[doc: menu/menu_registration.md]`

- 부모 그룹: `mywork` (이미 존재)
- 메뉴 코드: `notice`
- path: `/notice`
- 정렬: 12 (attendance 11 다음)
- 아이콘: `pi pi-megaphone`

---

## 워크스루 (처음부터 끝까지)

### Step 1 — 식별자 결정 (Pattern A Step 1)

| placeholder | 값 |
|---|---|
| `__DomainPascal__` | `Notice` |
| `__domainCamel__` | `notice` |
| `__domain-kebab__` | `notice` |
| `__DOMAIN_UPPER__` | `NOTICE` |
| `__dm_table_prefix__` | `nt2_` (`nt_` 는 notification 충돌, 신규 prefix) |
| `__domainKorean__` | `공지사항` |

### Step 2 — DB 스키마 (Pattern A Step 2)

신규 마이그레이션 `backend-core/src/main/resources/db/migration/V18__notice_schema.sql`:

```sql
CREATE TABLE platform_v3.nt2_notice (
    notice_id     VARCHAR(32) PRIMARY KEY,
    title         VARCHAR(256) NOT NULL,
    content       TEXT,
    importance    VARCHAR(16) DEFAULT 'NORMAL',
    pinned        BOOLEAN DEFAULT FALSE,
    created_by    VARCHAR(64),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP
);
CREATE INDEX idx_nt2_notice_created ON platform_v3.nt2_notice(created_at DESC);
```

### Step 3 — 메뉴·권한 등록 (`menu/menu_registration.md` Step 1~3)

신규 마이그레이션 `V19__notice_menu.sql`:

```sql
-- Step 1 (생략 — 부모 'mywork' 이미 존재)
-- Step 2: 자식 메뉴
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon)
VALUES ('notice', '공지사항', '/notice', 'mywork', 2, 12, 'pi pi-megaphone')
ON CONFLICT (menu_id) DO NOTHING;

-- Step 3: 권한
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print)
VALUES
  ('ROLE_USER',  'notice', TRUE, FALSE, FALSE, FALSE, TRUE, TRUE),
  ('ROLE_ADMIN', 'notice', TRUE, TRUE,  TRUE,  TRUE,  TRUE, TRUE)
ON CONFLICT (role_id, menu_id) DO NOTHING;
```

### Step 4 — Mapper (Pattern A Step 4)

- `backend-core/src/main/java/com/platform/v3/core/notice/mapper/NoticeMapper.java`
- `backend-core/src/main/resources/mapper/notice/NoticeMapper.xml`

```java
@Mapper
public interface NoticeMapper {
    List<Map<String,Object>> selectList(@Param("keyword") String keyword);
    Map<String,Object>      selectDetail(@Param("noticeId") String noticeId);
    int                     insertNotice(Map<String,Object> row);
    int                     updateNotice(Map<String,Object> row);
    int                     deleteNotice(@Param("noticeId") String noticeId);
}
```

### Step 5 — Service (Pattern A Step 5)

`backend-core/.../core/notice/NoticeService.java`:

```java
@Service
@RequiredArgsConstructor
public class NoticeService {
    private final NoticeMapper mapper;

    @DataSetServiceMapping("notice/searchList")
    public Map<String, Object> searchList(Map<String, Object> ds, String currentUser) {
        String keyword = ((Map<?,?>) ds.getOrDefault("ds_search", Map.of()))
                .getOrDefault("keyword", "").toString();
        var rows = mapper.selectList(keyword);
        return Map.of("ds_list", Map.of("rows", rows, "totalCount", rows.size()));
    }

    @DataSetServiceMapping("notice/searchDetail")
    public Map<String, Object> searchDetail(Map<String, Object> ds, String currentUser) {
        String id = ((Map<?,?>) ds.get("ds_data")).get("id").toString();
        return Map.of("ds_detail", Map.of("rows", List.of(mapper.selectDetail(id))));
    }

    @Transactional
    @DataSetServiceMapping("notice/save")
    public Map<String, Object> save(Map<String, Object> ds, String currentUser) {
        // requireAdmin() 가드 추가 권장
        var rows = (List<Map<String,Object>>) ((Map<?,?>) ds.get("ds_data")).get("rows");
        // ... I/U/D 분기 처리
        return Map.of("saved", rows.size());
    }
}
```

### Step 6 — 진입점

`DataSetController` 가 자동 라우팅. 별도 컨트롤러 불필요.

### Step 7 — 컨벤션 적용

- write 메서드 `@Transactional`
- ROLE_ADMIN 가드(`requireAdmin()`) — 쓰기 메서드에
- `BusinessException.notFound("notice not found")` 사용
- `log.info("notice/searchList user={} keyword={}", currentUser, keyword)`

### Step 8 — 화면 작성 (형태 1 + 형태 2)

#### 형태 1 — `ui/src/pages/PageNotice.vue`
→ `[doc: screens/01_list_with_search.md §4]` 의 가이드 따라가며 `__DomainPascal__=Notice`, `__domain-kebab__=notice` 치환.

#### 형태 2 — `ui/src/components/notice/NoticeDetailDialog.vue`
→ `[doc: screens/02_detail_dialog.md §4]` 의 가이드 따라가며 동일 치환.

### Step 9 — 라우터

`ui/src/router/index.ts` children 배열에 추가:
```typescript
{ path: 'notice', name: 'notice',
  component: () => import('@/pages/PageNotice.vue'),
  meta: { menuId: 'notice' } }
```

### Step 10 — 검증 (`menu/menu_registration.md` Step 8)

1. DB: `SELECT * FROM cm_menu WHERE menu_id='notice'` (1 row)
2. Backend: `POST /api/dataset/search { serviceName: 'notice/searchList' }` → 빈 배열
3. UI: ROLE_USER 로그인 → 사이드바 `내 업무 > 공지사항` 노출 → 클릭 → PageNotice 렌더
4. 가드: ROLE_ADMIN 로그인 → "+ 추가" 버튼 노출, ROLE_USER 는 미노출

### Step 11 — 자기검증

- [ ] `ApiResponse.ok(...)` 자동 래핑
- [ ] write 메서드 `@Transactional`
- [ ] requireAdmin() 가드 (쓰기)
- [ ] BusinessException 사용
- [ ] route path 와 menu_path 글자 일치 (`/notice`)
- [ ] cm_role_menu 행 ROLE_USER + ROLE_ADMIN

### Step 12 — PR

PR 제목: `feat(notice): 공지사항 도메인 추가 (CRUD)`
설명: 결정 트리 결과 + V18/V19 마이그레이션 + Pattern A SOP + 형태 1/2 적용 + 메뉴 8단계.
