# 챕터 ↔ 정보원 매핑표

**작성일**: 2026-04-27 (Phase 0.C)
**목적**: Phase 1 챕터 20개 작성 에이전트가 1차 인풋으로 사용할 산출물·코드 경로의 권위 매핑.

> 규칙: 각 챕터 에이전트는 본 표의 **1차 인풋**을 우선 정독한 뒤 **보강 코드 경로**를 grep/Glob 으로 확인. 사실 주장에 출처 명시 (`[src: docs/...]` / `[code: backend-core/.../Foo.java:L42-L80]`).

> 표기 약어: `BC` = `backend-core/src/main/java/com/platform/v3/core`, `BB` = `backend-bff/src/main/java/com/platform/v3/bff`, `UI` = `ui/src`, `INFRA` = `infra`, `MIG` = `backend-core/src/main/resources/db/migration`.

---

## Group A — 기술/아키텍처

### 1.1 `01_overview.md` — 프로젝트 개요
- **1차 인풋**:
  - `README.md` (옵션 C 하이브리드 비전)
  - `CLAUDE.md` (프로젝트 규칙·아키텍처 문장)
  - `framework_documentation_prompt.md` (목표 정렬)
  - `docs/PHASE14_REPORT.md` (현재 완성도)
- **보강**: `info.md`, `TODO.md`(Phase 0~14 흐름), `docs/scenarios.md`(시나리오 15종 → 적용 대상)
- **챕터 관점**: 비전, 적용 대상(SME/제조), 핵심 차별점(Keycloak SSO 허브 + 5개 외부 서비스 federation), 라이선스 전략(외부 서비스 모두 OSS).

### 1.2 `02_tech_stack.md` — 기술 스택
- **1차 인풋**:
  - `backend-core/pom.xml`, `backend-bff/pom.xml`
  - `ui/package.json`, `ui/vite.config.ts`, `ui/tsconfig.json`
  - `docs/port-allocation.md`
- **보강**: `inventory/02_stack_a_backend.md`, `inventory/03_stack_b_backend.md`, `inventory/04_frontend.md`
- **버전 매트릭스**: Spring Boot 3.2.5, MyBatis 3.0.4, Flowable 7.1.0, Flyway 10.10.0, MinIO Java 8.5.7, Vue 3 + PrimeVue 4.3.0 + Vite 6.1.0, keycloak-js 24.
- **라이선스**: Apache 2.0/MIT 적합성 표.

### 1.3 `03_architecture.md` — 아키텍처
- **1차 인풋**:
  - `inventory/03_stack_b_backend.md` (Hexagonal/Port-Adapter 그림)
  - `docs/PHASE14_PRODUCTION_GROUPWARE.md` (8 트랙 Wave)
  - `docs/group_ware.md` (외부 서비스 federation 5종)
  - `infra/docker-compose.yml`, `infra/docker-compose.traefik.yml`
- **보강**: C4 컨테이너/컴포넌트는 `inventory/01_tree.txt` + 03·04 파일 결합으로 Mermaid 작성.
- **HA 토폴로지**: 현재는 단일 노드 docker compose. Active-Active는 향후 계획. 솔직하게 기술.

### 1.4 `04_data_model.md` — 데이터 모델
- **1차 인풋**:
  - `inventory/05_database.md` (V1~V17 + 관계도)
  - `MIG/V*.sql` 17개 (실제 DDL)
  - `BC/**/mapper/*.xml` (외래키/조인 단서)
- **보강**: `BC` 도메인별 엔티티(예: `approval/ApprovalService.java` 의 SQL 호출).
- **핵심**: ERD(Mermaid), 정규화 정책(3NF + 일부 비정규화 widget·favorite), Flyway 전진-only, Drizzle 미사용 — MyBatis-XML.

### 1.5 `05_api_spec.md` — API 명세
- **1차 인풋**:
  - `BC/dataset/DataSetController.java` (단일 진입점)
  - `BB/api/BffController.java` (Federation 게이트웨이)
  - `docs/api-catalog.md`, `docs/group_ware.md` (외부 API 매뉴얼)
- **보강**: `BC/notification/NotificationController.java`, `BC/code/CodeController.java`, `BC/i18n/I18nController.java`
- **핵심**: `POST /api/dataset` DataSet 라우터 패턴(서비스명 + 메서드명 + 페이로드), `/api/bff/*` federation, 페이지네이션·정렬·필터 규약.

---

## Group B — 프론트엔드

### 1.6 `06_frontend_structure.md` — 프엔 구조
- **1차 인풋**:
  - `inventory/04_frontend.md`
  - `UI/router/index.ts`, `UI/main.ts`, `UI/App.vue`
  - `UI/api/interceptor.ts`, `UI/keycloak.ts`
  - `ui/vite.config.ts`, `ui/tsconfig.json`
- **보강**: `docs/vue-spring-fw-reuse-map.md`(원본 → 복사 추적)
- **핵심**: 디렉토리, 라우팅(27 라우트), Pinia 3 store, Vite 빌드 설정.

### 1.7 `07_frontend_components.md` — 컴포넌트 카탈로그
- **1차 인풋**:
  - `UI/components/**/*.vue` (70+ 컴포넌트)
  - `UI/pages/*.vue` (라우팅 단위)
  - `inventory/04_frontend.md` 카테고리 표
- **핵심**: PrimeVue 4 채택 이유, Multi-panel pattern (grid/detail/chart/form), Layout/Approval/Board/Dashboard 위젯 카탈로그, FullCalendar/livekit-client 통합.

### 1.8 `08_frontend_conventions.md` — 프엔 규약
- **1차 인풋**:
  - `UI/composables/*.ts` (23개)
  - `UI/components/approval/*.vue`(단일파일 Vue 패턴 예시)
  - `docs/approval.md`
- **보강**: `CLAUDE.md` (네이밍 규칙)
- **핵심**: 단일파일 Vue 패턴 순서(types→API→state→actions→template), Cm~/cm~ 프리픽스(현재 "Cm" 미사용 — `Layout*`, `Widget*`, `App*`, `Page*` 접두), useXxx composable 규약.

---

## Group C — 백엔드

### 1.9 `09_backend_structure.md` — 백엔드 구조
- **1차 인풋**:
  - `inventory/02_stack_a_backend.md`, `inventory/03_stack_b_backend.md`
  - `BC/dataset/DataSetController.java`, `ServiceRegistry.java`, `DataSetServiceMapping.java`
  - `BB/api/BffController.java`, `BB/port/*.java`, `BB/adapter/*Adapter.java`
- **핵심**: Pattern A (Vue + Service.java + Mapper.xml DataSet 단일 엔드포인트), Pattern B (BFF Port-Adapter), Pattern C(외부 서비스 federation). 16개 도메인 인벤토리.

### 1.10 `10_backend_conventions.md` — 백엔드 규약
- **1차 인풋**:
  - `BC/**/mapper/*.xml` (MyBatis 동적 SQL)
  - `BC/approval/ApprovalService.java` (트랜잭션 경계)
  - `BC/common/ApiResponse.java`, `BusinessException.java`, `GlobalExceptionHandler.java`
  - `docs/approval.md` (도메인 규약 사례)
- **핵심**: MyBatis 동적 SQL 규약, `@Transactional` 경계, `_rowType` C/U/D 패턴, `DataSetService` `@DataSetServiceMapping` 어노테이션.

### 1.11 `11_backend_logging.md` — 로깅·추적
- **1차 인풋**:
  - `inventory/08_logging.md`
  - `BC/admin/AdminAuditAspect.java`
  - `infra/loki/loki-config.yml`, `infra/loki/promtail-config.yml`
- **보강**: `BC/src/main/resources/logback*.xml` (있으면), `UI/api/interceptor.ts` (요청 추적).
- **핵심**: 구조화 JSON 로깅, cid/hint 필드, AOP 감사 로그(admin/system_audit), Loki+Promtail 수집.

---

## Group D — 운영/품질

### 1.12 `12_security.md` — 보안
- **1차 인풋**:
  - `inventory/09_security.md`
  - `BB/config/SecurityConfig.java`, `BC/config/SecurityConfig.java`
  - `BB/adapter/KeycloakIdentityAdapter.java`
  - `infra/keycloak/openplatform-v3-realm.json`
  - `docs/minio-console-oidc-analysis.md`
- **보강**: `MIG/V6__menu_permission.sql`, `MIG/V14__admin_audit.sql`
- **핵심**: JWT 인증, RBAC(role-permission), 비밀관리(.env + realm secret), OWASP Top 10 매트릭스.

### 1.13 `13_deployment.md` — 배포
- **1차 인풋**:
  - `inventory/07_ops.md`
  - `infra/docker-compose*.yml` (8개)
  - `infra/traefik/traefik.yml`, `dynamic.yml`
  - `start.sh`, `stop.sh`, `scripts/*.sh`
- **보강**: `docs/port-allocation.md`, `infra/livekit.yaml`
- **핵심**: Docker Compose 다층 구성(8 yml), Traefik 리버스 프록시, healthcheck/resources/cron/observability 분리.

### 1.14 `14_testing.md` — 테스트
- **1차 인풋**:
  - `inventory/06_tests.md`
  - `docs/scenarios.md`, `docs/video-manual-check.md`
  - `docs/PHASE14_PRODUCTION_GROUPWARE.md`(트랙별 DoD)
- **솔직 명시**: 단위/통합 테스트 인프라 미흡(JUnit 거의 없음). Playwright MCP로 E2E 수행. k6/Toxiproxy 미적용.
- **권장**: `inventory/06_tests.md` 의 권장사항 그대로 인용.

### 1.15 `15_observability.md` — 관찰성
- **1차 인풋**:
  - `inventory/08_logging.md`
  - `infra/prometheus/prometheus.yml`
  - `infra/grafana/provisioning/datasources/loki-prom.yml`
  - `infra/loki/*.yml`
- **보강**: `infra/docker-compose.observability.yml`
- **핵심**: Prometheus 스크레이프 타깃(actuator/prometheus), Grafana 대시보드 프로비저닝, Loki 로그 집계, 알람 규칙(있으면).

---

## Group E — 매뉴얼

### 1.16 `16_user_manual.md` — 사용자 매뉴얼
- **1차 인풋**:
  - `docs/scenarios.md` (시나리오 15종)
  - `docs/PHASE14_PRODUCTION_GROUPWARE.md`(8 트랙 = 사용자 기능)
  - 루트 `*.png` 32개(스크린샷)
- **핵심**: 역할별 시나리오(관리자/일반/외부), 화면 흐름, 스크린샷 임베드.

### 1.17 `17_operations_manual.md` — 운영 매뉴얼
- **1차 인풋**:
  - `info.md`, `docs/PHASE14_REPORT.md`
  - `start.sh`, `stop.sh`, `scripts/backup.sh`, `restore.sh`, `security-scan.sh`, `perf-scan.sh`
  - `infra/docker-compose.cron.yml`(스케줄러), `healthcheck.yml`
- **핵심**: 설치/업그레이드, 백업/복구 런북, 장애 시나리오, 롤링 배포(현재 단일 노드 → 향후 계획).

---

## Group F — 가이드/부록

### 1.18 `18_dev_guide.md` — 개발 가이드
- **1차 인풋**:
  - `CLAUDE.md` (워크스페이스 + 프로젝트)
  - `developer_manual_codebase_driven_prompt.md`
  - `docs/vue-spring-fw-reuse-map.md`
  - `warn.md`(개발 결정 이력에서 규약 추출)
- **핵심**: 워크스페이스 규칙(포트 할당·v1/v2 무복사), 자율 모드, AI 생성 제약, 단일파일 Vue 패턴, Mapper 규약. CODING_STANDARDS.md 부재 → warn 보고.

### 1.19 `19_troubleshooting.md` — 트러블슈팅
- **1차 인풋**:
  - `warn.md`(SSO/JMAP/CORS/host 통일 등 빈도순 이슈 다수)
  - `fatal.md`(현재 무)
  - `docs/minio-console-oidc-analysis.md`
- **보강**: `inventory/08_logging.md`(로그 패턴), `docs/video-manual-check.md`(LiveKit 헤드리스 제약)
- **핵심**: SSO 통합 결함 이력, JMAP serialization 이슈, host 통일(`kc.localtest.me`) 등.

### 1.20 `20_appendix.md` — 부록
- **1차 인풋**:
  - `SESSION_HANDOFF.md`, `TODO.md`, `server-info.txt`
  - `doc/*.pdf`, `doc/*.html`
  - `MIG/V9__i18n_labels_and_seed_data.sql`(용어집 ko/en/ja/zh-CN)
- **핵심**: 용어집 KR/EN, 외부 링크, 라이선스 전문, 변경 이력(Phase 0~14 요약).

---

## 공통 보조 자료 (모든 챕터)

- `inventory/01_tree.txt` — 디렉토리 구조 그림
- `inventory/00_existing_artifacts.md` — 산출물 통계

## 인용 형식 표준

- **문서 출처**: `[src: docs/PHASE14_PRODUCTION_GROUPWARE.md §3.2]`
- **코드 출처**: `[code: backend-core/.../ApprovalService.java:L42-L80]`
- **인벤토리 인용**: `[inv: inventory/04_frontend.md "Composables"]`

## 챕터 ↔ 인벤토리 커버리지 (00–09 매트릭스)

| 인벤토리 파일 | 사용 챕터 |
|---|---|
| 00_existing_artifacts.md | 1.1, 1.20 |
| 01_tree.txt | 1.3, 1.6, 1.9 |
| 02_stack_a_backend.md | 1.2, 1.4, 1.5, 1.9, 1.10 |
| 03_stack_b_backend.md | 1.2, 1.3, 1.5, 1.9, 1.12 |
| 04_frontend.md | 1.2, 1.6, 1.7, 1.8 |
| 05_database.md | 1.4 |
| 06_tests.md | 1.14 |
| 07_ops.md | 1.13, 1.15, 1.17 |
| 08_logging.md | 1.11, 1.15, 1.19 |
| 09_security.md | 1.12 |

→ 모든 인벤토리 파일이 최소 1개 챕터에서 인용됨. 미인용 0건.
