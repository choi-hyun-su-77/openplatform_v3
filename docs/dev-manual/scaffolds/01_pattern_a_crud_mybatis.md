# scaffolds/01_pattern_a_crud_mybatis.md — Pattern A: 표준 CRUD + MyBatis

> Phase 2.1 산출물. 단일 도메인 영속, MyBatis Mapper 1개, DataSet 진입점.
> 모범 도메인: **board** (게시판) — `[code: backend-core/.../board/]`

## 적용 시점
- 외부 시스템 호출 없음
- 워크플로 / state machine 없음
- 단일 도메인 CRUD (search / save / delete)
- 권한: implicit (currentUser) 또는 (public)

## 사전 결정 체크
- 도메인 식별자(0.E 변환규칙 적용): `__DomainPascal__`, `__domain-kebab__`, `__dm_table_prefix__`
- 화면 형태 결정: `screens/00_screen_decision.md` 참조 (목록형 → 형태 1)
- 권한 결정: `ROLE_USER` 만으로 충분한가, `ROLE_ADMIN` 가드 필요한가

---

## Step 1 — 사전 결정 (식별자/화면/권한)

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | 결정만 수행 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | (예: `Notice`) | 전 단계 |
| `__domain-kebab__` | (예: `notice`) | 전 단계 |
| `__dm_table_prefix__` | (예: `nt_`) | 전 단계 |
| `__DOMAIN_UPPER__` | (예: `NOTICE`) | 전 단계 |

---

## Step 2 — 영속 계층 (DDL/스키마/마이그레이션)

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: backend-core/src/main/resources/db/migration/V4__board_calendar.sql]` (board CREATE TABLE 블록) | `V{N+1}__{domain}_schema.sql` | `__dm_table_prefix__`, `__domain_snake__` | |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `backend-core/src/main/resources/db/migration/V{N+1}__{domain}_schema.sql` | 도메인 테이블 마이그레이션 | `templates/pattern_a/V__schema.sql.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__dm_table_prefix__` | (예: `nt_`) | 마이그레이션 |
| `__domain_snake__` | (예: `notice`) | 마이그레이션 |
| `__DomainPascal__` | (예: `Notice`) | 주석 |

### DDL 패턴
```sql
CREATE TABLE platform_v3.__dm_table_prefix__main (
    __domain_snake___id  VARCHAR(32) PRIMARY KEY,
    title                VARCHAR(256) NOT NULL,
    content              TEXT,
    created_by           VARCHAR(64),
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP
);
CREATE INDEX idx___dm_table_prefix__main_created ON platform_v3.__dm_table_prefix__main(created_at DESC);
```

---

## Step 3 — 메뉴·권한 메타데이터 등록

> **본 Step 은 `menu/menu_registration.md` 8단계 절차로 위임. 절대 본 SOP 에 중복 서술 금지.**

→ `[doc: menu/menu_registration.md]` 의 Step 1~5, Step 8 수행.

---

## Step 4 — 데이터 액세스 계층 (Mapper)

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: backend-core/.../board/mapper/BoardMapper.java]` | `backend-core/.../{domain}/mapper/{DomainPascal}Mapper.java` | `__DomainPascal__`, `__domain_snake__` | |
| `[code: backend-core/src/main/resources/mapper/board/BoardMapper.xml]` | `backend-core/src/main/resources/mapper/{domain}/{DomainPascal}Mapper.xml` | namespace, `__dm_table_prefix__` | |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `backend-core/.../core/{domain}/mapper/{DomainPascal}Mapper.java` | Mapper 인터페이스 | `templates/pattern_a/Mapper.java.tmpl` |
| `backend-core/src/main/resources/mapper/{domain}/{DomainPascal}Mapper.xml` | MyBatis 매퍼 XML | `templates/pattern_a/Mapper.xml.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | (예: `Notice`) | Mapper 인터페이스, XML namespace |
| `__domain-kebab__` | (예: `notice`) | XML 폴더 |
| `__dm_table_prefix__` | (예: `nt_`) | SQL 테이블명 |

---

## Step 5 — 비즈니스 로직 (Service)

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: backend-core/.../board/BoardService.java]` | `backend-core/.../{domain}/{DomainPascal}Service.java` | `__DomainPascal__`, `__domain-kebab__`, `__domainCamel__` | `@DataSetServiceMapping("__domain-kebab__/...")` 필수 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `backend-core/.../core/{domain}/{DomainPascal}Service.java` | Service | `templates/pattern_a/Service.java.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음 — 새 Service 추가만) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | (예: `Notice`) | 클래스명, Mapper 주입 |
| `__domain-kebab__` | (예: `notice`) | DataSet serviceName 접두 |
| `__domainCamel__` | (예: `notice`) | 변수명 |

---

## Step 6 — 진입점 / 라우팅

> Pattern A 는 `DataSetController` 를 진입점으로 공유한다. 별도 컨트롤러 작성 불필요.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | DataSet 라우터 자동 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

> public REST 엔드포인트가 필요하면 `[code: backend-core/.../code/CodeController.java]` 를 참고하여 별도 Controller 작성.

---

## Step 7 — 표준 응답·로깅 컨벤션 적용

→ `[doc: inventory/07_conventions.md §1, §2]` 의 체크리스트를 따른다.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음, 컨벤션만 적용) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| Service 메서드 | 메서드 본문 | `log.info("__domain-kebab__/searchList user={} keyword={}", currentUser, keyword);` |
| Service write 메서드 | 메서드 시그니처 | `@Transactional` 추가 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__domain-kebab__` | 도메인 코드 | 로그 키 |

---

## Step 8 — 화면 작성

→ `[doc: screens/{형태}.md]` 참조. 화면 형태에 맞춰 SOP 따라감.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (화면 형태 SOP 의 표 1 사용) | — | — | 위임 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (화면 형태 SOP 의 표 2 사용) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (화면 형태 SOP 의 표 3 사용) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (화면 형태 SOP 의 표 4 사용) | — | — |

---

## Step 9 — 클라이언트 라우터 / 메뉴 매핑

→ `[doc: menu/menu_registration.md Step 5]` 위임.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음, menu_registration.md Step 5 위임) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/router/index.ts` | children 배열 | route entry 추가 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__domain-kebab__` | path / name / meta.menuId | router/index.ts |

---

## Step 10 — 테스트

> 갭(`[doc: inventory/09_gaps.md §1]`): 자동 테스트 인프라 부재. 본 Step 은 권장 단계.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음, 신규 도입 시 작성) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (선택) `backend-core/src/test/java/.../{domain}/{DomainPascal}ServiceTest.java` | 서비스 단위 테스트 | (없음) |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 테스트 클래스명 | (선택) |

> 단위 테스트가 없으므로 수동 검증 권장:
> 1. `POST /api/dataset/search { serviceName: "__domain-kebab__/searchList" }` 200 OK 확인
> 2. UI 페이지에서 행 클릭 → 상세 노출 확인
> 3. 저장/삭제 후 재조회 시 변경 반영 확인

---

## Step 11 — 자기검증 (컨벤션 체크리스트)

→ `[doc: inventory/07_conventions.md §8]` 의 체크리스트 적용.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (자기검증 - 발견한 누락이 있다면 해당 Step 으로 회귀) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

체크 항목:
- [ ] `ApiResponse.ok(...)` 사용
- [ ] write 메서드 `@Transactional`
- [ ] `BusinessException.{notFound|duplicate|forbidden|badRequest}` 사용
- [ ] 로그에 currentUser/serviceName 키
- [ ] DB 마이그레이션 IDEMPOTENT (`ON CONFLICT DO NOTHING`)
- [ ] route path 와 menu_path 글자 일치

---

## Step 12 — PR 준비

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (PR description) | (외부 시스템) | 변경 요약 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

PR 체크리스트는 `[doc: HANDBOOK.md 11장]` 사용.

---

## 모범 워크스루 — `board` 도메인 따라가기

> 모범: `[doc: inventory/08_references.md]` 선정. `board` 도메인을 처음부터 끝까지 따라가는 1페이지.

1. **Step 2 (DDL)**: `[code: backend-core/src/main/resources/db/migration/V4__board_calendar.sql]` 가 `bd_post`, `bd_comment`, `bd_attachment` 테이블 생성. PK `post_id`, `created_at` 인덱스.
2. **Step 3 (메뉴)**: `[code: V17__phase14_menus.sql]` 의 `board` 메뉴 등록 (parent=`work` 또는 `mywork`, path=`/board`).
3. **Step 4 (Mapper)**: `[code: backend-core/.../board/mapper/BoardMapper.java]` + XML — `selectPostList`, `selectPostDetail`, `insertPost`, `updatePost`, `deletePost`.
4. **Step 5 (Service)**: `[code: backend-core/.../board/BoardService.java]` — `@DataSetServiceMapping("board/searchPosts")`, `@DataSetServiceMapping("board/savePost")` 등. write 메서드에 `@Transactional`.
5. **Step 6 (진입점)**: `DataSetController.search/save` 가 `serviceName="board/..."` 를 BoardService 메서드로 라우팅.
6. **Step 7 (컨벤션)**: 응답은 `ApiResponse.ok(...)` 자동 래핑(컨트롤러 레벨), 로깅은 `log.info("board/searchPosts user={} ...", user)`.
7. **Step 8 (화면)**: `[code: ui/src/pages/PageBoard.vue]` — 형태 1(목록) + 형태 2(상세 다이얼로그) 결합. DataTable + BoardDetailDialog.
8. **Step 9 (라우터)**: `[code: ui/src/router/index.ts]` 의 children 에 `{ path: 'board', name: 'board', component: () => import('@/pages/PageBoard.vue'), meta: { menuId: 'board' } }`.
9. **Step 10 (테스트)**: 코드베이스에는 자동 테스트 부재 → 수동 시나리오 검증.
10. **Step 11~12 (자기검증·PR)**: 컨벤션 체크리스트 통과 후 PR.
