# openplatform_v3 기존 문서·자산 인벤토리

**작성일**: 2026-04-27  
**범위**: C:/claude/openplatform_v3/ 루트 및 모든 하위 디렉토리  
**목적**: 프레임워크 종합 문서화 및 개발자 매뉴얼 생성 시 활용할 기존 산출물 및 설정 자산 단일 목록화

---

## 1. 루트 레벨 핵심 메타 문서 (10개)

| 파일경로 | 종류 | 요약 | 매핑 챕터 |
|---------|------|------|----------|
| README.md | .md | Spring Boot 3.2 + Hexagonal BFF + Vue 3 PrimeVue 기반 옵션 C 하이브리드 그룹웨어; v1/v2 자산 융합 차세대 플랫폼 | 1.1 개요 |
| CLAUDE.md | .md | 프로젝트 규칙: 포트 할당(docker-info.xml 권위), 브랜치/커밋/코딩 정책 | 1.19 개발가이드 |
| SESSION_HANDOFF.md | .md | Phase A 진행 체크포인트(2026-04-16); 다음 세션 5분 복구 가능 요약 | 1.20 부록 |
| TODO.md | .md | 진행 상태 범례 및 작업 체크리스트; 현재 Phase 14 진행중 | 1.20 부록 |
| info.md | .md | 실시간 진행 상황(1분 단위 갱신); Phase 14 Mode B 병렬 진행 | 1.17 운영매뉴얼 |
| warn.md | .md | 판단 이력 및 개발 결정 추적; T6 UX/NotificationService 호환성 상세 기록 | 1.18 트러블슈팅 |
| atal.md | .md | 치명적 중단 사유; 현재 무(2026-04-27 정상 완료) | 1.18 트러블슈팅 |
| ramework_documentation_prompt.md | .md | 종합 문서화 프롬프트: 1차 정보원 우선, 누락금지, 병렬실행 원칙 | 1.1 개요 |
| developer_manual_codebase_driven_prompt.md | .md | 개발자 매뉴얼 작성 프롬프트: 스캐폴드/화면형태/메뉴등록 지침 | 1.19 개발가이드 |
| server-info.txt | .txt | 서버 접속 정보(2026-04-27 Phase 14 완료 시점) | 1.20 부록 |

---

## 2. docs/ 디렉토리 (10개 .md)

| 파일경로 | 종류 | 요약 | 매핑 챕터 |
|---------|------|------|----------|
| docs/PHASE14_PRODUCTION_GROUPWARE.md | .md | Phase 14 프로덕션급 그룹웨어 강화(병렬 8 트랙); 본 문서 그대로 다음 세션 실행 가능 | 1.16 유저매뉴얼 |
| docs/PHASE14_REPORT.md | .md | Phase 14 완료 보고서(2026-04-27); Phase 0~13 완료 전제 | 1.17 운영매뉴얼 |
| docs/approval.md | .md | 전자결재 개발 자료: approval 도메인 + PageApproval.vue DB/코드 덤프(2026-04-16) | 1.8 백엔드 규약 |
| docs/group_ware.md | .md | 외부 서비스 API 매뉴얼: Rocket.Chat(REST v1+DDP), Wiki.js(GraphQL), Minio, LiveKit, Keycloak SSO 5종 | 1.5 API & 통신 |
| docs/api-catalog.md | .md | API 카탈로그: v1 분석 결과 기반 v3 선택 포팅 목록; BFF 신규 설계 | 1.5 API & 통신 |
| docs/scenarios.md | .md | 사용자 시나리오 15종: UI 설계 및 Playwright E2E 근거 | 1.16 유저매뉴얼 |
| docs/port-allocation.md | .md | openplatform_v3 포트 할당표; 상위문서 docker-info.xml, port-change-report.md | 1.2 기술스택 |
| docs/vue-spring-fw-reuse-map.md | .md | vue-spring-fw 재사용 추적: C:\claude\vue-spring-fw(절대수정금지) → ui/src 복사 대상 | 1.6 프론트엔드구조 |
| docs/minio-console-oidc-analysis.md | .md | MinIO Console OIDC 분석(2026-04-14): Keycloak 연동 시 SSO 버튼 노출 현상 분석 | 1.5 API & 통신 |
| docs/video-manual-check.md | .md | LiveKit 화상회의 수동 검증 가이드(F-8); 헤드리스 Playwright 제약 | 1.14 테스트 |

---

## 3. doc/ 산출물 (6개: PDF/HTML)

| 파일경로 | 종류 | 요약 | 매핑 챕터 |
|---------|------|------|----------|
| doc/openplatform_v3_access_info.pdf | .pdf | 접근 정보 PDF 산출물 | 1.20 부록 |
| doc/openplatform_v3_session.pdf | .pdf | 세션 정보 PDF 산출물(Part 1) | 1.20 부록 |
| doc/openplatform_v3_session_part2.pdf | .pdf | 세션 정보 PDF 산출물(Part 2) | 1.20 부록 |
| doc/access-info.html | .html | 접근 정보 HTML 산출물 | 1.20 부록 |
| doc/session-continuation.html | .html | 세션 지속 정보 HTML 산출물 | 1.20 부록 |
| doc/conversation.html | .html | 대화 기록 HTML 산출물 | 1.20 부록 |

---

## 4. 스크린샷 (32개 .png)

### Approval 기능 (2개)
- phase-a-approval-list.png — 결재 목록 화면
- phase-a-submit-dialog.png — 결재 제출 다이얼로그

### 대시보드/UI (10개)
- phase-c1-dashboard-after-fix.png — C1 수정 후 대시보드
- 3-dashboard-final.png, 3-final-dashboard.png, 3-final-dashboard2.png — 최종 대시보드 변형
- 3-board.png, 3-final-board.png — 게시판
- 3-calendar.png, 3-final-calendar.png, 3-final-calendar2.png — 캘린더

### 조직/포털 (3개)
- 3-org.png, 3-final-org.png — 조직도
- 3-final-portal-dashboard.png — 포털 대시보드

### Rocket.Chat SSO (7개)
- ocketchat-login.png — 로그인 화면
- ocketchat-home.png — 홈 화면
- ocketchat-sso-result.png, ocketchat-sso-success.png — SSO 결과
- ocketchat-after-sso.png, ocketchat-final-state.png — SSO 후 최종 상태
- phase-c3-rocketchat-sso-success.png — C3 단계 성공

### MinIO (2개)
- minio-login.png — 로그인 화면
- minio-sso-attempt.png — SSO 시도

### LiveKit (3개)
- phase-c5-livekit-room-joined.png — 방 입장 화면
- 3-video.png — 비디오 화면
- 3-video-token.png — 비디오 토큰

### 기타 (5개)
- 3-after-upgrades.png — 업그레이드 후
- 3-messenger.png — 메신저
- 3-messenger-sso.png — 메신저 SSO
- 3-approval.png, 3-final-approval.png — 결재 화면
- 3-wiki-sso.png — Wiki SSO

---

## 5. infra/ 설정 파일 (13개)

### Docker Compose (6개)
| 파일경로 | 용도 |
|---------|------|
| infra/docker-compose.yml | 기본 구성 |
| infra/docker-compose.traefik.yml | Traefik 리버스프록시 |
| infra/docker-compose.healthcheck.yml | 헬스체크 설정 |
| infra/docker-compose.observability.yml | Prometheus/Loki 관찰성 |
| infra/docker-compose.resources.yml | 리소스 제한 |
| infra/docker-compose.cron.yml | 크론 작업 |

### Traefik (2개)
| 파일경로 | 용도 |
|---------|------|
| infra/traefik/traefik.yml | Traefik 메인 설정 |
| infra/traefik/dynamic.yml | Traefik 동적 라우팅 |

### 관찰성 (4개)
| 파일경로 | 용도 |
|---------|------|
| infra/prometheus/prometheus.yml | Prometheus 스크래이프 설정 |
| infra/loki/loki-config.yml | Loki 로그 수집 설정 |
| infra/loki/promtail-config.yml | Promtail 에이전트 설정 |
| infra/grafana/provisioning/datasources/loki-prom.yml | Grafana 데이터소스 프로비저닝 |

### SSO/인증 (1개)
| 파일경로 | 용도 |
|---------|------|
| infra/keycloak/openplatform-v3-realm.json | Keycloak Realm 설정 |

### 보조 인프라
- infra/ldap/users.ldif — LDAP 사용자 정의
- infra/livekit.yaml — LiveKit 화상회의 설정
- infra/init-sql/01-schema.sql — 초기 DB 스키마

---

## 6. 빌드/매니페스트 (5개)

| 파일경로 | 종류 | 용도 | 매핑 챕터 |
|---------|------|------|----------|
| ackend-bff/pom.xml | XML | BFF 계층 Maven 빌드 | 1.2 기술스택 |
| ackend-core/pom.xml | XML | Core 백엔드 Maven 빌드 | 1.2 기술스택 |
| ui/package.json | JSON | Vue 3 프론트엔드 npm 의존성 | 1.2 기술스택 |
| ui/vite.config.ts | TS | Vite 빌드 설정 | 1.2 기술스택 |
| ui/tsconfig.json | JSON | TypeScript 설정 | 1.2 기술스택 |

---

## 7. SQL 마이그레이션 (17개 V*.sql)

- V1__baseline.sql — 기본 테이블
- V2__org_schema.sql — 조직 스키마
- V3__common_code_notification.sql — 공통코드/알림
- V4__board_calendar.sql — 게시판/캘린더
- V5__seed_data.sql — 초기 데이터
- V6__menu_permission.sql — 메뉴/권한
- V7__seed_data.sql — 추가 시드
- V8__approval_and_extras.sql — 결재 및 부가
- V9__i18n_labels_and_seed_data.sql — 다국어 레이블 및 시드
- V10__attendance_leave.sql — 근태/휴가
- V11__room_booking.sql — 회의실 예약
- V12__data_library.sql — 자료실
- V13__work_report.sql — 업무보고
- V14__admin_audit.sql — 관리/감시
- V15__ux_features.sql — UX 강화(즐겨찾기/알림설정)
- V16__dashboard_widget.sql — 대시보드 위젯
- V17__phase14_menus.sql — Phase 14 메뉴

---

## 8. 핵심 Java 어댑터/포트/서비스

**주요 기능 영역** (코드베이스 분석):
- **approval** 도메인: ApprovalService, ApprovalMapper, PageApproval.vue
- **notification** 시스템: NotificationService (7인자 오버로드 추가, category 파라미터)
- **external API**: Rocket.Chat(REST), Wiki.js(GraphQL), MinIO, LiveKit, Keycloak (group_ware.md 참조)
- **UX 강화** (Phase 14 T6): SearchService(통합검색), FavoriteService(즐겨찾기), NotifyPrefService(알림설정)
- **Hexagonal 아키텍처**: Port/Adapter 패턴 적용

---

## 9. docs/dev-manual/ 디렉토리 구조

계획 단계(아직 산출물 없음):
- docs/dev-manual/inventory/ — 기존 artifact 인벤토리(본 문서)
- docs/dev-manual/menu/ — 메뉴 등록 가이드
- docs/dev-manual/recipes/ — 개발 레시피 모음
- docs/dev-manual/scaffolds/ — 스캐폴드 템플릿
- docs/dev-manual/screens/ — 화면형태 정의

---

## 10. 통계

| 종류 | 수량 | 비고 |
|------|------|------|
| .md 문서 | 20 | 루트 10개 + docs 10개 |
| .pdf 산출물 | 3 | 접근정보 1, 세션 2 |
| .html 산출물 | 3 | 접근정보, 세션지속, 대화기록 |
| .png 스크린샷 | 32 | 대시보드/SSO/결재/메신저 커버 |
| docker-compose.*.yml | 6 | Traefik/헬스체크/관찰성/리소스/크론 |
| 기타 설정(prometheus/loki/traefik/keycloak/ldap/livekit) | 7 | YAML/JSON/LDIF |
| 빌드 파일 (pom.xml/package.json/vite/tsconfig) | 5 | Maven + Vue 3 |
| SQL 마이그레이션 | 17 | V1~V17 |
| **총 문서·자산** | **93** | 산출/설정/마이그레이션 포함 |

---

## 11. 챕터 매핑 (framework_documentation_prompt.md 기준)

| 챕터 | 커버 문서 |
|------|----------|
| 1.1 개요 | README.md, framework_documentation_prompt.md |
| 1.2 기술스택 | port-allocation.md, pom.xml, package.json, vite.config.ts |
| 1.3 아키텍처 | PHASE14_PRODUCTION_GROUPWARE.md |
| 1.5 API & 통신 | group_ware.md, api-catalog.md, minio-console-oidc-analysis.md |
| 1.6 프론트엔드 구조 | vue-spring-fw-reuse-map.md |
| 1.8 백엔드 규약 | approval.md |
| 1.14 테스트 | video-manual-check.md, scenarios.md |
| 1.16 유저매뉴얼 | PHASE14_PRODUCTION_GROUPWARE.md, scenarios.md |
| 1.17 운영매뉴얼 | info.md, PHASE14_REPORT.md |
| 1.18 트러블슈팅 | warn.md, fatal.md |
| 1.19 개발가이드 | CLAUDE.md, developer_manual_codebase_driven_prompt.md |
| 1.20 부록 | SESSION_HANDOFF.md, TODO.md, server-info.txt, PDF/HTML산출물 |

---

## 12. 주요 노트

1. **1차 정보원 우선**: 본 인벤토리는 스캔 기반 팩트만 기재. 추론/확장은 담당 에이전트가 소스코드 직접 분석 후 수행.
2. **포트 할당 권위**: C:/docker-info.xml (워크스페이스 전체) + docs/port-allocation.md (v3 전용)
3. **외부 의존성**: v1(C:/openplatform) + v2(C:/openplatform_v2) + vue-spring-fw (절대수정금지) 재사용
4. **Phase 14 진행**: 2026-04-27 정상 완료; MODE B(Wave 병렬) 진행중
5. **개발자 재진입**: SESSION_HANDOFF.md + TODO.md + warn.md 3개만 5분내 읽으면 컨텍스트 복구

---

**끝**
