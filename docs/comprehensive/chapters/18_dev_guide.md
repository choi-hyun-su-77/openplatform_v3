# Chapter 1.18 — 개발 가이드 (Developer Guide)

**Project**: openplatform_v3 | **Date**: 2026-04-27
**Scope**: 코드 추가/수정 시 따라야 할 워크스페이스 규칙·자율 모드·재사용 정책·백엔드/프엔 컨벤션·셀프 QA 절차.

---

## 0. CODING_STANDARDS.md 부재에 대한 솔직 진술

본 저장소에는 **`CODING_STANDARDS.md` 가 존재하지 않는다**. (`docs/comprehensive/warn.md` Phase 0.C 갭 분석 — "CLAUDE.md + warn.md 결정 이력 + 컨벤션 grep 결과로 대체") [src: docs/comprehensive/warn.md L18]

본 챕터는 다음 3개 권위 정보원에서 사실상의 규약을 추출한다.

1. `C:/claude/CLAUDE.md` — 워크스페이스 공통
2. `C:/claude/openplatform_v3/CLAUDE.md` — 프로젝트 규칙
3. `warn.md` — 자율 결정 이력 (드래그 라이브러리 미채택, SVG 직접 구현 등)

명시적 표준 문서 부재 상태이며, 별도 `docs/CODING_STANDARDS.md` 작성이 권장된다.

---

## 1. 워크스페이스 공통 규칙

### 1.1 포트 할당 — 19xxx 전용
- 본 프로젝트 호스트 포트 대역은 **19xxx**. UI dev 만 25174 (자율 결정 — `warn.md [2026-04-14 22:15]`).
- 신규 포트 시 **3단계 필수**: ① 루트 `docker-info.xml` `<port-conflicts>` 충돌 확인 → ② 자기 프로젝트 `<service>` 갱신 → ③ `port-change-report.md` 이력 기록. [src: C:/claude/CLAUDE.md "포트 할당 규칙"]
- IANA ephemeral 범위(49152–65535) 회피, **1024–49151 만** 사용.

### 1.2 v1/v2 무복사 + Docker SSoT + 서브모듈
- v1(`openplatform`)/v2(`openplatform_v2`)는 **분석 후 필요 요소만 선택 포팅**. 통째 복사 금지. [src: warn.md L116-119]
- 루트 `docker-compose.yml` + `docker-info.xml` 은 단일 권위 소스. 컨테이너 추가/삭제 시 두 파일 모두 갱신. compose 최상단 `name:` 으로 프로젝트명 고정 (하이재킹 방지). [src: C:/claude/CLAUDE.md]
- **본 프로젝트는 서브모듈 없음.** 모든 코드 직접 관리. [src: openplatform_v3/CLAUDE.md "## 서브모듈"]

---

## 2. 자율 모드 운영

[src: C:/claude/CLAUDE.md "최상위 규칙: 완전 자율 실행"]

| 상황 | 행동 |
|---|---|
| 사용자에게 질문하고 싶을 때 | **금지.** 합리적 기본값 채택 후 `warn.md` 1행 기록 |
| 파일 생성/수정/삭제, 패키지 설치, Docker 실행, git push | 승인 없이 즉시 진행 |
| 외부 서비스 불가 | 로컬 mock 으로 대체 → `warn.md` 기록 |
| 오류 발생 | 원인 분석 → 수정 → 재검증 자동 반복 (최대 5회). 5회 초과 시 `fatal.md` + 사용자 알림 |
| 애매한 요구사항 | 합리적 기본값 결정 → `warn.md` 기록 |

**상태 파일 (1분 단위 갱신)**: `info.md` (현재 태스크) / `warn.md` (결정 이력) / `fatal.md` (치명 중단) / `TODO.md` (Phase 체크리스트).

---

## 3. AI 생성 제약 — vue-spring-fw 재사용 정책

`C:\claude\vue-spring-fw\**` 는 **원본 절대 수정 금지**. 정적 복사 후 `ui/src/**` 에 배치, 복사 이력은 `docs/vue-spring-fw-reuse-map.md` 에 (원본 → v3경로 → 수정사항) 1행씩 기록. [src: openplatform_v3/CLAUDE.md "## vue-spring-fw 취급 규칙"]

| 분류 | 정책 |
|---|---|
| `frontend/src/components/layout/Layout*.vue` | 복사 OK (메뉴 데이터 소스만 v3 교체) |
| `frontend/src/components/common/*.vue` (CrudToolbar/SearchPanel/PopupHost) | 복사 OK |
| `composables/use*.ts` (9개) | 복사 OK (API base URL `/api`, Keycloak roles 매핑) |
| `store/auth.ts` | **keycloak-js 어댑터로 교체** (JWT 자체 발급 → OIDC PKCE) |
| `api/interceptor.ts` | **Bearer 를 Keycloak access token 으로 교체**, 401 → `keycloak.updateToken()` |
| `pages/templates/*.vue` (Chart/Map/Flow/Kanban...) | 레퍼런스 참조, 필요 시 선택 복사 |
| `backend/**`, `docker/**`, `mybatis mapper XML`, `pages/admin/**` | **복사 금지** |
| 원본 어떤 파일도 수정 | **금지** |

---

## 4. 백엔드 규약 (DataSet 패턴)

### 4.1 표준 도메인 디렉토리 (예: `widget`)
[code: backend-core/.../widget/WidgetService.java]

```
backend-core/src/main/java/com/platform/v3/core/{domain}/
├── {Domain}Service.java          ← @Service + @DataSetServiceMapping
└── mapper/{Domain}Mapper.java    ← MyBatis 인터페이스
backend-core/src/main/resources/
├── mapper/{domain}/{Domain}Mapper.xml   ← 동적 SQL
└── db/migration/V{N}__{feature}.sql     ← Flyway 전진-only
```

### 4.2 DataSetService 어노테이션
[code: backend-core/.../widget/WidgetService.java:L63-L186]

```java
@Service
public class WidgetService {
    @DataSetServiceMapping("widget/listAll")
    @Transactional(readOnly = true)
    public Map<String, Object> listAll(Map<String, Object> params) { ... }

    @DataSetServiceMapping("widget/saveLayout")
    @Transactional
    public Map<String, Object> saveLayout(Map<String, Object> params) {
        String rowType = DataSetSupport.toStr(row.get("_rowType"));  // C/U/D 분기
    }
}
```

핵심:
- **단일 진입점**: `POST /api/dataset` → `ServiceRegistry` 가 `service` 키로 `@DataSetServiceMapping` 메서드 라우팅. [code: backend-core/.../dataset/DataSetController.java]
- **시그니처**: `Map<String,Object>` 입출력. snake_case ↔ camelCase 자동 변환 (`map-underscore-to-camel-case: true`).
- **`_rowType`**: UI 그리드 변경분을 `C` (Create) / `U` (Update) / `D` (Delete) 마킹.
- **트랜잭션**: 조회 = `readOnly=true`, 변경 = `@Transactional`. 1메서드 = 1트랜잭션.
- **응답·예외**: `ApiResponse<T>` 봉투 + `BusinessException` → `GlobalExceptionHandler` 매핑. [code: backend-core/.../common/]

### 4.3 MyBatis 동적 SQL · 순환 의존 회피
- `<choose>/<when>/<otherwise>`, `<if test="...">`, `<foreach>`, `useGeneratedKeys="true" keyProperty="docId"` (BIGSERIAL 자동 채움). 챕터 1.10 §1 상세.
- 같은 Wave 의 트랙 미존재 가능성 → `@Autowired(required = false) setter` 주입 [src: warn.md "T1 근태"]:
  ```java
  @Autowired(required = false)
  public void setLeaveService(LeaveService s) { this.leaveService = s; }
  ```

---

## 5. 프론트엔드 규약 (Vue 3 SFC)

### 5.1 `<script setup lang="ts">` 작성 순서 (챕터 1.8 §1)

```
(a) Types & Interfaces
(b) Composables & API 호출  →  const approval = useApproval();
(c) Props & Emits
(d) Reactive State (ref/reactive/computed)
(e) Actions & Handlers
(f) Lifecycle (onMounted/...)
```

### 5.2 useXxx Composable / Pinia / 네이밍
- `ui/src/composables/use{Domain}.ts` (현 23개). 1함수 = 1 DataSet 서비스 호출 → `ApiResponse` unwrap → ref 반환.
- Pinia store: `defineStore('{name}', () => { ... })` Composition API. `auth.ts` (Keycloak), `tab.ts` (탭바).
- 컴포넌트 prefix: `Layout*` / `Widget*` / `Page*` / `App*`. 다이얼로그는 `{Domain}{Action}Dialog.vue` (예: `ApprovalSubmitDialog.vue`).

---

## 6. 커밋·브랜치 규약 (`git log` 기반)

| Prefix | 용도 |
|---|---|
| `feat:` / `feat({domain}):` | 새 기능 (예: `feat(approval): Phase A complete`) |
| `fix:` / `fix({area}):` | 버그 수정 (예: `fix(sso): unify Keycloak host`) |
| `chore:` | 유지보수·문서·gitignore |
| `docs({domain}):` | 도메인별 문서 |
| `test:` | 테스트 추가 (예: `test: Playwright E2E scenarios`) |

브랜치는 단일 `main` 만 사용 (현재 git status). PR/머지 워크플로우는 코드베이스 미명시.

---

## 7. 금지·자제 사항 (warn.md 기반 사실상의 규약)

신규 npm 패키지 추가는 **자제**. 자율 결정 이력이 사실상의 규약 형성:

| 시도 | 채택 결정 | 출처 |
|---|---|---|
| `vuedraggable`/`Sortable.js` (드래그 정렬) | 미채택 → ▲▼ 버튼 + 일괄 호출 | warn.md T6 |
| `vue-grid-layout` (대시보드 드래그) | 미채택 → 화살표 버튼(←→↑↓ + W±/H±) + CSS Grid `order` + `--w/--h` | warn.md T7 |
| `Chart.js` (차트) | 미채택 → SVG `<circle>×2` (donut) / `<rect>×12` (막대) 직접 구현 | warn.md T1 / T7 |
| `md-editor-v3` (마크다운) | 미채택 → PrimeVue `Textarea` + 줄바꿈 처리 | warn.md Phase B |

원칙: 50명 규모 + SVG 직접 구현 가능 범위에서는 자체 구현 우선. 외부 패키지 도입 시 `warn.md` 도입 사유 기록.

---

## 8. 셀프 QA 루프 (CLAUDE.md 정의)

[src: openplatform_v3/CLAUDE.md "## 셀프 QA 루프"]

| 레이어 | 시점 | 도구 |
|---|---|---|
| Layer 0 — 정적 분석 | 개발 단위마다 즉시 | `mvn compile`, `vue-tsc --noEmit`, ESLint |
| Layer 1 — 단위 테스트 | 개발 단위마다 즉시 | (현재 미흡 — JUnit + Testcontainers 권장. 챕터 1.14 참조) |
| Layer 4 — E2E | Phase 종료 시 | **Playwright MCP** (필수) |

**CODING_STANDARDS 11항목 자기검증 체크리스트는 부재**. 본 챕터를 토대로 한 권장 11항목 초안:

1. `@DataSetServiceMapping("{domain}/{action}")` 형식 정확
2. 트랜잭션 경계 적절 (`readOnly=true` / `@Transactional`)
3. `_rowType` C/U/D 분기 처리
4. MyBatis 동적 SQL `<if>/<choose>` 사용
5. `ApiResponse<T>` 봉투 응답
6. `BusinessException` 으로 비즈니스 오류
7. Vue SFC `<script setup>` 순서 (a~f)
8. useXxx 1함수 = 1서비스
9. 신규 npm 패키지 미추가 (도입 시 warn.md 기록)
10. vue-spring-fw 원본 무수정 + 복사 이력 기록
11. 자율 결정은 `warn.md` 1행 기록

---

## 9. 신규 도메인 추가 절차 — 11단계 체크리스트

새 도메인 `Foo` 추가 시:

| # | 작업 | 위치 |
|---|---|---|
| 1 | DDL 작성 | `backend-core/src/main/resources/db/migration/V{N}__foo.sql` |
| 2 | Mapper 인터페이스 | `core/foo/mapper/FooMapper.java` |
| 3 | Mapper XML | `mapper/foo/FooMapper.xml` |
| 4 | Service + `@DataSetServiceMapping` | `core/foo/FooService.java` |
| 5 | (선택) BFF Port-Adapter | `backend-bff/.../port/FooPort.java` + `adapter/FooAdapter.java` |
| 6 | composable | `ui/src/composables/useFoo.ts` |
| 7 | Page 컴포넌트 | `ui/src/pages/PageFoo.vue` |
| 8 | (선택) 다이얼로그 | `ui/src/components/foo/Foo{Action}Dialog.vue` |
| 9 | router 등록 | `ui/src/router/index.ts` |
| 10 | 메뉴 INSERT | `cm_menu` 마이그레이션 SQL |
| 11 | Playwright E2E | smoke 시나리오 1건 |

> **공유 파일 충돌 회피**: 같은 Wave 병렬 작성 시 `router/index.ts`, `LayoutSidebar.vue`, `App.vue` 는 **트랙 8 통합 책임**으로 일괄 처리. 개별 트랙은 자기 도메인 파일만. [src: warn.md "Phase 14 Wave 1 spawn"]

---

## 참조

**1차 정보원**:
- `C:/claude/CLAUDE.md` (워크스페이스 공통)
- `C:/claude/openplatform_v3/CLAUDE.md` (프로젝트 규칙)
- `C:/claude/openplatform_v3/warn.md` (자율 결정 이력)
- `docs/vue-spring-fw-reuse-map.md` (재사용 추적표)
- `developer_manual_codebase_driven_prompt.md` (메타 프롬프트)
- `docs/comprehensive/warn.md` (Phase 0.C 갭 분석)

**코드 출처**:
- `backend-core/.../widget/WidgetService.java` (DataSet 표준 패턴)
- `backend-core/.../dataset/DataSetController.java` (단일 진입점)
- `backend-core/.../common/{ApiResponse,BusinessException,GlobalExceptionHandler,DataSetSupport}.java`
- `git log --oneline -30` (커밋 prefix 규약)

**인접 챕터**: 1.8 (Vue SFC 상세) · 1.10 (MyBatis·트랜잭션·응답 상세) · 1.14 (테스트 인프라 현황) · 1.19 (알려진 미완 항목)

---

## 이 챕터가 다루지 않은 인접 주제

- **CODING_STANDARDS.md 정식 본문** — §0 에서 부재 명시. §8 의 권장 11항목 초안을 출발점으로 후속 작성.
- **PR 코드리뷰 체크포인트** — `developer_manual_codebase_driven_prompt.md` Phase 1.11 산출물로 정의되어 있으나 미작성.
- **Pre-commit hook / lint-staged** — husky/lint-staged 설정 부재. ESLint/vue-tsc 는 IDE 단위.
- **테스트 컨벤션 (JUnit/Vitest)** — 챕터 1.14. 현 상태=E2E only, 권장=JUnit + Testcontainers + Vitest.
- **CI/CD 파이프라인** — GitHub Actions 등 미구성. 챕터 1.13 (단일 노드 docker compose 운영).
- **로깅·추적** — 챕터 1.11 (cid/hint 필드, AOP `AdminAuditAspect`, Loki+Promtail).
- **보안 코딩 (입력 검증/SQLi/XSS/OWASP)** — 챕터 1.12 (RBAC, JWT, OWASP Top 10).
- **i18n 작성 컨벤션** — V9 마이그레이션 98×4 lang 라벨 패턴 (챕터 1.4 / 1.7).
- **신규 외부 서비스 연동 절차** — 챕터 1.3 federation + 챕터 1.12 OIDC 등록 결합 (`recipes/04_add_external_integration.md` 권장).
