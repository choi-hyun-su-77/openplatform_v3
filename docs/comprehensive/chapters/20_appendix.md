# 1.20 부록 (Appendix)

본 챕터는 시리즈 종결 장. 용어집·링크·라이선스·변경이력·세션핸드오프·산출물·포트/계정 빠른 참조 모음.

---

## 1. 용어집 (Glossary)

V9 i18n (ko/en/zh/ja) 중 메뉴·버튼·도메인 핵심 ~40개 KR↔EN 매핑 [src: V9__i18n_labels_and_seed_data.sql §1]. zh/ja 는 V9 SQL 직접 참조.

### 1.1 메뉴 + 버튼

| 메뉴 | KR / EN | 버튼 | KR / EN |
|---|---|---|---|
| MENU_DASHBOARD | 대시보드 / Dashboard | BTN_SAVE / CANCEL | 저장/취소 — Save/Cancel |
| MENU_APPROVAL | 전자결재 / Approval | BTN_DELETE / EDIT | 삭제/수정 — Delete/Edit |
| MENU_BOARD / CALENDAR | 게시판/캘린더 / Board/Calendar | BTN_ADD / SEARCH | 추가/검색 — Add/Search |
| MENU_ORG / MESSENGER | 조직도/메신저 / Organization/Messenger | BTN_CLOSE / CONFIRM | 닫기/확인 — Close/Confirm |
| MENU_MAIL / WIKI / VIDEO | 메일/위키/화상회의 / Mail/Wiki/Video | BTN_LOGOUT / REFRESH / EXPORT | 로그아웃/새로고침/내보내기 — Logout/Refresh/Export |

### 1.2 결재 도메인 + 게시판/캘린더/공통

| 키 | KR / EN | 비고 |
|---|---|---|
| LBL_APPROVAL_INBOX / DRAFT / PENDING / COMPLETED / REJECTED | 결재함/기안함/대기함/완료함/반려함 — Inbox/Drafts/Pending/Completed/Rejected | 9-box |
| LBL_APPROVAL_SUBMIT / APPROVE / REJECT | 상신/승인/반려 — Submit/Approve/Reject | 액션 |
| LBL_APPROVAL_WITHDRAW / DELEGATE / RESUBMIT | 회수/대결/재상신 — Withdraw/Delegate/Resubmit | parent_doc_id 추적 |
| LBL_DOC_TITLE / FORM_CODE / AMOUNT | 문서제목/양식/금액 — Title/Form/Amount | DMN 키 |
| LBL_DRAFTER / APPROVER / APPROVAL_LINE | 기안자/결재자/결재선 — Drafter/Approver/Line | |
| LBL_ATTACHMENT / HISTORY | 첨부파일/이력 — Attachments/History | MinIO + 감사 |
| LBL_BOARD_NOTICE/GENERAL/FREE/DEPT | 공지/일반/자유/부서 — Notice/General/Free/Dept | 게시판 |
| LBL_VIEW_COUNT / PIN | 조회수/상단고정 — Views/Pinned | 게시판 |
| LBL_CAL_PERSONAL/DEPT/COMPANY/ALL_DAY | 개인/부서/회사/종일 — Personal/Department/Company/All Day | 캘린더 |
| LBL_NOTIFICATION / MARK_ALL_READ | 알림/모두읽음 — Notifications/Mark all read | 알림센터 |
| LBL_FORBIDDEN / NO_DATA / LOADING | 권한없음/데이터없음/로딩중 — Access denied/No data/Loading... | 공통 |

---

## 2. 외부 링크 / 참고 자료

### 2.1 핵심 프레임워크 + 인프라

| 영역 | 도구 / 버전 | 공식 URL |
|---|---|---|
| 백엔드 | Spring Boot 3.2.5 | https://docs.spring.io/spring-boot/docs/3.2.5/reference/html/ |
| 보안 | Spring Security 6.x | https://docs.spring.io/spring-security/reference/ |
| 영속화 | MyBatis 3.x · Flyway 9.x | https://mybatis.org/mybatis-3/ · https://documentation.red-gate.com/fd/ |
| BPMN | Flowable 7.x | https://www.flowable.com/open-source/docs/bpmn/ |
| 프론트 | Vue 3.4 · Vite 5.x · PrimeVue 4 | https://vuejs.org · https://vitejs.dev · https://primevue.org/ |
| 상태/라우팅 | Pinia 2.x · Vue Router 4.x | https://pinia.vuejs.org · https://router.vuejs.org |
| 캘린더 | FullCalendar 6.x | https://fullcalendar.io/docs |
| 인증 | keycloak-js 23.x | https://www.keycloak.org/docs/latest/securing_apps/ |
| IDP | Keycloak | https://www.keycloak.org/documentation |
| DB / 캐시 | PostgreSQL 15 · Redis | https://www.postgresql.org/docs/15/ · https://redis.io/docs/ |
| 스토리지 | MinIO | https://min.io/docs/minio/linux/ |
| 메신저 / 메일 | Rocket.Chat · Stalwart (JMAP) | https://docs.rocket.chat/ · https://stalw.art/docs/ |
| 위키 / 화상 | Wiki.js · LiveKit | https://docs.requarks.io/ · https://docs.livekit.io/ |
| 프록시 | Traefik | https://doc.traefik.io/traefik/ |

### 2.2 표준

- OAuth 2.0 / OIDC — https://openid.net/specs/openid-connect-core-1_0.html
- JMAP RFC 8620 / 8621 — https://datatracker.ietf.org/doc/html/rfc8620
- DMN 1.3 / BPMN 2.0 — https://www.omg.org/spec/DMN/1.3/ · https://www.omg.org/spec/BPMN/2.0/
- S3 Presigned URL — https://docs.aws.amazon.com/AmazonS3/latest/userguide/PresignedUrlUploadObject.html

---

## 3. 라이선스

### 3.1 본 프로젝트 — **확인 필요**

루트에 `LICENSE` 파일 부재. 운영 배포 전 다음 결정 필요:

- [ ] 라이선스 종류: MIT / Apache-2.0 / BSL / Proprietary
- [ ] 저작권 표기 (`Copyright (c) 2026 ...`)
- [ ] 외부 OSS 기여 정책 (CONTRIBUTING.md)

> **임시 가정**: 사내 폐쇄형 시스템. 외부 공개 시 본 섹션 갱신 필수.

### 3.2 외부 OSS 라이선스 요약

| 라이브러리 | 라이선스 |
|---|---|
| Spring Boot · MyBatis · Flyway · Flowable · Keycloak · LiveKit | Apache-2.0 (고지) |
| Vue · PrimeVue · Pinia · Router · FullCalendar · Rocket.Chat (Community) | MIT (고지) |
| PostgreSQL · Redis (>=7.4) | PostgreSQL · RSALv2/SSPLv1 (재배포 제약) |
| **MinIO · Wiki.js · Stalwart** | **AGPL-3.0** — 상용 SaaS 시 법무 검토 필수 |

> **AGPL-3.0 주의**: 위 3종은 *서비스로서 제공* 시 소스 공개 의무. 사내 폐쇄 사용은 무관.

---

## 4. 변경 이력 (Changelog) — Phase 0 ~ 14

`info.md` / `TODO.md` / git log 추출 [src: TODO.md, info.md]. 상세: `docs/PHASE14_REPORT.md`, 시나리오: `docs/scenarios.md` (1~23).

| Phase | 시기 | 핵심 변경 |
|---|---|---|
| 0~1 | 2026-04-14 | 뼈대 + 상태 파일 + docker-compose + Keycloak realm + 16/17 healthy |
| 2~3 | 2026-04-14~15 | backend-core (DataSet+MyBatis+Flowable) + backend-bff Port-Adapter 7종 |
| 4~5 | 2026-04-15 | UI 초기화 + vue-spring-fw 복사 + PKCE 로그인 + Dashboard 위젯 |
| 6~9 | 2026-04-15 | 결재/게시판/캘린더/조직도 UI 1차 |
| 10~12 + 12.1 | 2026-04-15 | RC/Stalwart/Wiki.js/LiveKit 통합 + MinIO presigned + SSE + i18n + SSO 통일 |
| Final | 2026-04-15 | C1~C6 시나리오 통과 + LiveKit WebRTC 정상화 |
| 13/0~A | 2026-04-16 | V8 결재 + Identity 정규화 + ApprovalService 8 메서드 + useApproval |
| 13/B~F | 2026-04-16 | 게시판/캘린더 풀 CRUD + 조직도 + NotificationBell SSE + V9 i18n + Page403 |
| 13/H | 2026-04-16 | Stalwart JMAP 3단 메일 UI |
| 14 W1 | 2026-04-27 | T1 근태/연차 + T2 회의실 + T3 자료실 + T5 어드민 |
| 14 W2 | 2026-04-27 | T4 업무일지 + T6 검색/즐겨찾기 + T7 대시보드 위젯 |
| 14 W3 | 2026-04-27 | V17 메뉴 + Router 13 + Calendar UNION + Flyway V1~V17 clean boot |

---

## 5. 세션 핸드오프 (5분 컨텍스트 복구)

`SESSION_HANDOFF.md` 의 핵심 절차 압축 [src: SESSION_HANDOFF.md §4].

### 5.1 첫 5분 체크리스트

```bash
cd /c/claude/openplatform_v3
git log --oneline -5
docker ps --format "{{.Names}} {{.Status}}" | grep ^v3-
curl -s -o /dev/null -w "core=%{http_code}\n" http://localhost:19090/actuator/health
curl -s -o /dev/null -w "bff=%{http_code}\n"  http://localhost:19091/actuator/health
```

모두 200 → 정상. 아니면 `docker compose -f infra/docker-compose.yml up -d`.

### 5.2 작업 진입 우선순위

1. `SESSION_HANDOFF.md` → `TODO.md` `[~]`/`[ ]` → `warn.md`/`fatal.md`/`info.md`
2. 변경 후 `docker compose ... build --no-cache <svc> && up -d --force-recreate <svc>`
3. Playwright MCP 시나리오 검증

### 5.3 Keycloak 토큰 발급 (E2E)

```bash
TOKEN=$(curl -s -X POST "http://localhost:19281/realms/openplatform-v3/protocol/openid-connect/token" \
  -d "client_id=v3-ui" -d "username=admin" -d "password=admin" -d "grant_type=password" \
  | python -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
```

> **보안 메모**: Phase Final 에서 `directAccessGrantsEnabled=false` 복구 완료. E2E 시 임시 true 필요.

---

## 6. 빌드 산출물 PDF / HTML

| 파일 | 설명 |
|---|---|
| `doc/access-info.html` (9 KB) | URL·계정·API 엔드포인트 가이드 (인쇄용) |
| `doc/openplatform_v3_access_info.pdf` (159 KB) | access-info.html PDF 변환본 |
| `doc/openplatform_v3_session.pdf` (364 KB) | Phase 0~12 세션 기록 1부 |
| `doc/openplatform_v3_session_part2.pdf` (306 KB) | Phase 13~14 세션 기록 2부 |
| `doc/conversation.html` (28 KB) | 전체 대화 스레드 HTML 아카이브 |
| `doc/session-continuation.html` (30 KB) | 세션 핸드오프 인쇄용 HTML |

> 본 챕터가 가장 최신·정규화된 정보. PDF/HTML 은 시점 스냅샷.

---

## 7. 포트 빠른 참조 (19xxx 단일 표)

[src: docs/port-allocation.md, doc/access-info.html §6].

| 서비스 | 호스트 포트 | 용도 |
|---|---|---|
| PostgreSQL · Redis · Keycloak | 19432 / 19379 / 19281 | DB · 캐시 · IDP |
| MinIO API / Console · OpenLDAP | 19900 / 19901 / 19389 | 스토리지 · LDAP |
| backend-core / backend-bff | 19090 / 19091 | `/api/dataset/*` · `/api/bff/*` |
| Rocket.Chat · Wiki.js · LiveKit | 19065 / 19001 / 19880 | 메신저 · 위키 · 화상 |
| Stalwart SMTP/IMAP/Admin | 19025 / 19143 / 19480 | 메일 · JMAP |
| UI Vite dev / nginx prod | 25174 / 19173 | dev · 빌드 산출물 |
| Grafana / Prometheus / Loki | 19300 / 19309 / 19310 | 관측 |
| Traefik 대시보드 (공유) | 18082 | 라우팅 |

---

## 8. 계정 빠른 참조

> **운영 변경 필요** = 프로덕션 배포 전 비밀번호 회전 / Secret Manager 이관 필수.

### 8.1 인프라 관리자 [src: doc/access-info.html §1~5]

모든 행 **운영 변경 필요** (default 비밀번호 회전 + Secret Manager 이관 필수).

| 시스템 | 계정 / 비밀번호 |
|---|---|
| Keycloak master | `admin` / `admin` |
| PostgreSQL | `platform_v3` / `platform_v3_pass` (DB `platform_v3`) |
| Redis | (없음) / `v3_redis_pass` |
| MinIO root | `v3minio` / `v3minio_pass` |
| OpenLDAP | `cn=admin,dc=v3,dc=local` / `adminpass` |
| Stalwart admin | `admin` / `b3C2k27fWn` (자동 생성) |
| Rocket.Chat 로컬 | `v3admin` / `Admin1234!` (SSO 우선) |
| Wiki.js 로컬 | `admin@v3.local` / `Admin1234!` (SSO 우선) |
| Grafana | `admin` / `admin` |

### 8.2 시드 사용자 (Realm `openplatform-v3`)

| 계정 | 비밀번호 | employee_no | 역할 |
|---|---|---|---|
| `admin` | `admin` | E0001 | 대표이사 (시드 데이터 소유자) |
| `user1` | `user1` | (정규화 fallback) | 일반 사용자 데모 |

> Identity 정규화: JWT `preferred_username` → `OrgMapper.findEmployeeByKeycloakUserId` → `employee_no`. 매핑 실패 시 username fallback [src: SESSION_HANDOFF.md §2.1].

### 8.3 운영 전환 체크리스트

- [ ] 모든 default 비밀번호 회전 (8.1 전체)
- [ ] Keycloak `directAccessGrantsEnabled=false` 유지
- [ ] MinIO root → IAM, Postgres least-privilege 분리, Redis ACL+TLS
- [ ] Secret Manager 이관 (Vault / AWS / Azure)
- [ ] 운영 도메인 인증서 (Traefik Let's Encrypt 또는 사설 CA)

---

## 참조

- `SESSION_HANDOFF.md` (§5 모체) · `TODO.md` / `info.md` / `warn.md` / `fatal.md` (§4)
- `backend-core/src/main/resources/db/migration/V9__i18n_labels_and_seed_data.sql` (§1)
- `docs/port-allocation.md` (§7) · `doc/access-info.html` (§7·§8)
- `docs/PHASE14_REPORT.md` (§4 W1~W3) · `docs/scenarios.md` (1~23)
- `C:\claude\docker-info.xml` — 워크스페이스 전체 포트 단일 권위 레지스트리

---

## 이 챕터가 다루지 않은 인접 주제

1. **운영 절차 매뉴얼** — 백업/복구/DR, on-call 룰북 (별도 RUNBOOK.md)
2. **테스트 전략 상세** — Playwright step 자동화는 `docs/scenarios.md`
3. **API 카탈로그 전체** — 95개+ DataSet 서비스는 `docs/api-catalog.md`
4. **CI/CD 파이프라인** — GitHub/GitLab CI 정의 미수록 (현재 로컬 docker compose)
5. **모니터링 대시보드** — Grafana JSON / 알림 규칙은 `infra/grafana/`
6. **법무 라이선스 의견서** — AGPL-3.0 상용 사용 검토 별도
7. **데이터 마이그레이션** — v1 → v3 ETL (본 챕터는 신규 구축 기준)
8. **국제화 추가 언어** — V9 4개 외 신규 언어 추가 시 cm_i18n_message 확장

---

**작성일**: 2026-04-27  
**버전**: 1.0  
**상태**: 본 종합 문서 시리즈의 종결 챕터 (1.20)
