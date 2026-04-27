# Stack B (Backend-BFF) Inventory

**Location:** `/backend-bff/src/main/java/com/platform/v3/bff/`

## Core Architecture

- **Framework:** Spring Boot 3.2.5 + WebClient (reactive HTTP)
- **Security:** OAuth2 ResourceServer (JWT from Keycloak)
- **Pattern:** Port-Adapter (Hexagonal) — BffController → Ports → Adapters
- **External Services:** 6 federation endpoints (Keycloak, RocketChat, Stalwart, LiveKit, MinIO, WikiJS)
- **Port:** 19091 (configured)

## API & Controller Layer

### BffController (/api/bff)

| Endpoint | Method | Port | Purpose |
|----------|--------|------|---------|
| `/identity/me` | GET | IdentityPort | Current user info (JWT claims) |
| `/identity/users` | POST | IdentityPort | Create Keycloak user (ROLE_ADMIN) |
| `/identity/users/{id}` | PUT/DELETE | IdentityPort | Update/delete user (ROLE_ADMIN) |
| `/messages` | GET/POST | MessagingPort | RocketChat room messages |
| `/messages/rooms` | GET | MessagingPort | List user's RocketChat rooms |
| `/mail/*` | GET/POST | MailPort | Stalwart email operations |
| `/wiki/*` | GET/POST | WikiPort | Wiki.js page operations |
| `/video/token` | POST | VideoPort | LiveKit room access token |
| `/storage/*` | GET/POST/DELETE | StoragePort | MinIO S3 operations (list, upload, presign) |
| `/health` | GET | - | Service health check |

**All endpoints require JWT (via SecurityConfig)**

## Port Interfaces (7 total)

| Port | Adapter(s) | Role |
|------|------------|------|
| `IdentityPort` | `KeycloakIdentityAdapter` | User/realm management, token grant |
| `MessagingPort` | `RocketChatAdapter` | Chat messages, rooms, subscriptions |
| `MailPort` | `StalwartMailAdapter` | Email send/receive, folders |
| `WikiPort` | `WikiJsAdapter` | Wiki page CRUD, rendering |
| `VideoPort` | `LiveKitAdapter` | Video room tokens, participant mgmt |
| `StoragePort` | `MinioStorageAdapter` | S3-compatible file operations |
| `NotificationPort` | (not bound in BFF) | Fallback for notification propagation |

## Adapters (6 total)

### KeycloakIdentityAdapter
- **Config:** `bff.keycloak.admin-url`, `realm`, `admin-user`, `admin-pass`, `admin-client-id`
- **Method:** Password grant (admin/admin + admin-cli public client) → access token
- **Operations:** getMe(), createUser(), updateUser(), deleteUser(), getRoles(), assignRoles()
- **Note:** Phase 14 warning: uses master realm admin-cli (not ideal for production)

### RocketChatAdapter
- **Config:** `bff.rocketchat.base-url`, `admin-token` (env var or realm export)
- **Method:** REST API with X-Auth-Token header
- **Operations:** getMessages(), sendMessage(), getRooms(), createRoom(), subscribeChannel()

### StalwartMailAdapter
- **Config:** `bff.stalwart.base-url`, `admin-user`, `admin-pass`
- **Method:** REST API with Basic Auth
- **Operations:** sendEmail(), getMessages(), getFolders(), markAsRead()

### LiveKitAdapter
- **Config:** `bff.livekit.url`, `api-key`, `api-secret` (JWT signing)
- **Method:** Generate AccessToken with RS256 JWT (api-secret as key)
- **Operations:** createAccessToken(), getRoomInfo(), participantList()

### MinioStorageAdapter
- **Config:** `bff.minio.endpoint`, `access-key`, `secret-key`, `bucket`
- **Method:** MinioClient SDK (Java)
- **Operations:** putObject(), getObject(), listObjects(), getPresignedObjectUrl(), removeObject()

### WikiJsAdapter
- **Config:** `bff.wikijs.base-url`, `api-token` (env var or realm export)
- **Method:** GraphQL API with Authorization header
- **Operations:** getPage(), createPage(), updatePage(), deletePage()

## Configuration

### application.yml (Backend-BFF)

```yaml
server:
  port: 19091

bff:
  rocketchat:
    base-url: http://localhost:19065
    admin-token: ${ROCKETCHAT_ADMIN_TOKEN}
  stalwart:
    base-url: http://localhost:19480
    admin-user: admin
    admin-pass: admin
  wikijs:
    base-url: http://localhost:19001
    api-token: ${WIKIJS_API_TOKEN}
  livekit:
    url: http://localhost:19880
    api-key: devkey
    api-secret: devsecret_v3_changeme_32chars_minimum
  minio:
    endpoint: http://localhost:19900
    access-key: v3minio
    secret-key: v3minio_pass
    bucket: platform-v3
  keycloak:
    admin-url: http://localhost:19281
    realm: openplatform-v3
    admin-user: admin
    admin-pass: admin
    admin-client-id: admin-cli

security:
  oauth2:
    resourceserver:
      jwt:
        jwk-set-uri: http://keycloak:8080/realms/openplatform-v3/protocol/openid-connect/certs
```

## SecurityConfig

- **Pattern:** Stateless (no sessions)
- **CORS:** Localhost:* (development mode, port 25174 for UI)
- **Endpoints:** `/actuator/health`, `/actuator/info`, `/actuator/prometheus` — permitAll()
- **Default:** All other requests require authentication
- **JWT:** Extracted from `Authorization: Bearer <token>`, validated against Keycloak JWKS

Code snippet (SecurityConfig.java lines 17-35):
```java
http.csrf(AbstractHttpConfigurer::disable)
    .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
    .cors(c -> c.configurationSource(req -> {
        CorsConfiguration cfg = new CorsConfiguration();
        cfg.setAllowedOriginPatterns(List.of("http://localhost:*", "http://127.0.0.1:*"));
        cfg.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        cfg.setAllowedHeaders(List.of("*"));
        cfg.setAllowCredentials(true);
        return cfg;
    }))
    .authorizeHttpRequests(auth -> auth
        .requestMatchers("/actuator/health/**", ...).permitAll()
        .anyRequest().authenticated()
    )
    .oauth2ResourceServer(o -> o.jwt(jwt -> {}));
```

## Federation Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Backend-BFF (19091)                         │
│  ┌──────────────────┐ ┌──────────────────────────────────────┐  │
│  │  BffController   │ │         Port-Adapter Layer           │  │
│  │  (/api/bff/*)    │ │                                      │  │
│  └────────┬─────────┘ │  IdentityPort ─→ KeycloakAdapter   │  │
│           │           │  MessagingPort ─→ RocketChatAdapter │  │
│           │           │  MailPort ─→ StalwartAdapter        │  │
│           │           │  WikiPort ─→ WikiJsAdapter          │  │
│           │           │  VideoPort ─→ LiveKitAdapter        │  │
│           │           │  StoragePort ─→ MinioAdapter        │  │
│           │           └──────────────────────────────────────┘  │
│           │                                                      │
└───────────┼──────────────────────────────────────────────────────┘
            │
    ┌───────┼────────────────────────────────────┐
    │       │                                    │
    ▼       ▼                                    ▼
  Keycloak  RocketChat  Stalwart  LiveKit  WikiJS  MinIO
  (19281)   (19065)     (19480)   (19880) (19001) (19900)
```

## Service Dependencies

| Adapter | Dependency | Version | Purpose |
|---------|-----------|---------|---------|
| KeycloakIdentityAdapter | spring-webflux WebClient | - | HTTP client for admin API |
| RocketChatAdapter | spring-webflux WebClient | - | REST API calls |
| StalwartMailAdapter | spring-webflux WebClient | - | REST API calls |
| LiveKitAdapter | livekit-server-sdk | (gradle) | JWT token generation |
| MinioStorageAdapter | io.minio:minio | 8.5.7 | S3 operations |
| WikiJsAdapter | spring-webflux WebClient | - | GraphQL requests |

## OAuth2 & JWT Flow

1. **UI Login** → Keycloak (OIDC implicit/auth code flow)
2. **Keycloak** → Issues access token (JWT) + refresh token
3. **UI stores tokens** in localStorage/sessionStorage
4. **API calls** include `Authorization: Bearer <token>`
5. **BFF SecurityConfig** validates JWT signature against Keycloak JWKS
6. **JwtAuthenticationToken** extracted from context in controller
7. **Admin operations** use Keycloak admin-cli client credentials (password grant)

## Key Design Patterns

- **Port-Adapter (Hexagonal):** External service dependencies injected via ports
- **Stateless REST:** No server-side sessions
- **WebClient (reactive):** Non-blocking HTTP for external APIs
- **Dual Auth:** End-user JWT + internal admin credentials
- **Error Handling:** BFFs translate 4xx/5xx from external services to meaningful HTTP responses

## Statistics

- **Controllers:** 1 (BffController, ~200 lines)
- **Ports:** 7 interfaces (~400 lines aggregate)
- **Adapters:** 6 implementations (~1500 lines aggregate)
- **Config:** 1 SecurityConfig class (~36 lines)
- **Total lines:** ~2.5 KB (16 Java files)

## External Integration Matrix

| Service | Protocol | Auth | Timeout | Retry |
|---------|----------|------|---------|-------|
| Keycloak | HTTPS/HTTP | Basic (admin) | 30s | 2x exponential |
| RocketChat | HTTPS/HTTP | X-Auth-Token | 30s | 1x |
| Stalwart | HTTPS/HTTP | Basic | 30s | 1x |
| LiveKit | HTTPS/HTTP | None (internal) | 30s | 1x |
| WikiJS | HTTPS/HTTP/GraphQL | Bearer Token | 30s | 1x |
| MinIO | HTTPS/HTTP | AWS Sig V4 | 60s | 1x |

**Approx size:** ~2.5 KB aggregate (16 Java files)
