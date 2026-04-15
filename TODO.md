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

## Phase 2: backend-core **신규 스캐폴딩 + 선택 포팅** (진행중)
- [x] 2-1. `backend-core/pom.xml` 신규 작성
- [x] 2-2. `Application.java`, `com.platform.v3.core` 네임스페이스
- [x] 2-3. `DataSetController` / `DataSetService` / `ServiceRegistry` / `@DataSetServiceMapping` 재작성 (AopUtils 사용, 중복 등록 검증, 레코드 기반)
- [ ] 2-4. 도메인 서비스 선택 포팅 (v1 분석 후 필요 메서드만):
  - `core/org/`: searchDeptTree, searchEmployees, searchApprovers
  - `core/approval/`: inbox, detail, submit, approve, reject, autoLine (DMN)
  - `core/board/`: searchPosts, searchDetail, savePosts
  - `core/calendar/`: searchEvents, saveEvents, searchToday
  - `core/notification/`: SSE + searchList/markRead
  - `core/code/`, `core/i18n/`: 공통
- [ ] 2-5. MyBatis mapper XML — v1 XML **분석 후 v3 네임스페이스로 재작성** (SELECT * 금지, camelCase 매핑 유지)
- [x] 2-6. `application.yml` 신규 (DB 19432, Redis 19379, Keycloak issuer, MinIO 19900, server.port 19090)
- [ ] 2-7. Flowable BPMN/DMN 리소스 내용 검토 후 선택 채택
- [x] 2-8. SecurityConfig (Keycloak JWT Resource Server)
- [x] 2-9. Dockerfile (multi-stage)
- [x] 2-10. V1__baseline.sql flyway
- [ ] 2-11. 공통(ApiResponse, BusinessException, GlobalExceptionHandler) — **완료**
- [ ] 2-12. 도메인 포팅: org / approval(Flowable) / board / calendar / notification / code / i18n
- [ ] 2-13. `mvn clean package -DskipTests` + 컨테이너 기동
  - 단위 테스트: `curl http://localhost:19090/actuator/health` UP
  - 단위 테스트: `curl http://localhost:19090/actuator/health` → UP
  - `curl -H "Authorization: Bearer <keycloak token>" http://localhost:19090/api/dataset/search -d '{"serviceName":"org/searchDeptTree","parameters":{}}'` → 200

## Phase 3: backend-bff Port-Adapter 스캐폴딩 (예상 90분)
- [ ] 3-1. Spring Boot 3.2.5 신규 모듈, 포트 19091
- [ ] 3-2. Port 인터페이스 7종 (`IdentityPort`, `MessagingPort`, `MailPort`, `VideoPort`, `WikiPort`, `StoragePort`, `NotificationPort`)
- [ ] 3-3. KeycloakAdapter (Admin API / OIDC introspection)
- [ ] 3-4. MattermostAdapter (v1 MattermostService 재활용)
- [ ] 3-5. StalwartAdapter (v1 MailService 재활용)
- [ ] 3-6. MinIOAdapter (presigned URL)
- [ ] 3-7. LiveKitAdapter (JWT 발급)
- [ ] 3-8. WikiJsAdapter (GraphQL 클라이언트)
- [ ] 3-9. `/api/bff/*` REST 컨트롤러 (messenger, mail, wiki, video, storage)
  - 단위 테스트: 각 어댑터 `health()` 메서드 pass, `/actuator/health` UP

## Phase 4: UI 초기화 + ts-spring-fw 컴포넌트 복사 (예상 60분)
- [ ] 4-1. `ui/` 에 Vite + Vue 3 + TS + PrimeVue 4 + Pinia 초기화 (ts-spring-fw package.json 참고)
- [ ] 4-2. ts-spring-fw에서 복사 (read-only 원본 → v3/ui로 정적 복사)
  - `components/layout/Layout{Default,Header,Sidebar,TabBar}.vue`
  - `components/common/{CrudToolbar,SearchPanel,PopupHost}.vue`
  - `components/login/LoginBrand*.vue`
  - `composables/{useDataSet,useDataSetPaging,usePermission,useCodes,useLabel,useMessage,useCombo,useLocale,useTheme}.ts`
  - `api/interceptor.ts`
  - `store/{auth,tab}.ts`
  - `router/index.ts`
  - `pages/PageLogin.vue`
- [ ] 4-3. `docs/ts-spring-fw-reuse-map.md` 갱신
- [ ] 4-4. `store/auth.ts` 와 `api/interceptor.ts` 를 keycloak-js 어댑터로 교체
- [ ] 4-5. `vite.config.ts` 포트 25174, proxy `/api → http://localhost:19090` + `/api/bff → http://localhost:19091`
  - 단위 테스트: `npm run dev -- --port 25174` 정상 기동, `/login` 진입

## Phase 5: 로그인 → 대시보드 가드/권한 (예상 45분)
- [ ] 5-1. Keycloak PKCE 로그인 플로우
- [ ] 5-2. Router 가드 (인증/권한/메뉴)
- [ ] 5-3. Dashboard 페이지 스캐폴딩 (5개 위젯: 일정/결재/공지/알림/메신저)
- [ ] 5-4. `useDataSet` 실사용 (org/searchDeptTree 호출)
  - 단위 테스트: Playwright MCP → 로그인 → 대시보드 스크린샷 비교

## Phase 6: 결재 UI (예상 90분)
- [ ] 6-1. 결재함 레이아웃 (좌측 9종 박스 트리 + 우측 리스트)
- [ ] 6-2. 문서 상세 뷰
- [ ] 6-3. 상신 폼 (양식 선택 → DMN 자동결재선 → 첨부 → 상신)
- [ ] 6-4. 결재 액션 (승인/반려/전결/대결/회수)
  - 단위 테스트: Playwright MCP 시나리오 3~4 실행

## Phase 7: 게시판 UI (예상 45분)
- [ ] 7-1. 게시글 목록 + 검색
- [ ] 7-2. 상세 뷰 + 작성/수정/삭제
- [ ] 7-3. 첨부 (MinIO presigned)

## Phase 8: 캘린더 UI (예상 60분)
- [ ] 8-1. FullCalendar 임베드 (ts-spring-fw 템플릿 참고)
- [ ] 8-2. 월/주/일 뷰 + 개인/부서/회사 필터
- [ ] 8-3. CRUD 다이얼로그

## Phase 9: 조직도 UI (예상 30분)
- [ ] 9-1. 부서 트리 (PrimeVue Tree)
- [ ] 9-2. 직원 카드 + 바로가기 (메신저/메일)

## Phase 10: 메신저 통합 (예상 60분)
- [ ] 10-1. BFF `/api/bff/messenger/*` 프록시
- [ ] 10-2. Mattermost iframe 임베드 + Keycloak Federation (GitLab OAuth 트릭)
- [ ] 10-3. 읽지 않은 메시지 뱃지 (Dashboard 연동)

## Phase 11: 메일/위키/화상회의 (예상 90분)
- [ ] 11-1. Stalwart 웹메일 임베드 (또는 BFF MailPort로 자체 UI)
- [ ] 11-2. Wiki.js iframe
- [ ] 11-3. LiveKit 룸 컴포넌트 (`@livekit/components-vue`)

## Phase 12: 공통 마무리 (예상 60분)
- [ ] 12-1. MinIO presigned URL 공통 업/다운로드 컴포넌트
- [ ] 12-2. SSE 알림 센터 (`/api/notification/subscribe`)
- [ ] 12-3. 다국어 전환 (`useLocale`)
- [ ] 12-4. 권한 제어 (`usePermission(menuId)`)

## Phase Final: E2E / 성능 / 보안 / README (예상 60분)
- [x] F-1. Playwright MCP 핵심 시나리오 6종 전부 실행 (C1~C6)
- [x] F-2. SSO 단일 호스트(kc.localtest.me) 통합 — 모든 6개 외부 서비스 single sign-on 달성
- [x] F-3. 사이드바 CSS 변수 누락 수정
- [x] F-4. LiveKit WebRTC 포트 매핑 정상화
- [x] F-5. PageVideo view-only 폴백
- [x] F-6. BFF /api/bff/video/config 신설
- [x] F-7. 모든 컨테이너 healthy 상태 확인
- [ ] F-8. **[인간] 실제 카메라/마이크 환경에서 화상회의 종단 검증** (헤드리스 환경 한계)

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
