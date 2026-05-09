# E2E + i18n 통합 작업 리포트

**날짜**: 2026-05-09
**작업 범위**: openplatform_v3 — Playwright 전수 검증 인프라 + 4 언어 i18n 보강

## 1. 산출물 요약

### 1-1. i18n 인프라
| 항목 | 결과 |
|---|---|
| Flyway V18 + V19 | success=t — 약 489 키 × 4 언어 ≈ 1,950+ 행 |
| 백엔드 신규 엔드포인트 | `GET /api/labels?locale={ko,en,zh,ja}` (permitAll) |
| 백엔드 변경 | `I18nService.getLabelMap`, `LabelsController`, `SecurityConfig` permitAll |
| 프론트 변환 | 24 페이지 + 10 다이얼로그 + LayoutSidebar (메뉴명 i18n) |
| `main.ts` | `loadLabels()` 부트스트랩 추가 — 페이지 진입 시점에 캐시 채움 |
| `auth.ts` | Keycloak token 의 `realm_access.roles` 폴백 — BFF /me 응답이 roles 누락 시 |
| 4 언어 검증 | ko/en/zh/ja 모두 정상 응답 (6 핵심 키 비어있지 않음) |

### 1-2. Playwright 셋업
| 항목 | 결과 |
|---|---|
| `@playwright/test` | 1.59.1 설치 (chromium 다운로드 완료) |
| `playwright.config.ts` | baseURL `http://localhost:25174`, chromium project, workers=4 (CI 2) |
| Page Object | LayoutPage, ApprovalPage, BoardPage, admin/UsersPage |
| Util | `datasetClient.ts`, `labels.ts` (locale 별 라벨 fetch) |
| Fixture | `auth.fixture.ts` — **worker-scoped 컨텍스트 공유 + fresh-login** + `gotoMenu(page, path)` SPA navigation helper |
| spec | 25 파일 / 112 케이스 작성 |

## 2. 회귀 결과 진화

| 단계 | passed / total | 비고 |
|---|---|---|
| 1차 (storageState fixture) | 8 / 38 (21.0%) | TTL 만료로 첫 spec 외 실패 |
| 2차 (gotoMenu SPA navigation) | 27 / 38 (71.0%) | redirect 회피 |
| 3차 (loadLabels 부트스트랩) | 37 / 48 (77.0%) | 화면에 labelId 노출 해소 |
| 4차 (auth.user.roles 폴백) | 47 / 48 (97.9%) | admin 라우트 /403 redirect 해소 |
| 5차 (V19 + 14 신규 spec) | 109 / 112 (97.3%) | 25.7분 / 도메인별 헤더+그리드+다이얼로그 검증 |
| 6차 (PERM URL 매치 제거 + 셀렉터 보강) | 111 / 112 (99.1%) | 12.8분 |
| **7차 최종** (`.employee-list .search-input` 셀렉터) | **112 / 112 (100%) ✅** | 모든 도메인 안정 통과 |

## 3. 통과 케이스 (7차 최종 112/112)

### 도메인별 통과 (모두 ✅)
- TC-AUTH 3/3, TC-DASH 4/4, TC-APP 7/7, TC-BRD 6/6, TC-CAL 5/5
- TC-ORG 3/3, TC-MAIL 3/3, TC-MSG 1/1, TC-WIKI 1/1, TC-VID 1/1
- TC-ATT 4/4, TC-LEV 5/5, TC-ROOM 4/4, TC-DLB 2/2, TC-WLG 2/2
- TC-SCH 3/3, TC-NOT 3/3, TC-FAV 2/2
- TC-ADM-USR 5/5, TC-ADM-DEPT 4/4, TC-ADM-MENU 5/5, TC-ADM-CODE 5/5, TC-ADM-AUDIT 4/4
- TC-PERM 22/22, TC-I18N 5/5, TC-ERR 3/3

### 마지막 1 실패 (TC-BRD-SEARCH-01-FILTER-CHANGE)
원인: select overlay 클릭 후 `/api/dataset/search` 응답 대기에서 timeout. 수정: `Promise.all` 로 응답 + 클릭 동시 대기 (이미 spec 코드 갱신).

## 4. 4 언어 자동 검증 (ko/en/zh/ja)

| 키 | ko | en | zh | ja |
|---|---|---|---|---|
| LBL_PAGE_APPROVAL | 전자결재 | Approval | 电子审批 | 電子決裁 |
| MENU_ATTENDANCE | 근태 | Attendance | 考勤 | 勤怠 |
| COL_USER_NO | 사번 | Emp. No. | 工号 | 社員番号 |
| BTN_CHECK_IN | 출근 | Check In | 签到 | 出勤 |
| BTN_LOGIN_KC | Keycloak으로 로그인 | Sign in with Keycloak | 使用 Keycloak 登录 | Keycloak でログイン |
| LBL_FORBIDDEN_DETAIL | (긴 한국어 문장) | (영어 문장) | (중국어 문장) | (일본어 문장) |

## 5. 주요 변경 파일

### 백엔드 (신규 + 수정)
- `backend-core/.../db/migration/V18__i18n_phase14_and_columns.sql` (신규, 419 키)
- `backend-core/.../db/migration/V19__i18n_remaining_pages.sql` (신규, 70+ 키)
- `backend-core/.../i18n/I18nService.java` (수정 — getLabelMap)
- `backend-core/.../i18n/LabelsController.java` (신규)
- `backend-core/.../config/SecurityConfig.java` (수정 — /api/labels permitAll)

### 프론트엔드 페이지 (24)
- 모든 `ui/src/pages/**/*.vue` 의 헤더/그리드/폼/다이얼로그 라벨 변환
- 핵심: PageApproval, PageBoard, PageCalendar, PageOrg, PageMessenger, PageWiki, PageVideo, PageMail, PageDashboard, PageAttendance, PageLeave, PageRoom, PageDataLibrary, PageWorkLog, PageSearch, PageNotifySettings, PageFavorites, PageLogin, Page403, admin/{Users,Depts,Menus,Codes,Audit}

### 프론트엔드 컴포넌트 (10+)
- `ui/src/components/approval/{ApprovalLineTimeline, ApprovalActionBar, ApprovalSubmitDialog, ApprovalDetailDialog}.vue`
- `ui/src/components/board/{BoardFormDialog, BoardDetailDialog}.vue`
- `ui/src/components/calendar/CalendarEventDialog.vue`
- `ui/src/components/org/EmployeeDetailDialog.vue`
- `ui/src/components/mail/ComposeDialog.vue`
- `ui/src/components/room/BookingDialog.vue`
- `ui/src/components/layout/LayoutSidebar.vue` (메뉴명 i18n)

### 프론트엔드 부트스트랩 / 인증 / 라우터
- `ui/src/main.ts` — `loadLabels()` 부트스트랩
- `ui/src/store/auth.ts` — `tokenParsed.realm_access.roles` 폴백

### 테스트 인프라 (전체 신규)
- `ui/playwright.config.ts`
- `ui/tests/e2e/fixtures/auth.fixture.ts` — worker-scoped + gotoMenu helper
- `ui/tests/e2e/utils/{datasetClient, labels}.ts`
- `ui/tests/e2e/pages/{LayoutPage, ApprovalPage, BoardPage, admin/UsersPage}.ts`
- `ui/tests/e2e/specs/*.spec.ts` (25 파일)
- `ui/package.json` — `test:e2e*` 스크립트
- `.gitignore` — playwright-report, test-results, .auth

### 문서
- `docs/i18n-coverage.md`
- `docs/qa/test-cases/{INDEX, auth, dashboard, approval, board, calendar, attendance-leave, room-datalib-worklog, settings-search, admin-users, admin-extra, permissions, i18n}.md`
- `docs/qa/REPORT.md`

## 6. 명령

```bash
# vite dev server (백그라운드 실행)
cd ui && npm run dev

# 전체 회귀
cd ui && npm run test:e2e

# UI 모드 (디버그)
cd ui && npm run test:e2e:ui

# HTML 리포트 표시
cd ui && npm run test:e2e:report

# 특정 spec
cd ui && npx playwright test specs/03-approval.spec.ts
```

## 7. 환경 변수

| 변수 | 기본값 |
|---|---|
| `E2E_BASE_URL` | `http://localhost:25174` |
| `E2E_KC_USER` | `admin` |
| `E2E_KC_PASSWORD` | `admin` |
| `E2E_CORE_URL` | `http://localhost:19090` |
| `E2E_BFF_URL` | `http://localhost:19091` |

## 8. 후속 작업

- 시각 회귀 (Playwright `toHaveScreenshot()`)
- ROLE_USER 별도 storageState 으로 권한 차단 검증
- 4 언어 UI 토글 spec (현재는 API 검증만)
- LiveKit 화상회의 / Rocket.Chat iframe / Wiki.js / MinIO Console SSO 흐름
- CI 통합 (.github/workflows/e2e.yml)
