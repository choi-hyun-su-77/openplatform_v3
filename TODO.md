# TODO — openplatform_v3 통합 그룹웨어

## 진행 상태 범례
- [ ] 미시작
- [~] 진행중 (재시작 시 여기서부터)
- [x] 완료
- [!] 블로킹 (fatal.md 참조)

---

## Phase 0: 뼈대 + 상태 파일 + 상위 동기화 (완료)
- [x] 0-1. v3 디렉토리 구조 생성 (`backend-core`, `backend-bff`, `ui`, `infra`, `docs`, `.claude`)
- [x] 0-2. info.md / warn.md / fatal.md / TODO.md 생성
- [x] 0-3. v3 CLAUDE.md (프로젝트 규칙, 상위 상속)
- [x] 0-4. `.claude/settings.local.json` (권한, ts-spring-fw/v1/v2 쓰기 차단)
- [x] 0-5. `docs/ts-spring-fw-reuse-map.md` 초안
- [x] 0-6. `docs/port-allocation.md`
- [x] 0-7. `docs/api-catalog.md` (v1 수집 결과)
- [x] 0-8. `docs/scenarios.md` (시나리오 15개)
- [x] 0-9. `C:\claude\docker-info.xml` 에 v3 프로젝트 블록 추가
- [x] 0-10. `C:\claude\port-change-report.md` 2026-04-14 이력 추가

## Phase 1: 인프라 docker-compose (완료 — 기동 검증 제외)
- [x] 1-1. `infra/docker-compose.yml` — postgres/redis/minio/keycloak/mattermost/wikijs/stalwart/livekit + backend/ui
- [x] 1-2. `infra/keycloak/openplatform-v3-realm.json` — realm, roles, clients 6종, 기본 사용자 2명
- [x] 1-3. `infra/init-sql/01-schema.sql` — platform_v3/flowable_v3 스키마 + mattermost_v3/wiki_v3 DB
- [ ] 1-4. `docker compose up -d` 실제 기동 검증 (Phase 2 완료 후 함께)

## Phase 2: backend-core **신규 스캐폴딩 + 선택 포팅** (완료)
- [x] 2-1. `backend-core/pom.xml` 신규 작성
- [x] 2-2. `Application.java`, `com.platform.v3.core` 네임스페이스
- [x] 2-3. `DataSetController` / `DataSetService` / `ServiceRegistry` / `@DataSetServiceMapping`
- [x] 2-4. 도메인 서비스 선택 포팅 (org/approval/board/calendar/notification/code/i18n 전부)
- [x] 2-5. MyBatis mapper XML (mapper/{org,approval,board,calendar,notification,code,i18n,menu})
- [x] 2-6. `application.yml`
- [x] 2-7. Flowable BPMN/DMN 리소스 (4개 process 파일)
- [x] 2-8. SecurityConfig (Keycloak JWT Resource Server)
- [x] 2-9. Dockerfile
- [x] 2-10. V1__baseline.sql flyway
- [x] 2-11. ApiResponse/BusinessException/GlobalExceptionHandler
- [x] 2-12. 도메인 포팅: org / approval(Flowable) / board / calendar / notification / code / i18n
- [x] 2-13. `mvn clean package` + 컨테이너 기동 검증 (Phase Final E2E)

## Phase 3: backend-bff Port-Adapter 스캐폴딩 (완료)
- [x] 3-1. Spring Boot 3.2.5 신규 모듈, 포트 19091
- [x] 3-2. Port 인터페이스 7종 (Identity/Messaging/Mail/Video/Wiki/Storage/**Notification** — 마지막 Notification 은 2026-04-15 19:55 보강 추가)
- [x] 3-3. KeycloakAdapter
- [x] 3-4. MattermostAdapter (Rocket.Chat 용으로 재사용)
- [x] 3-5. StalwartMailAdapter
- [x] 3-6. MinioStorageAdapter
- [x] 3-7. LiveKitAdapter
- [x] 3-8. WikiJsAdapter
- [x] 3-9. `/api/bff/*` REST 컨트롤러 (BffController, 132 lines, 모든 port 라우트)

## Phase 4: UI 초기화 + ts-spring-fw 컴포넌트 복사 (완료)
- [x] 4-1. Vite + Vue 3 + TS + PrimeVue 4 + Pinia 초기화
- [x] 4-2. ts-spring-fw 컴포넌트 정적 복사 (layout/login/composables/api/store/router/pages)
- [x] 4-3. `docs/ts-spring-fw-reuse-map.md`
- [x] 4-4. keycloak-js 어댑터로 auth.ts/interceptor.ts 교체
- [x] 4-5. vite.config.ts 포트/proxy

## Phase 5: 로그인 → 대시보드 가드/권한 (완료)
- [x] 5-1. Keycloak PKCE 로그인 (검증: C1)
- [x] 5-2. Router 가드
- [x] 5-3. Dashboard 페이지 (5개 위젯: 일정/결재/공지/알림/메신저)
- [x] 5-4. useDataSet 실사용

## Phase 6: 결재 UI (완료)
- [x] 6-1. 결재함 레이아웃 (9종 박스 트리 + 리스트)
- [x] 6-2. 문서 상세 뷰
- [x] 6-3. 상신 폼 (양식 + DMN + 첨부 + 상신)
- [x] 6-4. 결재 액션 (승인/반려/전결/대결/회수)

## Phase 7: 게시판 UI (목록/검색 완료, CRUD 폼 미완)
- [x] 7-1. 게시글 목록 + 검색
- [ ] 7-2. 상세 뷰 + 작성/수정/삭제 (스텁 — 컴포넌트 상에 `글쓰기는 Phase 7 예정` 주석. 기능 사용 가능 상태로 보강 필요)
- [ ] 7-3. 첨부 (MinIO presigned — StoragePort 는 완료, UI 바인딩 미완)

## Phase 8: 캘린더 UI (완료)
- [x] 8-1. FullCalendar 임베드
- [x] 8-2. 월/주/일 뷰 + scope 필터
- [x] 8-3. CRUD 다이얼로그

## Phase 9: 조직도 UI (완료)
- [x] 9-1. 부서 트리
- [x] 9-2. 직원 카드

## Phase 10: 메신저 통합 (SSO launcher 완료, proxy 미채택)
- [~] 10-1. BFF `/api/bff/messenger/*` 프록시 — BffController 에 라우트는 있으나 UI 는 proxy 대신 SSO launcher 방식 채택 (warn.md 결정)
- [x] 10-2. Rocket.Chat Custom OAuth (Mattermost→RC 교체 완료, C3 검증)
- [ ] 10-3. 읽지 않은 메시지 뱃지 (Dashboard 연동 — 저우선)

## Phase 11: 메일/위키/화상회의 (런처 + video 임베드 완료)
- [~] 11-1. Stalwart 웹메일 — launcher 채택 (iframe 미사용). BFF MailPort 로 대체 UI 는 보류
- [~] 11-2. Wiki.js — launcher 채택 (iframe 미사용)
- [x] 11-3. LiveKit 룸 컴포넌트 (PageVideo.vue 150+ lines, C5 검증)

## Phase 12: 공통 마무리 (완료)
- [ ] 12-1. MinIO presigned URL 공통 업/다운로드 컴포넌트 (BFF 엔드포인트 완료, UI 공통 컴포넌트 미제작)
- [x] 12-2. SSE 알림 센터 (NotificationController `/subscribe` 완료)
- [x] 12-3. 다국어 전환 (useLocale 192 lines)
- [x] 12-4. 권한 제어 (usePermission 97 lines, menuId→canRead/Create/Update/Delete)

## Phase Final: E2E / 성능 / 보안 / README (예상 60분)
- [x] F-1. Playwright MCP 핵심 시나리오 6종 전부 실행 (C1~C6)
- [x] F-2. SSO 단일 호스트(kc.localtest.me) 통합 — 모든 6개 외부 서비스 single sign-on 달성
- [x] F-3. 사이드바 CSS 변수 누락 수정
- [x] F-4. LiveKit WebRTC 포트 매핑 정상화
- [x] F-5. PageVideo view-only 폴백
- [x] F-6. BFF /api/bff/video/config 신설
- [x] F-7. 모든 컨테이너 healthy 상태 확인
- [ ] F-8. **[인간] 실제 카메라/마이크 환경에서 화상회의 종단 검증** (헤드리스 환경 한계)

## Phase 13: 업무용 앱 프로덕션 (2026-04-16 ~) — 진행중

> 상세 플랜: `C:\Users\hyunsu_choi\.claude\plans\magical-fluttering-wombat.md`
> 핸즈오프: `SESSION_HANDOFF.md`

### Phase 0 — Identity & Schema 기반 (P0 blocker, 6h) — 완료
- [x] 0-1. V8__approval_and_extras.sql (ap_document/line/attachment/delegation/history + bd_comment + cm_holiday + FORM_CODE/BOARD_TYPE seed)
- [x] 0-2. OrgMapper.findEmployeeByKeycloakUserId / findByNo
- [x] 0-3. KeycloakIdentityAdapter org_employee 병합 (frontend fallback 채택, BFF 변경 없음)
- [x] 0-4. NotificationService.notifyByUserNo (하드코딩 10L 제거)
- [x] 0-5. DataSetController currentUser 자동 정규화 (Keycloak username → employee_no, MyBatis camelCase 인지)
- [x] 0-6. auth.ts UserInfo 확장 (employeeNo/employeeId/deptId/positionName/positionLevel)
- [x] 0-7. PageApproval/Dashboard/Calendar 하드코딩 ID 제거
- [x] 0-8. Clean DB 검증 + Playwright /approval 200 + delegate 정규화 검증

### Phase A — 결재 프로덕션 (24h) — 백엔드 100% / 프론트 30%
- [x] A-1. ApprovalService 6 신규 메서드 (withdraw/resubmit/delegate/uploadAttachment/listAttachments/countPending) + searchHistory + recordHistory helper
- [x] A-2. ApprovalMapper XML 9 신규 SQL (insertAttachment/selectAttachmentsByDoc/insertHistory/selectHistoryByDoc/insertDelegation+CAST/cloneDocumentForResubmit/updateDocumentContent/resetLinesForWithdraw/deleteAttachment) + selectApproversForDocFromDmn 의 HR/IT 분기
- [x] A-3 관련 backend 검증: countPending/searchHistory/listAttachments/delegate/withdraw smoke test 통과
- [x] A-9. useApproval.ts composable (13 메서드)
- [x] A-6. ApprovalLineTimeline.vue (PrimeVue Timeline)
- [x] A-7. ApprovalActionBar.vue (승인/반려/회수/재상신/대결 + 다이얼로그)
- [x] A-10. backend-core 재빌드 + 재기동
- [ ] A-3. PageApproval.vue 재작성 (CrudToolbar + SearchPanel + 9-box + paged DataTable + DetailDialog 호스팅)
- [ ] A-4. ApprovalDetailDialog.vue (4탭: 내용/결재선/첨부/이력 + ActionBar footer)
- [ ] A-5. ApprovalSubmitDialog.vue (양식/제목/금액/본문 + DMN 결재선 미리보기 + 첨부)
  - [ ] 백엔드 사이드 신규: `approval/previewApprovers` DataSet 서비스
- [ ] A-8. ApprovalAttachmentList.vue (presigned PUT/GET 통한 업/다운/삭제)
  - [ ] 백엔드 사이드 신규: `approval/deleteAttachment` DataSet 서비스
- [ ] A-11. Playwright MCP A1~A3 (상신→승인 / 반려→재상신 / 회수)

### Phase E — Dashboard + SSE 알림 센터 (8h, A 와 병행) — 0%
- [ ] E-1. NotificationBell.vue (헤더 우상단, unread 배지, 최근 10건 dropdown)
- [ ] E-2. useNotificationSse.ts composable (EventSource ?token= 쿼리)
- [ ] E-3. notification.ts Pinia store
- [ ] E-4. NotificationController SSE ?token= 인증 (쿼리 토큰을 Authorization 헤더로 변환하는 OncePerRequestFilter)
- [ ] E-5. notification/getBadgeCount DataSet 서비스
- [ ] E-6. PageDashboard 위젯 click-through navigation
- [ ] E-7. 2탭 SSE 전파 Playwright 검증

### Phase B — 게시판 풀 CRUD (14h) — 0%
- [ ] B-1. BoardService 확장: searchDetail (viewCount++) / deletePost / saveComment / listComments / uploadAttachment
- [ ] B-2. BoardMapper XML 확장
- [ ] B-3. PageBoard.vue 재작성 (카테고리 필터 + paged DataTable + 행 클릭 → DetailDialog)
- [ ] B-4. BoardDetailDialog.vue (마크다운 readonly + 댓글)
- [ ] B-5. BoardFormDialog.vue (md-editor-v3 + 첨부)
- [ ] B-6. CommentThread.vue (1단계 대댓글)
- [ ] B-7. Playwright B 시나리오

### Phase C — 캘린더 풀 CRUD (10h) — 0%
- [ ] C-1. CalendarService.deleteEvent + searchHolidays
- [ ] C-2. PageCalendar.vue 핸들러 (eventClick/dateSelect/eventDrop/eventResize)
- [ ] C-3. CalendarEventDialog.vue (제목/시간/scope/반복 규칙)
- [ ] C-4. cm_holiday 배경 이벤트 표시
- [ ] C-5. Playwright C 시나리오

### Phase D — 조직도 강화 (6h) — 0%
- [ ] D-1. PageOrg.vue 검색 debounced + 카드 클릭 핸들러
- [ ] D-2. EmployeeDetailDialog.vue (아바타 + 연락처 + 빠른 액션 3종)
- [ ] D-3. (선택) 조직도 PNG 내보내기 (html2canvas)

### Phase H — 메일 포탈 내부 UI (18h) — 0%
- [ ] H-1. StalwartMailAdapter JMAP 전면 구현 (getSession/listMailboxes/listEmails/getEmail/sendEmail/saveDraft/uploadAttachment)
- [ ] H-2. BFF /api/bff/mail/* 확장
- [ ] H-3. PageMail.vue 3단 레이아웃 재작성
- [ ] H-4. MailboxTree / EmailList / EmailDetail / ComposeDialog 4 컴포넌트
- [ ] H-5. JMAP accountId 매핑 (서비스 계정 옵션 A)
- [ ] H-6. Playwright H 시나리오

### Phase F — 공통 인프라 + i18n 4언어 (10h, 전 Phase 병행) — 0%
- [ ] F-1. CrudToolbar 전 페이지 적용 (Approval/Board/Calendar/Org)
- [ ] F-2. Router 권한 가드 + /403 라우트
- [ ] F-3. i18n ko.json (1차 기준, 핵심 ~200 키)
- [ ] F-4. i18n en.json (번역기 초벌 + 감수)
- [ ] F-5. i18n zh.json
- [ ] F-6. i18n ja.json
- [ ] F-7. LoadingSkeleton.vue 공통 컴포넌트
- [ ] F-8. interceptor.ts 글로벌 에러 toast
- [ ] F-9. v3-ui directAccessGrantsEnabled=false 복구 (운영 보안)

### Phase 13 Final — 회귀 + 클린 부팅 검증 (6h) — 0%
- [ ] FINAL-1. 기존 C1~C6 SSO 시나리오 재실행
- [ ] FINAL-2. docker compose down + volume rm + up → Flyway V1~V8 적용 검증
- [ ] FINAL-3. 100h 작업 분량 회귀 종합 보고서

---

## Phase 12.1: SSO 결함 수정 (2026-04-15 추가) — 완료
- [x] 12.1-1. global.css `--sidebar-width`/`--header-height`/`--page-ground` 추가
- [x] 12.1-2. realm.json `mattermost` → `rocketchat` 전환 + protocolMapper
- [x] 12.1-3. realm.json `minio` 클라이언트 신설 + policy mapper
- [x] 12.1-4. KC_HOSTNAME_URL → kc.localtest.me 통일
- [x] 12.1-5. 모든 컨테이너 extra_hosts 추가 (kc.localtest.me:host-gateway)
- [x] 12.1-6. RC Custom OAuth REST API 등록 (OVERWRITE_SETTING 미작동 회피)
- [x] 12.1-7. Wiki.js auth strategy DB jsonb_set 으로 host 갱신
- [x] 12.1-8. MinIO client_secret realm/compose 동기화
- [x] 12.1-9. LiveKit livekit.yaml 작성 + 포트 1:1 매핑
- [x] 12.1-10. PageVideo view-only 폴백
- [x] 12.1-11. BFF /api/bff/video/config 엔드포인트 신설
- [x] 12.1-12. PageMessenger Keycloak authorize URL 직접 진입
- [x] 12.1-13. openldap LDIF 시드 (/seed-ldif 마운트)
- [x] 12.1-14. Playwright E2E C1~C6 전체 통과
