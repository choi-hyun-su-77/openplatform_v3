# Chapter 1.19: Troubleshooting & Known Issues

## Overview

Consolidates **frequent issues**, **resolved defects (Phase 12 SSO sweep, Phase H JMAP)**, **known incomplete items**, and **diagnostic patterns**. Sources: `warn.md`, `fatal.md`, `docs/minio-console-oidc-analysis.md`, `docs/video-manual-check.md`, `docs/comprehensive/inventory/08_logging.md`.

Sections: (1) FAQ → (2) SSO Phase 12 fixes → (3) JMAP Phase H fixes → (4) PrimeVue 4 TabPanel → (5) MyBatis camelCase → (6) PostgreSQL DATE cast → (7) MESSENGER stub → (8) Open TODOs → (9) Log-pattern triage → (10) LiveKit manual verification.

---

## 1. Frequency-ranked FAQ

| Symptom | Cause → Resolution |
|---------|--------------------|
| Sidebar width 0, layout collapses | CSS vars `--sidebar-width / --header-height / --page-ground` undefined → defined in `ui/src/styles/global.css` (Phase 12 fix #1) |
| `/api/messages` 500 toast on navigation | BFF stub returns 500 → interceptor `silentEndpoints` allowlist (commit 05275e6) |
| Stale `*.vue.js` build artifacts | vue-tsc emitting JS next to .vue sources → `tsconfig.json` `noEmit:true` + clear vite cache (commit 23571fe) |
| Login redirect loop on `kc.localtest.me` | Browser DNS not resolving 127.0.0.1 → verify `nslookup kc.localtest.me` returns 127.0.0.1 |
| Approval submitted, no SSE notification | `recipientId` null (employee_no→employee_id miss) → check `org_employee.keycloak_user_id`; `notifyByUserNo` early-exits with debug log |
| LiveKit ICE stuck `checking` | Wrong node-ip / firewall → `livekit.yaml` node-ip=127.0.0.1; UDP 19882 / TCP 19880-19881 open |
| MinIO Console SSO button missing | Console build > 2024-07 dropped `redirectRules` → direct Keycloak authorize URL (`minio-console-oidc-analysis.md` §6) |
| Stalwart JMAP 400 on mailbox query | `Object[]` serialised as JSON object → Phase H fix `List.of(...)` (§3) |
| user1/user2 mailboxes empty | accountId requires LDAP-synced user → only `admin` works until LDAP→Stalwart provisioning |
| Wiki.js "user not in any group" | autoEnrollGroups misconfigured → Phase 12.2 E3: `[1] Administrators` → `[2] Guests` |

---

## 2. SSO Integration Defects (Resolved — Phase 12)

Source: `warn.md` 2026-04-15 19:50.

| # | Component | Defect → Fix |
|---|-----------|--------------|
| 1 | Layout CSS | `var(--sidebar-width)` undefined → width 0 → defined in `ui/src/styles/global.css` |
| 2 | Keycloak host | Browser used `localhost`, containers used `keycloak` (mismatched issuer + cookie) → unified on `kc.localtest.me` (RFC public DNS → 127.0.0.1) + `extra_hosts: kc.localtest.me:host-gateway` on all services. Single domain → single SSO cookie |
| 3 | Rocket.Chat OAuth | `mattermost` realm client mis-targeted RC callback → replaced with `rocketchat` (callback `/_oauth/keycloak`) registered via RC `settings.update` REST API (env-var `OVERWRITE_SETTING` does NOT apply to Custom OAuth keys in RC 6.x) |
| 4 | MinIO Console OIDC | client_secret out of sync → added `minio` client + `protocolMapper(policy=consoleAdmin)`; synchronised |
| 5 | Wiki.js OIDC | Re-import overwrote secret; legacy strategy host on old port → `kcadm` set secret to `C45Mb5Fu6kVGwyk9i8cpxrAFi1lm6Nbm`; updated 5 jsonb host fields via `jsonb_set` to `kc.localtest.me:19281` |
| 6 | LiveKit ICE | dev auto-detected wrong node IP → wrote `livekit.yaml` (port=19880, tcp_port=19881, udp_port=19882, node-ip=127.0.0.1); compose now publishes 19881/tcp + 19882/udp |
| 7 | PageVideo | `createLocalTracks` rejection blocked room entry → try-catch → view-only fallback |
| 8 | BFF video config | UI hard-coded ws URL → added `/api/bff/video/config` returning `{ wsUrl }` |
| 9 | PageMessenger | Legacy `/oauth/gitlab/login` → direct Keycloak authorize URL `kc.localtest.me:19281/realms/.../auth?client_id=rocketchat&...` |
| 10 | OpenLDAP seed | osixia chown collision → mount at `/seed-ldif` + `LDAP_SEED_INTERNAL_LDIF_PATH=/seed-ldif` |

**Verification:** All six C-checkpoints (sidebar / Wiki.js / Rocket.Chat / MinIO Console / LiveKit / Mail) passed Playwright MCP 2026-04-15 19:51.

---

## 3. JMAP Serialization Bugs (Phase H, 2026-04-16)

Source: `warn.md` 2026-04-16 22:40.

| Bug | Symptom | Root Cause | Fix |
|-----|---------|------------|-----|
| methodCalls request | Stalwart JMAP 400 on mailbox query | Java `Object[]` serialised by Jackson as JSON object `{}` not array `[]` | `new Object[]{...}` → `List.of(...)` |
| methodResponses parse | ClassCastException | Response is `List<List<Object>>`, code cast to `List<Object[]>` | Generic corrected to `List<List<Object>>` |

After both fixes, 5 mailboxes return correctly for `admin`. Service-account auth uses `admin:admin` Basic; `accountId = preferred_username` requires LDAP→Stalwart sync.

---

## 4. PrimeVue 4 TabPanel API Change

`<TabPanel header="...">` alone fails TS compilation in PrimeVue 4 — `value` prop is now required (panel ID).
```vue
<TabPanel value="basic" header="기본 정보">...</TabPanel>
```
Apply to all Board / Calendar / Room / Admin dialogs. Source: `warn.md` 2026-04-16 05:32.

---

## 5. MyBatis camelCase Resolution

`map-underscore-to-camel-case: true` (default) — DB column `employee_no` becomes Map key `employeeNo`. Always read with camelCase preferred, snake_case fallback:
```java
String employeeNo = (String) (emp.get("employeeNo") != null
    ? emp.get("employeeNo")
    : emp.get("employee_no"));
```
Apply anywhere DataSet handlers read `org_employee` rows. Source: `warn.md` 2026-04-16 00:50.

---

## 6. PostgreSQL DATE Casting

`ApprovalCompleteDelegate` INSERT failed: `column "from_date" is of type date but expression is of type character varying`. PostgreSQL refuses implicit string→DATE in parameterised INSERTs. Use explicit `CAST` (chosen over MyBatis typeHandler — more explicit / easier to debug):
```xml
VALUES (..., CAST(#{fromDate} AS DATE), CAST(#{toDate} AS DATE), ...)
```
Source: `warn.md` 2026-04-16 00:50.

---

## 7. NotificationService MESSENGER — Stub

`RocketChatAdapter` has no `sendDm`; BFF has no `/api/bff/messenger/dm` (Phase 10 stub). `notifyByUserNo(..., category)` evaluates `NotifyPrefService.isChannelEnabled(MESSENGER)`; when enabled, `BffClient.sendNotificationDm()` emits `debug` log only and returns. `warn` log recorded per skip; **no notification loss** — PORTAL (SSE) and EMAIL still fire. To finish: add `POST /api/v1/im.create` → `POST /api/v1/chat.postMessage` in `RocketChatAdapter`, wire `BffClient.sendNotificationDm` → `/api/bff/messenger/dm`. Source: `warn.md` 2026-04-27 (T6).

---

## 8. Known Incomplete Items

| Item | Status / Workaround |
|------|---------------------|
| `ApprovalService.approve()` does not call `recordHistory()` | History tab missing APPROVE actions; submit/reject/withdraw/resubmit already record. One-line fix planned |
| `recordHistory.actorName = employee_no` raw | TODO: lookup `employee_name` via `OrgMapper.findEmployeeByNo` |
| BFF `/api/bff/mail/send` requires JWT, `BffClient.sendNotificationEmail` calls without auth | May 401; warn log only; PORTAL still delivered. Plan: service-account auth or internal-only endpoint |
| MESSENGER stub (§7) | warn log + skip |
| `v3-ui` realm client `directAccessGrantsEnabled=true` (dev) | Re-enabled for E2E smoke (Phase 13). **Phase F-9 must restore false before prod** |
| LiveKit dev in-memory state | Restart wipes rooms — production needs persistent backend |
| `selectApproversForDocFromDmn` HR branch returns 3 instead of 2 | `LIMIT 3` fills always; HR/IT formCode should LIMIT 2 |
| Calendar RRULE recurrence | No recurrence column on `cal_event` — design pending |
| Attachment-download permission check | Anyone with link can presigned-GET — covered in Phase A backlog A4 |

---

## 9. Log-Pattern Diagnostic Table

Patterns from `inventory/08_logging.md` plus operational experience.

| ERROR keyword | Likely Cause → First Action |
|---------------|------------------------------|
| `JWT validation failed: Signature verification failed` | Realm export changed, JWKS cached → restart backend-core or hit `/actuator/refresh` |
| `Connection is not available, request timed out after 30000ms` | HikariPool exhausted → inspect `pg_stat_activity`; raise `spring.datasource.hikari.maximum-pool-size` |
| `Unable to acquire JDBC Connection` | Cascade from above → same |
| `column "..." is of type date but expression is of type character varying` | Missing `CAST(... AS DATE)` → §6 |
| `Failed to send DM via RocketChat` (warn) | MESSENGER stub (§7) → ignore; PORTAL/EMAIL deliver |
| `400 Bad Request from POST /jmap` | Phase H `Object[]` regression → verify `List.of(...)` still in JmapClient |
| `ICE candidate gathering failed` | livekit node-ip mismatch / firewall → `livekit.yaml` node-ip; UDP 19882 |
| `Too many failures, redirecting to login` | Consecutive non-retryable failures ≥ threshold → check backend health; reload to clear `consecutiveFailCount` |
| `Login with SSO button not visible` | MinIO Console build dropped `redirectRules` → direct authorize URL (`minio-console-oidc-analysis.md` §6) |

---

## 10. Playwright / LiveKit Headless Constraint

Headless Playwright has no camera/microphone, so `createLocalTracks()` rejects with `NotFoundError`. **F-8 video verification is therefore manual** per `docs/video-manual-check.md`.

**Procedure summary:**
1. Pre-check `docker compose ps` — `v3-livekit` is `Up (healthy)`.
2. **1-person:** admin/admin → 화상회의 → room `v3-manual-test` → grant camera/mic → toggle controls → leave.
3. **2-person:** Browser A admin joins `v3-multi`; Browser B user1 joins → A sees B's tile + audio → B mutes / leaves → A reflects state.

**Pass criteria (Type A):** `/api/bff/video/token` 200 with `{ token, room, wsUrl }`; `wss://...:19880` 101 upgrade; ICE `connected`; `<video>` `readyState ≥ 2`; `RemoteTrack` event in 2-person test.

**Failure triage:** `docker logs v3-livekit --tail 50` (search `ICE candidate gathering`) → firewall UDP 19882 + TCP 19880,19881 → `docker compose restart livekit` → `curl http://localhost:19880` returning 404 is normal (WS-only signaling).

Record pass with `[YYYY-MM-DD HH:MM] F-8 수동 검증 통과 (테스터명)` line in `warn.md`.

---

## 참조

- `warn.md` — autonomous-decision history (Phase 12 SSO sweep, Phase H JMAP, Phase 13 Identity, Phase 14 tracks)
- `fatal.md` — only `2026-04-27 Docker daemon down` recorded; cleared after Wave 3 hot-fixes
- `docs/minio-console-oidc-analysis.md` — Console SSO button history & downgrade guide (§4 candidate tags, §6 alternative redirect path)
- `docs/video-manual-check.md` — F-8 manual verification procedure
- `docs/comprehensive/inventory/08_logging.md` — Logback / MDC / Loki pipeline
- `docs/comprehensive/chapters/11_backend_logging.md` — backend logging conventions
- `TODO.md` — Phase-level checklist (24 DONE / 4 STUB / 1 MISSING after Phase 12.2 E1 audit)

## 이 챕터가 다루지 않은 인접 주제

- **CI/CD 파이프라인 실패 분석** — Chapter 1.18 (Build & Deploy)
- **퍼포먼스 튜닝 / 캐시 전략** — Chapter 1.17 (Performance & Cache)
- **보안 취약점 sweep / RBAC 설계** — Chapter 1.16 (Security)
- **Flowable BPMN 모델링 가이드** — Chapter 1.13 (Workflow Engine)
- **DB 마이그레이션 충돌 해결** — Chapter 1.05 partial + dedicated migration runbook
- **재해 복구 / 백업 절차** — out of scope; planned as ops runbook
