# inventory/01_tech_stack.md — 기술 스택 인벤토리

> Phase 0.B 산출물. 본 문서의 모든 기술/버전/포트는 후속 SOP의 1차 정보원이다.
> 출처는 `[code: 경로:Line]` 형식으로 명시한다.

## 1. 계층별 기술 스택

| 계층 | 기술 | 버전 | 출처 | 비고 |
|---|---|---|---|---|
| Language Runtime | Java | 17 | `[code: backend-core/pom.xml:18]` | Eclipse Temurin 17-jre (Dockerfile) |
| Language Runtime | Node.js | 20-alpine | `[code: ui/Dockerfile:1]` | Frontend build 전용 |
| Web Framework | Spring Boot | 3.2.5 | `[code: backend-core/pom.xml:9]` | parent: spring-boot-starter-parent |
| Web Framework | Spring WebFlux | 3.2.5 | `[code: backend-bff/pom.xml:25]` | BFF 전용 reactive web |
| Web Framework | Spring Security | 3.2.5 | `[code: backend-core/pom.xml:32]` | OAuth2 Resource Server (JWT) |
| Frontend Framework | Vue.js | 3.5.13 | `[code: ui/package.json:28]` | Composition API + TS |
| Frontend Build | Vite | 6.1.0 | `[code: ui/package.json:34]` | dev port 25174 |
| Frontend Build | TypeScript | ~5.7.0 | `[code: ui/package.json:33]` | strict mode |
| Frontend Compiler | vue-tsc | 2.2.0 | `[code: ui/package.json:35]` | SFC 타입 체크 |
| Frontend UI Library | PrimeVue | 4.3.0 | `[code: ui/package.json:27]` | 주력 컴포넌트 라이브러리 |
| Frontend Icon | PrimeIcons | 7.0.0 | `[code: ui/package.json:26]` | PrimeVue 표준 아이콘 |
| State Management | Pinia | 3.0.0 | `[code: ui/package.json:25]` | Vue 3 store |
| Frontend Router | Vue Router | 4.5.0 | `[code: ui/package.json:29]` | SPA 라우터 |
| HTTP Client | axios | 1.15.0 | `[code: ui/package.json:20]` | Promise 기반 |
| Date/Time | dayjs | 1.11.0 | `[code: ui/package.json:21]` | 경량 날짜 |
| Calendar | @fullcalendar/vue3 | 6.1.20 | `[code: ui/package.json:16]` | daygrid/timegrid |
| Markdown Editor | md-editor-v3 | 6.4.1 | `[code: ui/package.json:24]` | WYSIWYG md |
| Video/WebRTC | livekit-client | 2.18.1 | `[code: ui/package.json:23]` | LiveKit Web SDK |
| Icons (Vector) | @tabler/icons-vue | 3.41.1 | `[code: ui/package.json:18]` | 5000+ 아이콘 |
| SSO Adapter | keycloak-js | 24.0.0 | `[code: ui/package.json:22]` | OIDC/PKCE |
| Persistence | PostgreSQL | 16-alpine | `[code: infra/docker-compose.yml:23]` | 19432 |
| Persistence | MyBatis | 3.0.4 | `[code: backend-core/pom.xml:19]` | mybatis-spring-boot-starter |
| Persistence Migration | Flyway | 10.10.0 | `[code: backend-core/pom.xml:21]` | V1~V17 |
| Cache | Redis | 7-alpine | `[code: infra/docker-compose.yml:44]` | 19379 |
| Cache Client | Spring Data Redis | 3.2.5 | `[code: backend-core/pom.xml:77]` | Reactive |
| Workflow | Flowable | 7.1.0 | `[code: backend-core/pom.xml:20]` | BPMN 2.0 + DMN |
| Storage | MinIO | RELEASE.2023-11-20 | `[code: infra/docker-compose.yml:60]` | 19900/19901 |
| Storage Client | io.minio | 8.5.7 | `[code: backend-core/pom.xml:22]` | Java SDK |
| Identity Provider | Keycloak | 24.0 | `[code: infra/docker-compose.yml:92]` | 19281 |
| Directory | OpenLDAP | 1.5.0 | `[code: infra/docker-compose.yml:222]` | 19389 |
| Messaging | Rocket.Chat | 6.13.0 | `[code: infra/docker-compose.yml:127]` | 19065 |
| Document DB | MongoDB | 7.0 | `[code: infra/docker-compose.yml:176]` | RC backend |
| Email | Stalwart | latest | `[code: infra/docker-compose.yml:244]` | SMTP/IMAP/Web |
| Wiki | Wiki.js | 2 | `[code: infra/docker-compose.yml:200]` | 19001 |
| Video | LiveKit | v1.9 | `[code: infra/docker-compose.yml:258]` | 19880-19882 |
| Auth/JWT | jjwt | 0.12.6 | `[code: backend-bff/pom.xml:51]` | JWT 서명/검증 |
| Metrics | Micrometer + Prometheus | 3.2.5 | `[code: backend-core/pom.xml:90]` | actuator |
| Logging | SLF4J + Logback | 3.2.5 | `[code: backend-core/src/main/resources/application.yml]` | DEBUG for `com.platform.v3.*` |
| Validation | Spring Validation | 3.2.5 | `[code: backend-core/pom.xml:40]` | Bean Validation |
| AOP | Spring AOP | 3.2.5 | `[code: backend-core/pom.xml:44]` | 감사 로그용 |
| Build Tool | Maven | 3.9 | `[code: backend-core/Dockerfile:1]` | 다중 모듈 |
| Container | Docker | (필수) | `[code: docker-compose.yml]` | multi-stage |
| Orchestration | Docker Compose | 3.x | `[code: infra/docker-compose.yml]` | 11 base + overlays |
| Reverse Proxy | Traefik | optional | `[code: infra/docker-compose.traefik.yml]` | production overlay |
| Observability | Prometheus + Grafana | optional | `[code: infra/docker-compose.observability.yml]` | overlay |

## 2. 빌드 명령

### Backend (Core + BFF)
```bash
mvn clean package -DskipTests -B
# 또는
cd backend-core && mvn clean package -DskipTests -B
cd backend-bff && mvn clean package -DskipTests -B
```

### UI (Frontend)
```bash
cd ui
npm install
npm run build      # Vite production build → dist/
npm run dev        # dev 서버 :25174
```

### Docker
```bash
docker compose -f infra/docker-compose.yml build
docker compose build backend-core backend-bff ui-frontend
```

## 3. 로컬 부트 절차

### 옵션 1 — 전체 한 줄 기동 (권장)
```bash
cd /c/claude/openplatform_v3
./start.sh
```

### 옵션 2 — 모드별 스크립트
```bash
./scripts/start.sh dev            # base 만(core/bff/postgres/redis/keycloak)
./scripts/start.sh full           # base + healthcheck + resource limits
./scripts/start.sh observability  # + Prometheus/Grafana
./scripts/start.sh traefik        # + Traefik
./scripts/start.sh production     # 모든 overlay + cron
```

### 옵션 3 — 수동 docker compose
```bash
docker compose -f infra/docker-compose.yml up -d
docker logs v3-<service>   # 디버깅
```

### 옵션 4 — UI dev only (백엔드/인프라 기동 후)
```bash
cd ui
npm install
npm run dev    # http://localhost:25174
```

### 검증 (모두 200 OK 이어야 함)
```bash
curl http://localhost:19090/actuator/health          # backend-core
curl http://localhost:19091/actuator/health          # backend-bff
curl http://localhost:19281/realms/openplatform-v3/.well-known/openid-configuration
curl http://localhost:19173/                          # UI (nginx)
curl http://localhost:19901/                          # MinIO console
```

### 종료
```bash
./stop.sh             # 데이터 볼륨 유지
./stop.sh --remove    # 컨테이너 + 볼륨 모두 제거 (full reset)
```

## 4. 구성 파일 인벤토리

| 파일 | 역할 | 주요 환경변수 오버라이드 |
|---|---|---|
| `backend-core/src/main/resources/application.yml` | Core 설정 (port 19090, datasource/Redis/Flowable/MyBatis/Keycloak JWT/MinIO/actuator) | `SPRING_PROFILES_ACTIVE`, `DB_HOST/PORT/NAME/USER/PASSWORD`, `REDIS_*`, `KEYCLOAK_JWK_URI`, `MINIO_*`, `SERVER_PORT`, `BFF_BASE_URL` |
| `backend-bff/src/main/resources/application.yml` | BFF 설정 (port 19091, OAuth2, downstream RC/Stalwart/Wiki.js/LiveKit/MinIO) | `SPRING_PROFILES_ACTIVE`, `KEYCLOAK_ISSUER_URI`, `ROCKETCHAT_URL`, `STALWART_URL`, `WIKIJS_URL`, `LIVEKIT_*`, `MINIO_*`, `KEYCLOAK_ADMIN_*` |
| `ui/vite.config.ts` | 프런트엔드 번들/dev 서버 (port 25174, /api proxy → :19090, /api/bff → :19091, path alias) | (하드코딩) |
| `ui/tsconfig.json` | TS compiler (ES2022, strict, alias `@/*`, `noEmit:true`) | (없음) |
| `ui/package.json` | npm 의존성 + scripts | (없음) |
| `infra/docker-compose.yml` | 핵심 인프라 (11 services + 네트워크 + volume + healthcheck) | `POSTGRES_*`, `REDIS_PASSWORD`, `MINIO_*`, `KC_*`, `ROCKETCHAT_*`, `LIVEKIT_*` 등 |
| `infra/docker-compose.healthcheck.yml` | production health probe overlay | (적용 시 -f) |
| `infra/docker-compose.resources.yml` | CPU/메모리 한도 overlay | (적용 시 -f) |
| `infra/docker-compose.observability.yml` | Prometheus + Grafana overlay | `PROMETHEUS_*`, `GRAFANA_*` |
| `infra/docker-compose.traefik.yml` | Traefik + SSL overlay | `TRAEFIK_*`, `ACME_*` |
| `infra/docker-compose.cron.yml` | 스케줄 작업 overlay | (없음) |
| `docker-compose.yml` (root) | infra/ 위임 wrapper | (없음) |
| `backend-{core,bff}/pom.xml` | Maven 빌드 (Java 17, Spring Boot 3.2.5) | (없음) |
| `ui/nginx.conf` | Nginx static + SPA rewrite | (없음) |
| `backend-{core,bff}/Dockerfile` | multi-stage Maven → Spring Boot JAR | (없음) |
| `ui/Dockerfile` | multi-stage Node 빌드 + Nginx serve | (없음) |

## 5. 주요 서비스 포트·기본 자격증명 (개발용)

| 서비스 | 포트 | 사용자 | 비밀번호 | URL |
|---|---|---|---|---|
| PostgreSQL | 19432 | platform_v3 | platform_v3_pass | jdbc:postgresql://localhost:19432/platform_v3 |
| Redis | 19379 | (없음) | v3_redis_pass | redis-cli -p 19379 -a v3_redis_pass |
| Keycloak | 19281 | admin | admin | http://localhost:19281 (realm: openplatform-v3) |
| MinIO API | 19900 | v3minio | v3minio_pass | http://localhost:19900 |
| MinIO Console | 19901 | v3minio | v3minio_pass | http://localhost:19901 |
| Rocket.Chat | 19065 | v3admin | Admin1234! | http://localhost:19065 |
| Wiki.js | 19001 | (Keycloak SSO) | (Keycloak SSO) | http://localhost:19001 |
| OpenLDAP | 19389 | cn=admin,dc=v3,dc=local | adminpass | ldap://localhost:19389 |
| Stalwart SMTP | 19025 | (system) | (system) | smtp://localhost:19025 |
| Stalwart IMAP | 19143 | (LDAP) | (LDAP) | imap://localhost:19143 |
| Stalwart Web | 19480 | — | — | http://localhost:19480 |
| LiveKit WS | 19880 | (JWT) | (JWT) | ws://localhost:19880 |
| backend-core | 19090 | (OAuth2) | (OAuth2) | http://localhost:19090/api |
| backend-bff | 19091 | (OAuth2) | (OAuth2) | http://localhost:19091/api/bff |
| UI (nginx) | 19173 | (public) | — | http://localhost:19173 |
| UI (vite dev) | 25174 | (public) | — | http://localhost:25174 |

## 6. 아키텍처 계층 요약

```
┌──────────────────────────────────────────────────┐
│ Frontend: Vue3 + PrimeVue + Pinia + Keycloak-JS  │
│ Build: Vite (TS, port 25174)                     │
│ Deploy: Nginx (port 19173)                       │
└──────────────────────────────────────────────────┘
                      │ /api/*
                      ▼
   ┌──────────────────────────────────────────────┐
   │  Spring Boot 3.2 BFF (WebFlux)               │ 19091
   │  Hexagonal: Port-Adapter (외부서비스 프록시) │
   └──────────┬───────────────────────────────────┘
              │ Internal /api
              ▼
   ┌──────────────────────────────────────────────┐
   │  Spring Boot 3.2 Core (Servlet)              │ 19090
   │  DataSet 도메인 + MyBatis + Flowable BPMN    │
   └──────────┬───────────────────────────────────┘
              │ JDBC / Redis / Flowable
              ▼
   ┌──────────────────────────────────────────────┐
   │ PostgreSQL 16 | Redis 7 | Flowable 7.1       │
   │ schemas: platform_v3, keycloak_v3,           │
   │          flowable_v3, wiki_v3                │
   └──────────────────────────────────────────────┘

   외부 마이크로서비스 (Keycloak SSO 보호):
   - MinIO 19900/19901, Rocket.Chat 19065,
     MongoDB 27017(internal), Stalwart 19025/19143/19480,
     OpenLDAP 19389, Wiki.js 19001, LiveKit 19880-19882
```

## 7. 운영 메모

- SSO 단일 호스트: `kc.localtest.me` (RFC 2606 항상 127.0.0.1) — 쿠키 도메인 단일화로 모든 서비스 SSO 공유
- DB 스키마: Flyway 가 `platform_v3` 자동 초기화, Keycloak·Flowable 은 자체 관리
- Optional Overlay: Traefik / observability / resources / cron 은 `-f` 플래그로 명시 적용 시에만 동작
- UI dev proxy: `/api` → backend-core:19090, `/api/bff` → backend-bff:19091
- 컨테이너 health: 대부분 `healthcheck` 정의됨, `start.sh` 가 backend-core health 폴링 후 성공 선언
