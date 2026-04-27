# Chapter 15. 관찰성 (Observability)

> 메트릭/로그/추적/알람/헬스체크 운영 현황. **사실(현재 적용)** 과 **권장(미적용)** 분리.
> 1차 인풋: `inventory/08_logging.md`, `infra/prometheus/prometheus.yml`,
> `infra/grafana/provisioning/datasources/loki-prom.yml`, `infra/loki/*`,
> `infra/docker-compose.observability.yml`, backend-core/bff `application.yml`(actuator).

## 15.1 스택 개요 — LGTM 부분 적용

**L**ogs(Loki) + **M**etrics(Prometheus) + 시각화(Grafana). **T**races(Tempo) 미적용.

```
backend-core/bff /actuator/prometheus ─► Prometheus(19309) ─► Grafana(19300)
traefik /metrics (현재 미활성) ───────────────────────────────► Grafana
모든 컨테이너 stdout ─► Promtail ─► Loki(19310) ─────────────► Grafana
```

기동: `docker compose -f infra/docker-compose.yml -f infra/docker-compose.observability.yml up -d`.
네트워크 `v3-net`(외부 `openplatform-v3-net`). 호스트 포트 19xxx: Grafana **19300**,
Prometheus **19309**, Loki **19310**. 출처: `docker-compose.observability.yml` 11-105.

## 15.2 메트릭 — Actuator + Micrometer

backend-core / backend-bff 동일 actuator 정책 (`application.yml` 74-91 / 40-54):
`management.endpoints.web.exposure.include: health,info,metrics,prometheus`,
`endpoint.health.show-details: when-authorized`, `endpoint.prometheus.enabled: true`,
`prometheus.metrics.export.enabled: true`, `metrics.tags.application` 으로 서비스 식별.

엔드포인트: `/actuator/health` (UP/DOWN, 상세 `when-authorized`), `/actuator/info` (빌드 메타 미주입),
`/actuator/metrics` (이름 목록), `/actuator/prometheus` (scrape 대상).

**Micrometer 자동 노출**(코드 불필요): JVM(`jvm_memory_used_bytes`, `jvm_gc_pause_seconds`, `jvm_threads_live_threads`),
HTTP(`http_server_requests_seconds_{count,sum,max}` + `method,uri,status,outcome,exception,application` 라벨),
HikariCP(`hikaricp_connections_{active,idle,pending,timeout_total}`),
Process/Tomcat/Logback(`process_cpu_usage`, `tomcat_threads_busy_threads`, `logback_events_total{level=...}`).

**커스텀 비즈니스 메트릭 — 현재 없음(솔직)**: 결재/알림/캘린더 도메인 카운터/타이머 미등록.
`08_logging.md` 의 `approval.submit.time` 은 권장 패턴일 뿐.

## 15.3 Prometheus — 스크레이프

`global.scrape_interval: 15s`, `external_labels: { cluster: openplatform_v3, env: dev }`.
3개 잡:

| job_name | targets | metrics_path |
|---|---|---|
| backend-core | backend-core:8080 | /actuator/prometheus |
| backend-bff  | backend-bff:8080  | /actuator/prometheus |
| traefik      | host.docker.internal:18082 | /metrics |

**솔직 진술:**
1. **포트 불일치 가능성** — `prometheus.yml` 은 `:8080` 인데 `application.yml` `server.port` 는
   `19090/19091`. `SERVER_PORT=8080` env 주입 없으면 `connection refused`. 운영 전환 시 검증 필수.
2. **traefik 미활성** — `traefik.yml` 에 `metrics.prometheus` 미활성 → 잡 `down`.
3. **외부 인프라 미스크레이프** — 15.10 참조.

보존: `--storage.tsdb.retention.time=15d`.

## 15.4 Grafana — 데이터소스 / 대시보드

`loki-prom.yml` 자동 등록: Loki(`http://loki:3100`, `maxLines:1000`, `timeout:60`),
**Prometheus(default, `http://prometheus:9090`, `httpMethod:POST`, `timeInterval:15s`)**.

**기본 대시보드 — 미제공(솔직)**: `provisioning/dashboards/` 디렉터리/JSON 부재 → 기동 직후 빈 상태.

권장: dashboards provider 추가 후 JVM Micrometer(ID 4701/11378), Spring Boot 2.x(10280),
HTTP RED, Hikari, Loki ERROR top-N 을 `infra/grafana/dashboards/*.json` 동봉.
admin 비밀번호(`admin/admin`) 운영 전환 시 Secret 외부화 필수.

## 15.5 Loki + Promtail

**Loki**: `auth_enabled:false` 단일 테넌트, `filesystem` chunk, `replication_factor:1`(HA 아님, 개발용),
스키마 `tsdb`+`v13`, **retention 168h(1주)**, compactor 활성. ruler `enable_api:true` 지만 룰 파일 비어 있음.

**Promtail**: `docker_sd_configs` 로 호스트 모든 컨테이너 stdout/stderr **자동 수집**(사이드카 불필요).
relabel 로 `container_name`, `image`, `job=docker` 부여. `batchwait:1s` 저지연 push.

LogQL 예: `{container_name="v3-backend-core"} |= "ERROR"`,
`sum by (container_name) (rate({job="docker"} |= "ERROR" [5m]))`.

**한계**: Logback 텍스트 패턴 → `| json` 파싱 불가. JSON encoder 전환 시 필드 쿼리 가능(권장).

## 15.6 알람 규칙 — **현재 미설정** (솔직)

Prometheus `rule_files`, Alertmanager 컨테이너, Loki ruler 알람 룰, Grafana Unified Alerting provisioning,
통지 채널(Slack/Email/PagerDuty) **모두 없음**. 수신 측 알람 0건 → 수동 대시보드 확인이 없으면 인지 불가능.

**권장 룰(요약)**: `BackendDown`(`up{job=~"backend-.*"}==0` for 2m, critical),
`HighErrorRate`(5xx 비율 > 1% for 5m), `HikariPoolNearExhausted`(active/max > 0.9 for 10m),
`JvmHeapPressure`(heap used/max > 0.85 for 10m), `LogbackErrorBurst`(`increase(logback_events_total{level="error"}[10m]) > 50`).

배포: `infra/prometheus/rules/*.yml` → `prometheus.yml` `rule_files` 추가 → Alertmanager + Slack/Email receiver.

## 15.7 SLI / SLO — **공식 정의 없음**

문서/코드 어디에도 SLO 명문화 없음. 최초 권장(개발 단계, 운영 전환 시 재조정):

| 카테고리 | SLI | SLO |
|---|---|---|
| 가용성 | `up{job=~"backend-.*"}` | **99% / 30일** |
| 응답 지연 | `/api/**` p95 | **< 500ms** |
| 에러율 | 5xx / total | **< 1%** |
| 결재 성공률 | 성공/시도 | **> 99.5%** (커스텀 카운터 미구현) |
| 로그 ingestion | Promtail→Loki | **< 10s** |

**히스토그램 활성 필수**(`histogram_quantile` 정확도):
`management.metrics.distribution.percentiles-histogram.http.server.requests: true`,
`management.metrics.distribution.slo.http.server.requests: 100ms,250ms,500ms,1s,2s`.

## 15.8 분산 추적 — **미적용**

Spring Cloud Sleuth / Micrometer Tracing 미사용(의존성 없음), OpenTelemetry SDK / Java Agent 미사용,
Jaeger/Tempo/Zipkin 컨테이너 없음, `traceparent`/`b3` 전파 코드 없음. `08_logging.md` 의 MDC `X-Request-ID`
는 권장 패턴이며 실제 `OncePerRequestFilter` 자동 주입은 미확인.

권장: OTel Java Agent 부착 → `OTEL_EXPORTER_OTLP_ENDPOINT=http://tempo:4318` → **Grafana Tempo** 추가
→ Loki `traceID` 로 Logs↔Traces 상관관계 → UI Axios `X-Request-ID` ↔ OTel SpanContext 매핑.

## 15.9 헬스체크 → Prometheus 연계

- `/actuator/health` 기본 인디케이터: `db, diskSpace, ping, redis, livenessState, readinessState`.
- Docker `healthcheck:` 가 `(healthy)` 표시 + 재시작 정책에 활용.
- Prometheus `up{job=...}` 이 가장 단순한 라이브니스. DB/Redis 다운은 actuator 응답에만 드러남 →
  권장: **blackbox_exporter 로 `/actuator/health` 폴링**.

## 15.10 외부 서비스 모니터링

Promtail 로 **로그는 자동 수집**, 메트릭은 별도 노출 필요. 모두 **현재 미스크레이프**.

| 서비스 | 메트릭 노출 경로 | 활성 방안 |
|---|---|---|
| Keycloak | `/metrics` (`KC_METRICS_ENABLED=true`) | env + scrape job |
| Rocket.Chat | `/metrics` (`PROMETHEUS_API_*`) | env + 포트 노출 |
| Stalwart Mail | `/metrics` 내장 | scrape 추가 |
| LiveKit | `prometheus_port` 옵션 | livekit.yaml + 등록 |
| Wiki.js | 공식 노출 없음 | DB exporter / blackbox |
| MinIO | `/minio/v2/metrics/cluster` | bearer + scrape |
| Postgres / Redis | `postgres_exporter` / `redis_exporter` | exporter 사이드카 |
| Traefik | `/metrics` (잡은 있으나 비활성) | `metrics.prometheus` 활성 |

**인프라 메트릭은 backend 2개 + traefik 시도 1개 외 사실상 비어 있다.** 운영 전환 전 단계적 활성 필요.

## 참조

- `infra/docker-compose.observability.yml` 1-105 (4 서비스), `infra/prometheus/prometheus.yml` 1-47 (scrape 3건)
- `infra/grafana/provisioning/datasources/loki-prom.yml` 1-34, `infra/loki/loki-config.yml` 1-69, `infra/loki/promtail-config.yml` 1-43
- `backend-core/.../application.yml` 74-91, `backend-bff/.../application.yml` 40-54
- `docs/comprehensive/inventory/08_logging.md`
- 외부 권장: OpenTelemetry Java Agent, Grafana Tempo, Alertmanager, blackbox/postgres/redis_exporter

## 이 챕터가 다루지 않은 인접 주제

- **Ch 8 Backend Core / Ch 9 BFF** — 도메인 로직/Federation 어댑터 내부. 본 챕터는 관측 표면만.
- **Ch 11 Security** — JWT/actuator endpoint 보호(`when-authorized` ROLE 매핑).
- **Ch 13 Infrastructure** — base compose, traefik.yml, `v3-net` 생성 순서.
- **Ch 14 Logging(별도 시)** — Logback 패턴/MDC/프론트 Axios 인터셉터. 본 챕터는 집계만.
- **Ch 16 Operations / Runbook** — 알람 대응 절차, on-call, post-mortem.
- **성능/부하 테스트(k6/Gatling)** — SLO 검증. 본 챕터는 정의만.
- **PII 마스킹 / 컴플라이언스 / 비용 최적화** — `08_logging.md` 및 운영 챕터로 위임.
