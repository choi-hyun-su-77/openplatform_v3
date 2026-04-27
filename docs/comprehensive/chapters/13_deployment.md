# Chapter 1.13: Deployment & Infrastructure

## Overview

OpenPlatform v3 의 배포는 **단일 노드(single-host) Docker Compose** 모델을 채택한다. 11~12 개의 컨테이너를 6 개의 override 파일로 합성하며, Traefik 리버스 프록시·Loki/Prometheus/Grafana 관측 스택·Ofelia 크론·healthcheck·리소스 제한이 모두 compose layer 로 분리된다. Active-Active HA / Kubernetes 전환은 향후 과제로 남아 있다 (Chapter 1.3 참조).

| 항목 | 현재 (2026-04) | 향후 |
|---|---|---|
| 호스트 | 단일 노드 docker compose | Swarm / K8s (Helm) |
| 라우팅 | Traefik file-provider (`*.v3.localhost`) | TLS + Let's Encrypt |
| DB | 컨테이너 PostgreSQL (volume) | Managed RDS / patroni HA |
| 인증 | Keycloak `start-dev` (admin/admin) | `start --optimized` + 강한 비밀번호 |
| 백업 | Ofelia + on-demand `backup-runner` | 외부 스토리지 (S3, restic) |

출처: `infra/docker-compose.yml`, `scripts/start.sh`, `infra/traefik/dynamic.yml`, `docs/comprehensive/inventory/07_ops.md`.

---

## 1. Compose 다층 구성 (6 layer)

| 파일 | 책임 |
|---|---|
| `infra/docker-compose.yml` | base — 11 서비스, 네트워크, 볼륨, env (라인 1~350) |
| `infra/docker-compose.healthcheck.yml` | 모든 컨테이너의 healthcheck (라인 1~89) |
| `infra/docker-compose.resources.yml` | `mem_limit` / `cpus` 캡 (라인 1~43) |
| `infra/docker-compose.observability.yml` | Loki / Promtail / Prometheus / Grafana (라인 1~106) |
| `infra/docker-compose.traefik.yml` | Traefik labels (도메인 라우팅, 라인 1~197) |
| `infra/docker-compose.cron.yml` | Ofelia 크론 + on-demand `backup-runner` (라인 1~39) |

`scripts/start.sh` (라인 14~46) 가 모드별 `-f` 조합을 정의:

```bash
BASE="-f infra/docker-compose.yml"
HEALTH="-f infra/docker-compose.healthcheck.yml"
RESOURCES="-f infra/docker-compose.resources.yml"
OBSERVABILITY="-f infra/docker-compose.observability.yml"
TRAEFIK="-f infra/docker-compose.traefik.yml"
CRON="-f infra/docker-compose.cron.yml"
```

| 모드 | 합성 |
|---|---|
| `dev` | BASE |
| `full` (기본) | BASE + HEALTH + RESOURCES |
| `observability` | + OBSERVABILITY |
| `traefik` | + TRAEFIK |
| `production` | 전체 6 파일 |

부수 명령: `status`, `logs <name>`, `init-mongo` (replica set 초기화 — 1 회성), `stop`. 루트의 `start.sh` / `stop.sh` 는 **존재하지 않는다** (Glob 검증). 진입점은 `scripts/start.sh` 단일 파일.

---

## 2. 네트워크

`infra/docker-compose.yml` 라인 3~8 에 두 네트워크 선언:

- **`v3-net`** (`openplatform-v3-net`): 내부 bridge. 11 개 서비스가 join, hostname (예: `postgres`, `redis`, `keycloak`) 으로 통신.
- **`traefik-net`** (external): 루트 워크스페이스 Traefik 스택이 사전 생성. `traefik` 모드 시 ui-frontend / backend-core / backend-bff / keycloak / minio / rocketchat / wikijs / stalwart 가 추가 join. `docker network create traefik-net` 선행 필요.

---

## 3. 컨테이너 인벤토리 (12 개)

| 서비스 (container) | 이미지 | 포트 (host:container) | depends_on |
|---|---|---|---|
| `v3-postgres` | postgres:16-alpine | 19432:5432 | — |
| `v3-redis` | redis:7-alpine | 19379:6379 | — |
| `v3-minio` | minio:RELEASE.2023-11-20 | 19900/19901 | — |
| `v3-keycloak` | quay.io/keycloak/keycloak:24.0 | 19281:8080 | postgres healthy |
| `v3-rocketchat` | rocket.chat:6.13.0 | 19065:3000 | mongo |
| `v3-mongo` | mongo:7.0 | (internal) | — |
| `v3-mongo-init` | mongo:7.0 (profile: init) | — | mongo |
| `v3-wikijs` | ghcr.io/requarks/wiki:2 | 19001:3000 | postgres healthy |
| `v3-openldap` | osixia/openldap:1.5.0 | 19389:389 | — |
| `v3-stalwart` | stalwartlabs/stalwart:latest | 19025/19143/19480 | openldap |
| `v3-livekit` | livekit/livekit-server:v1.9 | 19880/19881/19882-udp | — |
| `v3-backend-core` | build `../backend-core` | 19090:8080 | postgres+redis healthy, keycloak |
| `v3-backend-bff` | build `../backend-bff` | 19091:8080 | keycloak |
| `v3-ui-frontend` | build `../ui` | 19173:80 | backend-core, backend-bff |

영속 볼륨: `v3-postgres-data`, `v3-redis-data`, `v3-minio-data`, `v3-keycloak-data`, `v3-mongo-data`, `v3-wiki-data`, `v3-stalwart-data`, `v3-openldap-data`, `v3-openldap-config`. `mongo-init` 은 `profiles: [init]` 이므로 `start.sh init-mongo` 호출 시만 실행되어 replica set `rs0` 을 초기화 (`infra/docker-compose.yml` 라인 184~197).

### 3.1 단일 SSO 호스트 (`kc.localtest.me`)

Keycloak 이 `KC_HOSTNAME_URL=http://kc.localtest.me:19281` 로 강제되며, 동일 URL 을 모든 다운스트림 (rocketchat, wikijs, minio, backend-core, backend-bff) 이 `extra_hosts: kc.localtest.me:host-gateway` 로 매핑. RFC-public DNS 가 `*.localtest.me → 127.0.0.1` 로 해석하므로 **브라우저와 컨테이너가 동일 origin 사용** → SSO 쿠키 도메인이 일치하여 단일 세션이 모든 페더레이션 앱에서 공유 (`infra/docker-compose.yml` 라인 106~110).

---

## 4. Traefik 라우팅 (`infra/traefik/dynamic.yml`)

| 호스트 | 백엔드 URL | 서비스 |
|---|---|---|
| `portal.v3.localhost` | http://host.docker.internal:25174 | UI (Vite dev) |
| `api.v3.localhost` | http://host.docker.internal:19090 | backend-core |
| `bff.v3.localhost` | http://host.docker.internal:19091 | backend-bff |
| `keycloak.v3.localhost` | http://host.docker.internal:19281 | Keycloak |
| `minio.v3.localhost` | http://host.docker.internal:19901 | MinIO Console |
| `chat.v3.localhost` | http://host.docker.internal:19065 | Rocket.Chat |
| `wiki.v3.localhost` | http://host.docker.internal:19001 | Wiki.js |
| `mail.v3.localhost` | http://host.docker.internal:19480 | Stalwart |

`traefik.yml` (라인 24~27) 은 file provider 가 `dynamic.yml` 을 watch. 대안으로 `infra/docker-compose.traefik.yml` 은 docker-provider 라벨로 동일 매핑을 제공 + 공통 미들웨어 두 개:

- **`op3-gzip`**: gzip 압축
- **`op3-sec-headers`**: HSTS 1 년, `contentTypeNosniff`, `browserXssFilter`, `referrerPolicy=strict-origin-when-cross-origin` (라인 64~70)

MinIO 는 S3 API (9000) 와 Console (9001) 두 개 라우터 분리 (라인 132~146).

---

## 5. 헬스체크

`infra/docker-compose.healthcheck.yml` 이 11 개 서비스에 healthcheck 부여. 이미지마다 도구가 달라 전략이 분기:

| 패턴 | 적용 서비스 | 명령 |
|---|---|---|
| `pg_isready` | postgres (base) | `pg_isready -U platform_v3 -d platform_v3` |
| `redis-cli ping` | redis (base) | `redis-cli -a v3_redis_pass ping` |
| `wget actuator/health` | backend-core / backend-bff | `wget -qO- .../actuator/health \| grep -q UP` |
| `node http.get /api/info` | rocketchat, wikijs | `node -e "...statusCode===200"` |
| `mongosh ping` | mongo | `db.adminCommand('ping').ok` |
| `mc ready local` | minio | `mc ready local` |
| `pgrep` | livekit, openldap | `pgrep livekit-server`, `pgrep slapd` |
| `cat /proc/1/cmdline` | keycloak, stalwart (curl/ps 미포함) | `cat /proc/1/cmdline \| grep -q keycloak` |
| `nginx -t` | ui-frontend | `nginx -t \| grep -q successful` |

`start_period` 차등 (rocketchat 90s, backend-core 60s, livekit 15s). `retries` 는 backend-core/bff 가 가장 보수적인 20 회.

---

## 6. 리소스 제한 (`docker-compose.resources.yml`)

12 개 서비스에 `mem_limit` + `cpus` 캡. 메모리 합 약 9.3 GB, CPU 합 약 17 vCPU (캡일 뿐 실제 사용량은 훨씬 낮음).

| 서비스 | mem | cpus |
|---|---|---|
| postgres | 1 GB | 2.0 |
| keycloak / rocketchat | 1.5 GB | 2.0 |
| backend-core | 1 GB | 2.0 |
| backend-bff / mongo | 768 MB | 1.5 |
| minio / wikijs / stalwart / livekit | 512 MB | 1.0 |
| redis / openldap / ui-frontend | 256 MB | 1.0 |

> 의도: 단일 호스트에서 OOM cascade 방지. 운영 전환 시 backend-core / keycloak 우선 상향 권장.

---

## 7. 크론 작업 (Ofelia)

`infra/docker-compose.cron.yml` 이 두 컨테이너 정의:

### 7.1 `v3-ofelia` (daemon)

`mcuadros/ofelia:latest` 가 `/var/run/docker.sock` (read-only) 마운트로 docker-native cron 수행. TZ `Asia/Seoul`. 라벨로 작업 정의:

```yaml
ofelia.job-exec.backup-postgres.schedule: "0 0 3 * * *"   # 매일 03:00
ofelia.job-exec.backup-postgres.container: "v3-postgres"
ofelia.job-exec.backup-postgres.command: "sh -c 'pg_dumpall -U platform_v3 > /tmp/backup-$(date +%Y%m%d).sql'"
```

> 한계: 백업이 **컨테이너 내부 `/tmp`** 에 저장 (재시작 시 손실). 호스트 볼륨 마운트로 outbound 화 필요.

### 7.2 `v3-backup-runner` (on-demand)

`profiles: [backup]` — `docker compose run --rm backup-runner` 로 단발 호출. alpine + postgresql-client 가 `pg_dumpall` 을 `../backups/dump-YYYYMMDD-HHMMSS.sql` 로 출력 (라인 28~38).

---

## 8. 운영 스크립트

| 스크립트 | 인자 | 핵심 동작 |
|---|---|---|
| `scripts/start.sh` | `dev\|full\|observability\|traefik\|production\|stop\|status\|logs\|init-mongo` | 모드 합성 + `up -d` |
| `scripts/backup.sh` | `[PG_USER=...]` | 6 단계 백업 → `backups/v3-<ts>.tar.gz` |
| `scripts/restore.sh` | `<archive>` | tar 해제 → 6 단계 복원 |
| `scripts/perf-scan.sh` | `[BASE_URL]` | 4 endpoint × 10 회 curl → `reports/perf-<ts>.txt` |
| `scripts/security-scan.sh` | `[BASE_URL]` | npm audit + mvn dep:analyze + trivy/scout + 401 테스트 → `reports/security-<ts>.txt` |

### 8.1 `backup.sh` 6 단계

1. **PostgreSQL** — `docker exec v3-postgres pg_dumpall` → `postgres-dumpall.sql`
2. **MinIO** — `mc mirror` 후 `docker cp` 호스트 추출
3. **Keycloak realm** — `kc.sh export --realm openplatform-v3 --users realm_file` (실행 중 서버에서는 부분 실패 가능)
4. **OpenLDAP** — `ldapsearch -x -D cn=admin,dc=v3,dc=local` → `ldap-dump.ldif`
5. **Rocket.Chat Mongo** — `mongodump --archive --db=rocketchat`
6. **Wiki.js** — sqlite 파일 복사 (postgres 사용 시 1 단계에서 커버)

결과: `backups/v3-<timestamp>.tar.gz` + `backup-<timestamp>.log`. MSYS 경로 변환 회피 위해 `MSYS_NO_PATHCONV=1` 강제.

### 8.2 `restore.sh` 안전장치

- 인자 없으면 사용법 출력 후 exit 1
- backend-core / backend-bff 가 실행 중이면 5 초 경고 후 진행
- 6 단계 복원 후 `docker compose restart v3-keycloak v3-wikijs v3-backend-core v3-backend-bff` 권장

### 8.3 `perf-scan.sh`

측정 대상: `/actuator/health`, `/api/dataset/search?q=public&size=10`, `/api/codes`, `/api/i18n/ko`. 각 10 회 curl, avg/min/max 계산. 기본 BASE_URL `http://localhost:19090`.

### 8.4 `security-scan.sh`

4 단계: (1) ui `npm audit`, (2) backend-core/bff `mvn dependency:analyze`, (3) `trivy` 또는 `docker scout` 으로 minio/keycloak/rocketchat/wikijs 이미지 CVE, (4) 보호 엔드포인트 401 / 공개 200 검증.

---

## 9. 환경 변수

별도 `.env` 파일은 **현재 코드베이스에 없다** (Glob 검증). 모든 비밀이 `infra/docker-compose.yml` 에 평문 인라인.

### 9.1 운영 모드 변경 필수

| 변수 | 현재 값 (개발) | 운영 권장 |
|---|---|---|
| `KEYCLOAK_ADMIN_PASSWORD` | `admin` | 32 자 랜덤 |
| `POSTGRES_PASSWORD` | `platform_v3_pass` | secret manager |
| Redis `requirepass` | `v3_redis_pass` | 강한 패스 |
| `MINIO_ROOT_PASSWORD` | `v3minio_pass` | 강한 패스 |
| `LIVEKIT_API_SECRET` | `devsecret_v3_changeme_32chars_minimum` | 새 32+ 문자 |
| `Accounts_OAuth_Custom_Keycloak_secret` (RC) | `rc_v3_keycloak_secret_2026_long_enough` | 회전 |
| `MINIO_IDENTITY_OPENID_CLIENT_SECRET` | `minio_v3_keycloak_secret_2026_long_enough` | 회전 |
| Keycloak `command` | `start-dev` | `start --optimized` + DB build |
| Grafana `GF_SECURITY_ADMIN_PASSWORD` | `admin` | 강한 패스 |

### 9.2 LiveKit (`infra/livekit.yaml`)

```yaml
port: 19880          # WebSocket signaling
rtc:
  tcp_port: 19881    # TCP fallback
  udp_port: 19882    # UDP media
keys:
  devkey: devsecret_v3_changeme_32chars_minimum
development: true
```

ICE candidate 가 advertise 하는 포트가 컨테이너 내부 포트와 일치해야 NAT 없는 로컬에서 브라우저 도달 가능.

---

## 10. 롤링 배포 (현재 미지원, 권장)

단일 호스트 docker compose 에서는 무중단 롤링 불가. **권장 차선책**:

1. **Blue-Green** — 별도 compose project (`name: openplatform-v3-blue`) 로 신규 버전 기동, smoke test 후 Traefik 라우팅 전환.
2. **App-only restart** — `docker compose up -d --no-deps backend-core backend-bff ui-frontend` 로 인프라 재시작 회피.
3. **DB 마이그레이션 정책** — Flyway 가 backend-core 부팅 시 자동 적용. backward-compatible 만 사용, drop 은 다음 릴리스로 분리.
4. **K8s 전환** — Helm chart + `Deployment` `RollingUpdate` (Chapter 1.3 향후 과제).

---

## 11. DB 초기화

`v3-postgres` 처음 부팅 시 `infra/init-sql/*.sql` 자동 실행 → `platform_v3` / `flowable_v3` / `keycloak_v3` / `wiki_v3` 다중 schema 생성. 이후 스키마 변경은 backend-core 의 Flyway 가 `db/migration/V*.sql` 로 관리 (Chapter 1.9 참조).

---

## 참조

- `infra/docker-compose.yml` (350 라인) — base
- `infra/docker-compose.healthcheck.yml`, `resources.yml`, `observability.yml`, `traefik.yml`, `cron.yml`
- `infra/traefik/traefik.yml`, `infra/traefik/dynamic.yml`
- `infra/livekit.yaml`
- `scripts/start.sh`, `scripts/backup.sh`, `scripts/restore.sh`, `scripts/perf-scan.sh`, `scripts/security-scan.sh`
- `docs/port-allocation.md` — 포트 매핑 (19xxx 대역)
- `docs/comprehensive/inventory/07_ops.md`
- 관련 챕터: 1.3 (Architecture HA), 1.9 (Backend Structure / Flyway), 1.11 (Backend Logging / Loki), 1.12 (Security)

---

## 이 챕터가 다루지 않은 인접 주제

- **TLS 인증서 발급** — Let's Encrypt / mkcert 자동화 (현재 Traefik 은 `web` entrypoint:80 만 노출)
- **CI/CD 파이프라인** — GitHub Actions / Jenkinsfile (현재 코드베이스에 없음)
- **Kubernetes Helm chart** — 향후 작업 (Chapter 1.3 backlog)
- **Secret manager 통합** — Vault, AWS Secrets Manager, Doppler (현재 평문 인라인)
- **Disaster recovery 시나리오** — RTO/RPO 정의, off-site 백업 전송
- **모니터링 알림 규칙** — Grafana Alert / Prometheus Alertmanager (Chapter 1.11 backlog)
- **이미지 빌드 파이프라인** — backend-core / backend-bff / ui Dockerfile 멀티스테이지 (Chapter 1.10 일부)
- **Federation 서비스 설정 import** — `keycloak/openplatform-v3-realm.json`, `wiki-keycloak-config.json` 부트스트랩 (Chapter 1.12 Security)
