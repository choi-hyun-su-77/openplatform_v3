# Chapter 1.7: Frontend Components & UI Architecture

**OpenPlatform v3** 프론트엔드는 **Vue 3 + PrimeVue 4** 기반의 70+ 컴포넌트로 구성된 엔터프라이즈급 SPA입니다.

---

## 1. PrimeVue 4 채택 배경

원래 vue-spring-fw 프로젝트에서 PrimeVue 을 채택했으므로, 팀 역량을 재사용하면서 80+ 컴포넌트와 Material Design 기반 Theme 시스템을 활용합니다.

| 항목 | 이유 |
|------|------|
| **컴포넌트 수** | 80+ 공식 컴포넌트 (Button, DataTable, Dialog, Calendar 등) |
| **License** | MIT (무료, 상용 이용) |
| **Design** | Material Design 기반 |
| **TypeScript** | 정식 타입 정의 포함 |
| **접근성** | WCAG 2.1 AA 준수 |
| **성능** | Virtual scroller (대규모 데이터) |

**버전**: primevue@4.3.0, @primevue/themes@4.3.0, primeicons@7.0.0

---

## 2. 다중 패널 패턴

OpenPlatform v3 의 핵심은 **Grid/List + Detail + Chart/Status + Form** 4-패널 구조입니다.

### PageApproval.vue (결재함)

```
Left Panel: 9-box nav     |  Right Panel: DataTable
- DRAFT                  |  docId | 제목 | 작성자
- MY_DOCS               |  ─────────────────────
- PENDING (5)           |  상태 Tag | 페이지네이션
- ...                   |
```

**데이터 흐름**:
1. selectBox(code) → approval.searchInbox()
2. DataTable 갱신
3. row-click → ApprovalDetailDialog open
4. TabView (4탭): 내용 / 결재선 / 첨부 / 이력
5. ApprovalActionBar (footer): 승인/반려/위임
6. 변경 시 @changed emit → reload()

**출처**: /ui/src/pages/PageApproval.vue

### PageBoard.vue (게시판)

**구조**: Toolbar → DataTable → Detail Dialog → Form Dialog

**컴포넌트**:
- BoardDetailDialog (상세 + CommentThread)
- BoardFormDialog (작성/수정 + FileUploadPanel)

**md-editor-v3 준비**: Package.json 에 포함 (아직 미사용)

**출처**: /ui/src/pages/PageBoard.vue

### PageDashboard.vue (대시보드)

**특징**: 12-column CSS Grid + 동적 위젯 (add/remove/resize)

**컴포넌트 로드**:
```typescript
const COMPONENT_MAP: Record<string, Component> = {
  ATTENDANCE: WidgetAttendance,
  LEAVE_BALANCE: WidgetLeaveBalance,
  PENDING_APPROVAL: WidgetPendingApproval,
  TODAY_EVENTS: WidgetTodayEvents,
  NOTICES: WidgetNotices,
  MESSENGER_UNREAD: WidgetMessenger,
  MY_ROOMS: WidgetMyRooms,
  TEAM_WORKLOG: WidgetTeamWorklog,
  CHART_LEAVE_USAGE: WidgetLeaveChart
};
```

**레이아웃 저장**: _rowType ('C'=new, 'U'=update, 'D'=delete)

**출처**: /ui/src/pages/PageDashboard.vue

---

## 3. 컴포넌트 카탈로그 (45개)

### Layout (8개)
LayoutDefault, LayoutHeader, LayoutSidebar, LayoutTabBar, LayoutTopNav, FavoriteRail, SearchBar, ThemeSettingsDrawer

### Approval (5개)
ApprovalActionBar, ApprovalDetailDialog, ApprovalLineTimeline, ApprovalSubmitDialog, ApprovalAttachmentList

### Board (3개)
BoardFormDialog, BoardDetailDialog, CommentThread

### Dashboard Widgets (9개)
WidgetAttendance, WidgetLeaveBalance, WidgetLeaveChart, WidgetMessenger, WidgetMyRooms, WidgetNotices, WidgetPendingApproval, WidgetTodayEvents, WidgetTeamWorklog

**갱신 주기**:
- 5분: WidgetPendingApproval (poll), WidgetMessenger
- 1시간: WidgetAttendance, WidgetMyRooms, WidgetNotices, WidgetTodayEvents, WidgetTeamWorklog
- Daily: WidgetLeaveBalance, WidgetLeaveChart

### Common (8개)
CrudToolbar, FileUploadPanel, LoadingSkeleton, NotificationBell, AppActionSpeedDial, AppContextSpeedDial, PopupHost, SearchPanel

### Other (12개)
- calendar: CalendarEventDialog
- mail: MailboxTree, EmailList, EmailDetail, ComposeDialog
- org: EmployeeDetailDialog
- room: BookingDialog, RoomCard
- attendance: MonthlyCalendar
- leave: LeaveBalanceCard
- datalib: FolderActions
- worklog: DailyEditor

**출처**: /ui/src/components/*.vue (45 files total)

---

## 4. FullCalendar 6.1.20 통합

**사용처**: PageCalendar.vue

**기능**:
- 월/주/일 뷰 (dayGridMonth, timeGridWeek, timeGridDay)
- 드래그-드롭 이동 (eventDrop)
- 크기 조정 (eventResize)
- 공휴일 배경 표시
- 한국어 locale

**핵심**:
```typescript
eventDrop: handleEventDrop,  // 이동 후 API 저장
eventResize: handleEventResize  // 크기 조정 후 API 저장
```

**출처**: /ui/src/pages/PageCalendar.vue (lines 1-182)

---

## 5. LiveKit Client 2.18.1 통합

**사용처**: PageVideo.vue

**특징**: Keycloak SSO 기반 WebRTC (P2P + SFU)

**핵심**:
```typescript
room = new Room({ adaptiveStream: true, dynacast: true });
room.on(RoomEvent.ParticipantConnected, ...);
room.on(RoomEvent.TrackSubscribed, ...);
await room.connect(wsUrl, token);

// 카메라/마이크 권한 없으면 view-only 폴백
try {
  const tracks = await createLocalTracks({ audio: true, video: true });
} catch (mediaErr) {
  console.warn('view-only 모드:', mediaErr);
  micOn.value = false;
  camOn.value = false;
}
```

**중요**: 미디어 권한 거부 시 view-only 모드로 폴백 가능

**출처**: /ui/src/pages/PageVideo.vue (lines 1-156)

---

## 6. md-editor-v3 6.4.1

**상태**: 패키지 포함, 사용 대기 중

**용도**: 마크다운 WYSIWYG 에디터 (이미지 업로드, syntax highlighting)

**예상**: BoardFormDialog 내용 필드 교체 (Phase 15+)

**현재**: 미사용 (Textarea 로 충분)

---

## 7. 컴포넌트 이름 규칙

**본 프로젝트 명시적 규칙**:

| 접두사 | 용도 | 예시 |
|--------|------|------|
| Page* | 라우트 페이지 | PageApproval, PageBoard |
| Layout* | 레이아웃 | LayoutDefault, LayoutHeader |
| Widget* | 위젯 | WidgetAttendance |
| App* | 전역 UI | AppActionSpeedDial |
| [도메인]Dialog | 모달 | ApprovalDetailDialog |
| 기타 | 도메인+역할 | NotificationBell, SearchBar |

**❌ 미사용**: Cm* prefix (vue-spring-fw 스타일)

**이유**: 명시적 목적을 이름에 반영 → 자가 문서화

---

## 8. 상태 관리 (Pinia, 3 stores)

- **auth.ts**: user, tokens, roles, menus (localStorage + sessionStorage)
- **notification.ts**: notifications[], unreadCount (SSE 스트림)
- **tab.ts**: openTabs[] (sessionStorage, 탭별 독립)

---

## 9. Composables (23개)

주요: useApproval, useAttendance, useLeave, useRoom, useDataLibrary, useCodes, useMessage, usePermission, useWidget, useTheme, useNotificationSse

**패턴**:
```typescript
const { documents, load } = useApproval();
const { success, error } = useMessage();
onMounted(() => load());
```

**출처**: /ui/src/composables/*.ts

---

## 참조

**1차 입력**: /docs/comprehensive/inventory/04_frontend.md

**핵심 소스**:
- /ui/src/pages/PageApproval.vue — 4-패널
- /ui/src/pages/PageBoard.vue — 3-패널
- /ui/src/pages/PageDashboard.vue — 12-col Grid
- /ui/src/pages/PageCalendar.vue — FullCalendar
- /ui/src/pages/PageVideo.vue — LiveKit
- /ui/src/components/{layout,approval,board,dashboard,common}/*.vue
- /ui/package.json

**관련**:
- Chapter 1.3 — 라우터 (27+ 라우트)
- Chapter 1.4 — Pinia 상태 관리
- Chapter 1.5 — Axios 인터셉터
- Chapter 1.6 — Keycloak SSO

---

## 이 챕터가 다루지 않은 인접 주제

1. CSS/Styling — PrimeVue 테마, CSS Variables, Scoped styles
2. 테스트 — 단위/통합/e2e 테스트 전략
3. 성능 — Code splitting, Virtual scroller, Lazy loading
4. 접근성 (a11y) — WCAG 준수, 스크린리더
5. i18n — 다국어 (4언어: ko, en, ja, zh-CN)
6. Form 검증 — Client-side validation, Schema
7. 디버깅 — Vue DevTools, 성능 프로파일링
8. Vite 빌드 — 번들 분석, Production sourcemaps
9. WebSocket — 실시간 통신 (SSE만 다룸)
10. 컴포넌트 라이브러리 — npm publish 패키지화

---

**작성**: 2026-04-27  
**버전**: OpenPlatform v3.0.0  
**대상**: 프론트엔드 개발자, UI/UX 엔지니어, 신규 팀원  
**크기**: ~8 KB
