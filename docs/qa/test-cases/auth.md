# TC-AUTH — 인증 / 진입

| 항목 | 값 |
|---|---|
| spec 파일 | `ui/tests/e2e/specs/01-login.spec.ts` |
| 화면 | `PageLogin.vue`, `LayoutDefault.vue`, `LayoutSidebar.vue` |
| 라우트 | `/`, `/login`, `/dashboard` |
| 의존 | Keycloak SSO (PKCE), `auth.ts` 의 `loadUserInfo` |

## 케이스

| ID | 시나리오 | 사전조건 | 절차 | 기대 | 상태 |
|---|---|---|---|---|---|
| TC-AUTH-NAV-01-HAPPY | / → /dashboard 자동 진입 | storageState 유효 | `page.goto('/')` | URL `/dashboard` | ✅ |
| TC-AUTH-SIDEBAR-01-MENUS-LOADED | 사이드바 menu-label 1개 이상 | 로그인됨 | dashboard 진입 | `.menu-label.first()` visible | ✅ |
| TC-AUTH-LABELS-01-API-200 | /api/labels?locale=ko 정상 | backend healthy | `request.get('/api/labels?locale=ko')` | success=true, LBL_PAGE_APPROVAL=전자결재 | ✅ |
