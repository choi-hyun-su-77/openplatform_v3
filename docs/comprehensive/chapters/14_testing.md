# Chapter 1.14: Testing & Verification Strategy

## Overview

OpenPlatform v3 의 검증은 **JUnit/Mockito 단위 테스트가 거의 부재**한 상태에서, **Playwright MCP 라이브 E2E 시나리오** 와 **수동 화상회의 검증** 으로 운영된다. k6/Toxiproxy 부하·카오스, GitHub Actions CI 는 **미적용**.

| 영역 | 상태 |
|---|---|
| 단위 (JUnit/Mockito) | **부재** — `src/test/java` 자체 없음 |
| 통합 (Testcontainers) | **부재** — 권장 |
| E2E (Playwright MCP) | **운영 중** — 시나리오 15+8종, Phase A~F 통과 |
| UI 단위 (Vitest) | **부재** — `ui/package.json` `test` 스크립트 없음 |
| 수동 검증 | **운영 중** — LiveKit (`docs/video-manual-check.md`) |
| 부하 (k6/JMeter) | **미적용** — 권장 |
| 카오스 (Toxiproxy) | **미적용** — 권장 |
| CI 파이프라인 | **부재** — `.github/workflows/ci.yml` 없음 |

출처: `inventory/06_tests.md`, `scenarios.md`, `video-manual-check.md`, `info.md`, `warn.md`.

---

## 1. 테스트 전략 — 현재 진술

본 프로젝트는 옵션 C 하이브리드 + Phase 14 병렬 8 트랙 으로 기능 작성에 집중되어 자동화 테스트가 후순위로 밀렸다.

- backend-core/backend-bff `pom.xml` 에 **`spring-boot-starter-test` 미포함** (출처: `inventory/06_tests.md` §Maven)
- `ui/package.json` `scripts` 에 `"test"` 키 없음 (출처: 동 §NPM)
- 검증의 권위 = **Playwright MCP 라이브 검증** > 수동 가이드 (`video-manual-check.md`) > curl/Postman > Docker 로그

---

## 2. 단위 / 통합 테스트 — minimal, 권장 추가

`backend-core` 와 `backend-bff` 양쪽에 `src/test/java` 부재. Maven 테스트 플러그인 미설정 = *skip-by-default*.

권장 단위 테스트 (출처: `inventory/06_tests.md` §Recommended Testing Strategy):

```java
@SpringBootTest
public class ApprovalServiceTest {
  @MockBean ApprovalMapper mapper;
  @InjectMocks ApprovalService service;
  @Test void submitApprovalSuccess() {
    Map<String, Object> req = Map.of("form_type", "LEAVE");
    service.submitApproval(req);
    verify(mapper).insert(any());
  }
}
```

활성화: `spring-boot-starter-test` (scope=test) 추가. 통합 테스트는 Testcontainers `PostgreSQLContainer` + Flowable 로 `submit → approve → completion` 풀 흐름.

**권장 커버리지** (출처: `inventory/06_tests.md`):

| 컴포넌트 | 현재 → 목표 | 우선 |
|---|---|---|
| backend-core 서비스 | 0% → 70% | High |
| backend-bff 어댑터 | 0% → 50% | Medium |
| ui composables | 0% → 80% | High |
| E2E 사용자 흐름 | 수동 → 40% 자동화 | Medium |
| 보안 검사 | 수동 → CI 자동화 | High |

---

## 3. E2E (Playwright MCP) — 본 프로젝트의 핵심 검증

`@playwright/test` 패키지를 추가하지 않고, **Claude Code 의 Playwright MCP 서버** (`browser_navigate`, `browser_click`, `browser_evaluate` 등) 로 라이브 브라우저 인스턴스에 시나리오를 직접 실행한다.

**검증 시나리오 — 15 + 8종** (출처: `docs/scenarios.md`):

1. 통합 로그인 (Keycloak PKCE) / 2. 대시보드 5 위젯 / 3. 결재 상신 (DMN + MinIO + SSE) / 4. 결재 처리 9 탭 / 5. 부서 게시판 (WYSIWYG + 첨부 + 댓글) / 6. 일정 관리 FullCalendar / 7. 조직도 / 8. 메신저 (Rocket.Chat Custom OAuth) / 9. 웹메일 (Stalwart LDAP Federation) / 10. 위키 (Wiki.js OIDC) / 11. 화상회의 (LiveKit, view-only 폴백) / 12. 파일 공유 (MinIO presigned) / 13. 알림 센터 (SSE 실시간) / 14. 다국어 (ko/en/zh-CN) / 15. 권한 제어 (`usePermission`) / 16~23. Phase 14 트랙 1~8 (출퇴근/회의실/자료실/업무일지/관리자/검색/위젯/통합).

권장 자동화 도입 시 `ui/e2e/*.spec.ts` 에 `@playwright/test` 로 전환 (예시는 `inventory/06_tests.md` §E2E Tests).

---

## 4. 화상회의 수동 검증 (출처: `docs/video-manual-check.md`)

헤드리스 Playwright 는 카메라/마이크 디바이스 없어 자동화 불가.

**사전 조건**: `docker compose ps` → `v3-livekit` `Up (healthy)`, 카메라/마이크 물리 연결 + OS 권한.

**1인**: http://localhost:19173 → admin/admin → 사이드바 화상회의 → 룸 `v3-manual-test` → 권한 허용 → 자기 비디오 / 마이크·카메라 토글 / 나가기.

**2인**: A(시크릿)+admin → `v3-multi`, B(다른 프로필)+user1 → 동일 룸. A에서 B 타일 추가, B 마이크 끄기 → A 오디오 중단, B 나가기 → A 타일 사라짐.

**통과 기준 (Type A)**:
- `/api/bff/video/token` POST 200 + token/room/wsUrl
- `wss://...:19880` `101 Switching Protocols`
- ICE `connected` (`chrome://webrtc-internals`)
- 자기 비디오 `<video>` `readyState >= 2`
- 상대 `RemoteTrack` 수신 (2인)

**실패 시**: `docker logs v3-livekit --tail 50` (ICE) → 방화벽 UDP 19882 / TCP 19880,19881 → `docker compose restart livekit` → `curl http://localhost:19880` (404 = 정상, WS only).

---

## 5. 부하 / 카오스 — 미적용, 권장

k6/JMeter/wrk **미적용**. Toxiproxy/Chaos Mesh **미적용**. `inventory/06_tests.md` 가 언급한 `/scripts/perf-scan.sh` 도 실제 파일은 미작성.

**권장 부하 베이스라인** (출처: `inventory/06_tests.md`):

| 작업 | 목표 / 기대 |
|---|---|
| Login | <2s / 1.5s |
| Approval submit | <1s / 0.8s |
| Dashboard | <3s / 2.0s |
| Calendar (1년) | <2s / 1.2s |
| Board list | <1s / 0.6s |
| File upload (10 MB) | <5s / 3s |

권장 시작점: **k6 100 VU × 5분**, 1000 req/sec @ p99 < 500ms.

**권장 카오스**: DB 패킷 손실 5% (재시도) / Keycloak 5초 latency (timeout) / MinIO 503 30% (업로드 부분 실패 핸들링).

---

## 6. 동시성 / 세션 일관성 — 권장

| 시나리오 | 검증 포인트 |
|---|---|
| 동일 결재 두 명 동시 승인 | `ap_approval_line.status` race → 트랜잭션 격리 |
| 회의실 동일 슬롯 동시 예약 | `RoomService.reserve` (`SELECT ... FOR UPDATE`) |
| 출근 더블클릭 | `at_attendance` UNIQUE(employee_id, date) |
| SSE 다중 탭 구독 | 동일 사용자 N 세션 메모리 누수 |
| 토큰 만료 직전 동시 요청 | `auth.ts` refresh race (이미 단일 promise) |

도구: JMeter Concurrency Group, k6 `executor: 'shared-iterations'`, wrk2.

---

## 7. CI 통합 — 부재, 권장

`.github/workflows/ci.yml` 부재. 모든 빌드/테스트 로컬 수동.

권장 GitHub Actions:

```yaml
name: ci
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { java-version: '17', distribution: 'temurin' }
      - run: cd backend-core && mvn -B -DskipTests package
      - run: cd backend-bff && mvn -B -DskipTests package
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: cd ui && npm ci && npm run build
      - run: docker compose -f infra/docker-compose.yml up -d postgres keycloak
      - run: cd backend-core && mvn -B dependency-check:check
```

게이트: 단위 테스트 70% 미달 fail / vue-tsc 에러 0 (이미 로컬 강제) / OWASP CVE high+ 0 / Docker 5분 healthy.

---

## 8. 검증 통과 표 — Phase A~F 및 Phase 14

`info.md` / `warn.md` 의 라이브 검증 통과 사례 인용.

### 8.1 Phase 13 통과 (출처: `warn.md` Phase A 전체 완료)

- **A 결재**: submit BIZTRIP/500000 → docId=26, 결재선 3명 자동 생성 / 1단계 승인 → IN_PROGRESS / 회수 → DRAFT 리셋 / previewApprovers (BIZTRIP/HR) → 3명 / searchDetail·searchInbox·deleteAttachment → 200
- **B 게시판**: 댓글 CRUD 5 + 첨부 1 (parent_id 1단계 대댓글) / soft delete (`deleted=TRUE`)
- **C 캘린더**: dateClick / dateSelect / eventClick / eventDrop / eventResize 전부 통과 / 공휴일 cm_holiday 분홍 background
- **E SSE**: `?token=` 쿼리 인증 (SseTokenFilter) / preferred_username → employee_id 자동 매핑
- **F**: 4xx/5xx → `CustomEvent('global-error-toast')` / 권한 거부 → `/403` 리다이렉트

### 8.2 Phase 12 SSO 통합 (Playwright MCP, 2026-04-15 19:51)

C1 사이드바 (width=260px) / C2 Wiki.js SSO (admin@v3.local profile) / C3 Rocket.Chat SSO (Meteor.userId 발급) / C4 MinIO Console SSO (/browser 진입) / C5 LiveKit (view-only 폴백) / C6 메일 (`/api/bff/mail/mailbox=200`).

### 8.3 Phase 14 트랙 (출처: `info.md`)

T1 근태/연차, T2 회의실, T3 자료실, T4 업무일지, T5 어드민, T6 UX, T7 위젯, T8 통합 — **8 트랙 모두 done** (V10~V17 마이그레이션, mvn BUILD SUCCESS, 6 컨테이너 healthy).

### 8.4 알려진 미완 (정직 진술, 출처: `warn.md`)

- `ApprovalService.approve()` 가 `recordHistory()` 미호출 → 승인 액션 이력 미기록
- `recordHistory.actorName` 이 employee_no 그대로 — `OrgMapper.findEmployeeByNo` lookup 권장
- 첨부 다운로드 권한 검증 부재 → Phase F 보안 sweep
- `directAccessGrantsEnabled=true` (E2E password grant) → F-9 false 복구 완료

---

## 참조

- `docs/comprehensive/inventory/06_tests.md`
- `docs/scenarios.md`
- `docs/video-manual-check.md`
- `docs/PHASE14_PRODUCTION_GROUPWARE.md` §0.4 (DoD 7항목)
- `info.md`, `warn.md`
- `infra/seed/expand_test_data.sql`

---

## 이 챕터가 다루지 않은 인접 주제

- **Layer 0 정적 분석** (lint/sonarqube): vue-tsc + ESLint 로컬 동작, CI 미통합
- **보안 테스트 상세** (SAST/DAST/OWASP ZAP): Chapter 1.13 또는 별도 챕터
- **Accessibility (a11y)**: axe-core/pa11y 미적용
- **Visual regression** (Percy/Chromatic): 미적용
- **Contract testing** (Pact): DataSet 단일 엔드포인트라 우선순위 낮음
- **DB 마이그레이션 회귀**: `docker compose down -v && up -d` 수동, 자동화 권장
- **Loki/Grafana 대시보드 검증**: Chapter 1.11 인접 주제
