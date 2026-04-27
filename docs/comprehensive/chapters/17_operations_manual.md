# Chapter 1.17: 운영 매뉴얼 (Operations Manual)

본 챕터는 openplatform_v3 (50명 규모 통합 그룹웨어 — Phase 14 완료) 운영자용 단계별 명령어 카탈로그다. 작업 루트는 `C:/claude/openplatform_v3` 이며, 모든 명령어는 bash (Git Bash / WSL 호환).

> 출처: `scripts/start.sh`, `scripts/backup.sh`, `scripts/restore.sh`, `scripts/security-scan.sh`, `scripts/perf-scan.sh`, `infra/docker-compose.cron.yml`, `infra/docker-compose.healthcheck.yml`, `infra/docker-compose.observability.yml`, `docs/PHASE14_REPORT.md`.

---

## 1. 클린 설치

```bash
git clone <repo-url> openplatform_v3 && cd openplatform_v3
docker version
bash scripts/start.sh full              # base + healthcheck + resources
bash scripts/start.sh status            # 8 서비스 healthy 대기
bash scripts/start.sh init-mongo        # Rocket.Chat 최초 1회
docker exec v3-postgres psql -U platform_v3 -d platform_v3 \
  -c "select version, success from flyway_schema_history order by installed_rank desc limit 5"
# UI: http://localhost:19173/  (admin/admin → 즉시 변경)
```

기동 모드 (출처: `scripts/start.sh`): `dev` (base only) / `full` (+healthcheck+resources, 기본) / `observability` (+Loki/Grafana/Prometheus) / `traefik` (+리버스 프록시) / `production` (전체 + cron).

---

## 2. 업그레이드

```bash
bash scripts/backup.sh                  # 백업 먼저 (필수)
git pull --rebase
ls backend-core/src/main/resources/db/migration/V*.sql | sort   # V18__*.sql 충돌 확인

docker compose -f infra/docker-compose.yml -f infra/docker-compose.healthcheck.yml \
  build backend-core backend-bff ui-frontend
bash scripts/start.sh stop && bash scripts/start.sh full         # Flyway 가 자동 적용

docker exec v3-postgres psql -U platform_v3 -d platform_v3 \
  -c "select version, description, success from flyway_schema_history order by installed_rank desc"
```

마이그레이션 실패 시 Phase 14 V12 사례처럼 `flyway_schema_history` 의 `success=false` row 를 백업 후 삭제하고 SQL 보정 후 재기동 (출처: PHASE14_REPORT.md §4).

---

## 3. 백업·복구

### 3.1 백업 — `scripts/backup.sh`

```bash
bash scripts/backup.sh
# 결과: backups/v3-YYYYMMDD-HHMMSS.tar.gz + backup-*.log
```

6 도메인 (출처: `scripts/backup.sh`):

| # | 컨테이너 | 명령 | 산출물 |
|---|---|---|---|
| 1 | v3-postgres | `pg_dumpall -U platform_v3` | `postgres-dumpall.sql` |
| 2 | v3-minio | `mc mirror` | `minio/` |
| 3 | v3-keycloak | `kc.sh export --realm openplatform-v3 --users realm_file` | `keycloak/` |
| 4 | v3-openldap | `ldapsearch -b dc=v3,dc=local` | `ldap-dump.ldif` |
| 5 | v3-mongo | `mongodump --archive --db=rocketchat` | `rocketchat-mongo.archive` |
| 6 | v3-wikijs | `docker cp /wiki/db.sqlite` | `wikijs-db.sqlite` |

각 단계 실패 시 `warn` 로그 후 계속. 컨테이너 부재 시 자동 스킵.

### 3.2 복구 — `scripts/restore.sh`

```bash
docker stop v3-backend-core v3-backend-bff
bash scripts/restore.sh backups/v3-20260427-030000.tar.gz
docker compose -f infra/docker-compose.yml restart \
  v3-keycloak v3-wikijs v3-backend-core v3-backend-bff
```

복원 순서: tar 해제 → backend 중단 확인(5s) → Postgres `psql -U postgres` → MinIO `mc mirror` 역방향 → Keycloak `kc.sh import --override true` → OpenLDAP `ldapadd -c` → Mongo `mongorestore --archive --drop` → Wiki.js sqlite cp.

> 위험: 기존 데이터 덮어씀. 운영에서는 복원 직전 추가 백업 1회 권장.

---

## 4. 헬스체크 (8 서비스)

`infra/docker-compose.healthcheck.yml` 컨테이너별 명령:

| 서비스 | 명령 (interval × retries, start) |
|---|---|
| keycloak | `cat /proc/1/cmdline \| grep -q keycloak` (30s×5, 60s) |
| mongo | `mongosh --eval "db.adminCommand('ping').ok"` (20s×10, 20s) |
| rocketchat | `node -e "http.get(localhost:3000/api/info)"` (20s×15, 90s) |
| wikijs | `node -e "http.get(localhost:3000/, status<500)"` (20s×15, 60s) |
| stalwart | `cat /proc/1/cmdline \| grep -q stalwart` (30s×5, 60s) |
| openldap / livekit | `pgrep slapd` / `pgrep livekit-server` |
| backend-core/bff | `wget -qO- localhost:8080/actuator/health \| grep UP` (20s×20) |
| ui-frontend | `nginx -t \| grep successful` (30s×5, 15s) |

```bash
bash scripts/start.sh status
for c in $(docker ps --filter name=v3- --format '{{.Names}}'); do
  docker inspect --format '{{.Name}} {{.State.Health.Status}}' "$c"; done
```

Phase 14 검증: postgres / redis / keycloak / core / bff / ui 6 컨테이너 healthy + UI HTTP 200 (출처: PHASE14_REPORT.md §4).

---

## 5. 정기 작업 (Cron)

`infra/docker-compose.cron.yml` — `mcuadros/ofelia` 가 docker socket 으로 컨테이너 명령을 스케줄. 기본 작업 1건:

```yaml
ofelia.job-exec.backup-postgres.schedule: "0 0 3 * * *"   # 매일 03:00
ofelia.job-exec.backup-postgres.container: "v3-postgres"
ofelia.job-exec.backup-postgres.command:
  "sh -c 'pg_dumpall -U platform_v3 > /tmp/backup-$(date +%Y%m%d).sql'"
```

```bash
docker compose -f infra/docker-compose.yml -f infra/docker-compose.cron.yml up -d ofelia
docker compose -f infra/docker-compose.yml -f infra/docker-compose.cron.yml \
  --profile backup run --rm backup-runner       # 단발 백업
```

권장 추가: 일일 full 백업 (host cron `bash scripts/backup.sh` @03:00) / `sa_audit` 180일 보존 (@04:00) / 주간 통계 (Mon 08:00, `/internal/report/weekly`).

---

## 6. 보안 스캔

```bash
bash scripts/security-scan.sh                       # 기본 BASE_URL=http://localhost:19090
bash scripts/security-scan.sh https://api.v3.local  # 운영
# 결과: reports/security-YYYYMMDD-HHMMSS.txt
```

4 단계 (출처: `scripts/security-scan.sh`):

1. **`npm audit --audit-level=moderate`** (ui/) — moderate 이상.
2. **`mvn dependency:analyze`** (backend-core, backend-bff) — 미사용/누락.
3. **이미지 CVE** — `trivy` 우선, 없으면 `docker scout cves`. 대상: minio, keycloak, rocketchat, wiki. severity HIGH·CRITICAL.
4. **인증 우회** — `curl -w "%{http_code}"` 로:
   - 보호 (401 기대): `/api/admin/users`, `/api/admin/codes`, `/api/dataset/private`, `/actuator/env`, `/actuator/loggers`
   - 공개 (200 기대): `/actuator/health`, `/api/i18n/ko`

결과 해석:
- `[FAIL]` 보호 → 401 이외: SecurityConfig 누락. 즉시 차단.
- `[FAIL]` 공개 → 401: permitAll 누락.
- npm `high`/`critical` ≥ 1: `npm audit fix` 후 재실행.

---

## 7. 성능 스캔

```bash
bash scripts/perf-scan.sh
# 결과: reports/perf-YYYYMMDD-HHMMSS.txt — avg/min/max/success/fail (10회 반복)
```

기본 측정 대상:

```
/actuator/health
/api/dataset/search?q=public&size=10
/api/codes
/api/i18n/ko
```

권장 임계:

| 엔드포인트 | avg 목표 | 경고 |
|---|---:|---|
| `/actuator/health` | ≤ 50ms | > 200ms 면 GC/풀 점검 |
| `/api/dataset/search` | ≤ 300ms | > 800ms 면 인덱스 누락 |
| `/api/codes` | ≤ 100ms | > 300ms 면 캐시 미스 |
| `/api/i18n/ko` | ≤ 100ms | > 300ms 면 정적 캐시 점검 |

---

## 8. 장애 대응 시나리오

**(a) PostgreSQL 다운** — backend-core/bff `/actuator/health` DOWN. 우회 없음 (전 시스템 정지).
```bash
docker logs v3-postgres --tail 200
docker compose -f infra/docker-compose.yml restart postgres
# 디스크 손상: docker stop v3-postgres && bash scripts/restore.sh backups/v3-LATEST.tar.gz
```

**(b) Keycloak 다운 → SSO 전부 실패** — `/api/auth/*` 401, 신규 로그인 차단. 기존 JWT 만료 전까지 동작은 유지.
```bash
docker logs v3-keycloak --tail 200
docker compose -f infra/docker-compose.yml restart keycloak
# realm 손상: kc.sh import --dir /tmp/kc-restore --override true → restart
```

**(c) MinIO 다운 → 업/다운로드 실패** — `/api/datalib/*` presigned URL 발급 실패. 첨부파일 차단. 결재 본문은 정상.
```bash
docker logs v3-minio --tail 200
docker compose -f infra/docker-compose.yml restart minio
docker exec v3-minio mc admin info local
```

**(d) Rocket.Chat 다운 → 메신저 실패** — `/messenger` iframe 실패. 알림 MESSENGER 채널만 영향, **PORTAL/EMAIL 정상** (NotificationService 가 sendDm 실패 시 debug 로그 + PORTAL fallback — 출처: PHASE14_REPORT.md §3 트랙 6).
```bash
docker logs v3-rocketchat --tail 200; docker logs v3-mongo --tail 200
docker compose -f infra/docker-compose.yml restart mongo rocketchat
```

---

## 9. 롤링 배포

현재 단일 노드 (`v3-net`) 1 instance 기동. **무중단 배포는 Phase 15+ 권장.**

단기 (짧은 다운타임 허용):
```bash
docker compose build backend-core backend-bff ui-frontend
docker compose -f infra/docker-compose.yml -f infra/docker-compose.healthcheck.yml \
  up -d --no-deps --force-recreate backend-core   # healthy 대기 후 backend-bff, ui 순차
```

중장기 권장 — **Blue-Green** (두 번째 compose 프로젝트 `-p v3b` 동시 기동 → traefik weight 100/0 → 0/100 전환, DB 공유), **Canary** (traefik `service.weighted` 90/10 → 메트릭 보며 단계 상승, Prometheus 연동), **Rolling** (k8s/Swarm 이전 시 native).

---

## 10. 모니터링 대시보드

`bash scripts/start.sh observability` 후 진입:

| 도구 | URL | 초기 계정 |
|---|---|---|
| Grafana | http://localhost:19300 | admin / admin (즉시 변경) |
| Prometheus | http://localhost:19309 | — |
| Loki API | http://localhost:19310 | (Grafana 데이터소스 자동 등록) |

Grafana provisioning (`provisioning/`) 으로 Loki / Prometheus 데이터소스 자동 연결. 주요 LogQL:

```logql
{container_name="v3-backend-core"} | json | level="ERROR"
{job="docker"} | json | level=~"WARN|ERROR" | after_last: "1h"
```

Prometheus 스크레이프: `backend-core:8080/actuator/prometheus`, `backend-bff:8080/actuator/prometheus`, `traefik:8082/metrics`.

---

## 11. 운영 체크리스트

**일일 (09:00)** — `bash scripts/start.sh status` 8 healthy / `sa_audit` 24h count / Grafana "Backend Errors" 0 / 03:00 ofelia 백업 산출물 존재 / `df -h` < 80%.

**주간 (월요일)** — `bash scripts/backup.sh` 수동 + 사본 이동 / `security-scan.sh` FAIL 0 / `perf-scan.sh` baseline 회귀 검토 / `flyway_schema_history` `success=false` 0 / Keycloak Realm Roles 변경 + `sa_audit` 비정상 패턴 점검.

**월간 (1일)** — `npm outdated` + `mvn versions:display-dependency-updates` / `trivy image` 재스캔 / `sa_audit` 180일 초과 row 정리 / 백업 1건 무작위 dry-run 복원 시험 / Phase 14 잔여 항목 (RocketChat sendDm, BFF mail 인증, dept_manager_no, LiveKit Egress) 우선순위 갱신 (출처: PHASE14_REPORT.md §5).

---

## 참조

- `scripts/start.sh`, `scripts/backup.sh`, `scripts/restore.sh`, `scripts/security-scan.sh`, `scripts/perf-scan.sh`
- `infra/docker-compose.yml` / `.healthcheck.yml` / `.cron.yml` / `.observability.yml` / `.traefik.yml`
- `docs/PHASE14_REPORT.md` — 8 트랙 / DoD
- `docs/comprehensive/chapters/11_backend_logging.md` — Loki/LogQL
- `docs/comprehensive/chapters/12_backend_security.md` — Keycloak/RBAC
- 루트 `docker-info.xml` — 19xxx 포트 레지스트리

---

## 이 챕터가 다루지 않은 인접 주제

1. **k8s/Swarm 이행** — 현재 단일 노드 docker compose. 무중단 배포(blue-green/canary) 본격 도입은 별도 챕터.
2. **외부 SMTP 페일오버** — Stalwart 다운 시 SendGrid/SES fallback 라우팅.
3. **AlertManager / OpsGenie / Slack 통합** — Prometheus 알람 라우팅. 현재는 Grafana 알람 채널만.
4. **재해 복구 (DR) 멀티리전** — 현재 백업은 단일 호스트. S3/오프사이트 복제.
5. **Compliance 자동 보고서** — `sa_audit` → 월간 PDF 파이프라인.
6. **k6 / JMeter 부하 테스트** — `perf-scan.sh` 는 응답시간만, 동시성 부하는 별도 도구.
7. **Secrets Management** — application.yml 기본값 → Vault/Doppler/AWS SM 연동.
8. **Keycloak realm-management service-account** — 현재 admin-cli password grant. client_credentials 전환 (출처: PHASE14_REPORT.md §5).

---

**Date:** 2026-04-27  
**Version:** 1.0  
**Status:** Complete
