# openplatform_v3 개발자 핸드북 (HANDBOOK.md)

> 단일 입구 문서. 첫날 펼치는 책. 각 장은 1~2페이지, 상세는 후속 SOP 링크.
> 모든 사실 주장은 `inventory/` 의 1차 정보원 인용.

---

## 0장. 5분 요약

| 영역 | 한 줄 요약 |
|---|---|
| 아키텍처 | Vue 3 SPA → Spring Boot BFF (WebFlux) → Spring Boot Core (Servlet) → PostgreSQL/Redis/Flowable + 외부 마이크로서비스(Keycloak/MinIO/Rocket.Chat/Stalwart/Wiki.js/LiveKit) `[doc: README.md]` |
| 기술 스택 | Spring Boot 3.2.5 / Java 17 / Vue 3.5 / PrimeVue 4.3 / PostgreSQL 16 / Flowable 7.1 / Keycloak 24 `[doc: inventory/01_tech_stack.md]` |
| **백엔드 패턴** | **4종** — A 표준 CRUD / B Flowable Workflow / C BFF Port-Adapter / D Read-only 집계 `[doc: inventory/02_backend_patterns.md]` |
| **화면 형태** | **9종** — 다건 목록 / 단건 상세 / 마스터-디테일 / 캘린더 / 대시보드 / 다단계 입력 / SSO 래퍼 / 실시간 / 폼 매트릭스 `[doc: inventory/03_screen_types.md]` |
| **메뉴 등록** | **8단계** (필수 5 + 선택 3) → `menu/menu_registration.md` |
| 도메인 수 | backend-core 17개, BFF Adapter 6개 |
| DB 진화 | Flyway V1~V17, 모든 마이그레이션 `backend-core/src/main/resources/db/migration/` |
| 진입점 | DataSet 단일 라우터 (`POST /api/dataset/{search|save}`, `serviceName` 으로 분기) `[doc: inventory/02_backend_patterns.md §8]` |

---

## 1장. 환경 셋업

### 사전 요구
- Java 17 (Eclipse Temurin 권장)
- Node.js 20+
- Docker + Docker Compose
- Maven 3.9+

### 빠른 시작 (전체 기동)
```bash
cd /c/claude/openplatform_v3
./start.sh
```
모든 13 서비스가 `infra/docker-compose.yml` 기준으로 기동 + backend-core health 폴링 후 준비 완료.

### 모드별 기동
```bash
./scripts/start.sh dev            # base 만(core/bff/postgres/redis/keycloak)
./scripts/start.sh full           # base + healthcheck + resource limits
./scripts/start.sh observability  # + Prometheus/Grafana
./scripts/start.sh production     # 모든 overlay + cron
```

### UI dev 서버
```bash
cd ui && npm install && npm run dev   # http://localhost:25174
```

### 검증 (모두 200 OK)
```bash
curl http://localhost:19090/actuator/health
curl http://localhost:19091/actuator/health
curl http://localhost:19281/realms/openplatform-v3/.well-known/openid-configuration
```

자세한 포트·자격증명 표는 `[doc: inventory/01_tech_stack.md §5]` 참조.

---

## 2장. 첫 작업까지의 길 — "도메인 추가" 시나리오

신규 도메인(예: `notice` 공지사항)을 추가하는 표준 흐름.

```
[결정 1] 백엔드 패턴   → scaffolds/00_decision_tree.md
[결정 2] 화면 형태     → screens/00_screen_decision.md
[결정 3] 메뉴 등록     → menu/menu_registration.md
[종합]   레시피        → recipes/01_add_new_domain.md
```

가장 자주 펼치는 문서는 `recipes/01_add_new_domain.md` 이며 위 결정 결과를 종합해 처음부터 끝까지 따라간다.

---

## 3장. 명명 규칙

`[doc: inventory/04_naming.md]` 참조. 핵심 표 요약:

| 표기 | 변환 | 예시 (`approval`) |
|---|---|---|
| `__DomainPascal__` | PascalCase | `Approval` |
| `__domainCamel__` | camelCase | `approval` |
| `__domain-kebab__` | kebab-case | `approval` |
| `__DOMAIN_UPPER__` | UPPER | `APPROVAL` |
| `__dm_table_prefix__` | 2~3 letter | `ap_` |

규칙:
- Java Service 클래스: `{DomainPascal}Service`
- Mapper: `{DomainPascal}Mapper` + XML 동일명
- DataSet 액션: `@DataSetServiceMapping("{domainKebab}/{actionCamel}")`
- DB 테이블 prefix: 2~3 letter (`ap_`, `bd_`, `cal_`, `nt_`, `at_`, `rm_`, `dl_`, `wr_`, `org_`, `cm_`, `dw_`, `ux_`, `sa_`)
- UI 페이지: `Page{DomainPascal}.vue`
- 메뉴 코드: `{domainKebab}`
- i18n: `LBL_{DOMAIN}_*`, `MENU_{DOMAIN}`, `MSG_{DOMAIN}_*`

---

## 4장. 백엔드 패턴 결정 트리

`scaffolds/00_decision_tree.md` 요약:

```
외부 시스템 호출 필요?
├─ YES → Pattern C (BFF Port-Adapter) → scaffolds/03_pattern_c_bff_adapter.md
└─ NO
   └─ 워크플로/state machine 필요?
      ├─ YES → Pattern B (Flowable + Delegates) → scaffolds/02_pattern_b_workflow_flowable.md
      └─ NO
         └─ Read-only/집계?
            ├─ YES → Pattern D → scaffolds/04_pattern_d_aggregation_readonly.md
            └─ NO  → Pattern A (단순 CRUD) → scaffolds/01_pattern_a_crud_mybatis.md
```

상세는 `[doc: inventory/02_backend_patterns.md §3]` 참조.

---

## 5장. 화면 형태 결정 트리

`screens/00_screen_decision.md` 요약:

```
"사용자가 무엇을 하려 하는가?"

다건 조회 → 형태 1 (다건 목록)            → screens/01_list_with_search.md
단건 보기/편집 → 형태 2 (상세 다이얼로그)   → screens/02_detail_dialog.md
계층 탐색(부서/폴더) → 형태 3 (마스터-디테일) → screens/03_master_detail.md
일정 관리 → 형태 4 (캘린더)                → screens/04_calendar_grid.md
KPI/요약 → 형태 5 (대시보드)               → screens/05_dashboard_widgets.md
다단계 신청 → 형태 6 (다단계 다이얼로그)    → screens/06_multistep_dialog.md
외부 SSO → 형태 7 (SSO 래퍼)               → screens/07_sso_wrapper.md
실시간 협업 → 형태 8 (실시간)               → screens/08_realtime.md
설정 매트릭스 → 형태 9 (폼 매트릭스)        → screens/09_form_matrix.md
```

---

## 6장. 화면 파일 작성 순서 (단일 페이지 기준)

`[doc: inventory/03_screen_types.md]` + `[doc: inventory/06_ui_components.md]` 종합:

1. **새 페이지 파일 생성**: `ui/src/pages/Page{DomainPascal}.vue`
2. **Vue Router 등록** (`ui/src/router/index.ts`): path / name / component / meta.menuId
3. **상단 import**: PrimeVue 컴포넌트 + axios + dayjs. 형태 4(캘린더)면 `@fullcalendar/vue3`, 형태 8(실시간)이면 `livekit-client` 추가
4. **template**: 형태별 레이아웃 (목록/상세/마스터-디테일 등 — `screens/*.md` 의 SOP 따라감)
5. **script setup**: 데이터 fetch (`axios.post('/api/dataset/search', { serviceName, datasets })`)
6. **자식 다이얼로그 (형태 1·3 가 형태 2 와 결합되는 경우)**: `ui/src/components/{domain}/{Domain}{Role}Dialog.vue`
7. **i18n 라벨 추가**: 마이그레이션 또는 직접 cm_i18n_message 시드
8. **메뉴 등록**: `menu/menu_registration.md` 의 8단계 절차 따름

---

## 7장. 응답·예외·로깅 컨벤션

`[doc: inventory/07_conventions.md]`:

- **응답 봉투**: `ApiResponse<T>` (success/data/message/error/errors) — 팩토리 `ok()`, `fail()`, `validationFail()`
- **컨트롤러 표준 반환**: `return ApiResponse.ok(...)`
- **예외 매핑**: `BusinessException.notFound|duplicate|forbidden|badRequest` → `GlobalExceptionHandler` 가 HTTP 매핑
- **로깅**: SLF4J Logger per class. 키: `username`, `employee_no`, `serviceName`, `keyword`. (MDC traceId 갭)
- **트랜잭션**: write 메서드에 `@Transactional`, read 는 미사용. (`readOnly=true` 갭)

---

## 8장. 권한 모델

`[doc: inventory/07_conventions.md §4]`:

- 역할: `ROLE_USER`, `ROLE_APPROVER`, `ROLE_MANAGER`, `ROLE_ADMIN`
- 인증: Keycloak JWT OAuth2 Resource Server, stateless
- JWT → 사번 변환: `DataSetController.currentUser()` 가 `preferred_username → org_employee.keycloak_user_id → employee_no`
- Admin 가드: `requireAdmin()` 메서드 호출(`AdminService:400-410`)
- 워크플로 가드: `verifyDocAccess()` (소유자 + 결재선)
- 메뉴 권한: `cm_role_menu` 의 `can_*` 플래그 + router `beforeEach` `requiresAdmin` 가드

---

## 9장. 메뉴 등록 8단계 요약

`menu/menu_registration.md` 본문 참조. 단계 한 줄 요약:

1. 부모 메뉴 INSERT (기존 부모 그룹에 매달지 않을 때만) — `cm_menu` level=1
2. 자식 메뉴 INSERT — `cm_menu` level=2 + `menu_path`
3. Role-Menu 권한 INSERT — `cm_role_menu`
4. Vue 페이지 생성 — `ui/src/pages/Page{DomainPascal}.vue`
5. Vue Router 등록 — `ui/src/router/index.ts` `meta.menuId`
6. (선택) Tab 아이템 — 자동 생성, 수동 X
7. (선택) i18n 라벨 INSERT — `cm_i18n_message`
8. 권한 검증 테스트 — DB → API → 사이드바 → 가드

---

## 10장. 레시피 인덱스

| 레시피 | 목적 |
|---|---|
| `recipes/01_add_new_domain.md` | 새 도메인 추가 전 과정 (3 결정 + 워크스루) |
| `recipes/02_add_new_field.md` | 기존 도메인에 컬럼/필드 1개 추가 |
| `recipes/03_add_new_role.md` | 권한 모델에 역할 추가 |
| `recipes/04_add_external_integration.md` | 외부 시스템 연동 추가 |

---

## 11장. PR·코드리뷰 체크포인트

`[doc: inventory/07_conventions.md §8]` 의 컨벤션을 PR 체크리스트로:

- [ ] Controller 가 `ApiResponse.ok(...)` 또는 `fail(...)` 반환
- [ ] Service write 메서드에 `@Transactional` 명시
- [ ] 권한 분기 → `requireAdmin()` 또는 `verifyDocAccess()` (Pattern B)
- [ ] 비즈니스 예외 → `BusinessException.{notFound|duplicate|forbidden|badRequest}`
- [ ] 감사 대상은 `@DataSetServiceMapping("admin/*")` 패턴 사용
- [ ] 로깅에 currentUser/serviceName 키 포함
- [ ] DB 마이그레이션은 V{N+1} 단조 증가 + IDEMPOTENT (`ON CONFLICT DO NOTHING`)
- [ ] UI 페이지에 `meta.menuId` + 라우트 path 일치 (`menu_path` 와)
- [ ] `cm_role_menu` 행 추가 (ROLE_USER + ROLE_ADMIN)
- [ ] PrimeVue 컴포넌트 외 신규 라이브러리 도입 시 사유 명시
- [ ] vue-spring-fw 원본 수정 금지 (`[code: docs/vue-spring-fw-reuse-map.md]`)
- [ ] 포트 변경 시 `docker-info.xml` + `port-change-report.md` 동기화

---

## 12장. 트러블슈팅 FAQ

| 증상 | 원인 후보 | 해결 |
|---|---|---|
| `/api/dataset/search` 500 | `serviceName` 미등록(`@DataSetServiceMapping`) | `DataSetServiceRegistry` 로그 확인, classpath 스캔 시 빈 등록 여부 |
| 사이드바에 메뉴 안 보임 | `cm_menu` row 또는 `cm_role_menu` 누락 | DB 직접 조회, role_menu의 `can_read=TRUE` 확인 |
| `/403` redirect | `meta.requiresAdmin=true` 인데 `ROLE_ADMIN` 없음 | Keycloak 역할 부여 또는 라우트 meta 수정 |
| Keycloak SSO 실패 | 호스트가 `kc.localtest.me` 아님 | `/etc/hosts` 또는 RFC 2606 사용 확인 |
| LiveKit join 실패 | 토큰 발급 실패 | `/api/bff/video/token` 응답 확인, LIVEKIT_KEY/SECRET |
| MinIO upload 실패 | presigned URL 만료 | URL TTL 확인, BFF `presignedPutUrl` 재발급 |
| Flyway 마이그레이션 실패 | V{N} 중복 / 체크섬 불일치 | `flyway_schema_history` 정리, dev 환경에서만 `repair` |

---

## 13장. 부록

### 용어집

| 용어 | 의미 |
|---|---|
| **DataSet** | UI ↔ Backend 표준 데이터 전송 형식 (`{ ds_*: { rows: [{ _rowType, ... }] } }`) |
| **`_rowType`** | `I`(insert) / `U`(update) / `D`(delete) — 배치 저장 시 행 단위 동작 |
| **BFF** | Backend-For-Frontend (외부 시스템 어댑터 + 프록시 서비스, port 19091) |
| **Core** | DataSet 도메인 + MyBatis + Flowable 백엔드 (port 19090) |
| **Port-Adapter** | Hexagonal 의 외부 시스템 추상화 패턴 |
| **Flowable** | BPMN 2.0 워크플로 엔진 (결재 프로세스용) |
| **`cm_menu`** | 메뉴 마스터 테이블 |
| **`cm_role_menu`** | 역할-메뉴 권한 매핑 |
| **kc.localtest.me** | RFC 2606 항상 127.0.0.1 — Keycloak SSO 단일 호스트 |

### 모범 인덱스

| 영역 | 모범 |
|---|---|
| Pattern A (CRUD) | `board` 도메인 |
| Pattern B (Workflow) | `approval` 도메인 |
| Pattern C (BFF Adapter) | `admin` 도메인 (Keycloak) |
| Pattern D (Read-only) | `widget` 도메인 |
| 형태 1 목록 | PageBoard.vue |
| 형태 2 상세 | ApprovalDetailDialog.vue |
| 형태 3 마스터-디테일 | PageDataLibrary.vue |
| 형태 4 캘린더 | PageCalendar.vue |
| 형태 5 대시보드 | PageDashboard.vue |
| 형태 6 다단계 입력 | ApprovalSubmitDialog.vue |
| 형태 7 SSO 래퍼 | PageWiki.vue |
| 형태 8 실시간 | PageVideo.vue |
| 형태 9 폼 매트릭스 | PageNotifySettings.vue |

### 변경 이력

- 2026-04-27 — 초판 작성 (Phase 0 코드베이스 분석 기반)
