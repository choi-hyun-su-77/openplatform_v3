# Chapter 12 — 보안 아키텍처 (Security)

본 챕터는 openplatform_v3 의 인증·인가·외부 SSO·감사·하드닝 모델을 단일 권위 문서로 정리한다. 모든 인증은 Keycloak 단일 SSO 허브를 거치며, 백엔드는 Stateless OAuth2 Resource Server (RS256 JWT) 로 동작한다.

---

## 12.1 인증 모델 (Keycloak OIDC)

- **Realm**: `openplatform-v3` — `infra/keycloak/openplatform-v3-realm.json` 으로 임포트.
- **호스트 통일**: 브라우저·docker 컨테이너 모두 `kc.localtest.me` (RFC 공용 DNS, 127.0.0.1 응답) 로 접근 → 단일 SSO 쿠키 → 진정한 single sign-on 달성. 모든 다운스트림 컨테이너에 `extra_hosts: kc.localtest.me:host-gateway` 추가 [src: warn.md 2026-04-15 19:51 단일 호스트 통일].
- **세션 정책** [src: openplatform-v3-realm.json:11-14]:
  - `accessTokenLifespan`: 900s (15분)
  - `ssoSessionIdleTimeout`: 1800s (30분)
  - `ssoSessionMaxLifespan`: 36000s (10시간)
  - `bruteForceProtected`: true
- **클라이언트 5종**:

| clientId | 유형 | 용도 |
|---|---|---|
| `v3-ui` | public + PKCE S256 | 포털 SPA 표준 OIDC 흐름 [src: realm.json:25-37] |
| `v3-backend-core` | bearerOnly | Resource Server (JWT 검증만) |
| `v3-backend-bff` | bearerOnly | Resource Server (BFF 측) |
| `rocketchat`, `wiki-js`, `minio`, `livekit` | confidential / bearerOnly | 외부 서비스 federation |

---

## 12.2 JWT 토큰 구조 (RS256)

서명: Keycloak 내부 RSA 개인키 → 백엔드는 JWKS endpoint (`/realms/openplatform-v3/protocol/openid-connect/certs`) 로 자동 검증.

| Claim | 출처 | 사용처 |
|---|---|---|
| `sub` | Keycloak user UUID | 외부키, audit `actor_no` 후보 |
| `preferred_username` | LDAP/local username | `current-user-id` 매핑, DataSet `currentUser` 인자 |
| `name` / `given_name` / `family_name` | 프로파일 | 감사 `actor_name` 우선값 [code: AdminAuditAspect#resolveActorName] |
| `email` / `email_verified` | 프로파일 | 알림 EMAIL 채널 |
| `realm_access.roles[]` | realm 역할 | RBAC 핵심 — `ROLE_USER/APPROVER/MANAGER/ADMIN` |
| `resource_access.{client}.roles[]` | 클라이언트 역할 | 보조 (현재 미사용) |
| `azp` | 발급 클라이언트 | `v3-ui` 외 거부 가능 (현 미적용) |
| `policy` (minio 클라이언트 한정) | hardcoded mapper `consoleAdmin` | MinIO Console 접근 [src: realm.json:104-115] |

[src: docs/comprehensive/inventory/09_security.md:36-74]

---

## 12.3 SecurityConfig — 백엔드 두 모듈

두 SecurityConfig 모두 Stateless · CSRF off · CORS localhost wildcard · OAuth2 Resource Server JWT 흐름이다.

### backend-bff [code: backend-bff/.../config/SecurityConfig.java:17-35]

```java
http.csrf(AbstractHttpConfigurer::disable)
    .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
    .cors(c -> c.configurationSource(req -> { /* localhost:* + allowCredentials */ }))
    .authorizeHttpRequests(auth -> auth
        .requestMatchers("/actuator/health/**", "/actuator/info",
                         "/actuator/prometheus", "/actuator/metrics").permitAll()
        .anyRequest().authenticated())
    .oauth2ResourceServer(o -> o.jwt(jwt -> {}));
```

### backend-core [code: backend-core/.../config/SecurityConfig.java:29-58]

차이점:
1. `permitAll` 화이트리스트 확장: `/api/public/**`, `/api/codes/**`, `/api/i18n/**`.
2. **SSE 토큰 필터** — 브라우저 `EventSource` 가 커스텀 헤더를 못 보내므로 `?token=` 쿼리 파라미터를 `Authorization: Bearer …` 헤더로 변환하는 `SseTokenFilter` 추가 (UsernamePasswordAuthenticationFilter 앞단) [src: warn.md 2026-04-16 21:22 Phase E].
3. **JwtAuthenticationConverter 커스텀** [code: SecurityConfig.java:61-75] — `realm_access.roles[]` 를 Spring `ROLE_*` 권한으로 변환하면서 이미 `ROLE_` 가 붙은 경우 중복 방지(`replaceFirst("^ROLE_","")`).

CORS / CSRF / Stateless 핵심 결정:
- **CSRF off** — Stateless REST + JWT in localStorage 는 form 토큰 모델 불필요, 쿠키 기반 세션 없음.
- **CORS** — dev: `http://localhost:*` / `http://127.0.0.1:*` allowCredentials=true. **운영 배포 시 도메인 화이트리스트로 좁혀야 함** [src: 09_security.md:382-400].

---

## 12.4 RBAC — 역할·메뉴 매트릭스

권한 모델은 **Keycloak realm role** + **DB 메뉴 권한 매트릭스** 의 이중 구조이다 [src: V6__menu_permission.sql].

### 역할 시드 [code: V6__menu_permission.sql:48-53]

| role_id | role_name | 설명 |
|---|---|---|
| `ROLE_USER` | 일반 사용자 | 전 직원 기본 권한 |
| `ROLE_APPROVER` | 결재자 | 결재 권한 보유 |
| `ROLE_MANAGER` | 부서장 | 부서 관리 권한 |
| `ROLE_ADMIN` | 관리자 | 시스템 전체 관리 |

### 메뉴 권한 비트 (`cm_role_menu`, V6:22-32)

```
can_read | can_create | can_update | can_delete | can_export | can_print
```

기본 시드:
- `ROLE_USER`: read / create / update / export / print = TRUE, **delete = FALSE**.
- `ROLE_ADMIN`: 전 비트 TRUE.

### 적용 지점

1. **백엔드 어노테이션** — `BffController.requireAdmin(JwtAuthenticationToken)` 가 `realm_access.roles` 에 `admin` 포함 여부를 검사하여 `403` 던짐 [src: 09_security.md:178-197].
2. **Spring Authority** — backend-core 는 JWT → `SimpleGrantedAuthority("ROLE_ADMIN")` 로 변환하여 Spring Security 표현식과 통합 [code: SecurityConfig.java:64-74].
3. **프론트 라우터 가드** — `requiresAdmin` meta + `cm_role_menu.can_read` 체크 후 `/403` 리다이렉트 [src: 09_security.md:264-301].

---

## 12.5 외부 서비스 SSO Federation (5종)

모든 외부 서비스는 realm `openplatform-v3` 클라이언트로 등록되어 단일 자격증명으로 로그인된다.

| 서비스 | 메커니즘 | 클라이언트 | 비고 |
|---|---|---|---|
| Rocket.Chat | Custom OAuth (mattermost 프로파일 폐기) | `rocketchat` confidential [src: realm.json:49-76] | callback `/_oauth/keycloak`, REST `settings.update` 로 Custom-Keycloak 프로바이더 등록 [src: warn.md 2026-04-15 항목 3] |
| Wiki.js | OIDC Strategy | `wiki-js` confidential [src: realm.json:78-89] | autoEnrollGroups=[1] Administrators, DB jsonb_set 로 host URL 5종 갱신 |
| MinIO Console | OIDC + hardcoded `policy=consoleAdmin` | `minio` confidential [src: realm.json:91-117] | 2025 릴리즈 `redirectRules` 회귀 → 포털이 Keycloak `/auth` URL 로 직접 redirect, MinIO `/oauth_callback` 활용 [src: minio-console-oidc-analysis.md §6] |
| LiveKit | JWT (api-key/secret) — Keycloak 비경유 | `livekit` bearerOnly + `livekit.yaml` | 룸 토큰은 BFF `/api/bff/video/token` 이 LiveKit SDK 로 자체 서명 후 wsUrl 동봉 발급 |
| Stalwart Mail | Basic Auth | LDAP 동기화 자격증명 | SMTP/IMAP 은 OIDC 미지원 — LDAP 패스워드 직접 사용 |

---

## 12.6 Keycloak Admin 토큰 발급 (Phase 14 Track 5)

`KeycloakIdentityAdapter` 가 사용자 CRUD 를 위해 master realm 의 `admin-cli` public client + admin/admin 자격증명으로 password grant 토큰을 발급한다 [code: KeycloakIdentityAdapter.java:237-261].

```java
URI uri = URI.create(adminUrl + "/realms/master/protocol/openid-connect/token");
client.post().uri(uri)
      .contentType(MediaType.APPLICATION_FORM_URLENCODED)
      .body(BodyInserters.fromFormData("grant_type", "password")
              .with("client_id", adminClientId)   // admin-cli
              .with("username", adminUser)        // admin
              .with("password", adminPass));      // admin
```

- 자율 결정 사유: `realm-management` 의 service-account client_credentials 가 realm-export 에 없음 [src: KeycloakIdentityAdapter.java:22-28 javadoc].
- **운영 환경 필수 변경**: service-account client_credentials grant + Vault/Secrets Manager 보관 + 월간 로테이션 [src: 09_security.md:130-133, 396-400].

---

## 12.7 비밀 관리 (Secrets)

| 비밀 | 현재 위치 | 운영 권고 |
|---|---|---|
| Keycloak admin/admin | realm.json + `bff.keycloak.admin-pass` env | 강한 비밀번호 + Vault |
| 클라이언트 시크릿 (rocketchat/wiki-js/minio) | realm.json 평문 | env var 주입, realm export 시 시크릿 마스킹 |
| LiveKit api-key/secret | `livekit.yaml` | Vault + 컨테이너 mount |
| LDAP bind password | `.env` | 동일 |
| DB 자격증명 | `.env` (postgres/postgres) | 운영용 강 비밀번호 |

DEV 모드 한정 위험:
- `v3-ui` 클라이언트에 `directAccessGrantsEnabled=true` (E2E 스크립트용) → **운영 배포 시 false 필수** [src: warn.md 항목 잔여 사항].

---

## 12.8 감사 로그 (V14 + AdminAuditAspect)

`platform_v3.sa_audit` 테이블 [src: V14__admin_audit.sql:7-18]:
- `actor_no`, `actor_name`, `action` (DataSet serviceName), `target_type`, `target_id`, `before_json`, `after_json`, `ip_addr`, `acted_at`.
- 인덱스 3종: `(actor_no, acted_at DESC)`, `(target_type, target_id)`, `(action, acted_at DESC)`.

**AOP 자동 인서트** [code: AdminAuditAspect.java:64-95]:
1. `@DataSetServiceMapping` 어노테이션 메서드를 `@Around` 로 가로챔.
2. `serviceName` 이 `admin/` 으로 시작할 때만 동작.
3. 정상 종료 후에만 insert (예외는 propagate, audit skip).
4. `actor_name` 은 JWT `name` → `preferred_username` → currentUser fallback.
5. `before_json` (인풋 datasets), `after_json` (반환값) 16KB 상한 truncate.
6. `ip_addr` 은 `X-Forwarded-For` 첫 번째, fallback `RemoteAddr`.

대상 도메인 prefix → `target_type` 매핑: `user→USER`, `dept→DEPT`, `menu→MENU`, `perm→PERMISSION`, `code→CODE`, `audit→AUDIT`, 기본 `ADMIN`.

---

## 12.9 OWASP Top 10 (2021) 매트릭스

| 항목 | 본 프로젝트 대응 | 상태 |
|---|---|---|
| A01 Broken Access Control | `requireAdmin` + `cm_role_menu` + 라우터 가드 | OK |
| A02 Cryptographic Failures | RS256 JWT 자동 검증, TLS·at-rest 암호화 미적용 | dev OK / prod TODO |
| A03 Injection | MyBatis `#{}` strict, `${}` 금지 | OK |
| A04 Insecure Design | Port-Adapter 분리, BFF 외부 호출 격리 | OK |
| A05 Security Misconfiguration | CSRF off (stateless 안전), CORS localhost wildcard | dev OK / prod 좁힘 |
| A06 Vulnerable Components | OWASP DependencyCheck 미통합 | TODO |
| A07 Auth Failures | Keycloak SSO + bruteForceProtected + PKCE S256 + idle 30분 | OK |
| A08 Data Integrity | Flyway V1~V15, 이미지 태그 핀고정 | OK |
| A09 Logging & Monitoring | AdminAuditAspect + Loki + Prometheus + sa_audit 인덱스 | OK |
| A10 SSRF | BFF 외부 URL 화이트리스트, 사용자 URL 입력 금지 | OK |

XSS: Vue 3 템플릿 자동 escape; `v-html` 은 게시판 마크다운에 한정되며 `Textarea` + 줄바꿈만 처리 (외부 마크다운 패키지 미도입) [src: warn.md 2026-04-16 Phase B].

---

## 12.10 알려진 미완 (Known Gaps)

1. **`ApprovalService.recordHistory()` actorName** — currentUser(employee_no) 그대로 사용. `OrgMapper.findEmployeeByNo` 로 employee_name 추출 권고, TODO 주석 존재 [src: warn.md 2026-04-16].
2. **BFF `/api/bff/mail/send` service-auth 부재** — backend-core `BffClient` 가 인증 없이 호출 → `JwtAuthenticationToken` 필수 엔드포인트에서 401 가능. 현재 호출 실패는 warn 로그만 남기고 PORTAL 채널은 정상. 후속으로 service-account 인증 또는 internal-only 엔드포인트 필요 [src: warn.md 2026-04-27 T6].
3. **첨부 presigned GET 권한 검증** — Phase A 에서 `verifyDocAccess` 추가했으나 Board/Wiki 첨부 presigned 발급은 누구나 호출 가능 → Phase F sweep 처리 예정.
4. **Rate Limiting** — Redis 기반 IP throttle 미구현.
5. **At-rest 암호화** — `pgcrypto`/RDS encryption 미적용 (Phase 14.C 이후).
6. **HTTPS/TLS** — 전 노출 포트 평문. 운영 배포 시 Let's Encrypt + Traefik termination 필요.

---

## 참조

- `docs/comprehensive/inventory/09_security.md` — 보안 인벤토리
- `backend-bff/src/main/java/com/platform/v3/bff/config/SecurityConfig.java`
- `backend-core/src/main/java/com/platform/v3/core/config/SecurityConfig.java`
- `backend-bff/src/main/java/com/platform/v3/bff/adapter/KeycloakIdentityAdapter.java`
- `backend-core/src/main/java/com/platform/v3/core/admin/AdminAuditAspect.java`
- `infra/keycloak/openplatform-v3-realm.json`
- `backend-core/src/main/resources/db/migration/V6__menu_permission.sql`
- `backend-core/src/main/resources/db/migration/V14__admin_audit.sql`
- `docs/minio-console-oidc-analysis.md`
- `warn.md` (2026-04-15 단일 호스트 통일, 2026-04-16 Phase A/E, 2026-04-27 T6 EMAIL 채널)

---

## 이 챕터가 다루지 않은 인접 주제

- **DataSet 서비스 라우팅 / `@DataSetServiceMapping`** — Chapter 9 (Backend Structure).
- **JWT → currentUser 매핑 / `org_employee.employee_id` lookup** — Chapter 11 + Chapter 9 DataSetController.
- **알림 SSE `?token=` 쿼리 인증** — Chapter 11 + Chapter 5 (API Spec).
- **외부 서비스 자체 데이터 모델·운영** — Chapter 13 (External Integrations) 예정.
- **운영 하드닝 체크리스트 (TLS / Vault / DependencyCheck / 침투테스트)** — 별도 운영 가이드.
- **프론트 토큰 갱신 (keycloak-js updateToken / Pinia auth store)** — Chapter 6 인증 store 절.
