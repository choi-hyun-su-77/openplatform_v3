-- V17: Phase 14 신규 메뉴 일괄 등록 + 권한 매트릭스
-- 트랙 1~7 의 신규 페이지 13개 + 부모 그룹 4개 cm_menu 등록.
-- 사이드바는 authStore.menuTree 동적 렌더링이라 cm_menu INSERT 만으로 표시 갱신.

-- ============================================================
-- 1. 부모 그룹 메뉴 (top-level)
-- ============================================================
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon) VALUES
    ('mywork',   '내 업무',     NULL, NULL, 1, 10, 'pi pi-briefcase'),
    ('work',     '업무',         NULL, NULL, 1, 20, 'pi pi-folder'),
    ('settings', '설정',         NULL, NULL, 1, 80, 'pi pi-cog'),
    ('admin',    '시스템관리',   NULL, NULL, 1, 90, 'pi pi-shield')
ON CONFLICT (menu_id) DO NOTHING;

-- ============================================================
-- 2. 통합 검색 (top-level)
-- ============================================================
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon) VALUES
    ('search', '통합검색', '/search', NULL, 1, 5, 'pi pi-search')
ON CONFLICT (menu_id) DO NOTHING;

-- ============================================================
-- 3. mywork 그룹 (트랙 1·4)
-- ============================================================
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon) VALUES
    ('attendance', '근태',       '/attendance', 'mywork', 2, 11, 'pi pi-clock'),
    ('leave',      '연차/휴가',  '/leave',      'mywork', 2, 12, 'pi pi-calendar-plus'),
    ('worklog',    '업무일지',   '/worklog',    'mywork', 2, 13, 'pi pi-pencil')
ON CONFLICT (menu_id) DO NOTHING;

-- ============================================================
-- 4. work 그룹 (트랙 2·3)
-- ============================================================
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon) VALUES
    ('room',    '회의실예약', '/room',    'work', 2, 21, 'pi pi-users'),
    ('datalib', '자료실',     '/datalib', 'work', 2, 22, 'pi pi-folder-open')
ON CONFLICT (menu_id) DO NOTHING;

-- ============================================================
-- 5. settings 그룹 (트랙 6)
-- ============================================================
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon) VALUES
    ('settings_notify', '알림설정', '/settings/notify',    'settings', 2, 81, 'pi pi-bell'),
    ('settings_fav',    '즐겨찾기', '/settings/favorites', 'settings', 2, 82, 'pi pi-star')
ON CONFLICT (menu_id) DO NOTHING;

-- ============================================================
-- 6. admin 그룹 (트랙 5, ROLE_ADMIN 한정)
-- ============================================================
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon) VALUES
    ('admin_users', '사용자관리', '/admin/users', 'admin', 2, 91, 'pi pi-user-plus'),
    ('admin_depts', '조직관리',   '/admin/depts', 'admin', 2, 92, 'pi pi-sitemap'),
    ('admin_menus', '메뉴관리',   '/admin/menus', 'admin', 2, 93, 'pi pi-bars'),
    ('admin_codes', '공통코드',   '/admin/codes', 'admin', 2, 94, 'pi pi-list'),
    ('admin_audit', '감사로그',   '/admin/audit', 'admin', 2, 95, 'pi pi-history')
ON CONFLICT (menu_id) DO NOTHING;

-- ============================================================
-- 7. ROLE_USER 권한 — 일반 업무 메뉴 + 부모 그룹 (admin 제외)
-- ============================================================
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print)
SELECT 'ROLE_USER', menu_id, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE
FROM platform_v3.cm_menu
WHERE menu_id IN (
    'mywork', 'work', 'settings', 'search',
    'attendance', 'leave', 'worklog',
    'room', 'datalib',
    'settings_notify', 'settings_fav'
)
ON CONFLICT (role_id, menu_id) DO NOTHING;

-- ============================================================
-- 8. ROLE_MANAGER 권한 — USER 동일 + 부서장 추가 가시성 (UI 가 role 로 자체 분기)
-- ============================================================
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print)
SELECT 'ROLE_MANAGER', menu_id, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE
FROM platform_v3.cm_menu
WHERE menu_id IN (
    'mywork', 'work', 'settings', 'search',
    'attendance', 'leave', 'worklog',
    'room', 'datalib',
    'settings_notify', 'settings_fav'
)
ON CONFLICT (role_id, menu_id) DO NOTHING;

-- ============================================================
-- 9. ROLE_ADMIN 권한 — 신규 전체 RWUD
-- ============================================================
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print)
SELECT 'ROLE_ADMIN', menu_id, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
FROM platform_v3.cm_menu
WHERE menu_id IN (
    'mywork', 'work', 'settings', 'admin', 'search',
    'attendance', 'leave', 'worklog',
    'room', 'datalib',
    'settings_notify', 'settings_fav',
    'admin_users', 'admin_depts', 'admin_menus', 'admin_codes', 'admin_audit'
)
ON CONFLICT (role_id, menu_id) DO NOTHING;
