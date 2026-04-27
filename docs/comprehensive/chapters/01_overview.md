# 1.1 프로젝트 개요

## 프로젝트 비전

**openplatform v3** 는 레거시 v1(Spring Legacy + jQuery) 과 v2(Hexagonal BFF 실험) 를 모두 흡수하여 **단일 Keycloak SSO 허브 아래** 13개 마이크로 서비스를 오케스트레이션하는 **통합 그룹웨어**입니다 [src: README.md §1]. 

본 프로젝트는 **옵션 C 하이브리드** 아키텍처를 채택합니다 [src: README.md §하이브리드전략]:

| 영역 | 기원 | 채택 방식 |
|---|---|---|
| DataSet 컨트롤러 / MyBatis 매퍼 | v1 | 패턴만 포팅 (리팩터링) |
| Port-Adapter / BFF 프록시 | v2 | 확장 포팅 |
| Vue3 컴포넌트 / composable / store | vue-spring-fw | 원본 복사 (수정 금지) |
| 결재 BPMN (Flowable) | v1 | 선택 포팅 예정 |

- **backend-core** — DataSet 진입점, MyBatis + Flowable (결재 BPMN), 도메인 로직 [src: README.md §1]
- **backend-bff** — WebFlux 기반 Port-Adapter, 외부 시스템(Keycloak/Rocket.Chat/Stalwart/MinIO/LiveKit/Wiki.js) 추상화 [src: README.md §1]
- **ui** — Vue 3 + PrimeVue 4 + Pinia + keycloak-js (vue-spring-fw 컴포넌트 정적 복사) [src: README.md §1]
- **인프라 9종** — PostgreSQL / Redis / Keycloak / MinIO / Rocket.Chat / Stalwart / LiveKit / Wiki.js / Traefik [src: README.md §1]

현재 Phase 14 기준, 본 그룹웨어는 **50명 규모 회사가 한 달 단위로 실제 업무를 돌릴 수 있는** 프로덕션급 시스템으로 완성되었습니다 [src: docs/PHASE14_REPORT.md §목표]. 총 **17개 Flyway 마이그레이션**, **약 95개 DataSet 서비스**, **26개 UI 페이지**, **55개+ UI 컴포넌트**을 포함합니다 [src: docs/PHASE14_REPORT.md §산출통계].

---

## 2. 적용 대상

본 그룹웨어는 다음 두 부문의 조직을 주 타겟으로 설계되었습니다.

### 2.1 SME (중소 엔터프라이즈) 그룹웨어

- **조직 규모**: 30~100명 범위 (시드 데이터 기준 48명 샘플)
- **업무 유형**: 일반 사무직, HR, IT, 운영 부문
- **핵심 시나리오**:
  - 전자결재 (품의/휴가/지출/출장 4종 양식) [src: docs/scenarios.md §3-4]
  - 부서별 게시판 + 자유 커뮤니티 [src: docs/scenarios.md §5]
  - 통합 캘린더 (개인/팀/회사) [src: docs/scenarios.md §6]
  - 조직도 탐색 + 연락처 관리 [src: docs/scenarios.md §7]

### 2.2 제조 협업 (Manufacturing Collaboration)

- **조직 특성**: 생산부, 품질관리, 구매, 자재 부문
- **핵심 시나리오**:
  - 근태/연차/휴가 자동 관리 (Phase 14 트랙 1) [src: docs/PHASE14_REPORT.md §트랙1, docs/scenarios.md §16]
  - 회의실 예약 + 화상회의 자동 통합 (트랙 2) [src: docs/PHASE14_REPORT.md §트랙2, docs/scenarios.md §17]
  - 자료실 + 폴더 권한 관리 (트랙 3) [src: docs/PHASE14_REPORT.md §트랙3, docs/scenarios.md §18]
  - 일별 업무일지 + 부서장 팀 뷰 (트랙 4) [src: docs/PHASE14_REPORT.md §트랙4, docs/scenarios.md §19]

전자결재 시 자동으로 영업일 계산 (공휴일 + 주말 제외) 및 휴가 결재 승인 시 연차 자동 차감 기능이 제조 부문의 인사 효율화에 기여합니다 [src: docs/PHASE14_REPORT.md §트랙1].

---

## 3. 핵심 차별점

### 3.1 Keycloak 단일 SSO 허브

모든 외부 서비스 및 본 포탈이 **kc.localtest.me** 단일 호스트 아래 통합됩니다 [src: CLAUDE.md §아키텍처]. 사용자는 **한 번의 Keycloak 로그인으로** 이하 6개 서비스에 자동으로 접근합니다:

| 서비스 | 프로토콜 | 위치 | 인증 | 상태 |
|---|---|---|---|---|
| openplatform v3 UI | PKCE | http://localhost:25174 | Keycloak 토큰 | 운영 |
| Rocket.Chat | Custom OAuth | :19065 | Custom client | SSO 구현 |
| Stalwart Mail | OIDC | :19480 | OIDC client | JMAP + OIDC |
| Wiki.js | OIDC | :19001 | OIDC client | SSO 구현 |
| MinIO Console | OIDC | :19901 | OIDC client | 분석 완료 |
| LiveKit | JWT | :19880 | backend-bff 발급 | 통합 |

각 서비스는 `openplatform-v3` Realm 내 전용 클라이언트를 보유하며, 권한(role) 및 속성(mapper)은 중앙 제어됩니다 [src: docs/group_ware.md, docs/PHASE14_REPORT.md §트랙2-트랙5].

### 3.2 5개 외부 서비스 Federation

v3 포탈은 단순 UI를 제공하며, 메신저/메일/위키/화상회의/스토리지 기능은 모두 **OSS 외부 서비스**를 federation 합니다:

- **Rocket.Chat** (메신저) — REST API + Custom OAuth [src: docs/group_ware.md §Rocket.Chat]
- **Stalwart Mail** (웹메일) — JMAP 3.0 + OIDC [src: docs/group_ware.md §Stalwart]
- **Wiki.js** (문서/위키) — GraphQL + OIDC [src: docs/group_ware.md §Wiki.js]
- **MinIO** (파일 스토리지) — S3 호환 + presigned URL [src: docs/group_ware.md §MinIO]
- **LiveKit** (화상회의) — WebRTC + JWT [src: docs/group_ware.md §LiveKit]

본 v3 포탈은 **자체 메신저/메일/위키 구현 없음** — 각 서비스는 독립적으로 호스팅되며 BFF(backend-bff) 계층을 통해 추상화됩니다 [src: README.md §backend-bff, CLAUDE.md §아키텍처].

### 3.3 Port-Adapter Hexagonal Architecture

backend-bff 는 Spring WebFlux 기반 **Port-Adapter 패턴**을 구현합니다:

- **7개 Port 인터페이스**: Identity / Messaging / Mail / Video / Wiki / Storage / Notification [src: CLAUDE.md 암시, docs/PHASE14_REPORT.md §트랙5]
- **1개 BFF 컨트롤러**: `/api/bff/*` 단일 진입점, 모든 port 라우트 통합
- **6개 Adapter**: Keycloak / Rocket.Chat / Stalwart / MinIO / LiveKit / Wiki.js

이를 통해 외부 서비스 교체 시 Port 인터페이스만 재구현하면 되며, backend-core 및 UI 는 무영향 상태로 유지됩니다 [src: README.md, CLAUDE.md].

### 3.4 DataSet 라우터 패턴 (v1 자산)

backend-core 는 **DataSet Controller** 를 통해 모든 CRUD 를 단일 REST 엔드포인트로 처리합니다:

```
POST /api/dataset
{
  "service": "approval",
  "method": "submitDocument",
  "data": { ... }
}
```

이는 v1 레거시 패턴을 포팅한 것으로, 서비스명 + 메서드명 기반 라우팅을 제공합니다 [src: docs/api-catalog.md, docs/PHASE14_REPORT.md 암시].

### 3.5 Vue-Spring-fw 컴포넌트 정적 복사

UI 기반은 **vue-spring-fw** (동일 워크스페이스 내 별도 프로젝트) 의 컴포넌트, composable, store 를 **원본 미수정 정책** 하에 v3 로 복사합니다 [src: CLAUDE.md §vue-spring-fw취급규칙]:

- Layout / Header / Sidebar / Router guard 기본 구조는 vue-spring-fw 원본
- Approval / Board / Calendar 등 도메인 페이지는 v3 에서 신규 작성
- 복사 이력은 `docs/vue-spring-fw-reuse-map.md` 에 추적 [src: CLAUDE.md]

---

## 4. 라이선스 전략

### 4.1 외부 서비스 — 모두 OSS

v3 포탈이 federation 하는 모든 외부 서비스는 **오픈소스 라이선스**를 따릅니다:

| 서비스 | 라이선스 | 저장소 |
|---|---|---|
| Rocket.Chat | AGPL 3.0 | https://github.com/RocketChat/Rocket.Chat |
| Stalwart Mail | AGPL 3.0 | https://github.com/stalwartlabs/mail-server |
| Wiki.js | AGPL 3.0 | https://github.com/requarks/wiki |
| MinIO | AGPL 3.0 | https://github.com/minio/minio |
| LiveKit | Apache 2.0 | https://github.com/livekit/livekit-server |
| PostgreSQL | PostgreSQL License | https://www.postgresql.org |
| Redis | BSD 3-Clause | https://github.com/redis/redis |
| Keycloak | Apache 2.0 | https://github.com/keycloak/keycloak |
| Traefik | MIT | https://github.com/traefik/traefik |

본 프로젝트 자체 라이선스는 현재 **미정** 상태입니다 [src: README.md (라이선스 명시 없음), CLAUDE.md (명시 없음)]. 배포 전 프로젝트 팀과 협의하여 결정해야 합니다.

### 4.2 라이선스 적합성

모든 OSS 외부 서비스는 **컨테이너 이미지로 제공**되며, v3 포탈 코드와는 **별도 프로세스로 운영**됩니다. 따라서:

- v3 포탈 라이선스와 관계없이 각 서비스의 원 라이선스가 유지됩니다.
- AGPL 3.0 (Rocket.Chat/Stalwart/Wiki.js/MinIO) 서비스 사용 시 해당 서비스의 소스 공개 의무는 각 프로젝트에 귀속됩니다.
- v3 포탈이 AGPL 서비스 코드를 직접 상속/수정하지 않으면, 포탈 자체는 AGPL 의무가 없습니다 (API federation 만).

---

## 5. 단일 호스트 SSO 통일: kc.localtest.me

### 5.1 문제 배경

초기 개발 시 다음과 같은 SSO 통합 결함이 관찰되었습니다:

- localhost vs 127.0.0.1 혼용으로 인한 쿠키 도메인 불일치
- Keycloak hostname 변경 시 realm 설정과 컨테이너 환경 비동기
- 각 외부 서비스의 Valid Redirect URI 관리 혼란

### 5.2 해결: kc.localtest.me 단일화

Phase 12.1 에서 모든 서비스를 **kc.localtest.me** 로 통일했습니다 [src: CLAUDE.md, docs/PHASE14_REPORT.md §12.1]:

```yaml
# infra/docker-compose.yml — 모든 컨테이너 설정
services:
  v3-postgres:
    extra_hosts:
      - "kc.localtest.me:host-gateway"
  v3-keycloak:
    environment:
      KC_HOSTNAME_URL: http://kc.localtest.me:19281
      KC_HOSTNAME: kc.localtest.me
    ports:
      - "19281:8080"
  # ... 모든 서비스 동일
```

### 5.3 호스트 바인딩 (로컬 개발)

개발 호스트의 `/etc/hosts` (또는 Windows hosts 파일):

```
127.0.0.1  localhost kc.localtest.me
```

### 5.4 각 서비스별 설정

| 서비스 | Keycloak 설정 | 결과 |
|---|---|---|
| v3 UI | client `ui-v3`, redirect_uri `http://localhost:25174/*` | PKCE 로그인 → kc.localtest.me 리다이렉트 |
| Rocket.Chat | `Custom OAuth` 클라이언트, callback_url `http://kc.localtest.me:19065/login/...` | SSO 성공 |
| Stalwart | OIDC client `stalwart-v3` | LDAP Federation + OIDC |
| Wiki.js | OIDC client `wikijs-v3` | SSO 자동 로그인 |
| MinIO | OIDC client `minio-v3` | 콘솔 SSO 가능 |
| LiveKit | JWT 토큰 (backend-bff 발급, kid=livekit-v3) | 토큰 기반 룸 접근 |

---

## 6. 현재 완성도 (Phase 14 기준)

| 항목 | 상태 | 비고 |
|---|---|---|
| **Core 기능** | ✅ 완료 | 결재/게시판/캘린더/조직도 전부 |
| **근태/연차** | ✅ 완료 (V10) | 결재 승인 시 자동 차감 |
| **회의실 예약** | ✅ 완료 (V11) | LiveKit 자동 통합 |
| **자료실** | ✅ 완료 (V12) | 부서별 폴더 권한 |
| **업무일지** | ✅ 완료 (V13) | 부서장 팀 뷰 |
| **어드민 콘솔** | ✅ 완료 (V14) | 사용자/조직/메뉴/코드 관리 |
| **UX 강화** | ✅ 완료 (V15) | 통합검색/즐겨찾기/알림설정 |
| **대시보드 위젯** | ✅ 완료 (V16) | 12-column Grid + 9개 위젯 |
| **메뉴 통합** | ✅ 완료 (V17) | 26개 메뉴 + 역할 권한 매트릭스 |
| **SSO Federation** | ✅ 완료 | 6개 외부 서비스 + kc.localtest.me |
| **테스트** | 🟡 부분 | 단위/통합 약함, E2E 강함 |

모든 컨테이너(postgres/redis/keycloak/core/bff/ui/rocketchat/stalwart/livekit/wikijs/minio) 는 healthy 상태로 동작하며, Flyway V1~V17 clean boot 검증 완료입니다 [src: docs/PHASE14_REPORT.md §검증결과].

---

## 참조

### 1차 정보원 (문서)
- [README.md](../../README.md) — 프로젝트 개요, 아키텍처, 빠른 시작
- [CLAUDE.md](../../CLAUDE.md) — 프로젝트 규칙, 포트 할당, vue-spring-fw 취급
- [framework_documentation_prompt.md](../../framework_documentation_prompt.md) — 문서화 프롬프트 및 목표 정렬
- [docs/PHASE14_REPORT.md](../PHASE14_REPORT.md) — Phase 14 완료 보고서, 산출 통계
- [docs/PHASE14_PRODUCTION_GROUPWARE.md](../PHASE14_PRODUCTION_GROUPWARE.md) — Phase 14 상세 플랜
- [docs/scenarios.md](../scenarios.md) — 사용자 시나리오 16~23 (제조 협업 타겟)
- [docs/group_ware.md](../group_ware.md) — 외부 서비스 API 매뉴얼 및 Federation
- [docs/api-catalog.md](../api-catalog.md) — API 카탈로그 (DataSet 라우터)
- [docs/vue-spring-fw-reuse-map.md](../vue-spring-fw-reuse-map.md) — 컴포넌트 복사 추적
- [docs/comprehensive/inventory/10_chapter_source_map.md](../inventory/10_chapter_source_map.md) — 챕터 매핑

### 코드 경로 (참고)
- backend-core: Spring Boot 3.2, DataSet 패턴, MyBatis, Flowable BPMN
- backend-bff: WebFlux, Port-Adapter (7개 Port)
- ui: Vue 3, PrimeVue 4, Pinia, keycloak-js

---

## 이 챕터가 다루지 않은 인접 주제

- **상세 아키텍처 (C4 다이어그램)**: §1.3 참조
- **기술 스택 버전 및 라이선스 매트릭스**: §1.2 참조
- **Port-Adapter 구현 상세 (7개 Port 인터페이스)**: §1.5, §1.9 참조

---

_작성일: 2026-04-27 — openplatform v3 종합 문서화 Phase 1.1_
