# Chapter 1.16 사용자 매뉴얼 (User Manual)

> **대상 독자**: openplatform v3 그룹웨어를 일상 업무에 사용하는 최종 사용자(End-User), 부서장/매니저, 시스템 관리자, 외부(제휴사) 게스트.
> **근거 자료**: `docs/scenarios.md` (시나리오 1~23), `docs/PHASE14_PRODUCTION_GROUPWARE.md` (8 트랙 = 사용자 기능), `docs/video-manual-check.md`, `docs/comprehensive/inventory/00_existing_artifacts.md` §4 스크린샷 분류, 루트 32개 PNG 산출물.
> **상태**: Phase 14 정상 완료(2026-04-27) 시점의 화면 흐름 기준.

---

## 1. 역할별 시나리오

본 그룹웨어는 4 종 페르소나를 가정합니다. 각 역할은 Keycloak Realm `openplatform-v3` 의 `ROLE_USER` / `ROLE_MGR` / `ROLE_HR` / `ROLE_ADMIN` 에 매핑되며, UI 메뉴 가시성과 BFF 경유 백엔드 호출 시 권한 가드가 동시에 적용됩니다 [src: PHASE14 §1.8 권한 매트릭스].

### 1.1 (a) 일반 사용자 (`ROLE_USER`)

- 매일 출근/퇴근 체크인/아웃 (`/attendance`)
- 휴가/품의/지출/출장 4종 결재 상신·회수·재기안 (`/approval`)
- 부서 게시판 글 작성 + WYSIWYG 편집 + 첨부 (MinIO presigned)
- 본인 일정/회의실 예약·캘린더 동기화 (`/calendar`, `/room`)
- 자료실 — 회사 공용/본인 부서 폴더 RW, 외부 부서 폴더 차단 (`/datalib`)
- 일별 업무일지 (`/worklog`) 단일 행 본인 입력
- 메신저(Rocket.Chat)·메일(Stalwart)·위키(Wiki.js)·화상회의(LiveKit) SSO 자동 로그인

### 1.2 (b) 부서장/매니저 (`ROLE_MGR`)

일반 사용자 권한에 더해:

- 휴가/지출 결재 **승인·반려·전결·대결·회수 5종 액션** (`/approval` 결재함 9종 탭)
- 팀원 출퇴근 일별 조회 (`attendance/searchTeamDaily` — 부서장 가드)
- 팀 업무일지 5×N 매트릭스 뷰 (`/worklog` 우상단 토글)
- 팀 캘린더에 LEAVE 결재 자동 반영(초록), 회의실 예약 자동 반영(주황) 확인 [src: scenarios.md §23]

부서장 가드는 3단(JWT `MGR` 역할 / `dept_head=true` / `position_level≤30`) 으로 검증됩니다 [src: PHASE14 §6.3].

### 1.3 (c) 관리자 (`ROLE_ADMIN`)

- `/admin/users` GUI 만으로 Keycloak 사용자 생성/수정/비활성/임시 비밀번호 발행 (BFF `KeycloakIdentityAdapter` 경유, admin-cli password grant)
- `/admin/depts` 부서 트리 CRUD
- `/admin/menus` 메뉴 트리 + 권한 매트릭스(역할 × R/W/U/D) 편집
- `/admin/codes` 공통코드 그룹/항목 관리
- `/admin/audit` 감사 로그 — 모든 admin/\* 액션이 `sa_audit` 에 자동 기록(AdminAuditAspect AOP, JSON 16KB truncation, IP/actor 자동 추출) [src: PHASE14 §7.6]

관리자 한 명이 **DB 직접 수정 0건** 으로 운영 가능한 것을 Phase 14 의 핵심 목표로 합니다 [src: PHASE14 §0.1].

### 1.4 (d) 외부(제휴사) 게스트

- Keycloak 단일 SSO 허브를 통해 Wiki.js 의 OIDC SSO **자동 가입**(first-login flow) 후 읽기/제한적 편집 가능 [src: scenarios.md §10, group_ware.md §Wiki.js]
- 메신저는 별도 Federation 채널로 초대 시에만 접근 (Custom OAuth Provider)
- 결재/근태/연차/인사 도메인 전체는 차단 (`cm_menu_permission` 미부여)

---

## 2. 주요 화면 흐름

### 2.1 로그인 (Keycloak SSO)

`/login` → `keycloak-js` PKCE 리다이렉트 → 인증 성공 시 `/dashboard` 로 복귀 [src: scenarios.md §1]. **한 번의 인증** 으로 메신저/메일/위키/화상회의의 모든 외부 서비스 SSO 가 완료됩니다 (Federation 5종 일괄).

![Rocket.Chat SSO 성공 결과](../../phase-c3-rocketchat-sso-success.png)

### 2.2 대시보드 (위젯 9종)

첫 로그인 시 기본 6 위젯 자동 시드. 우상단 **편집** 토글로 12-column CSS Grid 위에서 화살표 버튼(← → ↑ ↓ W± H±)으로 위치/크기 조정 + 위젯 추가/제거 [src: scenarios.md §22, PHASE14 §9.4].

위젯 카탈로그 9종 — `ATTENDANCE`(출퇴근) / `LEAVE_BALANCE`(연차 Donut) / `PENDING_APPROVAL`(미결 결재) / `TODAY_EVENTS`(오늘 일정) / `NOTICES`(최근 공지) / `MESSENGER_UNREAD`(메신저 DM) / `MY_ROOMS`(다가오는 회의) / `TEAM_WORKLOG`(팀 업무일지) / `CHART_LEAVE_USAGE`(연차 사용 추이).

![최종 대시보드](../../v3-final-dashboard.png)
![포털 통합 대시보드](../../v3-final-portal-dashboard.png)

### 2.3 메뉴별 기능 매핑

`/approval` 9종 결재함·5액션·DMN / `/attendance` 출퇴근·월별 hex grid / `/leave` 잔여 Donut·LEAVE 결재 연동 / `/room` FullCalendar·화상회의 자동 / `/datalib` 폴더 트리·presigned / `/worklog` 본인+부서장 팀뷰 / `/calendar` 개인·부서·회사+LEAVE·Room 자동 / `/video` LiveKit + view-only 폴백 / 메신저·메일·위키 = 외부 SSO.

---

## 3. 결재 라이프사이클 (사용자 시점)

`PageApproval.vue` 는 9종 결재함 탭(내 대기함/내 진행함/완료함/반려함/회수함/대결함/공람함/임시저장/전체)을 가지며, 사용자는 한 화면에서 자신의 모든 문서를 확인합니다 [src: scenarios.md §3-4, approval.md].

### 3.1 상신 (Submit)

1. **양식 선택**: 품의/휴가(LEAVE)/지출/출장 중 1종
2. **폼 입력**: WYSIWYG 본문 + 양식별 필드(휴가는 `leave_type`/`from_date`/`to_date`/`days` 자동 계산(주말 제외)/`reason`)
3. **DMN 자동 결재선 도출** — 직책/금액 룰 기반
4. **파일 첨부** — MinIO presigned PUT
5. **상신** 버튼 → `ap_document` INSERT + Flowable 프로세스 시작 + 결재자에게 SSE 알림 발송

![결재 제출 다이얼로그](../../phase-a-submit-dialog.png)

### 3.2 결재 (Approve / Reject)

결재자는 **내 대기함** 탭에서 문서 클릭 → 본문/첨부/결재선 확인 → **승인 / 반려 / 전결 / 대결 / 회수** 5종 중 선택 → `ap_history` 자동 기록.

![결재 목록 — Phase A 시점](../../phase-a-approval-list.png)
![최종 결재 화면](../../v3-final-approval.png)

### 3.3 회수 (Recall) → 반려 (Reject) → 재기안 (Resubmit)

- **회수**: 상신자가 첫 결재자 결재 전이라면 회수 가능 → `ap_document.status='RECALLED'` → 임시저장으로 복귀
- **반려**: 결재자가 반려 시 → 상신자에게 SSE 알림 + `ap_history.action='REJECT'` 기록
- **재기안**: 임시저장에서 본문 수정 후 재상신 → 새 doc_id 발급(이력 추적용 `parent_doc_id` 보유 가능)

LEAVE 양식은 결재 승인 완료 시 `ApprovalCompleteDelegate` (Flowable listener) 가 `LeaveService.onDocApproved` 를 호출하여 **잔여 연차 자동 차감 + `at_attendance` 의 해당 일 status='LEAVE' 자동 갱신** 합니다 [src: PHASE14 §3.3].

---

## 4. 근태 / 연차

### 4.1 출/퇴근 체크인·아웃 (`/attendance`)

- 상단 큰 **출근** 버튼 → `attendance/checkIn` → `at_attendance.check_in_at` 기록 → 페이지 갱신 시 **퇴근** 으로 라벨 변경
- 퇴근 시 `work_minutes` 자동 계산 + status (NORMAL/LATE/EARLY) 결정 (회사 표준 출근 9시 기준)
- 월별 출근 시각화: 5×6 hex grid (출근=초록, 지각=노랑, 결근=빨강, 휴가=파랑, 공휴일=회색)
- 영업일 계산은 `cm_holiday` + 주말 제외 [src: scenarios.md §16]

### 4.2 연차 신청 (`/leave`)

- 상단 카드 3종(잔여/사용/총) — `at_leave_balance.remaining` 의 GENERATED 컬럼
- **휴가 신청** 버튼 → `ApprovalSubmitDialog (initialFormCode='LEAVE')` → `leave_type` Dropdown(연차/오전반차/오후반차/병가/경조/무급) + `from-to` DatePicker + `days` 자동(반차=0.5) + `reason`
- 상신 시 `ApprovalService.submitDocument` 가 form_code='LEAVE' 분기에서 `LeaveService.applyFromDoc` 자동 호출 → `at_leave_request` 와 `ap_document` 가 1:1 매핑
- 승인 완료 시 잔여일 차감 + 캘린더에 `L-{requestId}` readonly 이벤트 자동 추가(초록) [src: scenarios.md §23]

---

## 5. 회의실 예약 (`/room`)

좌측 회의실 목록(필터: 인원/장비/화상) + 우측 FullCalendar `timeGridWeek` 빈 슬롯 클릭 → `BookingDialog.vue` [src: scenarios.md §17, PHASE14 §4.4].

- 충돌 검증: `room/checkConflict` 으로 `roomId × [start_at, end_at)` 겹침 사전 검사
- 통과 시 `rm_booking` INSERT (트랜잭션)
- `has_video=true` 회의실은 BFF `LiveKitAdapter.createRoom` 자동 호출 → 룸 이름 `rm-{bookingId}` 자동 생성 (실패 시 view-only 폴백 — Phase 12.1 패턴 [src: PHASE14 §12])
- 참석자 each `NotificationService.notifyByUserNo`(category='ROOM') 호출
- 본인 캘린더에도 `cal_event` INSERT — 통합 캘린더 뷰에 주황 readonly `R-{bookingId}` 로 표시

![최종 캘린더 (회의실/일정 통합)](../../v3-final-calendar.png)
![최종 캘린더 변형 2](../../v3-final-calendar2.png)

---

## 6. 자료실 (`/datalib`)

좌측 폴더 트리(PrimeVue Tree) + 우측 파일 DataTable [src: scenarios.md §18, PHASE14 §5.4].

- **폴더 scope 3종**: COMPANY(전사) / DEPT(부서) / PERSONAL(개인)
- 부서 폴더는 본인 부서만 RW, 외부 부서는 R 차단(`canAccessFolder` 헬퍼)
- 업로드: `FileUploadPanel.vue` 재사용 → MinIO presigned PUT → `datalib/uploadMeta` 호출하여 `dl_file` 메타 INSERT
- 다운로드: `datalib/getDownloadUrl` → presigned GET 발급 + `download_count++`
- 우클릭 ContextMenu(`FolderActions.vue`): 이름 변경 / 삭제 / 새 폴더 / 새 파일

---

## 7. 메신저 SSO (Rocket.Chat)

Keycloak Custom OAuth Provider 가 Rocket.Chat 의 OAuth Service 로 등록되어, **포탈 로그인 후 메신저 메뉴 클릭 시 추가 입력 없이 자동 로그인** [src: scenarios.md §8, group_ware.md §Rocket.Chat].

![SSO 결과](../../rocketchat-sso-success.png)
![최종 상태](../../rocketchat-final-state.png)

채널 목록 → 메시지 → DM → 파일 전송. 알림 카테고리 `MENTION` 의 `ux_notify_pref` 에서 `MESSENGER` 채널 enabled 시 백엔드가 `BffClient.sendNotificationDm` 으로 DM 발송 시도 (현재는 stub — warn.md 기록) [src: PHASE14 §8.6 T6-3].

---

## 8. 메일 (Stalwart JMAP 3단 레이아웃)

Stalwart 메일 서버는 Keycloak LDAP Federation 으로 인증을 위임받습니다 [src: scenarios.md §9, group_ware.md §Stalwart].

- **3단 레이아웃**: 좌(폴더 트리) + 중(메일 리스트) + 우(스레드 본문)
- 받은편지함 → 스레드 → 작성/임시저장/발송
- 알림용 시스템 메일은 BFF `/api/bff/mail/send` 로 backend-core 가 발송 (NotifyPref 의 EMAIL 채널 enabled 시) [src: PHASE14 §8.3]

---

## 9. 위키 (Wiki.js — 게스트 자동 가입)

Wiki.js 의 OIDC SSO 가 Keycloak 와 연동되어, **첫 로그인 시 사용자 계정이 Wiki.js 에 자동 프로비저닝**됩니다 [src: scenarios.md §10, group_ware.md §Wiki.js].

![Wiki.js SSO 화면](../../v3-wiki-sso.png)

페이지 탐색 → 편집(Markdown/WYSIWYG) → 히스토리 diff. 외부 게스트는 OIDC `roles` claim 에 `wiki-guest` 가 매핑되어 읽기 전용 또는 특정 namespace 한정 편집을 부여받습니다.

---

## 10. 화상회의 (LiveKit + view-only 폴백)

회의 생성 → 참가자 초대 → 룸 입장 → 화면 공유 [src: scenarios.md §11]. BFF `/api/bff/video/token` POST 로 LiveKit JWT 발급 → WebSocket `wss://...:19880` (101 Switching Protocols) → ICE `connected` 도달 시 자기 비디오 + 상대 RemoteTrack 수신.

**헤드리스 Playwright 자동 검증 불가** — 카메라/마이크 디바이스 부재로 Phase 12 F-8 에서 수동 검증 가이드 별도 작성 [src: docs/video-manual-check.md]. LiveKit 룸 자동 생성 실패 시 `view-only` 폴백 (Phase 12.1 패턴) — 예약은 성공, 화상은 입장 시 재시도 [src: PHASE14 §12].

![LiveKit 룸 입장](../../phase-c5-livekit-room-joined.png)
![화상회의 메인](../../v3-video.png)

수동 검증 통과 기준 (5종): token 200, WS 101, ICE connected, video readyState≥2, RemoteTrack 수신.

---

## 11. 모바일 호환성 — 미적용 솔직 진술

**현재 Phase 14 시점에서 모바일 전용 반응형 UI 는 적용되지 않았습니다.** 의도적으로 우선순위에서 제외:

- PrimeVue 4 의 일부 컴포넌트(FullCalendar, Tree+DataTable 동시 노출, 결재 9탭)는 데스크탑(≥1280px) 가정 설계
- 위젯 시스템(트랙 7)의 12-column CSS Grid 는 모바일 1-column 자동 스택 미구현
- 메신저/메일/위키/화상회의 외부 서비스는 각각 자체 모바일 앱(Rocket.Chat / IMAP 클라이언트 / Wiki.js PWA / LiveKit Mobile SDK) 으로 우회 가능

**권장 사용 환경**: 데스크탑 Chrome / Edge / Firefox 최신 (해상도 1280×800 이상). 모바일·PWA 는 본 챕터 작성 시점에서 **로드맵에 미반영**.

---

## 12. 참조

- `docs/scenarios.md` — 시나리오 1~23 (Phase 0~13 15종 + Phase 14 8종)
- `docs/PHASE14_PRODUCTION_GROUPWARE.md` — 8 트랙 사용자 기능 명세
- `docs/video-manual-check.md` — LiveKit 수동 검증 5분 가이드 (F-8)
- `docs/group_ware.md` — 외부 5개 서비스 API 매뉴얼
- `docs/approval.md` — 결재 도메인 + PageApproval.vue 덤프
- `docs/comprehensive/inventory/00_existing_artifacts.md` §4 — 32개 스크린샷 분류
- 루트 PNG (32개) — placeholder, PDF 빌드 단계에서 실제 인라인

---

## 13. 이 챕터가 다루지 않은 인접 주제

본 챕터는 **사용자 시점의 화면 흐름** 만 다룹니다. 인접 주제는 별도 챕터:

- 운영자 일상 운영(모니터링/백업/Flyway/시드) → Chapter 1.17 운영 매뉴얼
- 장애·이상 동작 대응(warn.md/fatal.md, 5회 자율 복구) → Chapter 1.18 트러블슈팅
- 신규 메뉴/페이지 추가 절차(cm_menu INSERT, useDataSet, 권한 매트릭스) → Chapter 1.19 개발 가이드
- 백엔드 DataSet 서비스 사양(95개 service I/O) → Chapter 1.5 API & 통신
- Keycloak Federation 5종 SSO 동작 원리(PKCE, OIDC claim, LDAP Federation) → Chapter 1.5 / 1.3
- 컴포넌트 재사용 규칙(vue-spring-fw 정적 복사) → Chapter 1.6
- Playwright MCP 시나리오 14종 자동화 → Chapter 1.14 테스트
- 모바일·PWA 로드맵 — 미수립 (§11 솔직 진술로 갈음)
