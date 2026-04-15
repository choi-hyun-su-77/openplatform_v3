# 판단 이력 (개발자 검토용)

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
- **영향**: Phase 2 재설계 — "복제" → "선택 포팅 + v3 고유 스캐폴딩". ts-spring-fw 규칙과 동일한 취급.

## [2026-04-14 22:15] 자율 의사결정 — 백엔드 선택
- **상황**: v1/v2/ts-spring-fw 세 소스 중 어느 것을 v3 백엔드로 쓸지 결정 필요
- **판단 내용**: 옵션 C 하이브리드 채택 (v1 도메인 재사용 + v2 Port-Adapter BFF + ts-spring-fw UI 컴포넌트 복사 재사용)
- **근거**: UI 별도 제작 전제에서 v1의 결재/게시판/캘린더/조직도 70% 완성도 활용 가치가 최대. 외부 서비스는 v2의 Port-Adapter로 격리하면 장기 유연성 확보. ts-spring-fw는 원본 불변 규칙으로 컴포넌트만 복사.

## [2026-04-14 22:15] 자율 의사결정 — 포트 대역
- **상황**: v1(17xxx)/v2(18xxx)와 충돌하지 않는 v3 전용 포트 대역 결정
- **판단 내용**: v3 = 19xxx 대역 주력 + UI dev 25174 (ts-spring-fw 25xxx 대역과도 비충돌)
- **근거**: docker-info.xml 레지스트리 분석 결과 19xxx는 완전 비어있음. 번호 연속성으로 운영자가 기억하기 쉬움.

## [2026-04-14 22:15] 자율 의사결정 — 메신저 초기 어댑터
- **상황**: Mattermost TE vs Zulip 선택
- **판단 내용**: Mattermost TE로 시작, Port 추상화로 추후 Zulip 교체 가능 상태 유지
- **근거**: v1에서 MattermostService.java가 이미 구현되어 있어 즉시 재활용 가능. Keycloak GitLab OAuth 트릭으로 OIDC 유료 제약 우회.

## [2026-04-14 22:15] 자율 의사결정 — 인증 통합 방식
- **상황**: ts-spring-fw는 자체 JWT, openplatform은 Keycloak 사용
- **판단 내용**: Keycloak 단일 허브로 통일. ts-spring-fw에서 복사한 store/auth.ts와 api/interceptor.ts는 keycloak-js 어댑터로 교체.
- **근거**: 최상위 규칙 "Keycloak으로 통합 로그인". ts-spring-fw 원본은 건드리지 않고, 복사본만 수정하므로 규칙 준수.
