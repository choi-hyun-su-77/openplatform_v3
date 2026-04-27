# 02. 기술 스택

## 1. 백엔드 (Java/Spring) 의존성 매트릭스

본 프로젝트는 두 개의 Spring Boot 3.2.5 모듈로 구성된다 — `backend-core` (DataSet 도메인) + `backend-bff` (Port-Adapter Federation). 두 모듈 모두 Java 17 LTS 위에서 동작한다 `[src: backend-core/pom.xml]` `[src: backend-bff/pom.xml]`.

### 1.1 backend-core (`19090` port)

| 카테고리 | 라이브러리 | 버전 | 용도 |
|---|---|---|---|
| Framework | spring-boot-starter | 3.2.5 | 부모 BOM, autoconfiguration |
| Web | spring-boot-starter-web | 3.2.5 | REST + Servlet |
| Security | spring-boot-starter-oauth2-resource-server | 3.2.5 | JWT 검증 (Keycloak JWKS) |
| Persistence | mybatis-spring-boot-starter | 3.0.4 | XML 매핑 SQL |
| DB Driver | postgresql | runtime | PostgreSQL 15+ |
| Migration | flyway-core | 10.10.0 | V1~V17 마이그레이션 |
| Workflow | flowable-spring-boot-starter | 7.1.0 | BPMN/DMN 결재 |
| AOP | spring-boot-starter-aop | 3.2.5 | `AdminAuditAspect` |
| Storage | minio | 8.5.7 | 자료실 presigned URL |
| Cache | spring-boot-starter-data-redis | 3.2.5 | 선택, 세션/캐시 |
| Metrics | micrometer-registry-prometheus | (auto) | `/actuator/prometheus` |

`[inv: docs/comprehensive/inventory/02_stack_a_backend.md "Core Architecture"]` 

### 1.2 backend-bff (`19091` port)

| 카테고리 | 라이브러리 | 버전 | 용도 |
|---|---|---|---|
| Framework | spring-boot-starter-web | 3.2.5 | BffController |
| HTTP Client | spring-boot-starter-webflux | 3.2.5 | reactive WebClient (외부 호출) |
| Security | spring-boot-starter-oauth2-resource-server | 3.2.5 | JWT |
| JWT | jjwt-api / impl / jackson | 0.12.6 | LiveKit RS256 토큰 발급 |
| Storage | minio | 8.5.7 | StoragePort |

`[inv: docs/comprehensive/inventory/03_stack_b_backend.md "Service Dependencies"]`

> 두 모듈 모두 `pom.xml` 부모로 `spring-boot-starter-parent:3.2.5` 를 상속한다.

## 2. 프론트엔드 (Vue 3) 의존성

`ui/` 모듈은 Vite 6.1 기반 SPA. 빌드 산출물은 `dist/` → `nginx:alpine` 컨테이너에 마운트되어 19173 포트로 서비스된다 `[src: ui/package.json]`.

| 카테고리 | 라이브러리 | 버전 | 용도 |
|---|---|---|---|
| Framework | vue | 3.5.x | Composition API |
| UI | primevue | 4.3.0 | 80+ 컴포넌트, Material 테마 |
| Icons | primeicons | 7.0.0 | 표준 아이콘 |
| Icons (보조) | @tabler/icons-vue | 3.41.1 | 위젯/메뉴 아이콘 |
| Routing | vue-router | 4.5.0 | 27 라우트 + 가드 |
| State | pinia | 3.0.0 | auth/notification/tab 3 store |
| HTTP | axios | 1.15.0 | interceptor (JWT, 401, 5xx retry) |
| Calendar | @fullcalendar/vue3 | 6.1.20 | timeGridWeek/dayGridMonth |
| Editor | md-editor-v3 | 6.4.1 | 게시판/위키 마크다운 |
| Video | livekit-client | 2.18.1 | WebRTC 화상회의 |
| Auth | keycloak-js | 24.0.0 | OIDC 로그인/refresh |
| Date | dayjs | 1.11.x | 날짜 포매팅 |
| Build | vite | 6.1.0 | 빌드/dev server |
| Type | typescript | 5.7 | strict mode |
| Type (vue) | vue-tsc | (devDep) | .vue 타입체킹 |

`[inv: docs/comprehensive/inventory/04_frontend.md "Tech Stack"]`

### 2.1 Vite 설정 요약

`ui/vite.config.ts` 는 (a) `@vitejs/plugin-vue` 플러그인, (b) `/api/*` 프록시(→ `backend-bff:19091`), (c) `@/` alias(`src/`), (d) dev port 25174 를 설정한다 `[src: ui/vite.config.ts]`.

### 2.2 TypeScript 설정 요약

`ui/tsconfig.json` 은 (a) `strict: true`, (b) `noEmit: true` (Vite 가 빌드 담당), (c) `paths`alias 와 (d) `vue-tsc` 의 .vue 인식 설정을 둔다 `[src: ui/tsconfig.json]`. recent commit `23571fe` 가 stale .js emission 방지를 위해 noEmit 추가 `[src: git log]`.

## 3. 버전 매트릭스 (단일 표)

| 분류 | 항목 | 버전 |
|---|---|---|
| Runtime | Java | 17 LTS |
| Runtime | Node | (CI), 빌드 only |
| Framework | Spring Boot | 3.2.5 |
| ORM | MyBatis | 3.0.4 |
| Workflow | Flowable | 7.1.0 |
| Migration | Flyway | 10.10.0 |
| DB | PostgreSQL | 15+ |
| Cache | Redis | 7 |
| Storage | MinIO | 8.5.7 (Java SDK) |
| Auth | Keycloak | latest (image) |
| Frontend | Vue | 3.5 |
| Frontend | PrimeVue | 4.3.0 |
| Frontend | Vite | 6.1.0 |
| Frontend | TypeScript | 5.7 |
| External | Rocket.Chat | latest (image) |
| External | Stalwart Mail | latest (image) |
| External | Wiki.js | latest (image) |
| External | LiveKit | latest (image) |

`[inv: inventory/02_stack_a_backend.md, 03_stack_b_backend.md, 04_frontend.md]`

## 4. 라이선스 적합성

본 프로젝트는 Apache 2.0/MIT 호환 OSS 의존성만 사용한다.

| 라이브러리 | 라이선스 | 호환성 |
|---|---|---|
| Spring Boot | Apache 2.0 | ✓ |
| MyBatis | Apache 2.0 | ✓ |
| Flowable | Apache 2.0 | ✓ |
| Flyway Community | Apache 2.0 | ✓ |
| MinIO Java SDK | Apache 2.0 | ✓ |
| PostgreSQL JDBC | BSD-2-Clause | ✓ |
| Vue 3 | MIT | ✓ |
| PrimeVue | MIT | ✓ |
| Vite | MIT | ✓ |
| Pinia | MIT | ✓ |
| Axios | MIT | ✓ |
| FullCalendar (Standard) | MIT | ✓ (premium 기능 미사용) |
| livekit-client | Apache 2.0 | ✓ |
| keycloak-js | Apache 2.0 | ✓ |
| md-editor-v3 | MIT | ✓ |
| @tabler/icons-vue | MIT | ✓ |
| dayjs | MIT | ✓ |

> 본 프로젝트(openplatform_v3) 자체의 라이선스는 README 에 명시되어 있지 않음 — **확인 필요** (Apache 2.0 또는 사내 전용 결정 필요).

## 5. 포트 할당 (19xxx 대역)

`docs/port-allocation.md` 가 권위. 핵심 요약:

| 서비스 | 호스트 포트 | 내부 컨테이너 포트 |
|---|---|---|
| backend-core | 19090 | 8080 |
| backend-bff | 19091 | 8080 |
| ui (nginx) | 19173 | 80 |
| ui (Vite dev) | 25174 | (호스트만) |
| postgres | 19432 | 5432 |
| redis | 19379 | 6379 |
| keycloak | 19281 | 8080 |
| rocketchat | 19065 | 3000 |
| stalwart (HTTP) | 19480 | 8080 |
| livekit | 19880 / 19881 / 19882 | (WebRTC) |
| minio | 19900 / 19901 | 9000 / 9001 |
| wikijs | 19001 | 3000 |

`[src: docs/port-allocation.md]` `[src: C:/claude/docker-info.xml — 권위 레지스트리]`

## 6. 빌드/배포 도구

| 단계 | 명령 | 산출물 |
|---|---|---|
| backend 빌드 | `mvn clean package` (각 모듈) | `target/*.jar` |
| ui 빌드 | `npm run build` (vue-tsc + vite) | `ui/dist/` |
| 도커 빌드 | `docker compose build` | 3개 이미지 (core/bff/ui) |
| 통합 기동 | `start.sh` 또는 `docker compose -f infra/docker-compose.yml ... up -d` | 11~12 컨테이너 |

## 7. 진입점 요약

- `POST /api/dataset` — backend-core 단일 라우터 (DataSet 패턴)
- `/api/bff/*` — backend-bff Federation 게이트웨이
- `/api/notifications`, `/api/codes`, `/api/i18n` — backend-core 전용 컨트롤러
- UI dev: `http://localhost:25174` / prod: `http://localhost:19173`

자세한 API 명세는 챕터 1.5, 아키텍처 그림은 1.3 참고.

## 참조

- `backend-core/pom.xml`, `backend-bff/pom.xml`
- `ui/package.json`, `ui/vite.config.ts`, `ui/tsconfig.json`
- `docs/port-allocation.md`
- `docs/comprehensive/inventory/02_stack_a_backend.md`
- `docs/comprehensive/inventory/03_stack_b_backend.md`
- `docs/comprehensive/inventory/04_frontend.md`
- `C:/claude/docker-info.xml` (워크스페이스 권위 레지스트리)

## 이 챕터가 다루지 않은 인접 주제

- 시스템 컨텍스트·컨테이너 다이어그램은 챕터 1.3 (아키텍처) 참조.
- API 엔드포인트 표·페이로드 형식은 챕터 1.5 (API 명세) 참조.
- 외부 서비스 5종(Rocket.Chat/Stalwart/LiveKit/Wiki.js/MinIO)의 OAuth/SSO 설정은 챕터 1.12 (보안) 참조.
