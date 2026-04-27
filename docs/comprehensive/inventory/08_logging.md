# Logging & Observability Inventory

**Logging Architecture:** Spring Boot Logback (backend) + Axios interceptor (frontend) + ELK-style (Loki/Grafana)

## Backend Logging Configuration

### Logback Setup (Spring Boot default)

**File:** `src/main/resources/logback-spring.xml` (if custom config exists)

Expected configuration:
```xml
<configuration>
  <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>logs/application.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
      <fileNamePattern>logs/application.%d{yyyy-MM-dd}.%i.log.gz</fileNamePattern>
      <maxHistory>30</maxHistory>
      <maxFileSize>100MB</maxFileSize>
    </rollingPolicy>
    <encoder>
      <pattern>%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n</pattern>
    </encoder>
  </appender>

  <root level="INFO">
    <appender-ref ref="FILE"/>
    <appender-ref ref="CONSOLE"/>
  </root>

  <!-- Backend-Core specific -->
  <logger name="com.platform.v3.core" level="DEBUG"/>
  <logger name="org.springframework.security" level="INFO"/>
  <logger name="org.flowable" level="INFO"/>
  <logger name="org.mybatis" level="DEBUG"/>

  <!-- Backend-BFF specific -->
  <logger name="com.platform.v3.bff" level="DEBUG"/>
  <logger name="org.springframework.web.reactive.function.client.ExchangeFunctions" level="DEBUG"/>
</configuration>
```

### Log Levels (application.yml)

**Backend-Core:**
```yaml
logging:
  level:
    com.platform.v3: DEBUG
    org.springframework.security: INFO
    org.mybatis: DEBUG
    org.flowable: INFO
```

**Backend-BFF:**
```yaml
logging:
  level:
    com.platform.v3.bff: DEBUG
    org.springframework.web.reactive: DEBUG
```

### Structured Logging

**Pattern (Logback encoder):**
```
%d{ISO8601} [%thread] %-5level %logger{36} [%X{userId},%X{requestId}] - %msg%n
```

**MDC (Mapped Diagnostic Context) Integration:**
```java
// AdminAuditAspect.java — audit logging with context
MDC.put("userId", auth.getName());
MDC.put("action", "CREATE_APPROVAL");
MDC.put("timestamp", System.currentTimeMillis());
log.info("Audit log entry");
MDC.clear();
```

### Log Output

- **Console:** Docker logs (stdout/stderr)
- **File:** /app/logs/application.log (inside container)
- **Aggregation:** Promtail → Loki (from Docker container logs)

## Frontend Logging (Axios Interceptor)

**File:** `/ui/src/api/interceptor.ts` (lines 1-80)

### Request Interceptor

```typescript
axios.interceptors.request.use((config) => {
  const auth = useAuthStore();
  const kc = getKeycloak();
  const token = kc?.token || auth.accessToken;
  
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  
  // Request context
  const locale = localStorage.getItem('locale') || 'ko';
  config.headers['X-Locale'] = locale;
  config.headers['X-Request-ID'] = generateUUID(); // Optional tracing
  config.headers['Accept-Language'] = locale;
  
  // Console log (dev only)
  if (import.meta.env.DEV) {
    console.log(`[${new Date().toISOString()}] ${config.method.toUpperCase()} ${config.url}`);
  }
  
  return config;
});
```

### Response Interceptor (Error Logging)

```typescript
axios.interceptors.response.use(
  (r) => { consecutiveFailCount = 0; return r; },
  async (error: AxiosError) => {
    const url = error.config?.url || 'unknown';
    const status = error.response?.status || 0;
    
    // Log errors
    console.error(`[${new Date().toISOString()}] Error: ${status} ${url}`, error.response?.data);
    
    // On 401: token refresh + retry
    if (error.response?.status === 401) {
      // Attempt refresh (see lines 55-60)
    }
    
    // On 5xx: retry with exponential backoff (see lines 62-75)
    
    // Track consecutive failures
    if (!isRetryable(error)) {
      consecutiveFailCount++;
      if (consecutiveFailCount >= CONSECUTIVE_FAIL_THRESHOLD) {
        console.error('Too many failures, redirecting to login');
        await redirectToLogin(router);
      }
    }
    
    return Promise.reject(error);
  }
);
```

## Tracing & Context Propagation

### Request ID Tracing

**Pattern:** Generate UUID per request, propagate through layers

```java
// Backend-Core — SseTokenFilter (if added)
String requestId = request.getHeader("X-Request-ID");
if (requestId == null) {
  requestId = UUID.randomUUID().toString();
}
MDC.put("requestId", requestId);
response.setHeader("X-Request-ID", requestId);
// Filter chain continues
```

### Distributed Tracing (Optional)

If Jaeger or Zipkin integrated:
```yaml
spring:
  zipkin:
    base-url: http://localhost:9411
  sleuth:
    sampler:
      probability: 1.0  # 100% sampling (high volume; reduce in prod)
```

**Span Propagation:**
- Trace ID: Follow request from UI → BFF → Backend-Core → External Services
- Span ID: Track individual operation (e.g., ApprovalService.submitApproval)
- Parent-Child relationship: UI request spawns multiple backend operations

## Metrics & Monitoring

### Spring Boot Actuator (Backend-Core & Backend-BFF)

**Endpoints (exposed in application.yml):**
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  metrics:
    tags:
      application: openplatform-v3-backend-core
```

**Available metrics:**
- `/actuator/health` - Liveness (status: UP/DOWN)
- `/actuator/info` - App info (version, build time)
- `/actuator/metrics` - Metric names (JSON)
- `/actuator/prometheus` - Prometheus-format export

**Custom metrics (example):**
```java
@Service
public class ApprovalService {
  private final MeterRegistry meterRegistry;
  
  public void submitApproval(Map<String, Object> data) {
    Timer.Sample sample = Timer.start(meterRegistry);
    try {
      // Business logic
      sample.stop(Timer.builder("approval.submit.time")
        .tag("status", "success")
        .register(meterRegistry));
    } catch (Exception e) {
      sample.stop(Timer.builder("approval.submit.time")
        .tag("status", "error")
        .register(meterRegistry));
    }
  }
}
```

### Prometheus Scraping

**Config (/infra/prometheus/prometheus.yml):**
```yaml
scrape_configs:
  - job_name: 'backend-core'
    static_configs:
      - targets: ['backend-core:19090']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 15s
    
  - job_name: 'backend-bff'
    static_configs:
      - targets: ['backend-bff:19091']
    metrics_path: '/actuator/prometheus'
```

**Key metrics exposed:**
- `jvm_memory_used_bytes` - JVM heap/non-heap memory
- `jvm_threads_live_threads` - Active threads
- `http_server_requests_seconds` - REST endpoint latency (by method, path, status)
- `db_postgresql_connections_active` - DB connection pool status
- `cache_gets_hit` - Cache hit rate (if Redis metrics enabled)
- `flowable_process_instances_total` - Workflow stats

### Grafana Dashboards

**Location:** `/infra/grafana/provisioning/` (auto-loaded)

Typical dashboard panels:
1. **Request Rate** - req/sec over time
2. **Response Time** - p50, p95, p99 latency
3. **Error Rate** - 4xx, 5xx count
4. **Database Connections** - pool utilization
5. **JVM Memory** - heap usage, GC pauses
6. **Approval Workflow** - submissions, approvals, rejections per day
7. **Cache Performance** - hit/miss ratio, evictions
8. **System Uptime** - service availability (99.9%)

## Log Aggregation (Loki)

**Architecture:**
```
┌───────────────────┐
│   Docker Logs     │ (stdout/stderr from containers)
│ (all services)    │
└────────┬──────────┘
         │ (Promtail)
         ▼
┌───────────────────┐
│    Loki (logs)    │ (indexed by job, container, namespace)
└────────┬──────────┘
         │ (queries)
         ▼
┌───────────────────┐
│  Grafana (UI)     │ (Loki datasource: Search logs by label)
└───────────────────┘
```

**Promtail Config (/infra/loki/promtail-config.yml):**
```yaml
clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: docker
    docker: {}
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        target_label: container
      - source_labels: ['__meta_docker_container_label_com_docker_compose_service']
        target_label: service
```

**Example Loki query (Grafana explore):**
```logql
{service="backend-core"} | json | level="ERROR"
```

Returns all ERROR logs from backend-core in real-time.

## Alert Rules (Prometheus + AlertManager)

**Example alert (if configured):**
```yaml
groups:
  - name: application.rules
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_server_requests_seconds_count{status=~"5.."}[5m]) > 0.05
        for: 5m
        annotations:
          summary: "High error rate detected ({{ $value }})"
          
      - alert: DBConnectionPoolExhausted
        expr: db_postgresql_connections_active / db_postgresql_connections_max > 0.9
        for: 10m
        annotations:
          summary: "DB connection pool >90% utilization"
```

**Notification channels:** Email, Slack, PagerDuty (configurable)

## Performance Baselines

**Expected log volume:**
- Development: ~5 MB/day (DEBUG logs)
- Production: ~50 MB/day (INFO level)
- Retention: 30 days (configurable via Loki/logrotate)

**Query latency (Grafana):**
- Simple query (single service, 1 hour): <1s
- Complex query (join 5 services, 7 days): <5s

## Common Log Patterns & Troubleshooting

### Approval Workflow

```log
2026-04-27 10:15:30 [approval-service] DEBUG [userId=test1, action=SUBMIT_APPROVAL] - Submitting approval: type=LEAVE
2026-04-27 10:15:31 [flowable-engine] DEBUG [processId=approval_leave_001] - Process started
2026-04-27 10:15:32 [approval-service] DEBUG [userId=test1] - Approval notification sent to dept manager
2026-04-27 10:16:00 [approval-service] DEBUG [userId=admin, action=APPROVE_APPROVAL] - Approving: request_id=12345
2026-04-27 10:16:01 [flowable-engine] DEBUG [processId=approval_leave_001] - Task completed
2026-04-27 10:16:02 [notification-service] DEBUG [recipient=test1] - Leave approved notification sent
```

### Authentication Errors

```log
2026-04-27 11:00:15 [security] WARN [userId=unknown, endpoint=/api/approval] - JWT validation failed: Signature verification failed
2026-04-27 11:00:15 [security] DEBUG - Expected issuer: http://keycloak:8080/realms/openplatform-v3
2026-04-27 11:00:15 [bff] DEBUG [adapter=KeycloakIdentityAdapter] - Admin token refresh initiated
2026-04-27 11:00:16 [bff] DEBUG - New admin token issued: exp=2026-04-27T12:00:16Z
```

### Database Connection Issues

```log
2026-04-27 12:30:45 [db-pool] WARN - HikariPool: Connection is not available, request timed out after 30000ms
2026-04-27 12:30:45 [approval-service] ERROR - Failed to submit approval: Unable to acquire JDBC Connection
2026-04-27 12:30:46 [db-pool] DEBUG - Connection pool exhausted: active=20, idle=0, pending=5
```

**Remediation:** Check DB slow queries, increase pool size in application.yml

## Best Practices for Operations

1. **Log Rotation:** Enable in Logback (daily, max 100 MB per file)
2. **Sensitive Data:** Mask PII in logs (email, phone, SSN)
3. **Error Budget:** Allow for 0.1% error rate (99.9% availability SLO)
4. **Alert Fatigue:** Tune thresholds to reduce false positives
5. **On-Call:** Configure escalation for critical alerts
6. **Retention:** Archive old logs to S3 for compliance

**Approx log size in prod:** ~1.5 GB/month
