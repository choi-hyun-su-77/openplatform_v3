# Security & Authentication Inventory

**Security Model:** OAuth2 Resource Server (JWT) + Role-Based Access Control (RBAC)

## OAuth2 & JWT Flow

### Keycloak Configuration

**Realm:** `openplatform-v3` (imported from `/infra/keycloak/openplatform-v3-realm.json`)

**Clients:**
1. **openplatform-v3-ui** (Public Client)
   - Client ID: openplatform-v3-ui
   - Access Type: public (no secret)
   - Standard Flow: Enabled
   - Valid Redirect URIs: http://localhost:25174/*, http://localhost:19173/*
   - Web Origins: http://localhost:25174, http://localhost:19173

2. **openplatform-v3-api** (Confidential Client, if used)
   - For service-to-service communication
   - Client Secret: (env var, not in realm export)

**Token Exchange:**
```
UI (Login page)
   ↓ (redirect to Keycloak)
Keycloak (OIDC implicit or auth-code-pkce flow)
   ↓ (redirect with #access_token=JWT)
UI (keycloak-js stores token, refresh token)
   ↓ (API calls with Authorization: Bearer JWT)
Backend-BFF (validate JWT signature against JWKS)
   ↓ (extract claims, create JwtAuthenticationToken)
Backend-Core (OAuth2 ResourceServer validates JWT)
```

### JWT Token Structure (HS256 or RS256)

**Header:**
```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "keycloak-key-id"
}
```

**Payload (sample claims):**
```json
{
  "exp": 1714275600,
  "iat": 1714275000,
  "jti": "abc123",
  "iss": "http://keycloak:8080/realms/openplatform-v3",
  "aud": "openplatform-v3-api",
  "sub": "user-id-uuid",
  "typ": "Bearer",
  "azp": "openplatform-v3-ui",
  "session_state": "session-id",
  "name": "Test User",
  "preferred_username": "test1",
  "given_name": "Test",
  "family_name": "User",
  "email": "test1@example.com",
  "email_verified": true,
  "realm_access": {
    "roles": ["default-roles-openplatform-v3", "user"]
  },
  "resource_access": {
    "openplatform-v3-api": {
      "roles": ["user", "approval_viewer"]
    }
  }
}
```

**Signature:** RS256(header.payload, keycloak_private_key)

## Backend-BFF Security

**File:** `/backend-bff/src/main/java/com/platform/v3/bff/config/SecurityConfig.java`

### Configuration Details (lines 17-35)

```java
http
  .csrf(AbstractHttpConfigurer::disable)  // Stateless API (no forms)
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
    .requestMatchers("/actuator/health/**", "/actuator/info", "/actuator/prometheus", "/actuator/metrics")
    .permitAll()
    .anyRequest().authenticated()
  )
  .oauth2ResourceServer(o -> o.jwt(jwt -> {}));
```

**Key Security Properties:**
- CSRF: Disabled (stateless REST, not vulnerable)
- CORS: Development mode (localhost:* only; restrict to domain in prod)
- Sessions: None (JWT in localStorage)
- OAuth2: JWT validation against Keycloak JWKS endpoint

### Admin Token Generation (KeycloakIdentityAdapter)

**Flow for Phase 14 Track 5 (admin operations):**

1. BFF receives authenticated request with user JWT
2. Check: User has ROLE_ADMIN (from JWT claims)
3. Generate admin token:
   ```
   POST http://keycloak:8080/realms/openplatform-v3/protocol/openid-connect/token
   grant_type=password
   username=admin
   password=admin
   client_id=admin-cli
   ```
4. Receive admin token (long-lived, service account)
5. Use admin token to call Keycloak admin APIs:
   - POST /admin/realms/{realm}/users (create user)
   - PUT /admin/realms/{realm}/users/{id} (update)
   - DELETE /admin/realms/{realm}/users/{id} (delete)

**⚠️ WARNING (Phase 14):** admin-cli uses password grant with hardcoded admin/admin credentials (insecure). Production should use:
- Service account (client_credentials grant)
- Rotate credentials monthly
- Store in HashiCorp Vault / AWS Secrets Manager

## Backend-Core Security

**File:** `/backend-core/src/main/java/com/platform/v3/core/config/SecurityConfig.java`

Similar to BFF, but with additional role checking for sensitive operations.

### RBAC Implementation

**Menu-Based Authorization:**

```java
// router/index.ts (lines 70-82)
if (to.meta.requiresAdmin === true) {
  const roles = auth.user?.roles || [];
  if (!roles.includes('ROLE_ADMIN')) {
    return '/403';
  }
}

if (menuId && auth.menus.length > 0) {
  const menu = auth.menus.find(m => m.menuId === menuId || m.menuPath === to.path);
  if (menu && menu.canRead === false) {
    return '/403';
  }
}
```

**Backend Permission Checks (example in AdminService):**

```java
@Service
public class AdminService {
  public void createUser(Map<String, Object> data) {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (!auth.getAuthorities().stream()
        .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"))) {
      throw new BusinessException("PERMISSION_DENIED", "Admin role required");
    }
    // Create user logic
  }
}
```

### Endpoint Authorization (BffController)

```java
// api/BffController.java (lines 48-50)
@PostMapping("/identity/users")
public Map<String, Object> createUser(@RequestBody Map<String, Object> body, JwtAuthenticationToken auth) {
  requireAdmin(auth);  // Throws 403 if not ROLE_ADMIN
  return identityPort.createUser(...);
}

private void requireAdmin(JwtAuthenticationToken auth) {
  if (!auth.getTokenAttributes().getOrDefault("realm_access", new HashMap<>())
      instanceof Map realmAccess) {
    List<?> roles = (List<?>) realmAccess.get("roles");
    if (roles == null || !roles.contains("admin")) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Admin role required");
    }
  }
}
```

## Database Security

### SQL Injection Prevention

**Method:** MyBatis parameterized queries

```xml
<!-- SAFE: Parameterized -->
<select id="selectByUserId" resultType="map">
  SELECT * FROM approval_request WHERE created_by = #{userId}
</select>

<!-- UNSAFE: String interpolation (avoid!) -->
<select id="selectByStatus" resultType="map">
  SELECT * FROM approval_request WHERE status = '${status}'
</select>
```

### Data Encryption

**Fields to encrypt (recommendation):**
- user.email
- user.phone_number
- approval_attachment (sensitive documents)

**Approach:**
- At-rest: PostgreSQL pgcrypto extension
  ```sql
  SELECT pgp_sym_encrypt(email, 'secret_key') FROM "user";
  ```
- In-transit: HTTPS + TLS 1.2+

**Current status:** No encryption applied (needs Phase 14.C or later)

## API Rate Limiting

### Redis-Based Rate Limit (optional, not implemented)

If needed:
```java
@RestController
@RequestMapping("/api")
public class RateLimitFilter implements HandlerInterceptor {
  @Override
  public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler) {
    String key = "rate_limit:" + getClientIp(req);
    Integer count = redisTemplate.opsForValue().get(key);
    if (count != null && count > 100) {
      res.setStatus(429);  // Too Many Requests
      return false;
    }
    redisTemplate.opsForValue().increment(key);
    redisTemplate.expire(key, Duration.ofMinutes(1));
    return true;
  }
}
```

## Frontend Security (Router Guards)

**File:** `/ui/src/router/index.ts` (lines 57-85)

### Authentication Guard

```typescript
router.beforeEach(async (to) => {
  const auth = useAuthStore();
  
  // Non-auth routes (login, 403)
  if (to.meta.requiresAuth === false) {
    if (auth.isAuthenticated && to.path === '/login') return '/dashboard';
    return true;
  }
  
  // Protected routes
  if (!auth.isAuthenticated) {
    return { path: '/login', query: { redirect: to.fullPath } };
  }
  
  // Load user info if not loaded
  if (!auth.user) {
    await auth.loadUserInfo();
  }
  
  // Admin-only routes
  if (to.meta.requiresAdmin === true) {
    const roles = auth.user?.roles || [];
    if (!roles.includes('ROLE_ADMIN')) {
      return '/403';
    }
  }
  
  // Menu permission check
  const menuId = to.meta.menuId as string | undefined;
  if (menuId && auth.menus.length > 0) {
    const menu = auth.menus.find(m => m.menuId === menuId || m.menuPath === to.path);
    if (menu && menu.canRead === false) {
      return '/403';
    }
  }
  
  return true;
});
```

### Token Refresh & Expiration

**Keycloak.js (built-in):**
- Automatically refreshes token 5 min before expiry
- On 401 response: Call auth.refresh() (Pinia action)

**Auth store (/ui/src/store/auth.ts):**

```typescript
export const useAuthStore = defineStore('auth', () => {
  // ... state
  
  async function refresh() {
    try {
      const kc = getKeycloak();
      const success = await kc?.updateToken(30);  // Refresh if expires in 30s
      return success;
    } catch (e) {
      console.error('Token refresh failed', e);
      await logout();
      return false;
    }
  }
  
  async function logout() {
    const kc = getKeycloak();
    isAuthenticated.value = false;
    accessToken.value = '';
    refreshToken.value = '';
    user.value = null;
    menus.value = [];
    await kc?.logout();
  }
});
```

## LDAP Integration (Optional)

**File:** `/infra/ldap/users.ldif`

**Keycloak LDAP Provider Configuration:**
- Provider: ldap
- Server URL: ldap://ldap:389
- Bind DN: cn=admin,dc=example,dc=com
- Bind Password: (env var)
- User Search DN: ou=users,dc=example,dc=com

**Benefit:** Centralized user directory; users authenticate against LDAP instead of Keycloak local DB

**Current status:** Optional (test.ldif present but not required for dev)

## Audit & Compliance

### Audit Logging (AdminAuditAspect)

```java
@Aspect
@Component
public class AdminAuditAspect {
  @Before("@target(org.springframework.web.bind.annotation.RestController)")
  public void auditLog(JoinPoint jp) {
    // Log: who, what, when, where
    log.info("User {} performed action {} on {} at {}",
      getCurrentUserId(),
      jp.getSignature().getName(),
      jp.getTarget().getClass().getSimpleName(),
      LocalDateTime.now());
  }
}
```

Logged to:
- Database: admin_audit table
- Logs: logback (searchable via Loki)
- Metrics: audit event count (Prometheus)

## Security Checklist

| Area | Status | Notes |
|------|--------|-------|
| JWT Validation | ✓ | Keycloak JWKS endpoint |
| HTTPS/TLS | ⚠️ | Dev mode (localhost); enable in prod |
| CSRF Protection | N/A | Stateless API (not vulnerable) |
| SQL Injection | ✓ | MyBatis parameterization |
| XSS Protection | ✓ | Vue 3 auto-escapes templates |
| CORS | ⚠️ | Localhost:* (restrict in prod) |
| Rate Limiting | ✗ | Not implemented (recommended) |
| Data Encryption | ✗ | At-rest encryption (Phase 14.C) |
| Secrets Management | ⚠️ | Env vars (use Vault in prod) |
| Admin Credentials | ⚠️ | Hardcoded admin/admin (change in prod) |
| Dependency Scanning | ✗ | Not in CI/CD (add OWASP DependencyCheck) |

## Production Hardening Checklist

1. [ ] Enable HTTPS/TLS (Let's Encrypt)
2. [ ] Restrict CORS to production domain only
3. [ ] Change Keycloak admin password
4. [ ] Implement service account for Keycloak admin API (not password grant)
5. [ ] Enable SQL encryption-at-rest (pgcrypto or AWS RDS encryption)
6. [ ] Implement rate limiting (Redis + Spring Cloud Gateway)
7. [ ] Add OWASP Dependency Check to CI/CD
8. [ ] Rotate JWT signing keys monthly
9. [ ] Enable audit logging & monitoring
10. [ ] Conduct penetration testing

**Approx security code:** ~1.5 KB (SecurityConfig, RBAC checks, audit aspect)
