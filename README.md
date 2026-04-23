# openplatform v3 — 통합 그룹웨어

> Spring Boot 3.2 DataSet + Hexagonal BFF + Vue 3 PrimeVue 기반 **옵션 C 하이브리드 그룹웨어**
> v1(openplatform) 도메인 자산 + v2(openplatform_v2) 포트-어댑터 패턴 + vue-spring-fw UI 컴포넌트를 융합한 차세대 엔터프라이즈 플랫폼

---

## 1. 프로젝트 개요

openplatform v3 는 레거시 v1 (Spring Legacy + jQuery) 과 v2 (Hexagonal BFF 실험) 를 모두 흡수하여
**단일 Keycloak SSO 허브 아래** 13 개 마이크로 서비스를 오케스트레이션하는 **통합 그룹웨어**입니다.

- **backend-core** — DataSet 진입점, MyBatis + Flowable (결재 BPMN), 도메인 로직
- **backend-bff** — WebFlux 기반 Port-Adapter, 외부 시스템(Keycloak/Rocket.Chat/Stalwart/MinIO/LiveKit/Wiki.js) 추상화
- **ui** — Vue 3 + PrimeVue 4 + Pinia + keycloak-js (vue-spring-fw 컴포넌트 정적 복사)
- **인프라 9종** — PostgreSQL / Redis / Keycloak / MinIO / Rocket.Chat / Stalwart / LiveKit / Wiki.js / Traefik

하이브리드 전략:
| 영역 | 기원 | 채택 방식 |
|---|---|---|
| DataSet 컨트롤러 / MyBatis 매퍼 | v1 | 패턴만 포팅 (리팩터링) |
| Port-Adapter / BFF 프록시 | v2 | 확장 포팅 |
| Vue3 컴포넌트 / composable / store | vue-spring-fw | 원본 복사 (수정 금지) |
| 결재 BPMN (Flowable) | v1 | 선택 포팅 예정 |

---

## 2. 전체 아키텍처

```
                                ┌────────────────────────────────────────┐
                                │         Browser (Vue3 + PKCE)          │
                                │       http://localhost:25174           │
                                └──────────────┬─────────────────────────┘
                                               │ HTTPS/HTTP
                                               ▼
                            ┌─────────────────────────────────────┐
                            │        Traefik (reverse proxy)      │
                            │          :80 :443 :8080             │
                            └──────────────┬──────────────────────┘
                                           │
        ┌──────────────────────┬───────────┼────────────┬──────────────────────┐
        ▼                      ▼           ▼            ▼                      ▼
 ┌────────────┐        ┌──────────────┐ ┌──────┐ ┌──────────────┐      ┌───────────────┐
 │ ui-nginx   │        │ backend-core │ │ BFF  │ │   Keycloak    │◄────┤ LDAP/Federation│
 │  :19173    │        │    :19090    │ │:19091│ │    :19281     │      └───────────────┘
 └──────┬─────┘        └──────┬───────┘ └───┬──┘ └───┬────────┬──┘
        │                     │             │       │        │
        │            ┌────────┴────┐        │       │        │
        │            ▼             ▼        │       │        │
        │     ┌───────────┐ ┌────────┐      │       │        │
        │     │ PostgreSQL│ │ Redis  │      │       │        │
        │     │  :19432   │ │ :19379 │      │       │        │
        │     └───────────┘ └────────┘      │       │        │
        │                                    │       │        │
        │        ┌───────────┬───────────────┼───────┼────────┤
        │        ▼           ▼               ▼       ▼        ▼
        │  ┌──────────┐ ┌───────────┐  ┌──────────┐ ┌────────┐ ┌──────────┐
        │  │  MinIO   │ │Rocket.Chat │  │ Stalwart │ │LiveKit │ │ Wiki.js  │
        │  │19900/901 │ │  :19065   │  │:19025/143│ │ :19880 │ │  :19001  │
        │  └──────────┘ └───────────┘  └──────────┘ └────────┘ └──────────┘
        │
        └───────► (SPA 정적 파일 서빙)

  Networks:
    ├─ traefik-net    (외부 노출 서비스 공용 - reverse proxy 대상)
    ├─ v3-internal    (backend ↔ infra 내부 통신)
    └─ shared-infra   (타 워크스페이스 공용 DB/캐시 접근)
```

---

## 3. 빠른 시작

```bash
# 0) 전제: Docker Desktop 기동 + traefik-net 네트워크 존재
docker network create traefik-net 2>/dev/null || true

# 1) 인프라 먼저
cd C:/claude/openplatform_v3
docker compose -f infra/docker-compose.yml up -d postgres redis minio

# 2) IdP / SSO 허브
docker compose -f infra/docker-compose.yml up -d keycloak
#   Keycloak 헬스체크 대기 (10~30초)
curl -f http://localhost:19281/health/ready

# 3) 외부 시스템 어댑터 대상
docker compose -f infra/docker-compose.yml up -d rocketchat stalwart livekit wikijs

# 4) backend 애플리케이션
docker compose -f infra/docker-compose.yml up -d backend-core backend-bff

# 5) UI (개발 모드)
cd ui && npm install && npm run dev
# → http://localhost:25174
```

**One-shot (권장 시연용)**
```bash
docker compose -f infra/docker-compose.yml up -d
```

---

## 4. 개발 환경 셋업

| 항목 | 버전 | 비고 |
|---|---|---|
| JDK | 17 (Temurin) | backend-core / backend-bff 공용 |
| Maven | 3.9+ | wrapper 미사용, 로컬 설치 필요 |
| Node.js | 20 LTS | ui 빌드 |
| npm | 10+ | pnpm 금지 (lockfile 단일화) |
| Docker | 24+ / Compose v2 | WSL2 백엔드 권장 |
| Git | 2.40+ | submodule 사용 안 함 |

**초기 셋업**
```bash
# Java
java -version        # 17.x 확인
mvn -version

# backend 컴파일 테스트
cd backend-core && mvn -q -DskipTests package
cd ../backend-bff && mvn -q -DskipTests package

# UI 의존성
cd ../ui && npm ci
npm run lint
npm run build
```

**IDE 권장**: IntelliJ IDEA (backend) + VS Code (UI). `.editorconfig` / `.prettierrc` 준수.

---

## 5. 스택 구성표

| # | 서비스 | 컨테이너명 | 포트 (host:container) | 용도 |
|---|---|---|---|---|
| 1 | PostgreSQL 16 | v3-postgres | 19432:5432 | 전체 RDBMS (platform_v3 / flowable_v3 / wiki_v3 / keycloak_v3) |
| 2 | Redis 7 | v3-redis | 19379:6379 | 세션 / 캐시 / SSE pub-sub |
| 3 | Keycloak 24 | v3-keycloak | 19281:8080 | SSO IdP (realm openplatform-v3) |
| 4 | MinIO | v3-minio | 19900:9000, 19901:9001 | S3 호환 오브젝트 스토리지 (첨부/문서) |
| 5 | Rocket.Chat | v3-rocketchat | 19065:3000 | 메신저 (Custom OAuth keycloak → Keycloak) |
| 6 | Stalwart Mail | v3-stalwart | 19025/19143/19480 | SMTP/IMAP/Web 메일 서버 |
| 7 | LiveKit | v3-livekit | 19880:7880 | WebRTC 화상회의 |
| 8 | Wiki.js | v3-wikijs | 19001:3000 | 문서/위키 (Keycloak OIDC) |
| 9 | backend-core | v3-backend-core | 19090:8080 | DataSet API (Spring Boot + MyBatis + Flowable) |
| 10 | backend-bff | v3-backend-bff | 19091:8080 | WebFlux Port-Adapter 프록시 |
| 11 | ui-nginx | v3-ui | 19173:80 | 운영 빌드 서빙 (SPA) |
| 12 | Traefik | v3-traefik | 80/443/8080 | 리버스 프록시 + TLS |
| 13 | OpenLDAP (optional) | v3-openldap | 19389:389 | Federation 테스트용 디렉터리 |

UI 개발 전용 포트: **25174** (Vite dev server, /api → 19090 / /api/bff → 19091 프록시)

---

## 6. Keycloak SSO 플로우

```
┌────────┐                      ┌──────────┐                      ┌───────────┐
│Browser │                      │   UI     │                      │ Keycloak  │
│ (user) │                      │ (Vue3)   │                      │  :19281   │
└───┬────┘                      └────┬─────┘                      └─────┬─────┘
    │  (1) GET /                     │                                  │
    │───────────────────────────────▶│                                  │
    │                                │ (2) keycloak-js init (PKCE)      │
    │                                │─────────────────────────────────▶│
    │                                │ (3) redirect → /auth             │
    │◀───────────────────────────────│◀─────────────────────────────────│
    │  (4) 302 /realms/openplatform-v3/protocol/openid-connect/auth     │
    │──────────────────────────────────────────────────────────────────▶│
    │  (5) Login form (또는 LDAP Federation 자동 매칭)                   │
    │◀──────────────────────────────────────────────────────────────────│
    │  (6) credentials + code_challenge                                 │
    │──────────────────────────────────────────────────────────────────▶│
    │  (7) 302 back to UI with authorization_code                       │
    │◀──────────────────────────────────────────────────────────────────│
    │                                │                                  │
    │  (8) code → UI                 │                                  │
    │───────────────────────────────▶│ (9) /token (code + verifier)     │
    │                                │─────────────────────────────────▶│
    │                                │ (10) access_token + refresh       │
    │                                │◀─────────────────────────────────│
    │                                │                                  │
    │                                │ (11) Bearer access_token         │
    │                                │────────────────┐                 │
    │                                │                ▼                 │
    │                                │        ┌──────────────┐          │
    │                                │        │ backend-core │─JWKS────▶│
    │                                │        │    :19090    │          │
    │                                │        └──────────────┘          │
    │                                │                                  │
    │   동일 토큰으로 확장 SSO:                                          │
    │   Rocket.Chat (Custom OAuth client id=rocketchat)                  │
    │   Wiki.js    (OIDC client id=wikijs-v3)                            │
    │   MinIO      (OIDC client id=minio-v3)                             │
    │   Stalwart   (OIDC client id=stalwart-v3)                          │
    │   LiveKit    (JWT from backend-bff, kid=livekit-v3)                │
```

Realm: `openplatform-v3` | Clients: 6 | 기본 사용자: admin / user1~3

---

## 7. 시드 데이터 카운트

초기 import 기준 (`infra/init-sql/*.sql` + `keycloak/realm-export.json`):

| 엔터티 | 건수 | 비고 |
|---|---:|---|
| 부서 (org_dept) | 12 | 3 depth 트리 |
| 직원 (org_employee) | 48 | admin 포함 |
| 공통코드 그룹 | 18 | BOARD_TYPE / APPROVAL_STATUS 등 |
| 공통코드 값 | 126 | |
| 게시판 카테고리 | 6 | 공지/자유/FAQ/IT/HR/부서 |
| 게시글 샘플 | 30 | 카테고리당 5건 |
| 일정 (calendar_event) | 24 | 지난달~다음달 |
| 결재 양식 템플릿 | 8 | 품의/휴가/지출/출장 등 |
| 결재 문서 샘플 | 15 | 상태별 분포 |
| 알림 | 50 | 사용자별 혼합 |
| 다국어 메시지 (ko/en/ja) | 340 | |
| Keycloak 사용자 | 4 | admin, user1~3 |
| Keycloak 역할 | 6 | ROLE_ADMIN / USER / HR / IT / MGR / GUEST |

---

## 8. 주요 URL + 계정

| 항목 | URL | 계정 |
|---|---|---|
| UI (dev) | http://localhost:25174 | admin / admin |
| UI (prod) | http://localhost:19173 | user1 / user1 |
| backend-core Swagger | http://localhost:19090/swagger-ui.html | Bearer 필요 |
| backend-bff Swagger | http://localhost:19091/swagger-ui.html | Bearer 필요 |
| Keycloak Admin | http://localhost:19281/admin | admin / admin |
| MinIO Console | http://localhost:19901 | minioadmin / minioadmin |
| Rocket.Chat | http://localhost:19065 | SSO only |
| Stalwart Web | http://localhost:19480 | admin / admin |
| Wiki.js | http://localhost:19001 | SSO only |
| LiveKit Demo | http://localhost:19880 | Token from BFF |
| Traefik Dashboard | http://localhost:8080 | — |

> 운영 환경에서는 **반드시 모든 기본 비밀번호를 교체**하세요.

---

## 9. 트러블슈팅

**1) Keycloak realm import 실패**
- 증상: 기동 직후 `realm openplatform-v3 not found`
- 원인: `KC_IMPORT_REALM` 환경변수 미설정 또는 volume 경로 오타
- 해결: `docker compose logs v3-keycloak | grep -i import` 확인 후 `infra/keycloak/realm-export.json` 재마운트

**2) backend-core 기동 시 Flyway/MyBatis DB connection refused**
- 증상: `Connection to postgres:5432 refused`
- 원인: postgres 헬스체크 전에 backend 가 기동
- 해결: `depends_on.condition: service_healthy` 확인, `docker compose up -d postgres` 를 먼저 실행

**3) UI 에서 CORS / 401 루프**
- 증상: 로그인 후 /api 호출 시 401 → 재로그인 무한 루프
- 원인: Keycloak client 의 Valid Redirect URIs 에 25174 미등록
- 해결: Keycloak Admin → Clients → ui-v3 → Web Origins `+`, Valid Redirect URIs `http://localhost:25174/*`

**4) Rocket.Chat SSO "Invalid state parameter"**
- 증상: GitLab 로그인 클릭 후 에러
- 원인: cookie 도메인 불일치 (localhost vs 127.0.0.1)
- 해결: 항상 `localhost` 로 접근, `MM_GITLABSETTINGS_*` secret 재발급 후 적용

**5) MinIO 업로드 403 SignatureDoesNotMatch**
- 증상: BFF → MinIO putObject 실패
- 원인: 컨테이너 시간 비동기 (5분 초과)
- 해결: Docker Desktop 재시작 or `docker run --rm alpine date` 로 시간 확인, ntp 동기화

---

## 10. 백업 / 복원 절차

모든 백업은 `scripts/` 폴더에 있는 셸 스크립트로 수행합니다.

### 백업
```bash
cd C:/claude/openplatform_v3
bash scripts/backup.sh
# → backups/v3-YYYYMMDD-HHMMSS.tar.gz 생성
```

백업 대상:
- PostgreSQL 전체 DB (`pg_dumpall`)
- MinIO 버킷 (`mc mirror`)
- Keycloak realm export
- OpenLDAP ldapsearch dump
- Rocket.Chat / Rocket.Chat Mongo / Postgres dump
- Wiki.js DB (sqlite 또는 pg)

### 복원
```bash
bash scripts/restore.sh backups/v3-20260414-120000.tar.gz
```

복원 중 오류 발생 시 `scripts/restore.log` 확인 후 개별 단계를 수동으로 재시도하세요.

> **주의**: 복원은 **반드시 서비스 중단 상태**에서 수행 (`docker compose stop backend-core backend-bff`).

---

## 11. 기여 가이드

1. **브랜치 전략**: `main` 보호, 모든 변경은 `feat/*` `fix/*` `chore/*` 브랜치에서 PR
2. **커밋 메시지**: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`)
3. **코드 스타일**:
   - Java: Google Java Format (backend) / 4-space indent
   - TypeScript: Prettier 기본 + ESLint (ui/.eslintrc)
   - SQL: 대문자 키워드 + snake_case 컬럼
4. **테스트**: PR 머지 전 아래 3종 모두 green 필수
   - `mvn test` (backend-core, backend-bff)
   - `npm run lint && npm run build` (ui)
   - `docker compose -f infra/docker-compose.yml config -q`
5. **vue-spring-fw 원본 수정 금지** — 필요 시 v3 하위로 복사 후 수정
6. **문서 동기화 의무**:
   - 포트 추가/변경 → `C:\claude\docker-info.xml` + `C:\claude\port-change-report.md`
   - 새 API → `docs/api-catalog.md`
   - 새 시나리오 → `docs/scenarios.md`
7. **PR 템플릿**: Summary / Test plan / Screenshot (UI 변경 시)

---

## 참고 링크

- `docs/api-catalog.md` — 전체 REST API 카탈로그
- `docs/scenarios.md` — 사용자 시나리오 15종
- `docs/port-allocation.md` — 포트 할당표
- `docs/vue-spring-fw-reuse-map.md` — 재사용 자산 추적
- `C:\claude\CLAUDE.md` — 워크스페이스 최상위 규칙
- `C:\claude\docker-info.xml` — Docker 서비스 레지스트리

---

_Last updated: 2026-04-14 — openplatform v3 team_
