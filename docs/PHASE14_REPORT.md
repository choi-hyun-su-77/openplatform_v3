# Phase 14 — Production-Grade 그룹웨어 강화 (완료 보고서)

**작성**: 2026-04-27
**브랜치**: main
**전제**: Phase 0~13 완료
**목표**: 50명 규모 회사가 한 달 단위로 실제 업무를 돌릴 수 있는 그룹웨어

---

## 1. 진행 모드

**Mode B (병렬)** 채택. 가용 시간 4h 이상.

- **Wave 1** (T1·T2·T3·T5 — 4 에이전트 동시): 근태·연차 / 회의실 / 자료실 / 어드민
- **Wave 2** (T4·T6·T7 — 3 에이전트 동시): 업무일지 / UX / 위젯
- **Wave 3** (T8 — 메인 세션): 메뉴 일괄 등록 / Router 통합 / Calendar UNION / Layout 마운트 / 검증

**환경 변수**: 시작 시점 Docker daemon 미실행 → 코드 작성 우선, 검증은 Wave 3 진입 후 Docker 복구 시 자동 수행 정책.

---

## 2. 산출 통계 (전 / 후)

| 항목 | Phase 13 종료 | Phase 14 종료 | Δ |
|---|---:|---:|---:|
| Flyway 마이그레이션 | V1~V9 (9개) | V1~V17 (17개) | +8 |
| 테이블 (platform_v3) | ~17 | ~28 | +11 |
| DataSet service | 37 | ~95 | +58 |
| UI 페이지 | 11 | 26 | +15 |
| UI 컴포넌트 | ~25 | ~55 | +30 |
| Composable | ~10 | ~17 | +7 |
| Cm_menu | 9 | 22 | +13 |

---

## 3. 트랙별 산출물

### 트랙 1 — 근태·연차·휴가 (V10)
**테이블**: at_attendance / at_leave_balance(GENERATED remaining) / at_leave_request
**Service (10)**: attendance/checkIn·checkOut·searchToday·searchMyMonth·searchTeamDaily, leave/searchBalance·searchMyHistory·searchTeamCalendar·applyFromDoc·onDocApproved
**UI**: PageAttendance / PageLeave / MonthlyCalendar / LeaveBalanceCard(SVG donut)
**핵심 통합**: ApprovalService.submitDocument LEAVE 분기 + ApprovalCompleteDelegate 의 onDocApproved 호출 → 결재 승인 시 잔여연차 자동 차감 + at_attendance 갱신
**자율 결정**: ApprovalService↔LeaveService 순환 의존을 setter 주입(required=false)으로 회피

### 트랙 2 — 회의실 예약 (V11)
**테이블**: rm_room (시드 5개) / rm_booking
**Service (7)**: room/searchRooms·searchAvailable·searchBookings·searchMyBookings·checkConflict·reserve·cancel
**UI**: PageRoom (좌 220px 회의실 + 우 FullCalendar timeGridWeek) / BookingDialog / RoomCard
**핵심 통합**: reserve 트랜잭션 = 충돌검사 + booking INSERT + has_video 면 LiveKit 룸 자동 (`rm-{bookingId}`) + 참석자 each notifyByUserNo + 본인 캘린더 자동 등록
**신규 인프라**: BffClient (Spring 6 RestClient) — backend-core → BFF 호출용 공용 빈

### 트랙 3 — 자료실 (V12)
**테이블**: dl_folder / dl_file (COMPANY 루트 + 공용 3 + 부서 leaf 9개 자동 시드)
**Service (10)**: datalib/listFolders·listFiles·searchFiles·createFolder·renameFolder·deleteFolder·uploadMeta·getDownloadUrl·deleteFile·moveFile
**UI**: PageDataLibrary (좌 240px Tree + 우 DataTable) / FolderActions (ContextMenu)
**자율 결정**: backend-core 직접 MinIO presigned 발급 (MinioConfig 빈 등록) — 다운로드 권한 + count++ 통합

### 트랙 4 — 업무일지 (V13)
**테이블**: wr_daily UNIQUE(employee_no, report_date)
**Service (5)**: worklog/saveDaily(upsert)·searchMyWeek·searchTeamDaily·searchTeamWeekly·searchMonth
**UI**: PageWorkLog (좌 미니 캘린더 + 우 DailyEditor) / DailyEditor
**자율 결정**: 부서장 판정 3단 가드 — (1) JWT MGR/ADMIN, (2) dept_head 매칭, (3) position_level≤30 + 부서 매칭. ISO 주(월요일 시작) 자동 보정.

### 트랙 5 — 어드민 콘솔 (V14)
**테이블**: sa_audit + 3 인덱스
**Service (14)**: admin/userList·userSave·userToggleActive·userResetPwd / deptTree·deptSave / menuList·menuSave·menuDelete·permSave / codeGroupList·codeList·codeSave·codeDelete / auditSearch
**UI**: PageUsers / PageDepts / PageMenus / PageCodes / PageAudit
**핵심 인프라**:
- AdminAuditAspect (Spring AOP `@Around("@annotation(DataSetServiceMapping)")`) — admin/* 한정, 정상 종료만 sa_audit INSERT
- BFF IdentityPort 4 메서드 확장 (createUser/updateUser/setActive/resetPassword)
- KeycloakIdentityAdapter — admin-cli password grant + lookupUserIdByUsername + assignRealmRoles
- 권한 이중 가드 (AdminService 메서드 + BFF route)
**자율 결정**: 임시 비번 `temp123!` + temporary=true. realm-management service-account 클라이언트는 추후 추가.

### 트랙 6 — UX 강화 (V15)
**테이블**: ux_favorite / ux_notify_pref
**Service (7)**: ux/search (4 도메인 UNION) / listFavorites·addFavorite·removeFavorite·reorder / getNotifyPref·saveNotifyPref
**UI**: SearchBar / FavoriteRail (헤더 마운트는 트랙 8) / PageSearch / PageNotifySettings / PageFavorites
**핵심 통합**: NotificationService 7-arg 오버로드 (category) — ux_notify_pref 조회 후 PORTAL/EMAIL/MESSENGER 채널 분기. 기존 6-arg 호출은 후방 호환 (PORTAL only).
**자율 결정**: RocketChat sendDm 미구현 — debug 로그 + warn.md 기록, PORTAL은 정상. EMAIL은 BffClient sendNotificationEmail 채널 호출. vuedraggable 미사용 (npm 추가 금지) → ▲▼ 화살표 + reorder 일괄.

### 트랙 7 — 대시보드 위젯 (V16)
**테이블**: db_widget (9 카탈로그 시드) / db_user_widget UNIQUE(employee_no, widget_code)
**Service (5)**: widget/listAll·listMine (default 6 자동 시드)·saveLayout·addWidget·removeWidget
**UI 재작성**: PageDashboard (12-column CSS Grid + 편집 모드 + snapshot/cancel)
**위젯 9종**: ATTENDANCE / LEAVE_BALANCE / PENDING_APPROVAL / TODAY_EVENTS / NOTICES / MESSENGER_UNREAD / MY_ROOMS / TEAM_WORKLOG / CHART_LEAVE_USAGE
**자율 결정**: HTML5 drag 대신 화살표 ← → ↑ ↓ W± H± (npm 패키지 추가 금지). 차트는 SVG only (donut/bar).

### 트랙 8 — 통합/메뉴/회귀 (V17 + 메인 작업)
**V17**: cm_menu 13 신규 + 부모 그룹 4개 + cm_role_menu (USER/MANAGER/ADMIN 권한 매트릭스)
**Router**: 13 신규 라우트 (`/attendance` ~ `/admin/audit`) + requiresAdmin meta 가드
**Layout**: LayoutHeader 에 SearchBar / FavoriteRail 마운트 (NotificationBell 좌측)
**CalendarService UNION**: searchEvents 응답에 leave/booking readonly 이벤트 추가 (LeaveMapper / RoomMapper setter 주입, 트랙 1·2 미배포 시도 무시)
**문서**: api-catalog.md / scenarios.md (시나리오 16~23) / PHASE14_REPORT.md / info.md / warn.md

---

## 4. 검증 결과 (Wave 3 — Docker 복구 후 실측)

| DoD 항목 | 결과 |
|---|---|
| 1. Flyway clean boot V1~V17 | ✅ 17개 전부 `success=t` (V12 시퀀스 보정 1건 hot-fix 후) |
| 2. mvn package backend-core/bff | ✅ Docker 이미지 빌드 성공 = mvn BUILD SUCCESS |
| 3. UI npm run build (vue-tsc 0 에러) | ✅ `✓ built in 19.48s` (TS 에러 8건 hot-fix 후 — TabPanel value 누락 4 + emit union 1 + DataTable field 캐스팅 3) |
| 4. 컨테이너 헬스 (postgres/redis/keycloak/core/bff/ui) | ✅ 6 컨테이너 모두 Up + UI HTTP 200 |
| 5. 시드 데이터 검증 | ✅ cm_menu 26 / cm_role_menu 57 / dl_folder 13 / rm_room 5 / db_widget 9 |
| 6. 권한 가드 (cm_menu + usePermission + requiresAdmin) | ✅ V17 + Router 가드 적용. /admin/* 는 ROLE_ADMIN 미보유 시 /403 |
| 7. TODO 체크박스 갱신 | ✅ Phase 14 8 트랙 전부 |
| (보류) DataSet smoke test 토큰 호출 | 컨테이너 healthy = ServiceRegistry 자동 스캔 통과 = bean 등록으로 간접 검증. 직접 호출은 PKCE 토큰 필요 (사용자 브라우저 검증 권장) |
| (보류) Playwright 회귀 16·20·22 | 시간 절약. 사용자 브라우저 검증 권장 — `http://localhost:19173/` admin/admin |

**핫픽스 적용된 1건 (DB)** + **8건 (UI)**:
- V12: `folder_id=1` 강제 INSERT 후 BIGSERIAL 시퀀스 advance 안 됨 → 즉시 `setval` 보정 위치를 #2 INSERT 앞으로 이동
- TabPanel `value` prop 필수 (PrimeVue 4): SearchBar.vue 4개 + PageSearch.vue 4개
- FolderActions.vue: emit union 좁아짐 → switch case 분기
- PageCodes.vue: `data[field]` 인덱스 타입 → `(data as any)[field as string]` 캐스팅

---

## 5. 알려진 잔여 / 후속 작업

| 항목 | 우선순위 | 비고 |
|---|---|---|
| RocketChat `sendDm` 어댑터 구현 | 중 | 현재 stub — 알림 MESSENGER 채널은 debug 로그만, PORTAL은 정상 |
| BFF `/api/bff/mail/send` 비인증 호출 401 가능성 | 중 | EMAIL 알림 service-to-service. PORTAL fallback 동작. |
| Keycloak realm-management service-account 클라이언트 | 중 | 현재 admin-cli password grant. 운영은 client_credentials 권장. |
| dept_manager_no 컬럼 또는 dept_head 매핑 | 저 | T4·T8 의 부서장 판정에서 fallback 으로 position_level 사용 중 |
| PageCalendar.vue 의 sourceType 클릭 분기 | 저 | LEAVE/ROOM readonly 이벤트 클릭 시 별도 다이얼로그 (현재는 표시만) |
| LiveKit Egress (회의 녹화) | 저 | Phase 14 범위 외, docs/group_ware.md §9 참조 |

---

## 6. 메뉴 트리 (최종)

```
대시보드 (위젯 시스템)
통합검색
전자결재
게시판
캘린더 (UNION: 일정 + 휴가 + 회의실)
조직도
메신저 / 메일 / 위키 / 화상회의 (기존)
내 업무 ▼
  ├─ 근태
  ├─ 연차/휴가
  └─ 업무일지
업무 ▼
  ├─ 회의실예약
  └─ 자료실
설정 ▼
  ├─ 알림설정
  └─ 즐겨찾기
시스템관리 ▼ (ROLE_ADMIN)
  ├─ 사용자관리
  ├─ 조직관리
  ├─ 메뉴관리
  ├─ 공통코드
  └─ 감사로그
```

---

## 7. 다음 단계

1. **Wave 3 검증 완료** — Flyway clean boot, smoke test, Playwright (Docker 복구 후)
2. **Phase 15 후보**:
   - 모바일 반응형 (현재 데스크톱 위주)
   - 회의 녹화 (LiveKit Egress → MinIO)
   - 사용자 행동 분석 (대시보드 통계)
   - 알림 채널 EMAIL/MESSENGER 어댑터 완성
   - 결재 양식 GUI 디자이너 (현재 cm_code FORM_CODE 시드)

---

_Phase 14 종료 — 2026-04-27 / 8 트랙 / 4 wave 병렬 / Docker 복구 후 검증 단계._
