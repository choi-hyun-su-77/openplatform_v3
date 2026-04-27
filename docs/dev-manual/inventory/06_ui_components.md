# inventory/06_ui_components.md — UI 컴포넌트 라이브러리 매핑

> Phase 0.G 산출물. PrimeVue 4.3 + 외부 라이브러리(FullCalendar, livekit-client) 가 주력.
> 출처는 `[code: ui/...]` 형식.

## 1. UI 컴포넌트 라이브러리 식별

| 라이브러리 | 버전 | 출처 |
|---|---|---|
| PrimeVue | 4.3.0 | `[code: ui/package.json:27]` |
| PrimeIcons | 7.0.0 | `[code: ui/package.json:26]` |
| @tabler/icons-vue | 3.41.1 | `[code: ui/package.json:18]` |
| @fullcalendar/vue3 | 6.1.20 | `[code: ui/package.json:16]` |
| md-editor-v3 | 6.4.1 | `[code: ui/package.json:24]` |
| livekit-client | 2.18.1 | `[code: ui/package.json:23]` |
| keycloak-js | 24.0.0 | `[code: ui/package.json:22]` |
| dayjs | 1.11.0 | `[code: ui/package.json:21]` |
| axios | 1.15.0 | `[code: ui/package.json:20]` |
| Pinia | 3.0.0 | `[code: ui/package.json:25]` |
| Vue Router | 4.5.0 | `[code: ui/package.json:29]` |

## 2. PrimeVue 컴포넌트 카탈로그 (실제 import 기준)

> 출처: `ui/src/pages/`, `ui/src/components/` 의 import 분석

| 컴포넌트 | 용도 | 대표 사용처 |
|---|---|---|
| `DataTable` | 페이징·정렬·lazy 테이블 | PageBoard, PageApproval, PageLeave |
| `Column` | 테이블 컬럼 정의 | DataTable 동반 |
| `Paginator` | 페이지네이터 | DataTable 내장 |
| `Button` | 액션 버튼 | (전 화면) |
| `InputText` | 단일 라인 입력 | 검색바, 폼 |
| `InputNumber` | 숫자 spinner | ApprovalSubmitDialog |
| `Textarea` | 멀티라인 입력 | 게시글, 사유 |
| `Select` | 단일 dropdown | 카테고리 필터 |
| `MultiSelect` | 다중 dropdown | (다중 카테고리 필터) |
| `Dropdown` | 경량 dropdown | 결재선/폼 타입 |
| `Dialog` | 모달 다이얼로그 | 모든 상세/입력 다이얼로그 |
| `Tag` | 상태 라벨 | 결재 상태, 카테고리 |
| `DatePicker` | 날짜/시간 선택 | 일정/휴가 |
| `ToggleButton` | ON/OFF 스위치 | 알림 설정 |
| `Checkbox` | 체크박스 | 필터/권한 |
| `Listbox` | 리스트 선택 | 즐겨찾기/코드 |
| `Tree` | 계층 트리 | 조직도/폴더/메뉴 |
| `TabView` / `TabPanel` | 탭 인터페이스 | 결재 상세 |
| `Timeline` | 수직 타임라인 | 결재선 |
| `Divider` | 구분선 | 폼 섹션 분리 |
| `SpeedDial` | 플로팅 액션 메뉴 | AppActionSpeedDial |
| `OverlayPanel` | 오버레이 팝업 | NotificationBell, SearchBar |
| `ContextMenu` | 우클릭 메뉴 | FolderActions, LayoutTabBar |
| `Menu` / `Menubar` | 네비게이션 | LayoutHeader, LayoutTopNav |
| `SelectButton` | 버튼 그룹 토글 | 캘린더 scope, 워크로그 view |
| `Skeleton` | 로딩 placeholder | LoadingSkeleton |
| `Toast` / `useToast` | 토스트 알림 | (전역) |
| `Drawer` | 사이드 패널 | ThemeSettingsDrawer |
| `Card` | 카드 컨테이너 | Dashboard 위젯 |

## 3. 외부 라이브러리 사용 매트릭스

| 라이브러리 | 사용 화면 형태 | 핵심 객체 |
|---|---|---|
| `@fullcalendar/vue3` | 형태 4(캘린더), 4-room | `FullCalendar`, `dayGridPlugin`, `timeGridPlugin` |
| `livekit-client` | 형태 8(실시간) | `Room`, `RoomEvent`, `createLocalTracks`, `Track.Kind` |
| `md-editor-v3` | 형태 2/6 (게시판/결재) | `MdEditor` |
| `keycloak-js` | 전역 SSO | `Keycloak({url, realm, clientId})` |
| `dayjs` | 전 화면 | 날짜 포맷·연산 |

## 4. 화면 형태별 주력 컴포넌트 매핑

| 화면 형태 | 1차 (필수) | 2차 (자주) | 보조 (선택) |
|---|---|---|---|
| 1. 다건 목록 | `DataTable`, `Column`, `Paginator` | `Button`, `InputText`, `Select`, `Tag` | `CrudToolbar` (custom) |
| 2. 단건 상세 | `Dialog`, `TabView`, `TabPanel` | `Timeline`, `Divider`, `Button`, `Textarea` | ApprovalDetailDialog 등 (custom) |
| 3. 마스터-디테일 | `Tree`, `DataTable` | `InputText`, `Button`, `Select` | FolderActions / DailyEditor / MailboxTree |
| 4. 캘린더 | `FullCalendar` (외부), `SelectButton`, `DatePicker` | `Button`, `Dialog` | CalendarEventDialog, MonthlyCalendar |
| 5. 대시보드 | (custom grid CSS), `Button`, `Card` | — | Widget* (9 종) |
| 6. 다단계 입력 | `Dialog`, `Dropdown`, `InputText`, `DatePicker`, `Textarea` | `InputNumber`, `Button`, `Tag` | FileUploadPanel, ApprovalActionBar |
| 7. SSO 래퍼 | `Button`, `InputText` | — | (최소) |
| 8. 실시간 | `Button`, `OverlayPanel` | (외부) `livekit-client` | NotificationBell |
| 9. 폼 매트릭스 | `DataTable`, `Column`, `ToggleButton` | `Button`, `Select` | — |

## 5. 컴포넌트 작성 관습 (코드베이스 발견 기준)

- 페이지 파일: `ui/src/pages/Page{DomainPascal}.vue` (관리자: `ui/src/pages/admin/Page*.vue`)
- 도메인 컴포넌트: `ui/src/components/{domain}/{DomainPascal}{Role}{Suffix}.vue`
  - 예: `ApprovalSubmitDialog.vue`, `BoardFormDialog.vue`, `LeaveBalanceCard.vue`
- 공통 컴포넌트: `ui/src/components/common/` (CrudToolbar, FileUploadPanel, LoadingSkeleton 등)
- 레이아웃: `ui/src/components/layout/` (LayoutHeader, LayoutSidebar, LayoutTopNav, LayoutTabBar, NotificationBell, ThemeSettingsDrawer)
- 위젯: `ui/src/components/dashboard/Widget*.vue`

## 6. PrimeVue Pass-Through (기본 테마)

> `[code: ui/src/main.ts]` 등에서 PrimeVue 4 Aura 테마 또는 사용자 정의 PT 사용 가능.
> 본 코드베이스에서는 PrimeIcons + Tabler 아이콘 혼용.

## 7. vue-spring-fw 재사용 컴포넌트 매핑

> 출처: `[doc: docs/vue-spring-fw-reuse-map.md]`

- 원본 절대 수정 금지 (`C:\claude\vue-spring-fw\**`)
- 정적 복사 후 `ui/` 에서 사용; 19개 항목(레이아웃/공통/composable/store/router) 추적
- 신규 컴포넌트 작성 시 vue-spring-fw 의 동일 카테고리 컴포넌트가 있는지 먼저 확인 후 복사하여 도메인 명에 맞춰 변형
