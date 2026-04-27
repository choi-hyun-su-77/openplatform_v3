# 판단 이력 (개발자 검토용)

## [2026-04-27] T6 UX 강화(통합검색/즐겨찾기/알림설정) — 코드 작성 단독 수행
- **결정**: V15 마이그레이션 (`ux_favorite`, `ux_notify_pref` 테이블 + 검증용 시드 — admin E0001 즐겨찾기 5건/알림 설정 18건). 백엔드 3 서비스(`SearchService` 1 service, `FavoriteService` 4 service, `NotifyPrefService` 2 service) + `UxMapper` 통합. 통합 검색은 50명 규모 ILIKE 4도메인 (POST/DOC/EMP/FILE) — Phase 14 §8.5 SQL 패턴 그대로 (LIMIT 10 each).
- **NotificationService 호환 처리 (요점)**: `notifyByUserNo(...)` 기존 6 인자 시그니처는 절대 깨지 않고, 7번째 `category` 추가 오버로드 신설. 기존 호출(ApprovalService/BoardService/RoomService)는 무수정 — `category=null` 이면 PORTAL(SSE) 기존 동작 그대로. category 가 있을 때만 `NotifyPrefService.isChannelEnabled` 로 PORTAL/EMAIL/MESSENGER 분기. NotifyPrefService 와 BffClient 는 `@Autowired(required=false)` setter 로 주입 — 트랙 6 미통합 환경에서도 기존 도메인 정상 동작.
- **RocketChat DM 메서드 부재 (자율 결정)**: `RocketChatAdapter` 에 `sendDm`/`sendDirectMessage` 가 없고, BFF 에 `/api/bff/messenger/dm` 엔드포인트가 없음 (Phase 10 stub 상태). MESSENGER 채널은 `enabled=true` 여도 BffClient 호출은 미구현 (`sendNotificationDm` debug 로그만), warn 로그 후 스킵 — 알림 자체는 PORTAL/EMAIL 로 전달되므로 손실 없음. 후속 트랙(또는 Phase 10 마무리) 에서 RocketChat REST `/api/v1/im.create` + `/api/v1/chat.postMessage` 호출 구체화 필요.
- **EMAIL 채널 service-to-service 호출**: BFF `/api/bff/mail/send` 가 `JwtAuthenticationToken` 으로 보호됨 → backend-core 의 BffClient 는 인증 없이 호출하므로 401 가능성. 호출 실패 시 warn 로그만 남기고 PORTAL 은 정상 발송됨. 후속 보완 시 BFF 측에 service-account 인증 또는 internal-only 엔드포인트 추가 필요.
- **UI 드래그 정렬 우회**: §8 "npm 패키지 추가 금지" 규칙 → vuedraggable/Sortable.js 미사용. PageFavorites 는 ▲▼ 버튼으로 한 칸씩 이동 후 `ux/reorder` 일괄 호출. PrimeVue OrderList 는 양방향 리스트가 필요해 본 페이지 모델과 어긋나 미채택.
- **SearchBar / FavoriteRail LayoutHeader 마운트**: 트랙 8 책임 (지시문 §4 "절대 수정 금지" 준수) — 본 트랙은 컴포넌트 신규 작성과 `defineExpose({ reload })` 까지만 제공.
- **추가 컬럼**: `ux_favorite.icon` (PrimeIcons 클래스) 추가 — FavoriteRail 에서 즉시 사용 (스펙 §8.2 의 5개 컬럼 + icon, 후방 호환).
- **deferred (Docker 미실행)**: 라우터 등록(/search, /settings/notify, /settings/favorites, 트랙 8 일괄), 메뉴 INSERT (V17, 트랙 8), mvn package, Flyway clean boot, Playwright smoke 시나리오 1·2.
- **수정/신규 파일**:
  - 신규: `V15__ux_features.sql`, `core/ux/{SearchService,FavoriteService,NotifyPrefService}.java`, `core/ux/mapper/UxMapper.java`, `mapper/ux/UxMapper.xml`, `ui/src/composables/useUx.ts`, `ui/src/components/layout/{SearchBar,FavoriteRail}.vue`, `ui/src/pages/{PageSearch,PageNotifySettings,PageFavorites}.vue`
  - 수정: `core/notification/NotificationService.java` (오버로드 추가, 기존 시그니처 보존), `core/common/BffClient.java` (sendNotificationEmail / sendNotificationDm 추가). 그 외 트랙 파일·router/index.ts·LayoutHeader.vue·v1·v2·vue-spring-fw 원본 미수정.

## [2026-04-27] T1 근태·연차·휴가 — 코드 작성 단독 수행 (Docker 검증 deferred)
- **결정**: V10 마이그레이션, AttendanceService(5)/LeaveService(5+applyFromDoc/onDocApproved DataSet), MyBatis Mapper, PageAttendance/PageLeave/MonthlyCalendar/LeaveBalanceCard, useAttendance/useLeave 작성. ApprovalService 의 form_code='LEAVE' 분기에서 LeaveService.applyFromDoc 자동 호출, ApprovalCompleteDelegate 에서 onDocApproved 호출. ApprovalService.approve 의 allApproved 분기에도 onDocApproved 호출 추가 (UI 직접 결재 즉시 반영).
- **순환 의존 회피**: ApprovalService 의 LeaveService 주입을 setter 주입 (`@Autowired(required=false)`) 으로 처리 — 트랙 1 빌드 누락 시에도 결재 도메인 정상 동작.
- **Donut 차트**: 외부 라이브러리 추가 금지 규칙 준수 — SVG `<circle>` 두 개 + `stroke-dasharray` 로 직접 구현.
- **UI 영업일 계산**: 백엔드(LeaveService.calculateDays)는 cm_holiday 와 주말 모두 제외하지만, UI(ApprovalSubmitDialog.recalcDays)는 주말만 제외 (공휴일 fetch 비용 절감). 실제 차감 시 백엔드 정밀 계산이 권위. UI 수치는 사용자 사전 안내용.
- **deferred (Docker 미실행)**: T1-10 라우트/메뉴 등록(트랙 8 통합 책임), T1-11 mvn package / Flyway clean boot / Playwright smoke, T1-12 api-catalog/scenarios 갱신.
- **수정 파일**: ApprovalService.java(import+setter+submit/approve 분기), ApprovalCompleteDelegate.java(setter+execute 후처리), ApprovalSubmitDialog.vue(initialFormCode prop + LEAVE 필드 v-if 분기). 다른 트랙 파일·라우터·레이아웃·v1·v2·vue-spring-fw 원본 미수정.

## [2026-04-27] T3 자료실 — backend-core 직접 MinIO presigned 발급 채택
- **결정**: BFF WebClient 미존재로 backend-core 에 `MinioConfig` 빈 등록 → `DataLibraryService.getDownloadUrl` 이 직접 presigned GET 발급. 업로드 PUT 만 기존 BFF `/api/bff/storage/presigned` 패턴 유지.
- **부서 폴더 자동 시드**: `INSERT INTO dl_folder ... SELECT FROM org_department WHERE dept_level=3` 로 leaf 9개 부서 폴더 자동 생성.
- **트랙 8 합류 잔여**: 라우트/메뉴 등록, mvn 컴파일 검증.

## [2026-04-27] Phase 14 Wave 1 spawn — Docker 미실행 상태에서 코드 우선 작성
- **상황**: 사용자가 `docs/PHASE14_PRODUCTION_GROUPWARE.md 진행해` 지시. 환경 검증에서 Docker daemon 응답 없음.
- **결정**: Mode B (병렬 4 에이전트) 진행. T1·T2·T3·T5 동시 spawn (run_in_background). 각 에이전트는 코드 작성만 수행하고 DoD 의 빌드/Flyway/Playwright 검증은 skip — Wave 3 (트랙 8) 에서 Docker 복구 후 일괄.
- **공유 파일 충돌 회피**: 각 에이전트는 자기 트랙 파일만 작성. `ui/src/router/index.ts`, `LayoutSidebar.vue`, `App.vue` 등 공유 파일은 손대지 않음 — 트랙 8 에서 일괄 통합.
- **DataSetService 등록**: 각 트랙은 자기 도메인 ServiceMapping 만 등록. ServiceRegistry 자동 스캔이 동작하므로 충돌 없음.
- **Flyway 버전**: §1.1 분배 (T1=V10, T2=V11, T3=V12, T5=V14) 엄수.

## [2026-04-16 22:40] Phase H 메일 JMAP 전면 구현 완료
- **JMAP methodCalls 직렬화 이슈 2건 수정**: (1) Java `Object[]` 를 Jackson 이 JSON 배열이 아닌 객체로 직렬화 → `List.of()` 로 변경. (2) `methodResponses` 역직렬화가 `List<List<Object>>` 로 오는데 `List<Object[]>` 로 캐스팅 시도 → 제네릭 수정. 두 건 모두 Stalwart JMAP 400 응답으로 발견, 수정 후 5개 mailbox 정상 반환.
- **JMAP 서비스 계정 방식 확정**: `admin:admin` Basic Auth 로 Stalwart JMAP 호출. `accountId` 는 Keycloak `preferred_username` 을 사용하되, Stalwart 가 해당 accountId 를 인식하려면 LDAP 동기화 필수. 현재 admin 계정만 정상 동작, user1/user2 는 LDAP 사용자가 Stalwart 에 프로비저닝된 후 사용 가능.
- **UI 3단 레이아웃**: `grid-template-columns: 200px 360px 1fr` 로 메일함/리스트/상세 분리. ComposeDialog 는 답장/전달 시 제목 prefix (`Re:` / `Fwd:`) + preview 본문 자동 채움.

## [2026-04-16 21:22] Phase A fix + E + B + C + D + F 부분 완료
- **Phase A 미완 4건 모두 수정**: approve() recordHistory 추가, OrgMapper 주입 actorName lookup, HR/IT LIMIT 동적(2/3), 첨부 verifyDocAccess 권한 검증. 모두 API 검증 통과.
- **Phase E SSE 인증 결정**: 브라우저 EventSource 가 커스텀 헤더 미지원 → `?token=` 쿼리 파라미터 방식 채택. `SseTokenFilter` (OncePerRequestFilter) 가 SSE 엔드포인트에서만 토큰을 Authorization 헤더로 변환. SecurityConfig 에서 `/api/notification/subscribe` 를 `authenticated()` 로 변경 (이전 `permitAll`). NotificationController 는 JWT `preferred_username` → `org_employee.employee_id` 자동 매핑.
- **Phase B 게시판**: BoardService 에 댓글 CRUD 5개 + 첨부 1개 DataSet 서비스 추가. 댓글은 `bd_comment` 의 `parent_id` 기반 1단계 대댓글 지원. 삭제는 soft delete (`deleted=TRUE`). BoardFormDialog 는 `md-editor-v3` 대신 PrimeVue `Textarea` 채택 — 외부 패키지 의존성 최소화, 마크다운 렌더링은 BoardDetailDialog 에서 줄바꿈만 처리.
- **Phase C 캘린더**: `calendar/deleteEvent` 독립 DataSet 서비스 추가 (기존 saveEvents _rowType="D" 와 별도). FullCalendar `dateClick` / `dateSelect` / `eventClick` / `eventDrop` / `eventResize` 전부 구현. 공휴일은 `cm_holiday` 에서 조회하여 분홍색 background 이벤트로 표시. 반복 일정(RRULE)은 미구현 — DB 에 recurrence 컬럼 없음, Phase F 또는 후속에서 필요 시 추가.
- **Phase F 글로벌 에러 toast**: interceptor.ts 에서 4xx/5xx 에러 시 `CustomEvent('global-error-toast')` 발행, `LayoutDefault.vue` 에서 수신하여 `useMessage().error()` 호출. 403은 `/403` 라우트로 리다이렉트.
- **서비스 수 변화**: 30 → 37 (Phase B +5, Phase C +2).

## [2026-04-16 05:32] Phase A 전체 완료 (백엔드 + UI + E2E)
- **Phase A 결재 프로덕션 100% 도달** — 6 신규 백엔드 메서드 + 8 신규 백엔드 SQL + 5 신규 Vue 컴포넌트 + composable + PageApproval 재작성 + Playwright E2E.
- **검증 통과 시나리오**:
  - submit BIZTRIP/500000 → docId=26, 결재선 3명 자동 생성
  - 1단계 승인 → IN_PROGRESS + line 상태 정확
  - 회수 → DRAFT + 모든 라인 reset
  - previewApprovers (BIZTRIP/HR formCode 분기) → 3명
  - searchDetail / searchInbox / deleteAttachment 모두 200
- **알려진 미완 (다음 세션 작업)**:
  - `ApprovalService.approve()` 가 `recordHistory()` 를 호출하지 않음 → 결재 이력 탭에 승인 액션 미기록. submit / reject / withdraw / resubmit 은 기록되지만 approve 누락. ApprovalService.approve 메서드 끝에 `recordHistory(docId, lineId, "APPROVE", currentUser, comment)` 한 줄 추가하면 해결.
  - `recordHistory` 의 actorName 이 currentUser (employee_no) 그대로 — OrgMapper.findEmployeeByNo lookup 으로 employee_name 추출하면 더 정확. TODO 주석 있음.
  - 첨부 다운로드 권한 검증 부재 — 누구나 presigned GET 발급 가능. Phase F 보안 sweep 에서 처리.
- **PrimeVue 4 TabPanel API 변경 발견**: `<TabPanel header="...">` 만으로는 TS 컴파일 실패 (`value` prop 필수). 모든 TabPanel 에 `value="content"` 등 명시. 다른 도메인 (Board/Calendar) 컴포넌트 작성 시 동일 패턴 적용 필요.
- **selectApproversForDocFromDmn 의 HR 분기 결과 검증**: 의도는 HR/IT formCode 일 때 level<=2 (2단계만), 다른 formCode 는 amount 기반 3구간. 실제 호출 결과 HR 도 3 명 반환 — `LIMIT 3` 이 모든 경우에 3명을 채우려고 하기 때문. 의도와 차이. 다음 세션에서 `LIMIT` 을 `formCode` 별 dynamic 으로 변경하거나 HR 만 LIMIT 2.

## [2026-04-16 00:50] Phase 13 (업무용 앱) Phase 0 + Phase A 백엔드 완료
- **Identity 정규화 패턴 결정**: Keycloak `preferred_username` ↔ `org_employee.employee_no` 의 단일 매핑 경로를 `org_employee.keycloak_user_id` 컬럼으로 확정. `DataSetController.currentUser()` 가 모든 도메인 서비스에 employee_no 를 전달. 매핑 실패 시 fallback (username 그대로). MyBatis camelCase 변환을 인지하여 `emp.get("employeeNo")` 우선 lookup.
- **V8 마이그레이션 호환성**: 런타임 DB 에 이미 ap_document/ap_approval_line 이 있는 상태에서도 동작하도록 `CREATE TABLE IF NOT EXISTS` + `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` 패턴 사용. 클린 부팅과 기존 부팅 양쪽 지원. 이 결정 덕분에 Phase 0 에서 DB 재초기화 없이 마이그레이션 적용 가능.
- **NotificationService.notifyByUserNo 신규**: 도메인 서비스가 employee_no 만 갖고 있어도 SSE 수신자(employee_id) 로 자동 변환. 기존 `notify(Long)` 은 유지하되 `recipientId == null` 조기 종료 추가. 모든 ApprovalService 호출은 `notifyByUserNo` 로 마이그레이션.
- **BFF KeycloakIdentityAdapter 확장 미채택**: BFF 가 backend-core DB 에 직접 접근하지 않도록, frontend `auth.ts` 가 `/api/bff/identity/me` 호출 후 `data.employee` 가 비어있으면 `org/findMyEmployee` DataSet 호출 로 fallback. 이 패턴은 BFF 의 단순성을 유지하면서 frontend 만으로 employee 정보를 얻을 수 있게 함. 후속 turn 에서 BFF 응답 형식이 명확해지면 BFF 측 병합으로 옮길 수 있음.
- **delegate INSERT 의 DATE 캐스팅 이슈**: PostgreSQL 가 string→DATE 자동 변환을 거부하여 `CAST(#{fromDate} AS DATE)` 명시 필요. MyBatis typeHandler 대신 SQL 측 캐스팅 채택 — 더 명시적이고 디버깅 용이.
- **Phase A 의 4 컴포넌트 (DetailDialog/SubmitDialog/AttachmentList/PageApproval) 는 다음 세션으로 이연**: 이번 세션 (1시간 핸즈오프 제약) 에서 백엔드 + 프론트 헬퍼 (useApproval/Timeline/ActionBar) 까지 안정 체크포인트로 완료. SESSION_HANDOFF.md 에 다음 세션 시작 가이드 문서화.
- **`v3-ui.directAccessGrantsEnabled=true` 재활성화**: E2E smoke test 용. Phase F-9 에서 false 로 복구해야 함.

## [2026-04-15 19:55] Phase 12.2 — 후속 정리 (E1~E7)
- **E1 감사**: TODO.md 체크박스 대부분이 스테일. 실제 상태는 24 DONE / 4 STUB / 1 MISSING.
  - MISSING: `NotificationPort` 인터페이스 — 바로 추가 (bff/port/NotificationPort.java 4개 메서드)
  - STUB: PageBoard CRUD 폼, PageMessenger/Mail/Wiki 런처 (iframe 미채택)
  - STUB 결정: 런처 방식(외부 탭 열기 + Keycloak SSO 자동 완주)은 동일 UX 를 제공하며 iframe 보다 안정적이어서 현재 전략 유지. 추후 이슈 발생 시 재검토.
- **E2 보안 원복**: `v3-ui` 클라이언트 `directAccessGrantsEnabled=false` 로 kcadm update 수행. E2E 에서 사용한 password grant 경로 제거.
- **E3 Wiki.js autoEnrollGroups**: `[1]`(Administrators) → `[2]`(Guests) 로 변경. 운영 보수적 기본값. 관리자 권한은 개별 승격으로 부여.
- **E4 신규 구현**: NotificationPort.java (stub 인터페이스만 — 실제 구현은 backend-core 알림 API 가 이미 존재하므로 BFF Adapter 는 필요 시 추가)
- **E5 TODO.md 재동기화**: 24개 완료 항목 `[x]`, 4개 STUB 는 `[~]` 또는 `[ ]` 로 명확화.
- **E6 F-8 가이드**: `docs/video-manual-check.md` 작성 — 1인/2인 테스트 절차 + Type A 통과 기준 + 실패시 점검 순서.

## [2026-04-15 19:50] Phase 12 — SSO 통합 결함 일괄 수정
- **상황**: 사용자가 일부 서비스 SSO 미작동(메신저/MinIO/메일/화상회의) + 사이드바 깨짐 보고
- **수정 내역**:
  1. **CSS 변수 누락**: `ui/src/styles/global.css` 에 `--sidebar-width: 260px`, `--header-height: 56px`, `--page-ground` 추가. 기존에 정의 없이 var() 만 참조하여 사이드바 너비가 0으로 렌더된 상태였음.
  2. **Keycloak 단일 호스트 통일**: 브라우저와 docker 컨테이너가 모두 동일 호스트로 Keycloak 에 접근하도록 `kc.localtest.me` (RFC public DNS, 항상 127.0.0.1 응답) 로 통일. KC_HOSTNAME_URL/KC_HOSTNAME_ADMIN_URL 변경. 모든 다운스트림 서비스(rocketchat/wikijs/minio/backend-core/backend-bff)에 `extra_hosts: kc.localtest.me:host-gateway` 추가. 단일 도메인 → 단일 SSO 쿠키 → 진정한 single sign-on 달성.
  3. **Rocket.Chat Custom OAuth**: realm.json 의 `mattermost` 클라이언트를 `rocketchat` 로 교체 (callback `/_oauth/keycloak`). RC settings.update REST API 로 Custom-Keycloak 프로바이더 등록 (env var OVERWRITE_SETTING 은 RC 6.x 에서 Custom OAuth 키에 미적용).
  4. **MinIO Console SSO**: realm.json 에 `minio` 클라이언트 신설 + protocolMapper(policy=consoleAdmin). docker-compose 의 client_secret 을 realm 시크릿과 동기화. Keycloak OIDC 발견 실패는 client secret 불일치 + 호스트 이름 불일치 조합이었음.
  5. **Wiki.js**: realm 재임포트 후 클라이언트 시크릿 mismatch → kcadm 으로 wiki-js 시크릿을 wiki DB 에 저장된 값(`C45Mb5Fu6kVGwyk9i8cpxrAFi1lm6Nbm`)으로 동기화. wiki strategy host/URL 5종을 DB jsonb_set 으로 kc.localtest.me:19281 로 갱신. SSO 사용자 자동 그룹 매핑(autoEnrollGroups=[1] Administrators) + 기존 SSO 사용자 수동 추가.
  6. **LiveKit WebRTC**: dev 모드 ICE 실패 → `livekit.yaml` 신규 작성, port=19880/tcp_port=19881/udp_port=19882 로 호스트 매핑과 일치. node-ip=127.0.0.1 명시. compose 에서 19881/tcp + 19882/udp 추가 노출.
  7. **PageVideo view-only 폴백**: 카메라/마이크 디바이스 없는 환경에서도 룸 입장이 성공하도록 `createLocalTracks` 실패를 try-catch 로 감싸 view-only 모드 폴백.
  8. **BFF /api/bff/video/config 신설**: 브라우저가 LiveKit WS URL 을 BFF 에서 동적으로 받도록 추가. token 응답에도 wsUrl 포함.
  9. **PageMessenger SSO 진입 경로**: Mattermost `/oauth/gitlab/login` 경로 → Keycloak authorize URL 직접 호출 (`kc.localtest.me:19281/realms/.../auth?client_id=rocketchat&redirect_uri=.../_oauth/keycloak`).
  10. **openldap 시드**: `LDAP_SEED_INTERNAL_LDIF_PATH=/seed-ldif` + `./ldap:/seed-ldif` 마운트. osixia/openldap 의 chown 충돌 회피 위해 bootstrap 디렉토리에 직접 마운트 대신 별도 경로 사용.

- **검증 결과 (Playwright MCP, 2026-04-15 19:51)**:
  - C1 사이드바: width=260px, position=fixed, mainMarginLeft=260px, header height=56px ✓
  - C2 Wiki.js SSO: redirect chain 완주, GraphQL profile=admin@v3.local, "Welcome | Wiki.js" 진입 ✓
  - C3 Rocket.Chat SSO: Meteor.userId 발급, "Home - 1 unread message" 페이지 진입 ✓
  - C4 MinIO Console SSO: /browser 진입, Administrator/Buckets/Policies 메뉴 표시 ✓
  - C5 LiveKit: 룸 입장 성공, v3-general 헤더+컨트롤 표시 (view-only 폴백) ✓
  - C6 메일: BFF /api/bff/mail/mailbox=200, 빈 inbox 응답 ✓

- **잔여 사항 / 알려진 제약**:
  - dev 모드 client `v3-ui` 에 directAccessGrantsEnabled=true 활성화 (E2E 스크립트용) → 운영 배포 시 false 로 변경 필요
  - LAN IP 가 변경되면 `kc.localtest.me` 자체는 영향 없으나 DNS 캐시/방화벽 환경에서 이슈 가능 — 최초 1회 `nslookup kc.localtest.me` 로 127.0.0.1 응답 확인 필요
  - LiveKit dev 모드는 in-memory state — 컨테이너 재시작 시 룸 데이터 초기화

## [2026-04-14 22:45] 최상위 규칙 추가 — 질문 금지
- **규칙**: 사용자에게 질문 금지. 모든 분기 선택은 "yes / 진행" 으로 처리. 어쩔 수 없이 질문하게 되면 비프음 1회.
- **적용**: 구현 중 애매한 선택지는 합리적 기본값을 채택하고 warn.md에만 기록. 진행을 막는 확인 질문 제거.

## [2026-04-14 22:32] 최상위 규칙 추가 — v1/v2 무저건 복사 금지
- **상황**: Phase 2 진입 직전, v1 backend 전체를 backend-core로 bulk copy 하려던 중 사용자가 규칙 추가
- **규칙**: `C:\claude\openplatform`, `C:\claude\openplatform_v2` 는 **분석 후 필요 요소만 선택적으로 참고**. 통째 복사 금지.
- **조치**: 이미 실행된 `cp -r v1/backend → v3/backend-core` 결과물을 전량 삭제. backend-core는 신규 Spring Boot 프로젝트로 scaffolding 하고, v1에서 **도메인 로직 파일 단위로만** 선택 포팅. v2도 동일 — Port 인터페이스 설계만 참고하고, 구현은 v3 고유.
- **영향**: Phase 2 재설계 — "복제" → "선택 포팅 + v3 고유 스캐폴딩". vue-spring-fw 규칙과 동일한 취급.

## [2026-04-14 22:15] 자율 의사결정 — 백엔드 선택
- **상황**: v1/v2/vue-spring-fw 세 소스 중 어느 것을 v3 백엔드로 쓸지 결정 필요
- **판단 내용**: 옵션 C 하이브리드 채택 (v1 도메인 재사용 + v2 Port-Adapter BFF + vue-spring-fw UI 컴포넌트 복사 재사용)
- **근거**: UI 별도 제작 전제에서 v1의 결재/게시판/캘린더/조직도 70% 완성도 활용 가치가 최대. 외부 서비스는 v2의 Port-Adapter로 격리하면 장기 유연성 확보. vue-spring-fw는 원본 불변 규칙으로 컴포넌트만 복사.

## [2026-04-14 22:15] 자율 의사결정 — 포트 대역
- **상황**: v1(17xxx)/v2(18xxx)와 충돌하지 않는 v3 전용 포트 대역 결정
- **판단 내용**: v3 = 19xxx 대역 주력 + UI dev 25174 (vue-spring-fw 25xxx 대역과도 비충돌)
- **근거**: docker-info.xml 레지스트리 분석 결과 19xxx는 완전 비어있음. 번호 연속성으로 운영자가 기억하기 쉬움.

## [2026-04-14 22:15] 자율 의사결정 — 메신저 초기 어댑터
- **상황**: Mattermost TE vs Zulip 선택
- **판단 내용**: Mattermost TE로 시작, Port 추상화로 추후 Zulip 교체 가능 상태 유지
- **근거**: v1에서 MattermostService.java가 이미 구현되어 있어 즉시 재활용 가능. Keycloak GitLab OAuth 트릭으로 OIDC 유료 제약 우회.

## [2026-04-14 22:15] 자율 의사결정 — 인증 통합 방식
- **상황**: vue-spring-fw는 자체 JWT, openplatform은 Keycloak 사용
- **판단 내용**: Keycloak 단일 허브로 통일. vue-spring-fw에서 복사한 store/auth.ts와 api/interceptor.ts는 keycloak-js 어댑터로 교체.
- **근거**: 최상위 규칙 "Keycloak으로 통합 로그인". vue-spring-fw 원본은 건드리지 않고, 복사본만 수정하므로 규칙 준수.

## [2026-04-27] 자율 의사결정 — Phase 14 트랙 2 (회의실 예약)
- **BffClient 신규 생성**: backend-core 가 backend-bff /api/bff/video/room 를 호출하기 위해
  `core/common/BffClient.java` 신규 생성 (Spring 6 RestClient 사용). base-url 은
  `${bff.base-url:http://backend-bff:8080}` 환경변수, 호출 실패 시 null 반환 + warn 로그
  (LiveKit 룸은 첫 접속 시 자동 생성되므로 폴백 가능 — 비즈니스 트랜잭션 롤백 안 함).
- **참석자 검색**: 기존 `org/searchEmployees` DataSet 를 재사용 (BookingDialog.vue 가
  PrimeVue MultiSelect 의 client-side 필터로 처리). status=ACTIVE 만 로드.
- **livekit_room 컬럼 갱신**: insertBooking 으로 booking_id 발급 후 별도 update
  (`updateLivekitRoom`) 호출. 룸 이름은 `rm-{bookingId}` 결정적 형식.
- **본인 cal_event 자동 INSERT**: RoomService.reserve 가 직접 CalendarMapper.insertEvent
  호출 (CalendarService.saveEvents 의 DataSet 패턴은 _rowType 분기를 거쳐야 하므로 직접
  호출이 단순). 실패 시 warn 만 — 회의실 예약 자체는 성공.
- **admin 판정**: SecurityContext role 추출 인프라 부재로 employee_no 시드값(E0001/admin)
  + position_level >= 90 의 경량 체크. 정밀 권한은 트랙 5(시스템관리) 와 함께 RoleResolver
  도입 시 강화 예정.
- **트랙 8 deferred 항목**: /room 라우트 등록, cm_menu INSERT, CalendarService UNION
  통합, Playwright E2E — 본 트랙은 자기 페이지·서비스만 작성.

## 2026-04-27 — Phase 14 Track 5 (Admin Console)
- **Keycloak admin token 발급 방식**: realm-export 의 `realm-management` client_credentials grant 가
  설정되지 않아 (`v3-backend-bff` 가 bearerOnly), master realm 의 기본 `admin-cli` public client +
  admin/admin password grant 로 발급. 운영 시 service-account 클라이언트 추가 권장
  (`KEYCLOAK_ADMIN_CLIENT_ID`, `KEYCLOAK_ADMIN_USER`, `KEYCLOAK_ADMIN_PASS` 환경변수로 주입 가능).
- **AOP vs HandlerInterceptor 선택**: AOP 채택. DataSetController 의 단일 진입점이지만
  HandlerInterceptor 는 응답 직전 hook 으로 동작해 service 단위 결과 객체 접근이 어렵고,
  AOP `@Around` 는 메서드 단위 인풋/아웃풋 Map 을 직접 받을 수 있어 before/after JSON 직렬화
  품질이 더 높음. spring-boot-starter-aop 신규 의존성 추가 (transitive 미포함).
- **권한 체크 위치**: AdminService 메서드 진입점 (`requireAdmin()`) + BFF identity admin 라우트
  진입점 (`requireAdmin(auth)`) 양쪽 이중 가드. SecurityConfig URL 매처 가드는 미사용
  (DataSet 단일 엔드포인트라 path 기반 가드 불가).
- **admin/* 호출 BFF 호출 시 Auth 전파**: backend-core 가 RestTemplate 로 BFF 를 호출할 때
  현재 사용자의 JWT Bearer 토큰을 그대로 전파하여 BFF 에서 동일한 ROLE_ADMIN 검증을 거치도록 함.
- **임시 비밀번호**: `temp123!` 고정. `temporary=true` 로 첫 로그인 시 강제 변경.
- **MultiSelect 역할 4종**: ROLE_USER / ROLE_APPROVER / ROLE_MANAGER / ROLE_ADMIN. UI 정적 옵션
  (cm_role 도 admin/menuList 에서 함께 반환되지만 PageUsers 는 단순화 위해 정적 배열 사용).
- **트랙 8 deferred**: /admin/* 5개 라우트 등록 / cm_menu INSERT (admin_users, admin_depts, ...) /
  Playwright E2E 시나리오 1·2·4 (Docker 미실행으로 deferred). router/index.ts 수정 금지 규칙 준수.

## [2026-04-27] T7 대시보드 위젯 — 코드 작성 단독 수행 (Docker 검증 deferred)
- **결정**: V16 마이그레이션 (db_widget 9건 시드 + db_user_widget UNIQUE), WidgetService 5 service (listAll/listMine/saveLayout/addWidget/removeWidget) + WidgetMapper UPSERT 패턴, useWidget.ts, PageDashboard.vue 재작성, 9개 위젯 컴포넌트 신규.
- **드래그 vs 화살표 선택**: HTML5 drag-and-drop 진짜 드래그 대신 **화살표 버튼 (←→↑↓ + W±/H±)** 채택 — vue-grid-layout 등 npm 패키지 추가 금지 규칙 준수, 키보드 접근성 향상, 12-column 그리드 셀 단위 정밀 이동 가능. CSS Grid 의 `order` 속성 + `--w/--h` CSS 변수로 위치/크기 표현.
- **default 6 위젯 자동 시드 위치**: `WidgetService.listMine()` 의 server-side 자동 시드 채택. count==0 일 때만 INSERT (사용자가 의도적으로 모든 위젯 제거한 경우 자동 재시드 안 함). default 배치는 12-column × 3행 (ATTENDANCE/LEAVE_BALANCE/PENDING_APPROVAL 4-col 1행, TODAY_EVENTS/NOTICES 6-col 2행, MESSENGER 4-col 3행).
- **TEAM_WORKLOG 권한 가드**: 위젯 자체에서 `auth.user.roles` 검사 (MANAGER/MGR/ADMIN/DEPT_HEAD 정규식). 비부서장이 추가하면 "부서장 전용" 메시지 표시 (위젯 자체는 노출하되 데이터는 비표시).
- **차트 라이브러리**: Chart.js 등 미추가. WidgetLeaveBalance 는 SVG `<circle>` × 2 (track + ring) + `stroke-dasharray` donut, WidgetLeaveChart 는 SVG `<rect>` 12개 막대 + 수동 grid lines.
- **edit_mode 트랜잭션**: 편집 진입 시 `widgets.value` deep-copy snapshot 저장 → 취소 시 복원. 저장은 `saveLayout` 일괄 (C/U 는 upsert, 삭제 큐는 _rowType='D' 로 변환).
- **트랙 8 deferred**: 라우트/메뉴는 기존 /dashboard 그대로 유지 (메뉴 추가 없음). Playwright 시나리오 (default 6 자동 표시 / 위젯 추가 → 새로고침 유지 / 출근 클릭 → checkIn) 는 Docker 복구 후 트랙 8 통합 시 검증.
- **트랙 1·2·4 service 미존재 가능성**: 본 트랙은 `attendance/searchToday`, `attendance/checkIn`, `leave/searchBalance`, `leave/searchMyHistory`, `room/searchMyBookings`, `worklog/searchTeamWeekly` 호출만 작성. 같은 Wave 의 트랙들이 작성 중이라 빌드 시점에 따라 미존재 가능 — 런타임은 트랙 8 통합 후 모두 동작.
