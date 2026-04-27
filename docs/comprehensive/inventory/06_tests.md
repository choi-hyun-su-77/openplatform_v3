# Testing & Test Infrastructure Inventory

**Status:** Minimal test coverage. No unit tests found. Integration tests would be in `src/test/java/`.

## Current Test Situation

- **Unit Tests:** None found (backend-core, backend-bff)
- **Integration Tests:** None found
- **E2E Tests:** None (no Playwright/Cypress in ui package.json)
- **Test Data:** `/infra/seed/expand_test_data.sql` (SQL-based, loaded at docker-compose up)

## Test Data Setup

### Seed Users (from V5__seed_data.sql)

| Login | Password | Role | Dept | Purpose |
|-------|----------|------|------|---------|
| admin | admin | ROLE_ADMIN | 본부 | System admin (not used in Keycloak flow) |
| test1 | test1 | ROLE_USER | 개발팀 | Regular user |
| test2 | test2 | ROLE_USER | 영업팀 | Regular user (different dept) |

**Note:** These are database records. Actual Keycloak users created via keycloak/openplatform-v3-realm.json realm export.

### Test Data Expansion (infra/seed/expand_test_data.sql)

Inserted on first docker-compose up:
- 100+ additional users (test_user_001, test_user_002, ..., test_user_100)
- 10 test departments with hierarchy
- 50+ common codes (approval types: 결재, 보고, 휴가 | leave types: 연차, 병가, 특별휴가)
- 200+ calendar events (sample meetings/deadlines)
- 100+ board posts (sample notices)
- 50+ leave requests (various statuses: 신청, 승인, 반려)
- 50+ room bookings (conference rooms, equipment)
- 50+ work reports (team standups)

## Build & Test Configuration

### Maven (pom.xml)

**Backend-Core & Backend-BFF:**
- No test plugin configuration (implies tests disabled or skip-by-default)
- Dependencies section has NO spring-boot-starter-test
- No JUnit 5 or TestNG configured

**To enable tests:**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

### NPM (ui/package.json)

- No test script defined (no "test" key in scripts)
- No vitest, jest, or playwright-test in dependencies
- No devDependencies for testing

**To add E2E tests:**
```json
{
  "devDependencies": {
    "@playwright/test": "^1.50.0",
    "vitest": "^2.1.0"
  }
}
```

## Automated Checks (CI/CD)

### GitHub Actions (.github/workflows/ci.yml)

**Current pipeline (if exists):**
- Likely triggers on: push to main/develop, pull requests
- Typical steps: checkout → setup Java → build → test → docker build
- Docker push (if master branch)

**Note:** Check `ci.yml` for actual configuration; may include:
- Maven clean install
- Docker Compose up (integration test environment)
- Smoke tests (health checks)
- Security scans (SAST, dependency check)

## Manual Testing Approach

Since no automated tests, testing appears to be manual:

### Backend Testing

1. **cURL / Postman**
   - Test approval workflow: POST /api/dataset → ApprovalService.submitApproval()
   - Test data operations: POST /api/dataset → various service methods
   - Test external integrations: /api/bff/identity/*, /api/bff/messages, etc.

2. **Browser DevTools**
   - Network tab: inspect requests/responses
   - Console: check for JavaScript errors
   - Application tab: verify token storage (localStorage)

3. **Docker Logs**
   ```bash
   docker compose logs backend-core
   docker compose logs backend-bff
   ```
   - Check for exceptions, slow queries, auth failures

### Frontend Testing

1. **Dev Server (Vite)**
   - `npm run dev` on localhost:25174
   - Manual user flows (login → approve → submit worklog, etc.)
   - Test responsive design (mobile, tablet, desktop)

2. **Browser DevTools**
   - Vue DevTools (Pinia store inspection)
   - Network tab: verify token refresh, SSE stream
   - Console: JavaScript errors, deprecation warnings

3. **Cross-Browser**
   - Chrome, Firefox, Safari, Edge (manual)

## Load Testing

### Performance Scan Script

**File:** `/scripts/perf-scan.sh`

Likely uses:
- Apache JMeter (command-line)
- wrk (HTTP benchmarking)
- ghc (Go HTTP checker)

**Typical tests:**
- 100 concurrent users
- 5 min sustained load
- Metrics: response time, throughput, error rate
- Target: 1000 req/sec @ p99 <500ms

## Security Testing

### Security Scan Script

**File:** `/scripts/security-scan.sh`

Likely includes:
- OWASP Dependency Check (Maven plugin)
  ```bash
  mvn dependency-check:check
  ```
- SAST tools (SonarQube, Checkmarx, Snyk if CI/CD)
- Manual review: SQL injection (MyBatis parameterization), XSS (Vue sanitization), CSRF (Spring Security)

**Key areas:**
- JWT validation (Keycloak JWKS cert pinning?)
- Password hashing (if DB user authentication used; currently OAuth2 only)
- File upload security (MinIO bucket policy, path traversal)
- HTTP headers (HSTS, CSP, X-Frame-Options)

## Recommended Testing Strategy

### Unit Tests (if to add)

```java
// backend-core/src/test/java/com/platform/v3/core/approval/ApprovalServiceTest.java
@SpringBootTest
public class ApprovalServiceTest {
  @MockBean ApprovalMapper mapper;
  @InjectMocks ApprovalService service;
  
  @Test
  void submitApprovalSuccess() {
    // given
    Map<String, Object> request = new HashMap<>();
    request.put("form_type", "LEAVE");
    
    // when
    service.submitApproval(request);
    
    // then
    verify(mapper).insert(any());
  }
}
```

### Integration Tests

```java
// Spin up real PostgreSQL + Flowable containers
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Testcontainers
public class ApprovalIntegrationTest {
  @Container static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>();
  
  @Test void approvalWorkflow() {
    // Test: submit → approve → workflow completion
  }
}
```

### E2E Tests (Playwright)

```typescript
// ui/e2e/approval.spec.ts
import { test, expect } from '@playwright/test';

test('approval workflow', async ({ page }) => {
  await page.goto('http://localhost:25174/login');
  await page.fill('input[type=text]', 'test1');
  await page.fill('input[type=password]', 'test1');
  await page.click('button[type=submit]');
  
  await page.goto('http://localhost:25174/approval');
  await page.click('text=신규 결재 신청');
  
  // Fill form, submit
  await page.fill('textarea[name=content]', 'Test approval');
  await page.click('button:has-text("제출")');
  
  // Verify submission
  expect(page.url()).toContain('/approval');
});
```

## Test Execution Workflow

```
$ npm run build          # TypeScript check, Vue compile
$ mvn clean install -DskipTests  # Build jars
$ docker compose up -d   # Start infra + services
$ npm run test:e2e       # Playwright tests
$ mvn verify             # Integration tests (if present)
$ ./scripts/perf-scan.sh # Load test
$ ./scripts/security-scan.sh # Security check
```

## Testing Coverage Goals

| Component | Current | Target | Priority |
|-----------|---------|--------|----------|
| backend-core services | 0% | 70% | High (business logic) |
| backend-bff adapters | 0% | 50% | Medium (external deps) |
| ui composables | 0% | 80% | High (reusable logic) |
| e2e user flows | 0% | 40% | Medium (critical paths) |
| security checks | Manual | Automated CI | High |

## Performance Baselines

Expected metrics (no baseline data available):

| Operation | Target | Typical |
|-----------|--------|---------|
| Login (auth flow) | <2s | 1.5s |
| Approval submit | <1s | 0.8s |
| Dashboard load | <3s | 2.0s |
| Calendar query (1 year) | <2s | 1.2s |
| Board post list (paginated) | <1s | 0.6s |
| File upload (10 MB) | <5s | 3s |

## Test Artifacts

- **Log files:** docker-compose logs → /tmp/*.log (retention: 7 days)
- **Test reports:** Maven Surefire (target/surefire-reports/) — if tests enabled
- **Performance results:** perf-scan.sh output → results/ (JSON, CSV)
- **Security scan:** dependency-check report → target/dependency-check-report.html

**Test Infrastructure Status:** Minimal; automated testing recommended for production deployments
