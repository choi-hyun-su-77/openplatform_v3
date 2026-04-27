# inventory/03_screen_types.md — 화면 형태 인벤토리

> Phase 0.D 산출물. UI 페이지·컴포넌트 클러스터링 결과 **9개 화면 형태** 도출.
> 후속 `screens/` 의 SOP 개수는 9개로 결정된다.

---

## 1. 형태 1 — 다건 목록 (List with Search & Filter)

- 한글: 다건 보기(목록) 화면
- English: DataTable List + Toolbar

**식별 기준 (필수)**
- `DataTable` + `Column` (PrimeVue) + `paginator` + `rowHover=true`
- 행 클릭 핸들러 → 상세 다이얼로그 또는 라우트 이동

**식별 기준 (선택)**
- `InputText` (키워드), `Select` (카테고리/상태), `Button` (액션)

**사용 시나리오**
- 다건 레코드 조회, 키워드 검색, 페이지네이션(10/20/50)
- 행 액션 또는 상세 다이얼로그로 편집/삭제
- 카테고리 필드(boardType / status / leaveType)로 필터

**레이아웃 스케치**
```
┌─ Header (Title + Action Buttons) ─────────────┐
├─ Toolbar (Search + Filter + Add) ─────────────┤
├─ DataTable (striped, hover) ───────────────────┤
│ ID │ Title │ Author │ Date │ Status            │
├──────────────────────────────────────────────┤
│ ... │ ...   │ ...    │ ...  │ <Tag>            │
├──────────────────────────────────────────────┤
│ Paginator (Page Size Selector)                 │
└──────────────────────────────────────────────┘
```

**대표 페이지**
- `[code: ui/src/pages/PageApproval.vue:9-88]` (9-box inbox + DataTable)
- `[code: ui/src/pages/PageBoard.vue:1-143]` (게시판)
- `[code: ui/src/pages/PageLeave.vue:29-71]` (휴가 신청 이력)
- `[code: ui/src/pages/admin/PageUsers.vue:12-39]` (사용자 lazy paginate)
- `[code: ui/src/pages/PageSearch.vue:50-118]` (통합검색 4탭 DataTable)

**핵심 컴포넌트**
- PrimeVue: `DataTable`, `Column`, `Paginator`, `Button`, `InputText`, `Select`, `Tag`
- Custom: `CrudToolbar`

**데이터 흐름**
- `onMounted`: `axios.post('/api/dataset/search')` (serviceName + filter datasets)
- 행 클릭: 상세 Dialog 또는 `router.push`
- 필터 변경: 300ms debounce → `load()`

---

## 2. 형태 2 — 단건 상세/편집 (Detail Dialog)

- 한글: 단건 보기/상세/편집 다이얼로그 화면
- English: Dialog Form + Tabbed Detail + Action Buttons

**식별 기준 (필수)**
- `Dialog` (`v-model:visible`) + 폼 필드 (`InputText`/`Textarea`/`Select`/`DatePicker`)
- 저장(신청) + 취소 버튼

**식별 기준 (선택)**
- `TabView` (다중 섹션), `Timeline` (결재선), `Divider`

**사용 시나리오**
- 목록 행 클릭 → 모달 오버레이
- 읽기 전용 상세 표시(결재 문서/게시글/사원)
- 편집 모드 + 검증 + 저장
- 다단계: 보기 → 편집 → 확인 → 저장

**레이아웃 스케치**
```
┌─ Dialog Header ─────────────────────────┐
├─ TabView (상세/편집/첨부) ───────────────┤
├─ Detail Pane ────────────────────────────┤
│ 결재 라인 (Timeline)                      │
│ 제목/기안자/날짜/내용                    │
├─ Footer (승인/반려/저장/취소) ────────────┤
└──────────────────────────────────────────┘
```

**대표 페이지**
- `[code: ui/src/components/approval/ApprovalDetailDialog.vue]` (결재 상세)
- `[code: ui/src/components/board/BoardDetailDialog.vue]` (게시글 + 댓글)
- `[code: ui/src/components/org/EmployeeDetailDialog.vue]` (직원 상세)
- `[code: ui/src/components/calendar/CalendarEventDialog.vue]` (일정 편집)

**핵심 컴포넌트**
- PrimeVue: `Dialog`, `TabView`, `TabPanel`, `Timeline`, `Divider`, `Button`, `InputText`, `Textarea`, `DatePicker`, `Tag`
- Custom: ApprovalDetailDialog, BoardDetailDialog, EmployeeDetailDialog

**데이터 흐름**
- 부모 → 자식: `docId`/`postId`/`employeeId` props
- 자식: `axios.get('/api/bff/.../:id')` 또는 `dataset/search`
- 폼 저장: `axios.post('/api/dataset/save', { datasets: { ds_data: [{ _rowType: 'U', ... }] } })`

---

## 3. 형태 3 — 마스터-디테일 분할 (Split-Panel Master-Detail)

- 한글: 마스터-디테일 분할 화면
- English: Left (Tree/List) + Right (Detail/Editor)

**식별 기준 (필수)**
- 좌측 = `Tree` 또는 list sidebar, 우측 = content editor/detail
- `display: grid; grid-template-columns: <width> 1fr` (고정폭 좌측)
- 좌측 항목 선택 → 우측 자동 갱신

**사용 시나리오**
- 계층 탐색(부서→직원, 폴더→파일)
- 맥락 인식 편집(선택 폴더의 파일만 표시)
- Tree expand/collapse + depth navigation
- worklog: 좌측 캘린더 + 우측 editor

**레이아웃 스케치**
```
┌────────────────┬──────────────────────────┐
│ Tree           │ Right Detail              │
│ ├ 회사         │ DataTable (파일 목록)      │
│ │ ├ 부서A      │ 선택: 문서1                │
│ │ │ └ 문서1    │ [다운로드][삭제]           │
│ └ ...          │                            │
└────────────────┴──────────────────────────┘
```

**대표 페이지**
- `[code: ui/src/pages/PageOrg.vue:1-116]` (부서Tree + 직원cards; 280px:1fr)
- `[code: ui/src/pages/PageDataLibrary.vue:14-140]` (폴더Tree + 파일DataTable; 240px:1fr)
- `[code: ui/src/pages/PageMail.vue:117-134]` (mailbox + list + detail; 200px:360px:1fr)
- `[code: ui/src/pages/PageWorkLog.vue:36-83]` (calendar + DailyEditor; 280px:1fr)

**핵심 컴포넌트**
- PrimeVue: `Tree`, `DataTable`, `InputText`, `Button`
- Custom: FolderActions, DailyEditor, EmployeeDetailDialog, MailboxTree

**데이터 흐름**
- 좌측 클릭: `selectedFolder/Dept/Node` 설정
- 우측 watch: 파일/직원/메일 reload
- Tree 검색 300ms debounce

---

## 4. 형태 4 — 캘린더 그리드 (Calendar with Event Management)

- 한글: 캘린더 그리드 화면
- English: FullCalendar + Event Dialog

**식별 기준 (필수)**
- `FullCalendar` (vue3) with `dayGridPlugin`, `timeGridPlugin`
- 이벤트 클릭 → Dialog 생성/편집
- 드래그/리사이즈 (`editable=true`)
- 범위 필터 (PERSONAL/DEPT/COMPANY)

**사용 시나리오**
- 개인/팀 일정 month/week/day
- date-click 또는 time-select 로 신규 일정
- Dialog 로 제목/시작/종료 편집
- 회의실 예약: 캘린더 + room sidebar
- 회의실 가용성 시각화

**레이아웃 스케치**
```
┌─ Toolbar (Scope + Add Event) ───────────────┐
├─ FullCalendar Grid ─────────────────────────┤
│ Mon │ Tue │ Wed │ Thu │ Fri               │
│      [회의]   [휴가]                          │
└─────────────────────────────────────────────┘
```

**대표 페이지**
- `[code: ui/src/pages/PageCalendar.vue:1-182]` (개인 캘린더)
- `[code: ui/src/pages/PageRoom.vue:31-42]` (room list + timeGridWeek; 240px:1fr)
- `[code: ui/src/components/worklog/DailyEditor.vue]` (DatePicker inline)

**핵심 컴포넌트**
- PrimeVue: `SelectButton`, `Button`, `Dialog`
- 외부: `FullCalendar` (`dayGridMonth`, `timeGridWeek`, `timeGridDay`)
- Custom: `CalendarEventDialog`, `MonthlyCalendar` (근태 위젯)

**데이터 흐름**
- `onMounted`: `searchEvents(start, end, scope)` POST
- `dateClick`/`eventClick`: Dialog 오픈
- `eventDrop`/`eventResize`: 배치 update (`_rowType: 'U'`)

---

## 5. 형태 5 — 대시보드 위젯 그리드 (Dashboard Widget Grid)

- 한글: 대시보드 위젯 그리드
- English: 12-Column Grid + Resizable Widgets + Edit Mode

**식별 기준 (필수)**
- `display: grid; grid-template-columns: repeat(12, 1fr)`
- 위젯 컴포넌트 맵 (ATTENDANCE / LEAVE_BALANCE / PENDING_APPROVAL / TODAY_EVENTS / NEWS / WORK_REPORT 등)
- 편집 모드: 크기 조정(±W/±H), 삭제(×), 저장/취소

**식별 기준 (선택)**
- 위젯 picker Dialog

**사용 시나리오**
- 사용자별 맞춤 대시보드
- 위젯 추가/삭제/리사이즈
- 위젯별 KPI 표시 (근태/연차/대기 결재)
- 편집 버튼으로 overlay 컨트롤 토글

**레이아웃 스케치**
```
┌─ Header (편집 / 위젯추가 / 저장) ────────────┐
├─ 12-Col Grid ─────────────────────────────┤
│ ┌Widget(4×1)─┐ ┌Widget(4×2)─┐               │
│ │ Attendance │ │LeaveBalance│               │
│ └────────────┘ └────────────┘               │
│ ┌Widget(12×1)──────────────┐                │
│ │ Today Events             │                │
│ └──────────────────────────┘                │
└─────────────────────────────────────────────┘
```

**대표 페이지**
- `[code: ui/src/pages/PageDashboard.vue:1-375]` (위젯 그리드 + edit mode)

**핵심 컴포넌트**
- PrimeVue: `Button`, `Card`
- Custom: WidgetAttendance / WidgetLeaveBalance / WidgetPendingApproval / WidgetTodayEvents / WidgetNews / WidgetWorkReport
- Grid CSS: `--w` (1-12), `--h` (1-3) CSS 변수, `order` 로 reflow

**데이터 흐름**
- `onMounted`: `widget/listMine` + `widget/listAll`
- 편집 모드: 스냅샷 저장(취소용)
- 저장: 배치 `widget/saveLayout` (position/size + `_rowType: 'D'` 삭제)

---

## 6. 형태 6 — 다단계 입력/신청 다이얼로그 (Multi-Step Submit Dialog)

- 한글: 다단계 입력/신청 다이얼로그
- English: Multi-Step Submission Dialog

**식별 기준 (필수)**
- `Dialog` (modal) + 폼 필드 + `form_code` 프리셋 (LEAVE / EXPENSE / PURCHASE / TRIP)
- 신청 버튼 + 필드 검증

**식별 기준 (선택)**
- 단계 표시(Step 1: 기본 → Step 2: 첨부 → Step 3: 결재선)
- 결재선 자동/수동 선택

**사용 시나리오**
- 결재 문서 신규 (휴가/지출/구매/출장)
- `form_code` 에 따라 필드 표시 분기
- 다단계: 기본정보 → 첨부 → 결재선 → 신청
- 인라인 다이얼로그(PageLeave / PageApproval 재사용)

**레이아웃 스케치**
```
┌─ Dialog (신규 문서 신청) ────────────────┐
├─ Step Indicator (1 → 2 → 3) ─────────────┤
├─ Form Panel ────────────────────────────┤
│ 제목/기간/사유/첨부                       │
├─ 결재선 선택 ────────────────────────────┤
├─ Footer (이전 / 다음 / 신청) ─────────────┤
└──────────────────────────────────────────┘
```

**대표 페이지**
- `[code: ui/src/components/approval/ApprovalSubmitDialog.vue:1-200]`
- `[code: ui/src/pages/PageLeave.vue:74-78]` (`initial-form-code='LEAVE'`)

**핵심 컴포넌트**
- PrimeVue: `Dialog`, `Dropdown`, `InputText`, `InputNumber`, `Textarea`, `DatePicker`, `Button`, `Tag`
- Custom: `FileUploadPanel`, `ApprovalActionBar`

**데이터 흐름**
- 부모 → 자식: `v-model:visible`, `initial-form-code`
- Submit: 검증 → `approval/submitDoc`
- 응답: `docId` `@submitted` emit

---

## 7. 형태 7 — 외부 iframe / SSO 래퍼 (External SSO Wrapper)

- 한글: 외부 iframe/SSO 래퍼 화면
- English: Keycloak SSO → External App Launcher

**식별 기준 (필수)**
- 최소 Vue 템플릿 (헤더 카드 + SSO 버튼만)
- `window.open(ssoUrl, '_blank')` → Keycloak OAuth → 외부 앱
- 임베디드 iframe 사용하지 않음 (보안: separate origin)
- SSO URL 구성 (clientId, redirectUri, state, scope)

**사용 시나리오**
- Wiki.js / Rocket.Chat / Mail / MinIO / LiveKit 진입
- 보안: 임베디드 iframe 금지
- 단일 호스트 `kc.localtest.me` SSO 쿠키 공유

**레이아웃 스케치**
```
┌─ Page ──────────────────────────────────┐
│ ┌ SSO Panel (gradient) ────────────────┐ │
│ │ 📖 위키 (Wiki.js)                     │ │
│ │ Keycloak SSO 로 위키 열기              │ │
│ │ [위키 열기] (외부 링크)                │ │
│ └──────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**대표 페이지**
- `[code: ui/src/pages/PageWiki.vue:1-37]` (위키 SSO)
- `[code: ui/src/pages/PageMessenger.vue:1-45]` (RC OAuth)
- `[code: ui/src/pages/PageMail.vue:1-114]` (Mail IMAP UI)
- `[code: ui/src/pages/PageVideo.vue:1-156]` (LiveKit room)

**핵심 컴포넌트**
- PrimeVue: `Button`, `InputText` (room name 등)
- 외부: `livekit-client` (WebRTC), FullCalendar (room booking)

**데이터 흐름**
- SSO: OAuth URL 구성 → `window.open(ssoUrl, '_blank')`
- LiveKit: `POST /api/bff/video/token` → `Room.connect`
- Mail: `GET /api/bff/mail/mailboxes` (IMAP proxy)

---

## 8. 형태 8 — 실시간 협업 (Real-Time SSE / Live Updates)

- 한글: 실시간 SSE/Video room 화면
- English: Real-Time SSE + Live Video Tiles

**식별 기준 (필수)**
- WebSocket / EventSource SSE 연결로 라이브 업데이트
- reactive 상태 동기화(결재 상태 변경, 비디오 타일)
- 우아한 disconnect + reconnect

**식별 기준 (선택)**
- `RoomEvent` 리스너 (ParticipantConnected / TrackSubscribed)

**사용 시나리오**
- 비디오 룸: local + remote tiles, mic/cam toggle
- 결재 알림: SSE → NotificationBell push
- worklog 실시간 팀 그리드 업데이트
- 출근 체크인 broadcast

**레이아웃 스케치**
```
┌─ Room (dark bg) ─────────────────────────┐
│ 🎥 v3-general (정원 8명)                 │
│ ┌─ Video Grid (tiles) ───────────────┐  │
│ │ [Local Me]  [김철수]               │  │
│ │ [이영희]    [박동준]               │  │
│ └────────────────────────────────────┘  │
│ [마이크 OFF][카메라 OFF][나가기]         │
└─────────────────────────────────────────┘
```

**대표 페이지**
- `[code: ui/src/pages/PageVideo.vue:38-156]`
- `[code: ui/src/pages/PageAttendance.vue:13-87]` (실시간 출근 + 월 캘린더)
- `[code: ui/src/components/layout/NotificationBell.vue]` (SSE OverlayPanel)

**핵심 컴포넌트**
- PrimeVue: `Button`, `OverlayPanel`
- 외부: `livekit-client` (Room, RoomEvent, createLocalTracks, Track.Kind)
- Custom: Pinia store 로 상태 동기화

**데이터 흐름**
- Video: `RoomEvent.ParticipantConnected` → reactive array push → tile 렌더
- Notification: `EventSource` SSE → `NotificationBell` 갱신
- 폴링 없이 실시간 mutate

---

## 9. 형태 9 — 폼 매트릭스 (Form Matrix / 설정)

- 한글: 복합 폼/설정 매트릭스 화면
- English: Form Grid with In-Place Edits + Batch Save

**식별 기준 (필수)**
- 셀 단위 폼 컨트롤(toggle/select/text)을 가진 DataTable
- 배치 저장 버튼 (모두 저장)

**식별 기준 (선택)**
- 기본값 reset 버튼

**사용 시나리오**
- 알림 설정: 카테고리 × 채널 매트릭스 (ToggleButton)
- 관리자 코드 마스터: tree + detail
- 권한 매트릭스: 역할 × 메뉴 × 권한

**레이아웃 스케치**
```
┌─ Header (기본값/저장) ────────────────────┐
├─ DataTable (Matrix) ──────────────────────┤
│ 카테고리 │ 포탈(ON/OFF) │ 이메일           │
│ 결재     │ [ON]         │ [OFF]            │
│ 게시판   │ [ON]         │ [ON]             │
│ 회의실   │ [OFF]        │ [ON]             │
└──────────────────────────────────────────┘
```

**대표 페이지**
- `[code: ui/src/pages/PageNotifySettings.vue:41-78]`
- `[code: ui/src/pages/admin/PageCodes.vue]` (코드 마스터 tree + detail)

**핵심 컴포넌트**
- PrimeVue: `DataTable`, `Column`, `ToggleButton`, `Button`, `Select`

**데이터 흐름**
- `onMounted`: 매트릭스 데이터 fetch
- 셀 변경: 로컬 상태 update (즉시 저장 X)
- Save: 배치 POST (`ds_matrix: [...]`)

---

## 10. 형태별 SOP 매핑

| 형태 | screens 파일 | 모범 페이지 |
|---|---|---|
| 1 다건 목록 | `screens/01_list_with_search.md` | PageBoard / PageApproval |
| 2 단건 상세 | `screens/02_detail_dialog.md` | ApprovalDetailDialog |
| 3 마스터-디테일 | `screens/03_master_detail.md` | PageDataLibrary |
| 4 캘린더 | `screens/04_calendar_grid.md` | PageCalendar / PageRoom |
| 5 대시보드 | `screens/05_dashboard_widgets.md` | PageDashboard |
| 6 다단계 입력 | `screens/06_multistep_dialog.md` | ApprovalSubmitDialog |
| 7 SSO 래퍼 | `screens/07_sso_wrapper.md` | PageWiki / PageMessenger |
| 8 실시간 | `screens/08_realtime.md` | PageVideo / NotificationBell |
| 9 폼 매트릭스 | `screens/09_form_matrix.md` | PageNotifySettings |

## 11. 데이터 흐름 패턴 (전 화면 형태 공통)

| 패턴 | 호출 형태 | 응답 위치 |
|---|---|---|
| A. DataSet POST | `axios.post('/api/dataset/search', { serviceName, datasets })` | `response.data.data.<ds_*>.rows` |
| B. REST GET | `axios.get('/api/bff/.../id')` | `response.data` |
| C. SSO 래퍼 | `window.open(${kcBase}/realms/{realm}/protocol/openid-connect/auth?...)` | (외부 redirect) |
| D. WebSocket/LiveKit | `new Room().connect(wsUrl, token)` + `RoomEvent.*` 리스너 | reactive 상태 |
| E. SSE | `new EventSource('/api/notification/subscribe?token=...')` | `onmessage` 핸들러 |
