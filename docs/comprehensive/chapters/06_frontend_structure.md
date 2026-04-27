# Chapter 1.6: Frontend Architecture & Structure

**Document Root**: `C:/claude/openplatform_v3/ui/src/`  
**Framework**: Vue 3 (Composition API) + PrimeVue 4 + TypeScript 5.7 + Vite 6.1  
**Build & Serve**: Vite dev server (port 25174), production build with gzip + caching  
**Last Updated**: 2026-04-27  

---

## 1. Directory Structure Overview

```
ui/src/
├── pages/              # 24 Vue page components (lazy-loaded)
├── components/         # 70+ reusable Vue components (8 categories)
├── composables/        # 23 TypeScript composables (business logic hooks)
├── store/              # 3 Pinia stores (auth, notification, tab)
├── router/             # SPA routing (27+ routes)
├── api/                # Axios interceptor (token + retry + error handling)
├── styles/             # Global CSS (PrimeVue theme overrides)
├── App.vue             # Root component (Toast, ConfirmDialog, router-view)
├── main.ts             # Entry point (Vue + Pinia + PrimeVue + Router + Keycloak init)
└── keycloak.ts         # Keycloak OIDC adapter
```

### Directory Tree with File Counts

| Directory | Files | Category | Purpose |
|-----------|-------|----------|---------|
| `pages/` | 24 .vue | Page Templates | Dashboard, Approval, Board, Calendar, Org, Messenger, Mail, Wiki, Video, Attendance, Leave, Room, DataLib, WorkLog, Search, Settings, Admin, Login, 403 |
| `components/approval/` | 5 | Approval UI | ApprovalActionBar, ApprovalDetailDialog, ApprovalLineTimeline, ApprovalSubmitDialog, ApprovalAttachmentList |
| `components/common/` | 8 | Reusable | CrudToolbar, FileUploadPanel, LoadingSkeleton, NotificationBell, AppActionSpeedDial, AppContextSpeedDial, PopupHost, SearchPanel |
| `components/layout/` | 8 | Layout Wrapper | LayoutDefault, LayoutHeader, LayoutSidebar, LayoutTabBar, LayoutTopNav, FavoriteRail, SearchBar, ThemeSettingsDrawer |
| `components/dashboard/widgets/` | 8 | Dashboard | WidgetAttendance, WidgetLeaveBalance, WidgetLeaveChart, WidgetMessenger, WidgetMyRooms, WidgetNotices, WidgetPendingApproval, WidgetTodayEvents |
| `composables/` | 23 .ts | Business Logic | useAdmin, useApproval, useAttendance, useCodes, useCombo, useDataLibrary, useDataSet, useItemPermission, useLabel, useLeave, useLocale, useMessage, useNotificationSse, usePermission, usePopup, useQuickActions, useRoom, useStorage, useTheme, useTransaction, useUx, useWidget, useWorkLog |
| `store/` | 3 .ts | State | auth.ts, notification.ts, tab.ts |
| `router/` | 1 .ts | Routing | index.ts (27+ routes) |
| `api/` | 1 .ts | HTTP | interceptor.ts |

---

## 2. Routing Architecture (27+ Routes)

**Source**: `ui/src/router/index.ts` (88 lines)

### Route Structure

The router follows a **hierarchical, lazy-loaded** design with 27+ routes organized under root path and guarded by auth/admin/menu permissions.

**Main Routes** (under `/` with LayoutDefault):
- `/dashboard` — Dashboard (menuId: dashboard)
- `/approval` — Approval requests (menuId: approval)
- `/board` — Discussion board (menuId: board)
- `/calendar` — Calendar (menuId: calendar)
- `/org` — Organization directory (menuId: org)
- `/messenger` — Messaging (menuId: messenger)
- `/mail` — Email (menuId: mail)
- `/wiki` — Wiki (menuId: wiki)
- `/video` — Video conferencing (menuId: video)
- `/attendance` — Attendance tracking (menuId: attendance) — Phase 14
- `/leave` — Leave requests (menuId: leave)
- `/room` — Room booking (menuId: room)
- `/datalib` — Data library (menuId: datalib)
- `/worklog` — Work log (menuId: worklog)
- `/search` — Global search (menuId: search)
- `/settings/notify` — Notification settings (menuId: settings_notify)
- `/settings/favorites` — Favorites (menuId: settings_fav)
- `/admin/users` — User management (menuId: admin_users, requiresAdmin: true)
- `/admin/depts` — Department management (menuId: admin_depts, requiresAdmin: true)
- `/admin/menus` — Menu management (menuId: admin_menus, requiresAdmin: true)
- `/admin/codes` — Code management (menuId: admin_codes, requiresAdmin: true)
- `/admin/audit` — Audit log (menuId: admin_audit, requiresAdmin: true)

**Auth Routes**:
- `/login` — Keycloak redirect (requiresAuth: false)
- `/403` — Permission denied (requiresAuth: false)

**Fallback**: Unmatched paths redirect to `/dashboard`

### Route Meta Guards (router.beforeEach)

| Flag | Values | Handler |
|------|--------|---------|
| `requiresAuth` | true/false | Redirect to `/login` if true and unauthenticated |
| `requiresAdmin` | true/false | Redirect to `/403` if true and user lacks ROLE_ADMIN |
| `menuId` | string | Check menu permission (canRead) from auth.menus; redirect `/403` if denied |

---

## 3. State Management (Pinia 3)

### 3.1 Auth Store (`auth.ts`)

**State**:
- `isAuthenticated` — Login status
- `user` — User info (id, name, email, dept, roles)
- `accessToken` — JWT/OAuth2 access token
- `refreshToken` — Optional refresh token
- `menus` — Menu items with canRead/canWrite/canDelete flags
- `roles` — User roles (ROLE_ADMIN, ROLE_USER, etc.)

**Key Actions**:
- `login()` — Redirect to Keycloak
- `logout()` — Clear tokens + menus
- `refresh()` — Keycloak updateToken() -> accessToken
- `loadUserInfo()` — Fetch from `/api/bff/identity/me`
- `hasRole(role)` — Check if user has role
- `canRead(menuId)` — Check menu permission

**Persistence**: localStorage (tokens), sessionStorage (user info)

### 3.2 Notification Store (`notification.ts`)

**State**:
- `notifications` — Array of notification objects
- `unreadCount` — Badge count for notification bell

**Actions**: add(), remove(), markAsRead(), clear()

**Trigger**: SSE stream from `/api/notifications/stream` (useNotificationSse composable)

### 3.3 Tab Store (`tab.ts`)

**State**:
- `openTabs` — Array of open page tabs
- `activeTabPath` — Currently active tab

**Actions**: open(), close(), closeAll(), setActive()

**Persistence**: sessionStorage (per browser tab)

---

## 4. Axios Interceptor & Error Handling

**Source**: `ui/src/api/interceptor.ts` (103 lines)

### Request Interceptor
- Inject Authorization header: `Bearer ${keycloak.token || auth.accessToken}`
- Inject X-Locale and Accept-Language from localStorage

### Response Interceptor

| Status | Action |
|--------|--------|
| 2xx | Reset fail counter, return response |
| 401 | Refresh token; if success retry; else redirect /login |
| 403 | Redirect /403 |
| 4xx/5xx | Show error toast (skip silent paths: /api/messages, /api/i18n/, /api/codes/, /bff/identity/me) |
| 5xx | Exponential backoff retry (max 2 attempts, 1000 * 2^n ms); if consecutive fail >= 3: redirect /login |

---

## 5. Keycloak Integration

**Source**: `ui/src/keycloak.ts` (37 lines)

**Config**:
- URL: `VITE_KEYCLOAK_URL` (default: `http://kc.localtest.me:19281`)
- Realm: `VITE_KEYCLOAK_REALM` (default: `openplatform-v3`)
- Client: `VITE_KEYCLOAK_CLIENT` (default: `v3-ui`)

**Init**:
```typescript
kc.init({
  onLoad: 'check-sso',
  silentCheckSsoRedirectUri: window.location.origin + '/silent-check-sso.html',
  pkceMethod: 'S256',
  checkLoginIframe: false
})
```

**Token Refresh**: Every 5 minutes, `kc.updateToken(60)` (auto-refresh if <= 60s to expiry)

---

## 6. Vite Configuration & Build

**Dev Server** (port 25174):
- Proxy `/api/bff` -> `http://localhost:19091`
- Proxy `/api` -> `http://localhost:19090`

**Build**:
- Output: `ui/dist/` (gzipped)
- Source maps enabled
- Path alias: `@` -> `src/`

**TypeScript**:
- Target: ES2022
- Module: ESNext
- Strict mode enabled
- Path aliases configured

---

## 7. Vue-Spring-Framework Reuse Policy

**Source**: `docs/vue-spring-fw-reuse-map.md`

**Core Principle**:
- Original: `C:\claude\vue-spring-fw` — Read-only (never modify)
- Target: `C:\claude\openplatform_v3\ui\src\` — Static copy + modification tracking
- Method: Phase-based copying (Phase 4 onward)

**Reuse Categories**:
- **Layouts**: LayoutDefault, LayoutHeader, LayoutSidebar, LayoutTabBar (source: frontend/)
- **Components**: CrudToolbar, SearchPanel, PopupHost (source: frontend/)
- **Composables**: useDataSet, usePermission, useCodes, useLabel, useMessage, useCombo, useLocale, useTheme (source: composables/)
- **Stores**: auth.ts (major refactor to Keycloak), tab.ts (source: store/)
- **Interceptor**: api/interceptor.ts (refactored for Keycloak tokens, source: api/)
- **Router**: router/index.ts (routes replaced, guard logic retained)
- **Login**: pages/PageLogin.vue (layout retained, logic -> Keycloak redirect)

**Forbidden**:
- Modify original files (read-only rule)
- Copy backend/**, docker/**, MyBatis XML, pages/admin/**

---

## 8. Composables & Business Logic

23 composables organized by domain:

| Composable | Domain | Function |
|-----------|--------|----------|
| useApproval | Approval | Fetch, submit, approve/reject |
| useAttendance | Attendance | Check-in/out, stats |
| useLeave | Leave | Submit, balance, requests |
| useRoom | Room | List, book, cancel |
| useDataLibrary | Data Lib | Folder CRUD, file upload/download |
| useDataSet | API | POST /api/dataset router pattern |
| useDataSetPaging | Pagination | Dataset pagination wrapper |
| useCodes | Dropdown | Fetch codes by group |
| useCombo | Lookup | Fetch combo data |
| useAdmin | Admin | CRUD for users, depts, menus, codes, audit |
| useItemPermission | Permission | Check read/write/delete |
| useLabel | i18n | Fetch labels by locale |
| useLocale | i18n | Manage i18n (ko, en, ja, zh-CN) |
| useMessage | Toast | Global notifications |
| usePermission | Auth | Check roles (ROLE_ADMIN, etc.) |
| usePopup | Dialog | Dialog/modal state |
| useQuickActions | Actions | Dynamic action menu (FAB) |
| useStorage | Storage | localStorage/sessionStorage |
| useNotificationSse | SSE | EventSource from /api/notifications/stream |
| useTheme | Theme | PrimeVue theme switching |
| useTransaction | Form | Dirty check, unsaved changes |
| useUx | UX | Favorites, search history |
| useWidget | Dashboard | Widget config, drag-drop |
| useWorkLog | WorkLog | Daily submit, team view |

---

## 9. Tech Stack

| Category | Package | Version | Purpose |
|----------|---------|---------|---------|
| Framework | vue | 3.4+ | Frontend framework (Composition API) |
| Build | vite | 6.1.0 | Dev server + bundler |
| Type | typescript | 5.7+ | Static type checking |
| UI | primevue | 4.3.0+ | Material Design components (80+) |
| Router | vue-router | 4.5.0 | SPA routing |
| State | pinia | 3.0.0 | State management |
| HTTP | axios | 1.15.0 | HTTP client (interceptors) |
| Auth | keycloak-js | 24.0.0 | OAuth2/OIDC client |
| Calendar | fullcalendar | 6.1.20 | Calendar widget |
| Editor | md-editor-v3 | 6.4.1 | Markdown editor |
| Video | livekit-client | 2.18.1 | WebRTC video |
| Icons | @tabler/icons-vue, primeicons | 3.41.1, 7.0.0 | Icons |
| Date | dayjs | 1.11.0 | Date manipulation |

---

## 10. Key Design Patterns

1. **Composition API**: Business logic in `useXxx` composables
2. **Lazy Loading**: Route-level code splitting (each page is separate chunk)
3. **Reactive State**: Pinia stores for global state (auth, notifications, tabs)
4. **Type Safety**: Full TypeScript, strict mode
5. **Centralized Error Handling**: Axios interceptor + useMessage composable
6. **Multi-Layer Permission Guards**: Router beforeEach + composable + conditional rendering

---

## 11. Entry Point & Bootstrap

**Source**: `ui/src/main.ts`

**Boot Sequence**:
1. Create Vue app + Pinia store
2. Register router + PrimeVue + services
3. Setup Axios interceptor
4. Initialize Keycloak (OIDC check-sso)
5. Load user info from backend
6. Mount to `#app`

---

## 12. Root Component (App.vue)

**Hosts**:
- Toast notifications (top-right)
- Confirm dialogs
- Router view (page content)

---

## 참조

### Primary Sources
- `docs/comprehensive/inventory/04_frontend.md` — Tech stack, component inventory
- `ui/src/router/index.ts` — Routes and guards
- `ui/src/main.ts` — Bootstrap sequence
- `ui/src/api/interceptor.ts` — HTTP interceptor
- `ui/src/keycloak.ts` — Keycloak adapter
- `ui/vite.config.ts` — Build config
- `docs/vue-spring-fw-reuse-map.md` — Reuse policy

---

## 이 챕터가 다루지 않은 인접 주제

1. **Backend API Contracts** — Endpoint specs, schemas (Reference: Chapter 2.x, `docs/api-catalog.md`)
2. **Database Schema & ORM** — MyBatis, Flyway (Reference: Backend inventory)
3. **Keycloak Realm Config** — User federation, roles setup (Reference: `infra/keycloak/`)
4. **Component Deep-Dives** — PrimeVue component usage (Reference: PrimeVue docs, component sources)
5. **Test Suite** — Unit/E2E tests (Reference: `ui/tests/**/*`)
6. **CI/CD Pipeline** — GitHub Actions, deployment (Reference: `.github/workflows/ci.yml`)
7. **Performance Optimization** — Bundle analysis, code splitting (Reference: Vite tools)
8. **Accessibility (a11y)** — ARIA, keyboard nav (Reference: PrimeVue a11y)
9. **i18n Details** — Translation files (Reference: `useLocale`, `useLabel` composables)
10. **Form Validation** — Zod/Valibot (Reference: Page components)
11. **Responsive Design** — Tailwind/Grid (Reference: `global.css`)
12. **WebSocket & Real-Time** — SSE details (Reference: `useNotificationSse`)
13. **Error Boundaries** — Custom error pages (Reference: `pages/Page403.vue`)
14. **Environment Config** — `.env.local` (Reference: Vite env vars)

---

**Document**: `docs/comprehensive/chapters/06_frontend_structure.md`  
**Status**: Complete  
**Last Check**: 2026-04-27
