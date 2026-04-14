# 판단 이력 (개발자 검토용)

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
