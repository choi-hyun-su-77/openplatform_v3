# Operations & Infrastructure Inventory

**Root Location:** `/infra/`, `/scripts/`, root `docker-compose.yml`, `start.sh`, `stop.sh`

## Docker Compose Orchestration (8 files)

All files in `/infra/` and root, composed via:
```bash
docker compose -f docker-compose.yml \
               -f infra/docker-compose.yml \
               -f infra/docker-compose.resources.yml \
               -f infra/docker-compose.healthcheck.yml \
               -f infra/docker-compose.traefik.yml \
               -f infra/docker-compose.observability.yml \
               -f infra/docker-compose.cron.yml
```

### 1. Root `docker-compose.yml`

**Services (minimal bootstrap):**
- Likely just version & anchors; actual services in infra/ files

### 2. `infra/docker-compose.yml` (Main services)

| Service | Image | Port | Health Check | Purpose |
|---------|-------|------|--------------|---------|
| db | postgres:15 | 19432 | pg_isready | PostgreSQL (platform_v3 + flowable_v3 schemas) |
| redis | redis:7 | 19379 | PING | Cache, sessions, rate-limiting |
| keycloak | keycloak/keycloak:latest | 19281 | /auth/health | OAuth2/OIDC identity provider |
| rocketchat | rocketchat:latest | 19065 | /api/v1/info | Team messaging (RocketChat) |
| stalwart | stalwart-mail:latest | 19480 | /admin/server/info | Email server (SMTP, IMAP) |
| livekit | livekit/livekit-server:latest | 19880 | /status | WebRTC video conferencing |
| minio | minio/minio:latest | 19900 | /minio/health/live | S3-compatible file storage |
| wikijs | requarks/wiki:latest | 19001 | /favicon.ico | Wiki knowledge base |
| backend-core | openplatform-v3-backend-core:latest | 19090 | /actuator/health | Business logic microservice |
| backend-bff | openplatform-v3-backend-bff:latest | 19091 | /actuator/health | API gateway / federation layer |
| ui | openplatform-v3-ui:nginx | 19173 | / (200 OK) | Vue 3 SPA (nginx reverse proxy) |

**Network:**
- Default bridge (platform-network or implicit)
- Services reach each other via hostname (e.g., http://backend-bff:19091)

**Volumes:**
- db: `/var/lib/postgresql/data` → `platform-db-data` volume
- redis: `/data` → optional (ephemeral if omitted)
- keycloak: `/opt/keycloak/data` → `keycloak-data` volume
- rocketchat: `/app/uploads` → `rocketchat-data` volume
- minio: `/minio/data` → `minio-data` volume
- wikijs: `/var/lib/wiki` → `wikijs-data` volume

**Environment Variables (sample):**
```env
DB_HOST=db
DB_PORT=19432
DB_USER=platform_v3
DB_PASSWORD=platform_v3_pass
DB_NAME=platform_v3

REDIS_HOST=redis
REDIS_PASSWORD=v3_redis_pass

KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin

ROCKETCHAT_ADMIN_TOKEN=${ROCKETCHAT_ADMIN_TOKEN}
STALWART_ADMIN_USER=admin
STALWART_ADMIN_PASS=admin

LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=devsecret_v3_changeme_32chars_minimum

MINIO_ACCESS_KEY=v3minio
MINIO_SECRET_KEY=v3minio_pass

WIKIJS_API_TOKEN=${WIKIJS_API_TOKEN}
```

### 3. `infra/docker-compose.resources.yml`

**Resource Limits:**
```yaml
services:
  backend-core:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
  backend-bff:
    # Similar limits
  ui:
    # Minimal (nginx)
```

**Justification:** Prevent memory/CPU runaway; protect host system

### 4. `infra/docker-compose.healthcheck.yml`

**Liveness & Readiness Probes:**
```yaml
services:
  backend-core:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:19090/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

Kubernetes-style checks (can be used by orchestrators like Docker Swarm, K8s)

### 5. `infra/docker-compose.traefik.yml`

**Reverse Proxy Configuration:**

| Service | Traefik Route | Domain | Scheme |
|---------|---------------|--------|--------|
| keycloak | `Host(keycloak.localhost)` | http://keycloak.localhost | HTTP |
| rocketchat | `Host(chat.localhost)` | http://chat.localhost | HTTP |
| minio | `Host(minio.localhost)` | http://minio.localhost | HTTP |
| wikijs | `Host(wiki.localhost)` | http://wiki.localhost | HTTP |
| livekit | `Host(video.localhost)` | ws://video.localhost | WS |
| backend-api | `Host(api.localhost)` | http://api.localhost/api | HTTP |
| ui | `Host(localhost)` | http://localhost | HTTP |

**Traefik Config Files:**
- `/infra/traefik/traefik.yml` - Global config (API, provider, entrypoints)
- `/infra/traefik/dynamic.yml` - Dynamic routing (routers, middlewares, services)

**Example middleware (dynamic.yml):**
```yaml
http:
  middlewares:
    auth-jwt:
      headers:
        customRequestHeaders:
          Authorization: "Bearer token"
    cors:
      headers:
        accessControlAllowMethods:
          - GET
          - POST
          - OPTIONS
```

### 6. `infra/docker-compose.observability.yml`

**Monitoring Stack:**

| Service | Port | Purpose |
|---------|------|---------|
| prometheus | 19090 | Metrics scraping (backend-core, backend-bff `/actuator/prometheus`) |
| loki | 3100 | Log aggregation (JSON stdin from containers) |
| grafana | 3000 | Dashboards & alerts (Prometheus + Loki datasources) |

**Prometheus Config (/infra/prometheus/prometheus.yml):**
```yaml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'backend-core'
    static_configs:
      - targets: ['backend-core:19090']
    metrics_path: '/actuator/prometheus'
  - job_name: 'backend-bff'
    static_configs:
      - targets: ['backend-bff:19091']
    metrics_path: '/actuator/prometheus'
```

**Loki Config (/infra/loki/loki-config.yml):**
```yaml
auth_enabled: false
ingester:
  chunk_idle_period: 3m
  max_chunk_age: 1h
```

**Promtail Config (/infra/loki/promtail-config.yml):**
```yaml
clients:
  - url: http://loki:3100/loki/api/v1/push
scrape_configs:
  - job_name: docker
    docker: {}
```

**Grafana Datasources (/infra/grafana/provisioning/datasources/loki-prom.yml):**
```yaml
datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus:9090
  - name: Loki
    type: loki
    url: http://loki:3100
```

### 7. `infra/docker-compose.cron.yml`

**Scheduled Jobs:**

| Job | Schedule | Container | Command | Purpose |
|-----|----------|-----------|---------|---------|
| backup | 02:00 daily | postgres | pg_dump | Database backup |
| rotate-logs | 00:00 daily | syslog | logrotate | Log archival |
| cache-warm | 08:00 daily | redis | FLUSHDB + warm | Cache eviction |
| report-gen | 23:00 daily | backend-core | POST /api/dataset (worklog aggregation) | Team report |

Implemented via:
- `mcuadros/ofelia` (job scheduler) OR
- Kubernetes CronJob / systemd timer (production)

### 8. External Config Files

**Keycloak Realm Export (`/infra/keycloak/openplatform-v3-realm.json`):**
- Realm: openplatform-v3
- Users: admin, test1, test2 (imported from LDAP or hardcoded)
- Clients: openplatform-v3-ui (public), openplatform-v3-api (confidential)
- LDAP Federation: users.ldif (optional LDAP server)

**LDAP Users (`/infra/ldap/users.ldif`):**
```ldif
dn: cn=test1,ou=users,dc=example,dc=com
cn: test1
uid: test1
userPassword: {SSHA}...
```

**Stalwart Mail Config (`/infra/stalwart-config.toml`):**
```toml
[server.listener."smtp"]
protocol = "smtp"
port = 25
max_clients = 100

[directory.ldap]
url = "ldap://ldap:389"
```

**LiveKit Config (`/infra/livekit.yaml`):**
```yaml
port: 7880
bind_addresses:
  - "0.0.0.0"
keys:
  devkey: devsecret_v3_changeme_32chars_minimum
```

**Wiki.js Keycloak Config (`/infra/wiki-keycloak-config.json`):**
```json
{
  "strategy": "oauth2",
  "oauth2Endpoint": "http://keycloak:8080/realms/openplatform-v3/protocol/openid-connect/",
  "oauth2ClientId": "wikijs",
  "oauth2ClientSecret": "..."
}
```

## Shell Scripts

### `start.sh` (root)

**Purpose:** One-command startup

```bash
#!/bin/bash
# Bring up all services in order
docker compose -f docker-compose.yml \
               -f infra/docker-compose.yml \
               -f infra/docker-compose.resources.yml \
               -f infra/docker-compose.healthcheck.yml \
               -f infra/docker-compose.traefik.yml \
               -f infra/docker-compose.observability.yml \
               -f infra/docker-compose.cron.yml \
               up -d

# Wait for services
sleep 30
echo "Services starting. Check: http://localhost:19173 (UI)"
```

### `stop.sh` (root)

**Purpose:** Clean shutdown

```bash
#!/bin/bash
docker compose -f docker-compose.yml \
               -f infra/docker-compose.yml \
               ... down

# Optional: preserve volumes or remove them
# docker compose down -v  # Remove volumes
```

### `/scripts/backup.sh`

**Purpose:** PostgreSQL backup

```bash
#!/bin/bash
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

docker compose exec -T db pg_dump -U platform_v3 platform_v3 \
  > "$BACKUP_DIR/platform_v3_backup_$TIMESTAMP.sql"

gzip "$BACKUP_DIR/platform_v3_backup_$TIMESTAMP.sql"
```

### `/scripts/restore.sh`

**Purpose:** PostgreSQL restore from backup

```bash
#!/bin/bash
BACKUP_FILE=$1

docker compose exec -T db psql -U platform_v3 platform_v3 \
  < <(gunzip -c "$BACKUP_FILE")
```

### `/scripts/perf-scan.sh`

**Purpose:** Load testing

Likely uses JMeter or wrk:
```bash
#!/bin/bash
# Load test: 100 concurrent users, 5 min
wrk -t 4 -c 100 -d 5m http://localhost:19173/dashboard
```

### `/scripts/security-scan.sh`

**Purpose:** Vulnerability scanning

```bash
#!/bin/bash
# OWASP dependency check
mvn dependency-check:check

# SonarQube (if configured)
sonar-scanner -Dsonar.projectKey=openplatform-v3
```

## Database Initialization

### Init SQL (`/infra/init-sql/01-schema.sql`)

Runs automatically on first docker compose up:
```sql
CREATE SCHEMA IF NOT EXISTS platform_v3;
CREATE SCHEMA IF NOT EXISTS flowable_v3;

-- Flyway auto-migration from V1 onwards
```

## Ports Map (Quick Reference)

| Service | Port | URL |
|---------|------|-----|
| PostgreSQL | 19432 | jdbc:postgresql://localhost:19432/platform_v3 |
| Redis | 19379 | redis://localhost:19379 |
| Keycloak | 19281 | http://localhost:19281 |
| RocketChat | 19065 | http://localhost:19065 |
| Stalwart | 19480 | http://localhost:19480 |
| LiveKit | 19880 | ws://localhost:19880 |
| MinIO | 19900 | http://localhost:19900 |
| Wiki.js | 19001 | http://localhost:19001 |
| Backend-Core | 19090 | http://localhost:19090/api |
| Backend-BFF | 19091 | http://localhost:19091/api/bff |
| UI (Nginx) | 19173 | http://localhost:19173 |
| Prometheus | 9090 | http://localhost:9090 |
| Grafana | 3000 | http://localhost:3000 |
| Loki | 3100 | http://localhost:3100 |
| Traefik | 8080 | http://localhost:8080 (dashboard) |

## Deployment Modes

### Development

- `docker compose up -d` (all-in-one)
- Volumes mount source code (hot-reload for UI)
- Logging: docker logs (stdout)

### Staging / Production

- Kubernetes (Helm charts, if available)
- Or Docker Swarm with constraints
- External DB (managed PostgreSQL)
- Separate caches (managed Redis)
- CDN for static assets
- Load balancer (Nginx, HAProxy) in front
- SSL/TLS (Let's Encrypt certificates)

**Approx size:** ~2.5 MB (docker-compose YAML files + scripts)
