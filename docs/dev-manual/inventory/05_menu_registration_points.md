# inventory/05_menu_registration_points.md — 메뉴 등록 지점

> Phase 0.F 산출물. 발견된 등록 지점은 **8단계** (필수 5 + 선택 3).
> 후속 `menu/menu_registration.md` 가 본 인벤토리를 본문으로 한다.

## 1. DB 스키마

### `cm_menu` 테이블 — `[code: backend-core/src/main/resources/db/migration/V6__menu_permission.sql:3-32]`

| 컬럼 | 타입 | 비고 |
|---|---|---|
| `menu_id` | VARCHAR(32) PK | 메뉴 식별자 (예: `approval`, `mywork`) |
| `menu_name` | VARCHAR(128) | 표시명(현 시점 직접 저장; i18n 미연결) |
| `menu_path` | VARCHAR(256) | 라우터 경로 (`/approval`) |
| `parent_menu_id` | VARCHAR(32) | 부모 menu_id (1단계 root 면 NULL) |
| `menu_level` | INT | 1=root, 2=leaf |
| `sort_order` | INT | 정렬 순서 |
| `icon` | VARCHAR(64) | PrimeIcon 클래스 (예: `pi pi-home`) |
| `use_yn` | CHAR(1) | `Y`/`N` |

### `cm_role` 테이블

| 컬럼 | 타입 |
|---|---|
| `role_id` | VARCHAR(32) PK (`ROLE_USER`, `ROLE_ADMIN` 등) |
| `role_name` | VARCHAR(128) |
| `description` | TEXT |

### `cm_role_menu` 테이블

| 컬럼 | 타입 | 비고 |
|---|---|---|
| `role_id` + `menu_id` | composite PK | 역할-메뉴 매핑 |
| `can_read` / `can_create` / `can_update` / `can_delete` / `can_export` / `can_print` | BOOLEAN | 권한 플래그 |

## 2. 모범 INSERT 패턴 (V17 기준)

> 출처: `[code: backend-core/src/main/resources/db/migration/V17__phase14_menus.sql:8-99]`

```sql
-- 부모 메뉴 (level=1, path=NULL)
INSERT INTO platform_v3.cm_menu
  (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon)
VALUES
  ('mywork', '내 업무', NULL, NULL, 1, 10, 'pi pi-briefcase')
ON CONFLICT (menu_id) DO NOTHING;

-- 자식 메뉴 (level=2, parent + path)
INSERT INTO platform_v3.cm_menu
  (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon)
VALUES
  ('attendance', '근태', '/attendance', 'mywork', 2, 11, 'pi pi-clock')
ON CONFLICT (menu_id) DO NOTHING;

-- 역할-메뉴 권한 (다중 행)
INSERT INTO platform_v3.cm_role_menu
  (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print)
SELECT 'ROLE_USER', menu_id, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE
FROM platform_v3.cm_menu
WHERE menu_id IN ('mywork', 'attendance', 'leave', ...)
ON CONFLICT (role_id, menu_id) DO NOTHING;
```

## 3. 백엔드 메뉴 조회 API

### `MenuService.searchByUser` — `[code: backend-core/src/main/java/com/platform/v3/core/menu/MenuService.java:23-34]`

```java
@DataSetServiceMapping("menu/searchByUser")
public Map<String, Object> searchByUser(Map<String, Object> datasets, String currentUser) {
    // SecurityContext 에서 roles 추출
    // menuMapper.selectMenusByRoles(roles) 호출
    // ds_menus key 로 평면화된 메뉴 list 반환
}
```

### MyBatis 쿼리 — `[code: backend-core/src/main/resources/mapper/menu/MenuMapper.xml:5-22]`

- `INNER JOIN cm_menu m ON m.menu_id = rm.menu_id`
- `WHERE m.use_yn='Y' AND rm.role_id IN (:roles)`
- `GROUP BY menu_*` 컬럼
- `BOOL_OR` 집계로 권한 플래그 합치기
- `ORDER BY menu_level, sort_order`

## 4. Vue Router 등록 — `[code: ui/src/router/index.ts:4-50, 57-85]`

```typescript
{
  path: 'attendance',
  name: 'attendance',
  component: () => import('@/pages/PageAttendance.vue'),
  meta: { menuId: 'attendance' }
}

// 관리자 라우트 (admin 가드)
{
  path: 'admin/users',
  name: 'admin-users',
  component: () => import('@/pages/admin/PageUsers.vue'),
  meta: { menuId: 'admin_users', requiresAdmin: true }
}
```

`router.beforeEach` 가드 로직:
- `meta.requiresAdmin` 검사 → `ROLE_ADMIN` 없으면 `/403` redirect
- `auth.menus` 의 `canRead` 검사 → false 면 `/403` redirect

## 5. 사이드바 동적 렌더링 — `[code: ui/src/store/auth.ts:55-72, ui/src/components/layout/LayoutSidebar.vue:39-82]`

- `auth.ts` `menuTree` computed: 평면 list → `parentMenuId` 로 트리 구성, `sortOrder` 정렬
- `LayoutSidebar.vue`: `v-for="menu in displayMenus"` 로 동적 렌더
  - children 보유: 토글 폴더 UI
  - leaf: 클릭 → `router.push(menu.menuPath)`
  - active: `mostSpecificActivePath` computed 로 prefix 충돌 방지
  - 아이콘: `:class="menu.icon || 'ti ti-folder'"`

대안 레이아웃 — `[code: ui/src/components/layout/LayoutTopNav.vue:51-89]`:
- group → PrimeVue `MenuItem.items` (hover dropdown)
- leaf → `MenuItem.command`

## 6. i18n 라벨 (선택 단계)

> 출처: `[code: backend-core/src/main/resources/db/migration/V9__i18n_labels_and_seed_data.sql:24-35]`

```sql
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message)
VALUES
  ('MENU_DASHBOARD','ko','MENU','대시보드'),
  ('MENU_DASHBOARD','en','MENU','Dashboard'),
  ('MENU_DASHBOARD','zh','MENU','仪表盘'),
  ('MENU_DASHBOARD','ja','MENU','ダッシュボード')
ON CONFLICT DO NOTHING;
```

> 갭: 현재 메뉴명은 `cm_menu.menu_name` 에 직접 저장되며 i18n 키와 자동 연결되지 않음. (warn.md 기록)

## 7. 아이콘 등록

- `cm_menu.icon` 컬럼이 PrimeIcon 클래스(`pi pi-clock`) 또는 Tabler(`ti ti-folder`) 직접 저장
- 별도 mapping 테이블 없음
- LayoutSidebar 에서 `:class="menu.icon"` 로 적용

## 8. K-단계 등록 절차 (총 8단계 — 필수 5 + 선택 3)

### Step 1 (필수) — 부모 메뉴 INSERT (계층이 새로 필요한 경우만)
- 파일: `backend-core/src/main/resources/db/migration/V{N+1}__{domain}_menu.sql`
- 추가 위치: 신규 마이그레이션
- 모범 예시: V17 의 `mywork` 행
- 검증: `SELECT * FROM platform_v3.cm_menu WHERE menu_id='__parent__'`

### Step 2 (필수) — 자식 메뉴 INSERT (도메인 메뉴 본체)
- 파일: 동일 마이그레이션
- 모범 예시: V17 의 `attendance` 행
- 검증: `parent_menu_id='__parent__' AND menu_level=2 AND menu_path='/__domain-kebab__'`

### Step 3 (필수) — Role-Menu 권한 INSERT
- 파일: 동일 마이그레이션
- 모범 예시: V17 의 `cm_role_menu` 패턴 (ROLE_USER + ROLE_ADMIN 각각 권한 분리)
- 검증: 역할별 1행씩, `can_read=TRUE`

### Step 4 (필수) — Vue 페이지 컴포넌트 생성
- 파일: `ui/src/pages/Page{DomainPascal}.vue`
- 추가 위치: 신규 파일
- 모범 예시: `[code: ui/src/pages/PageBoard.vue]` 등 형태별 SOP 의 골격
- 검증: 컴파일/렌더 성공

### Step 5 (필수) — Vue Router 등록
- 파일: `ui/src/router/index.ts`
- 추가 위치: children 배열 (line 33~46 부근)
- 패턴:
  ```typescript
  { path: '__domain-kebab__', name: '__domain-kebab__',
    component: () => import('@/pages/Page__DomainPascal__.vue'),
    meta: { menuId: '__domain-kebab__' } }
  ```
- 관리자: `meta: { menuId: 'admin___domain_snake__', requiresAdmin: true }`
- 검증: 컴파일 + path 가 Step 2 의 `menu_path` 와 일치

### Step 6 (선택) — Tab 아이템 등록
- 파일: `ui/src/store/tab.ts`
- 비고: 라우터 meta 와 `router.resolve` 로 자동 생성, 수동 등록 불필요

### Step 7 (선택) — i18n 라벨 INSERT
- 파일: `backend-core/src/main/resources/db/migration/V{N+2}__i18n_{domain}.sql`
- 패턴: `MENU_{DOMAIN}` 4개 로케일 (ko/en/zh/ja)
- 비고: 현재는 `cm_menu.menu_name` 직접 사용 → frontend 코드 변경 시 i18n key 매핑 도입 필요

### Step 8 (필수) — 권한 검증 테스트
- 1) DB: `SELECT * FROM cm_menu WHERE menu_id='__domain__'`
- 2) Backend API: `POST /api/dataset/search { serviceName: 'menu/searchByUser' }` → 결과에 메뉴 포함
- 3) 사이드바: `ROLE_USER` 로 로그인 → 부모 그룹 아래에 메뉴 노출 확인
- 4) 가드: `can_read=FALSE` 로 변경 → URL 직접 접근 시 `/403`
- 5) admin 라우트: `requiresAdmin=true` 인 경우 `ROLE_USER` 직접 접근 시 `/403`

## 9. 핵심 통찰

- **단일 정보원(SSOT)**: 사이드바/탑네비 모두 `authStore.menuTree` 만 렌더 (하드코딩 메뉴 없음)
- **권한 시행 지점 3곳**:
  1. `MenuMapper` 쿼리: `WHERE rm.role_id IN :roles`
  2. `router.beforeEach`: `requiresAdmin` + `canRead` 체크
  3. 사이드바/탑네비: `can_read=TRUE` 인 메뉴만 표시
- **라우터 단독 등록은 무효**: `cm_menu` row 가 없으면 사이드바에 보이지 않음 (라우트 + DB row + role 권한 3가지 모두 필요)
- **갭**: 메뉴명-다국어 자동 lookup 미구현 (warn.md 기록)

## 10. 출처 정리

- `[code: backend-core/src/main/resources/db/migration/V6__menu_permission.sql:3-32]` — 스키마
- `[code: backend-core/src/main/resources/db/migration/V17__phase14_menus.sql:8-99]` — 모범 INSERT
- `[code: backend-core/src/main/resources/db/migration/V9__i18n_labels_and_seed_data.sql:24-35]` — i18n
- `[code: backend-core/src/main/java/com/platform/v3/core/menu/MenuService.java:23-34]` — Service
- `[code: backend-core/src/main/resources/mapper/menu/MenuMapper.xml:5-22]` — 쿼리
- `[code: ui/src/router/index.ts:4-50, 57-85]` — 라우트 + 가드
- `[code: ui/src/store/auth.ts:55-72]` — menuTree
- `[code: ui/src/components/layout/LayoutSidebar.vue:39-82]` — 사이드바 렌더
- `[code: ui/src/components/layout/LayoutTopNav.vue:51-89]` — 탑네비 렌더
