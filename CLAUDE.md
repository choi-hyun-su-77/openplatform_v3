# openplatform_v3 — 통합 그룹웨어 프로젝트 규칙

상위 규칙은 `C:\claude\CLAUDE.md` 및 `C:\claude\CLAUDE_CODE_AUTONOMOUS_DEV_FRAMEWORK_V2.md` 에서 상속한다.

## 아키텍처
- 옵션 C 하이브리드: v1 DataSet 도메인(backend-core) + v2 Port-Adapter(backend-bff) + ts-spring-fw UI 컴포넌트 복사(ui)
- Keycloak 단일 SSO 허브, 6개 외부 서비스 Federation (Mattermost/Stalwart/LiveKit/Wiki.js/MinIO/포탈)

## 포트 대역
v3 전용 19xxx + UI dev 25174. 자세한 할당은 `docs/port-allocation.md`.

## ts-spring-fw 취급 규칙 (최상위)
- `C:\claude\ts-spring-fw\**` **원본 절대 수정 금지**
- 컴포넌트/composable/store/interceptor/템플릿은 읽기 후 `ui/` 로 **정적 복사**
- 복사 이력은 `docs/ts-spring-fw-reuse-map.md` 에 (원본경로 → v3경로 → 수정사항) 기록

## 상태 파일 (1분 단위 갱신)
- `info.md`: 현재 태스크 + 진행률
- `warn.md`: 자율 결정 이력
- `fatal.md`: 치명적 중단 (해당 없을 때 "중단 없음" 유지)
- `TODO.md`: Phase별 체크리스트

## 셀프 QA 루프
Layer 0(정적분석) → Layer 1(단위테스트) 는 개발 단위마다 즉시 실행. Layer 4(E2E Playwright MCP)는 Phase 종료 시.

## 서브모듈
없음. 모든 코드를 직접 관리.

## 실행
```bash
cd C:/claude/openplatform_v3
docker compose -f infra/docker-compose.yml up -d
cd ui && npm run dev -- --port 25174
```
