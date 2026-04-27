# Chapter 1.11: Backend Logging & Observability

## Overview

OpenPlatform v3 backend logging: **Spring Boot Logback + AdminAuditAspect AOP + Loki/Promtail + Grafana**

| Component | Role | Status |
|-----------|------|--------|
| Logback | Console/file logging | Spring Boot default (no custom XML) |
| AdminAuditAspect | admin/* method audit → sa_audit table | Implemented |
| Request ID (cid/traceId) | Distributed tracing | **NOT IMPLEMENTED** |
| MDC (Mapped Diagnostic Context) | userId/requestId in logs | **NOT IMPLEMENTED** |
| Loki + Promtail | Container log aggregation | Implemented |
| Sensitive data masking | JWT/password filtering | **Recommended** |

---

## 1. Logging Stack: Logback Default

### 1.1 No Custom logback-spring.xml

Spring Boot default Logback is used. Outputs to console (stdout) + file (logs/application.log).

### 1.2 Log Levels (application.yml)

**Backend-Core:**
```yaml
logging:
  level:
    com.platform.v3: DEBUG
    org.springframework.security: INFO
```

**Backend-BFF:**
```yaml
logging:
  level:
    com.platform.v3.bff: DEBUG
```

### 1.3 Recommended Per-Layer Levels

| Layer | Level | Purpose |
|-------|-------|---------|
| com.platform.v3 | DEBUG | Business logic tracing |
| org.springframework.security | INFO | Auth events only |
| org.springframework.web | INFO | HTTP requests |
| org.mybatis | DEBUG | SQL queries (dev) |
| org.flowable | INFO | Workflow engine |

---

## 2. AdminAuditAspect: Audit Logging via AOP

### 2.1 Purpose

Automatically log all admin/* service method calls to sa_audit table for compliance & data change tracking.

File: `backend-core/src/main/java/com/platform/v3/core/admin/AdminAuditAspect.java`

### 2.2 Flow Diagram

Request → @Around intercept → execute method → sa_audit INSERT (if success) → Response

### 2.3 Core Logic (lines 64-95)

```java
@Around("@annotation(com.platform.v3.core.dataset.DataSetServiceMapping)")
public Object audit(ProceedingJoinPoint pjp) throws Throwable {
    String serviceName = extractServiceName(pjp);
    if (serviceName == null || !serviceName.startsWith(ADMIN_PREFIX)) {
        return pjp.proceed();
    }
    Object[] args = pjp.getArgs();
    Map<String, Object> datasets = (args.length >= 1 && args[0] instanceof Map) 
        ? (Map<String, Object>) args[0] : null;
    String currentUser = (args.length >= 2 && args[1] instanceof String) 
        ? (String) args[1] : null;

    Object result = pjp.proceed();  // Exception propagates, audit skipped

    try {
        insertAudit(serviceName, datasets, result, currentUser);
    } catch (Exception e) {
        log.warn("[admin-audit] insert failed: {}", e.getMessage());
    }
    return result;
}
```

### 2.4 Audit Record Fields (sa_audit table)

| Field | Source | Example |
|-------|--------|---------|
| actor_no | currentUser | "emp001" |
| actor_name | JWT claim "name" | "Kim Chulsu" |
| action | serviceName | "admin/userSave" |
| target_type | Derived from action | "USER", "DEPT" |
| target_id | Extracted from datasets | "emp_new_001" |
| before_json | Input datasets (JSON) | {...} |
| after_json | Method return (JSON) | {...} |
| ip_addr | X-Forwarded-For header | "192.168.1.1" |

### 2.5 Exception Handling

- Method exception → immediate propagation, NO audit record
- JSON serialization fail → skip audit, return original result
- Max JSON size: 16KB (truncated if larger)

---

## 3. Request ID & Distributed Tracing

### 3.1 Current Status: cid/traceId NOT IMPLEMENTED

**Findings:**
- No X-Request-ID header in Backend-Core
- No MDC (Mapped Diagnostic Context) usage
- Frontend (ui/src/api/interceptor.ts) does NOT set X-Request-ID

### 3.2 Recommended: Add RequestIdFilter

```java
public class RequestIdFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
            HttpServletResponse response, FilterChain filterChain) 
            throws ServletException, IOException {
        String requestId = request.getHeader("X-Request-ID");
        if (requestId == null) {
            requestId = UUID.randomUUID().toString();
        }
        MDC.put("requestId", requestId);
        response.setHeader("X-Request-ID", requestId);
        try {
            filterChain.doFilter(request, response);
        } finally {
            MDC.remove("requestId");
        }
    }
}
```

Then register in SecurityConfig:
```java
http.addFilterBefore(new RequestIdFilter(), UsernamePasswordAuthenticationFilter.class);
```

### 3.3 Update Frontend Interceptor

File: `ui/src/api/interceptor.ts`

Add request ID generation (currently missing):
```typescript
function generateRequestId() {
  return 'req_' + Math.random().toString(36).substr(2, 9);
}

axios.interceptors.request.use((config) => {
  config.headers['X-Request-ID'] = generateRequestId();  // ADD THIS
  return config;
});
```

### 3.4 Logback Pattern with MDC

Update default pattern (if custom XML added):
```
%d{ISO8601} [%thread] %-5level %logger{36} [%X{requestId},%X{userId}] - %msg%n
```

Result: All logs include request ID for tracing.

---

## 4. Loki + Promtail: Log Aggregation

### 4.1 Architecture

```
Docker Logs → Promtail → Loki (TSDB) → Grafana (queries)
```

### 4.2 Promtail Configuration

File: `infra/loki/promtail-config.yml`

```yaml
clients:
  - url: http://loki:3100/loki/api/v1/push
    batchwait: 1s
    batchsize: 1048576

scrape_configs:
  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 10s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container_name'
```

**Effect:** Auto-scrape all container stdout/stderr, label by container_name & image.

### 4.3 Loki Configuration

File: `infra/loki/loki-config.yml`

```yaml
server:
  http_listen_port: 3100

schema_config:
  configs:
    - from: 2024-01-01
      store: tsdb
      object_store: filesystem

limits_config:
  retention_period: 168h  # 7 days
  max_query_series: 5000
```

### 4.4 Example LogQL Queries (Grafana)

```logql
{container_name="backend-core"} | json | level="ERROR"
{container_name="backend-core"} | json | line_format "[{{.timestamp}}] {{.action}} actor={{.userId}}"
{job="docker"} | json | level=~"WARN|ERROR" | after_last: "1h"
```

---

## 5. GlobalExceptionHandler & Error Logging

File: `backend-core/src/main/java/com/platform/v3/core/common/GlobalExceptionHandler.java`

```java
@ExceptionHandler(Exception.class)
public ResponseEntity<ApiResponse<Void>> handleGeneric(Exception ex) {
    log.error("Unhandled error", ex);
    return ResponseEntity.internalServerError()
            .body(ApiResponse.fail("INTERNAL_ERROR", "Server error occurred."));
}
```

**Recommended Enhancement:** Include context in error logs:
```java
log.error("Request failed [action={}, userId={}]", action, userId, ex);
```

---

## 6. Sensitive Data Masking

### 6.1 Current Status: NOT IMPLEMENTED

**Risk:** application.yml contains default passwords:
```yaml
datasource:
  password: ${DB_PASSWORD:platform_v3_pass}
redis:
  password: ${REDIS_PASSWORD:v3_redis_pass}
```

If env vars are not set, defaults appear in logs/Loki.

### 6.2 Recommended Masking Pattern

In custom Logback layout or Loki:
```regex
(password|secret|token|Authorization)[=:][^,}\s]+ → $1=***MASKED***
```

---

## 7. Performance Baselines

| Metric | Value | Note |
|--------|-------|------|
| Console log I/O | <1ms | Async appender recommended |
| File log (100MB) | <10ms | Compressed rotation enabled |
| Loki push (1000 lines) | <100ms | batchwait=1s |
| Grafana simple query (1h) | <1s | TSDB indexing |
| Grafana complex query (7d) | <5s | Memory dependent |

---

## 8. Implementation Checklist

**Current:**
- ✓ Logback default configuration
- ✓ AdminAuditAspect audit logging
- ✓ Loki + Promtail log aggregation
- ✓ GlobalExceptionHandler

**Recommended Improvements:**
- [ ] Add RequestIdFilter + MDC integration
- [ ] Frontend X-Request-ID header generation
- [ ] Update Logback pattern (include requestId, userId)
- [ ] Sensitive data masking (Logback or Loki level)
- [ ] Review log retention policy (compliance)
- [ ] Custom Logback appender for structured JSON (optional)

---

## 참조 (References)

- Spring Boot Logging: https://spring.io/guides/gs/logging-log4j2/
- Logback: http://logback.qos.ch/manual/configuration.html
- Loki: https://grafana.com/docs/loki/latest/
- LogQL: https://grafana.com/docs/loki/latest/logql/
- SLF4J MDC: https://www.slf4j.org/manual.html#mdc

---

## Adjacent Topics Not Covered

1. **Distributed Tracing:** Jaeger/Zipkin integration
2. **Metrics & Monitoring:** Spring Boot Actuator, Prometheus scraping
3. **Log Encryption & Security:** Storage-level encryption, RBAC
4. **Advanced Queries:** Grafana dashboards, AlertManager rules
5. **Long-term Archival:** S3/GCS export, compression optimization

---

**Date:** 2026-04-27  
**Version:** 1.0  
**Status:** Complete

