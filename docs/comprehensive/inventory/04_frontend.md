# Frontend (UI) Inventory

**Location:** `/ui/src/`, Framework: Vue 3 + PrimeVue 4 + TypeScript 5.7 + Vite 6

## Tech Stack

- **Framework:** Vue 3 (Composition API)
- **UI Library:** PrimeVue 4.3.0 (Material Design, 80+ components)
- **Router:** Vue Router 4.5.0 (SPA with lazy loading)
- **State Management:** Pinia 3.0.0 (3 stores: auth, notification, tab)
- **HTTP Client:** Axios 1.15.0 (with interceptors: token injection, 401 refresh, 5xx retry)
- **Calendar:** FullCalendar 6.1.20 (Vue 3 plugin)
- **Editor:** md-editor-v3 6.4.1 (Markdown editor)
- **Video:** livekit-client 2.18.1 (WebRTC video conferencing)
- **Authentication:** keycloak-js 24.0.0 (OIDC / OAuth2 implicit + refresh)
- **Icons:** @tabler/icons-vue 3.41.1, PrimeIcons 7.0.0
- **Date/Time:** dayjs 1.11.0 (lightweight date lib)
- **Build Tool:** Vite 6.1.0 (fast dev server + optimized build)

## Router & Page Structure (27+ routes)

### Main Routes (under root / with LayoutDefault wrapper)

| Path | Component | MenuId | Auth | Admin |
|------|-----------|--------|------|-------|
| `/dashboard` | PageDashboard.vue | dashboard | Yes | No |
| `/approval` | PageApproval.vue | approval | Yes | No |
| `/board` | PageBoard.vue | board | Yes | No |
| `/calendar` | PageCalendar.vue | calendar | Yes | No |
| `/org` | PageOrg.vue | org | Yes | No |
| `/messenger` | PageMessenger.vue | messenger | Yes | No |
| `/mail` | PageMail.vue | mail | Yes | No |
| `/wiki` | PageWiki.vue | wiki | Yes | No |
| `/video` | PageVideo.vue | video | Yes | No |
| `/attendance` | PageAttendance.vue | attendance | Yes | No |
| `/leave` | PageLeave.vue | leave | Yes | No |
| `/room` | PageRoom.vue | room | Yes | No |
| `/datalib` | PageDataLibrary.vue | datalib | Yes | No |
| `/worklog` | PageWorkLog.vue | worklog | Yes | No |
| `/search` | PageSearch.vue | search | Yes | No |
| `/settings/notify` | PageNotifySettings.vue | settings_notify | Yes | No |
| `/settings/favorites` | PageFavorites.vue | settings_fav | Yes | No |
| `/admin/users` | PageUsers.vue | admin_users | Yes | **Yes** |
| `/admin/depts` | PageDepts.vue | admin_depts | Yes | **Yes** |
| `/admin/menus` | PageMenus.vue | admin_menus | Yes | **Yes** |
| `/admin/codes` | PageCodes.vue | admin_codes | Yes | **Yes** |
| `/admin/audit` | PageAudit.vue | admin_audit | Yes | **Yes** |

### Auth Routes

| Path | Component | Auth | Purpose |
|------|-----------|------|---------|
| `/login` | PageLogin.vue | No | Keycloak redirect + SSO |
| `/403` | Page403.vue | No | Permission denied |

### Route Guards (router/index.ts lines 57-85)

- **requiresAuth:** Redirect to login if unauthenticated
- **requiresAdmin:** Redirect to 403 if not ROLE_ADMIN
- **menuId:** Check menu.canRead permission (from auth.menus)
- **Fallback:** Redirect unmatched paths to /dashboard

## Components Structure (70+ components, 12 categories)

### Layout Components (8 files)

| Component | Purpose |
|-----------|---------|
| LayoutDefault.vue | Main layout wrapper (header, sidebar, content) |
| LayoutHeader.vue | Top navigation bar (logo, search, user menu, notifications) |
| LayoutSidebar.vue | Left sidebar (main menu tree, collapsible) |
| LayoutTabBar.vue | Tab bar for open pages (Phase 14 feature) |
| LayoutTopNav.vue | Secondary nav (breadcrumbs, actions) |
| FavoriteRail.vue | Floating favorites rail (quick access) |
| SearchBar.vue | Global search input (board, wiki, users) |
| ThemeSettingsDrawer.vue | Theme switcher (light/dark, color scheme) |

### Approval Components (5 files)

| Component | Purpose |
|-----------|---------|
| ApprovalActionBar.vue | Approve/Reject/Delegate buttons + signature |
| ApprovalDetailDialog.vue | Full approval request display (modal) |
| ApprovalLineTimeline.vue | Timeline of approvers + status |
| ApprovalSubmitDialog.vue | Form to submit new approval request |
| ApprovalAttachmentList.vue | File list + upload |

### Board Components (3 files)

| Component | Purpose |
|-----------|---------|
| BoardFormDialog.vue | Create/edit post (title, content, attachments) |
| BoardDetailDialog.vue | Full post view + comment thread |
| CommentThread.vue | Nested comments with reply UI |

### Dashboard Widgets (8 files)

| Widget | DataSource | Refresh |
|--------|-----------|---------|
| WidgetAttendance.vue | `/api/attendance/month` | 1h |
| WidgetLeaveBalance.vue | `/api/leave/balance` | Daily |
| WidgetLeaveChart.vue | `/api/leave/stats` | Daily |
| WidgetMessenger.vue | `/api/bff/messages/rooms` | 5m |
| WidgetMyRooms.vue | `/api/room/bookings` | 1h |
| WidgetNotices.vue | `/api/board?type=notice` | 1h |
| WidgetPendingApproval.vue | `/api/approval/pending` | 5m (poll) |
| WidgetTodayEvents.vue | `/api/calendar/today` | 1h |
| WidgetTeamWorklog.vue | `/api/worklog/team` | 1h |

### Common Components (8 files)

| Component | Purpose |
|-----------|---------|
| CrudToolbar.vue | Search + Filter + Action buttons (reusable table toolbar) |
| FileUploadPanel.vue | Drag-drop file upload, progress bar |
| LoadingSkeleton.vue | Shimmer placeholder while loading |
| NotificationBell.vue | Notification bell icon + dropdown (SSE stream) |
| AppActionSpeedDial.vue | FAB menu (quick actions by context) |
| AppContextSpeedDial.vue | Context-specific FAB (e.g., approval: Submit/Delegate/Reject) |
| PopupHost.vue | Popup toast container (mounted in App.vue) |
| SearchPanel.vue | Global search overlay |

### Other Component Groups

- **attendance/** - MonthlyCalendar.vue
- **calendar/** - CalendarEventDialog.vue
- **leave/** - LeaveBalanceCard.vue
- **mail/** - ComposeDialog, EmailDetail, EmailList, MailboxTree (4 files)
- **org/** - EmployeeDetailDialog.vue
- **room/** - BookingDialog, RoomCard (2 files)
- **datalib/** - FolderActions.vue
- **worklog/** - DailyEditor.vue

## Composables (23 files)

| Composable | Functionality |
|-----------|--------------|
| useApproval | fetch approval data, submit, approve/reject |
| useAttendance | check-in/out, get monthly stats |
| useLeave | submit leave, calculate balance, fetch requests |
| useRoom | list rooms, create/cancel booking, check availability |
| useDataLibrary | folder ops (CRUD), file upload/download (MinIO presign) |
| useDataSet | POST /api/dataset router pattern (dynamic service calls) |
| useDataSetPaging | pagination wrapper for dataset queries |
| useCodes | fetch dropdown codes by group |
| useCombo | fetch combo/lookup data |
| useAdmin | user/dept/menu/code/audit CRUD |
| useItemPermission | check read/write/delete on entity (role-based) |
| useLabel | fetch i18n labels by locale |
| useLocale | manage i18n (ko, en, ja, zh-CN) |
| useMessage | global toast/snackbar notifications |
| usePermission | check user roles (ROLE_ADMIN, etc.) |
| usePopup | dialog/modal state management |
| useQuickActions | dynamic action menu (context-aware) |
| useStorage | localStorage/sessionStorage wrapper |
| useNotificationSse | EventSource stream from `/api/notifications/stream` |
| useTheme | PrimeVue theme switching |
| useTransaction | form dirty check, unsaved changes guard |
| useUx | UX preferences (favorites, search history) |
| useWidget | widget config, drag-drop dashboard editor |
| useWorkLog | daily worklog submit, team worklog view |

## Stores (Pinia, 3 stores)

### auth.ts

- **State:** isAuthenticated, user, accessToken, refreshToken, menus, roles
- **Actions:** login(), logout(), refresh(), loadUserInfo(), hasRole(), canRead()
- **Persistence:** localStorage (tokens), sessionStorage (user info)
- **Logic:** Keycloak token refresh (exponential backoff on failure)

### notification.ts

- **State:** notifications (array), unreadCount
- **Actions:** add(), remove(), markAsRead(), clear()
- **Trigger:** SSE stream from useNotificationSse composable
- **Badge:** Global notification bell badge count

### tab.ts

- **State:** openTabs (array of { path, title })
- **Actions:** open(), close(), closeAll(), setActive()
- **Persistence:** sessionStorage (per browser tab)
- **Sync:** Cross-tab message via storage events (experimental)

## API Layer (interceptor.ts)

**File:** `/ui/src/api/interceptor.ts` (lines 1-80+)

### Key Features

1. **Request Interceptor (lines 36-48)**
   - Inject Keycloak token (from keycloak-js or auth store)
   - Set X-Locale, Accept-Language headers

2. **Response Interceptor (lines 50-80+)**
   - On 401: Retry with token refresh (auth.refresh())
   - On 5xx: Exponential backoff retry (max 2 retries, 1s base delay)
   - Track consecutive failures; redirect to login if >3 consecutive errors
   - Skip retry for sensitive endpoints: /auth/*, /bff/identity/me, /api/messages, /api/i18n, /api/codes

3. **Error Translation**
   - Convert Axios error to business exception
   - Display user-friendly toast message

## Keycloak Integration (keycloak.ts)

- **Flow:** OAuth2 implicit (browser-based)
- **Token Storage:** In-memory (keycloak-js) + localStorage backup
- **Endpoints:**
  - Realm: `http://keycloak:8080/realms/openplatform-v3`
  - OIDC Config: `http://keycloak:8080/realms/openplatform-v3/.well-known/openid-configuration`
- **UI Client ID:** `openplatform-v3-ui` (public, no secret)
- **Silent Check:** `/public/silent-check-sso.html` (check token validity)
- **Refresh:** Auto-refresh 5 min before expiry (keycloak-js built-in)

## Build & Deployment

### Dev Server
```bash
npm run dev  # Vite dev server on http://localhost:25174
```

### Production Build
```bash
npm run build  # vue-tsc + vite build
# Output: dist/ → uploaded to nginx container
# Nginx config: nginx.conf (gzip, caching, SPA fallback)
```

### Vite Config (vite.config.ts)
- Vue 3 plugin enabled
- TypeScript strict mode
- Source maps for production debugging
- Env variables: VITE_API_BASE_URL, VITE_KEYCLOAK_URL (auto-injected at build time)

## Build & Runtime Statistics

- **Vue Files:** 70 .vue components + 1 App.vue
- **TypeScript Files:** 23 composables + 3 stores + 1 router + 1 interceptor + 1 keycloak.ts
- **Styles:** PrimeVue theming + global.css
- **Node Packages:** 10 dependencies + 4 devDependencies
- **Build Time:** ~10s (Vite cached)
- **Bundle Size:** ~300 KB gzipped (Vue 3 + PrimeVue + FullCalendar)

## Key Design Patterns

- **Composition API:** useXxx composables instead of Options API
- **Lazy Loading:** Route-level code splitting (each page .vue is separate chunk)
- **Reactive State:** Pinia stores for global state (auth, notifications, tabs)
- **Type Safety:** Full TypeScript (no any types where possible)
- **Error Handling:** Centralized via axios interceptor + useMessage composable
- **Permission Guards:** router.beforeEach() + usePermission composable

**Approx size:** ~8 KB aggregate (70 Vue files + 23 composables + supporting infrastructure)
