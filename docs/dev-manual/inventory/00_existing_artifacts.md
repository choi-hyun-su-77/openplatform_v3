# inventory/00_existing_artifacts.md — 기존 문서·산출물 인벤토리

> Phase 0.A 산출물. 이 인벤토리는 후속 모든 SOP·핸드북의 1차 정보원이다.
> 모든 행은 `[doc: 경로]` 인용 형식으로 후속 문서에서 참조된다.

## 1. 마크다운/문서

| 경로 | 종류 | 1줄 요약 | 매핑 대상 |
|---|---|---|---|
| `README.md` | README | Spring Boot 3.2 + Hexagonal BFF + Vue 3 기반 통합 그룹웨어 개요 · 아키텍처 · 빠른시작 · 13 서비스 | HANDBOOK 0장(5분 요약) |
| `CLAUDE.md` | Project Rules | 포트 19xxx 대역, vue-spring-fw 원본 수정 금지, 상태파일(info/warn/fatal.md) 운영 규칙 | HANDBOOK 1장(환경 셋업) |
| `SESSION_HANDOFF.md` | Handoff | Phase A 진행 체크포인트, Identity 정규화, V8 마이그레이션 등 세션 핸드오프 가이드 | inventory/07_conventions(절차) |
| `TODO.md` | Checklist | Phase 0~14 100h 플랜, V1~V17 Flyway 진행 현황, Phase 14 완료 마킹 | HANDBOOK 부록(변경 이력) |
| `docs/api-catalog.md` | API Catalog | 95개 DataSet service 카탈로그 — REST 엔드포인트 + 도메인별 정리 | inventory/02_backend_patterns + scaffolds |
| `docs/scenarios.md` | User Scenarios | 23개 사용자 시나리오(로그인/대시보드/결재/게시판/일정/조직/메신저/메일/위키/화상/파일/알림/다국어/권한) | inventory/03_screen_types + recipes |
| `docs/port-allocation.md` | Infrastructure | 19xxx 주력 + 25174 UI dev 포트 할당표 (인프라/백엔드/외부서비스 13종) | HANDBOOK 1장 |
| `docs/approval.md` | Feature Reference | 결재 백엔드 구조(ApprovalService/Mapper/BPMN), 8 메서드, DMN 결재선, 첨부/위임/이력 | scaffolds(Workflow 패턴) |
| `docs/vue-spring-fw-reuse-map.md` | Asset Tracking | 원본 읽기-금지, 정적 복사 추적(레이아웃/공통컴포넌트/composable/store/router 19개) | inventory/04_naming + screens |
| `docs/group_ware.md` | External APIs | 5개 외부 서비스 매뉴얼(Rocket.Chat / Wiki.js / MinIO / Stalwart / LiveKit) + BFF 어댑터 매트릭스 | scaffolds(Port-Adapter 패턴) |
| `docs/minio-console-oidc-analysis.md` | Analysis | MinIO 콘솔 OIDC 연동 분석 | inventory/07_conventions(권한) |
| `docs/video-manual-check.md` | Test Note | 화상회의 수동 검증 노트 | recipes/04_external_integration |
| `docs/PHASE14_PRODUCTION_GROUPWARE.md` | Detailed Plan | Phase 14 8-트랙 병렬 계획(근태/회의실/자료실/업무일지/관리자/통합검색/위젯/메뉴) | HANDBOOK 0장 |
| `docs/PHASE14_REPORT.md` | Completion Report | Phase 14 완료 보고서 — V1~V17, 95 DataSet service, 26 UI page, 55 컴포넌트 | HANDBOOK 0장 |
| `framework_documentation_prompt.md` | Meta-Prompt | 풀스택 프레임워크 종합 문서화 프롬프트 (참고용) | (참조) |
| `developer_manual_codebase_driven_prompt.md` | Meta-Prompt | 본 매뉴얼 작성 지침 프롬프트 | (참조) |
| `info.md` | Status File | 현재 태스크 + 진행률 (1분 단위 갱신 운영) | (운영) |
| `warn.md` | Status File | 자율 결정 이력 | (운영) |
| `fatal.md` | Status File | 치명적 중단 (해당 없을 때 "중단 없음" 유지) | (운영) |

## 2. 데이터베이스 스키마 진화 (Flyway 마이그레이션 V1~V17)

> 모든 파일: `backend-core/src/main/resources/db/migration/`

| 버전 | 파일 | 1줄 요약 |
|---|---|---|
| V1 | `V1__baseline.sql` | 초기 스키마 — org/approval/board/calendar/notification/code/i18n/menu 테이블 선언 |
| V2 | `V2__org_schema.sql` | 조직 스키마 — `org_dept`, `org_employee`, `org_position` |
| V3 | `V3__common_code_notification.sql` | 공통코드 + 알림 테이블 |
| V4 | `V4__board_calendar.sql` | 게시판 + 캘린더 테이블 |
| V5 | `V5__seed_data.sql` | 초기 시드(부서/직원/공통코드/게시판) |
| V6 | `V6__menu_permission.sql` | 메뉴/권한 테이블(`cm_menu`, `cm_role`, `cm_role_menu`) |
| V7 | `V7__seed_data.sql` | 추가 시드 |
| V8 | `V8__approval_and_extras.sql` | 결재 확장 — `ap_document`, `ap_line`, `ap_attachment`, `ap_delegation`, `ap_history` |
| V9 | `V9__i18n_labels_and_seed_data.sql` | 다국어 라벨(98개 키 × 4언어 ko/en/zh/ja) |
| V10 | `V10__attendance_leave.sql` | 근태/연차 — `at_attendance`, `at_leave_balance`, `at_leave_request` |
| V11 | `V11__room_booking.sql` | 회의실 예약 — `rm_room`, `rm_booking` |
| V12 | `V12__data_library.sql` | 자료실 — `dl_folder`, `dl_file` (부서폴더 9개 자동 시드) |
| V13 | `V13__work_report.sql` | 업무일지 — `wr_daily`, `wr_team_weekly` |
| V14 | `V14__admin_audit.sql` | 관리자 + 감사 — `sa_audit` (AOP 자동 기록) |
| V15 | `V15__ux_features.sql` | UX — 통합검색/즐겨찾기/알림설정 — `ux_favorite`, `ux_notify_pref` |
| V16 | `V16__dashboard_widget.sql` | 대시보드 위젯 — `dw_widget_layout` (12-column CSS Grid) |
| V17 | `V17__phase14_menus.sql` | Phase 14 메뉴 일괄 등록 (4 부모 + 13 leaf + `cm_role_menu` 57행) |

## 3. 구성/인프라 파일

| 경로 | 종류 | 1줄 요약 |
|---|---|---|
| `backend-core/src/main/resources/application.yml` | Backend Config | Spring Boot 설정(datasource/jpa/mybatis/logging/actuator/keycloak) |
| `backend-bff/src/main/resources/application.yml` | BFF Config | WebFlux 설정(port 19091/actuator/logging) |
| `docker-compose.yml` (root) | Infra | 루트 docker-compose — 모든 13 서비스 one-shot 기동 |
| `infra/docker-compose.yml` | Infra | v3 전용 docker-compose — postgres/redis/minio/keycloak/rocketchat/stalwart/livekit/wikijs/backend/ui |
| `infra/docker-compose.cron.yml` 외 4개 | Infra Aux | cron/healthcheck/observability/resources/traefik 보조 compose (loki/prometheus/grafana) |
| `infra/keycloak/realm-export.json` | IdP Config | Keycloak realm export — openplatform-v3, 6 clients, 6 roles, 4 사용자 |
| `infra/livekit.yaml` | Service Config | LiveKit 서버 설정 |
| `infra/init-sql/01-schema.sql` | DB Init | PostgreSQL 초기화(platform_v3/flowable_v3/wiki_v3/keycloak_v3 스키마) |
| `infra/seed/expand_test_data.sql` | Seed | 확장 테스트 데이터 |
| `.github/workflows/ci.yml` | CI/CD | GitHub Actions(lint/build/test) |
| `start.sh` / `stop.sh` | Script | 로컬 부트/종료 스크립트 |

## 4. 메타 분류 요약

- 마크다운 문서: **16개**
- Flyway 마이그레이션: **17개 (V1~V17)**
- 인프라/구성: **11개**
- 메타-프롬프트: **2개** (framework_documentation_prompt.md, developer_manual_codebase_driven_prompt.md)
- 운영 상태 파일: **3개** (info/warn/fatal.md)

## 5. 후속 단계 매핑 요약

| 후속 산출물 | 주요 1차 정보원 |
|---|---|
| `inventory/01_tech_stack.md` | `README.md`, `pom.xml`(2개), `package.json`, `docker-compose.yml`, `application.yml`(2개) |
| `inventory/02_backend_patterns.md` | `docs/api-catalog.md`, `docs/approval.md`, `docs/group_ware.md`, backend-core 도메인 폴더 |
| `inventory/03_screen_types.md` | `docs/scenarios.md`, `ui/src/pages/`, `ui/src/components/` |
| `inventory/04_naming.md` | V1~V17 마이그레이션, backend-core 도메인 폴더, ui/src/pages/ |
| `inventory/05_menu_registration_points.md` | `V6__menu_permission.sql`, `V17__phase14_menus.sql`, `ui/src/router/index.ts`, `ui/src/components/layout/` |
| `inventory/06_ui_components.md` | `package.json`, `docs/vue-spring-fw-reuse-map.md`, `ui/src/components/` |
| `inventory/07_conventions.md` | `application.yml`, `core/common/`, `bff/config/`, AOP 감사(`V14`) |
| `inventory/08_references.md` | `docs/PHASE14_REPORT.md`, 본 인벤토리 |
