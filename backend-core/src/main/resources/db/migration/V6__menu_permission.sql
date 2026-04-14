-- 메뉴 + 권한 스키마

CREATE TABLE IF NOT EXISTS platform_v3.cm_menu (
    menu_id         VARCHAR(32) PRIMARY KEY,
    menu_name       VARCHAR(128) NOT NULL,
    menu_path       VARCHAR(256),
    parent_menu_id  VARCHAR(32),
    menu_level      INT NOT NULL DEFAULT 1,
    sort_order      INT NOT NULL DEFAULT 0,
    icon            VARCHAR(64),
    use_yn          CHAR(1) NOT NULL DEFAULT 'Y',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS platform_v3.cm_role (
    role_id     VARCHAR(32) PRIMARY KEY,
    role_name   VARCHAR(128) NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS platform_v3.cm_role_menu (
    role_id       VARCHAR(32) NOT NULL REFERENCES platform_v3.cm_role(role_id) ON DELETE CASCADE,
    menu_id       VARCHAR(32) NOT NULL REFERENCES platform_v3.cm_menu(menu_id) ON DELETE CASCADE,
    can_read      BOOLEAN NOT NULL DEFAULT TRUE,
    can_create    BOOLEAN NOT NULL DEFAULT FALSE,
    can_update    BOOLEAN NOT NULL DEFAULT FALSE,
    can_delete    BOOLEAN NOT NULL DEFAULT FALSE,
    can_export    BOOLEAN NOT NULL DEFAULT FALSE,
    can_print     BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (role_id, menu_id)
);

-- 메뉴 시드 (9종 포털 메뉴)
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon) VALUES
    ('dashboard', '대시보드',  '/dashboard', NULL, 1, 1, 'pi pi-th-large'),
    ('approval',  '전자결재',  '/approval',  NULL, 1, 2, 'pi pi-file-edit'),
    ('board',     '게시판',    '/board',     NULL, 1, 3, 'pi pi-comment'),
    ('calendar',  '캘린더',    '/calendar',  NULL, 1, 4, 'pi pi-calendar'),
    ('org',       '조직도',    '/org',       NULL, 1, 5, 'pi pi-sitemap'),
    ('messenger', '메신저',    '/messenger', NULL, 1, 6, 'pi pi-send'),
    ('mail',      '메일',      '/mail',      NULL, 1, 7, 'pi pi-inbox'),
    ('wiki',      '위키',      '/wiki',      NULL, 1, 8, 'pi pi-book'),
    ('video',     '화상회의',  '/video',     NULL, 1, 9, 'pi pi-video')
ON CONFLICT (menu_id) DO NOTHING;

-- 역할 시드
INSERT INTO platform_v3.cm_role (role_id, role_name, description) VALUES
    ('ROLE_USER',     '일반 사용자', '전 직원 기본 권한'),
    ('ROLE_APPROVER', '결재자',      '결재 권한 보유'),
    ('ROLE_MANAGER',  '부서장',      '부서 관리 권한'),
    ('ROLE_ADMIN',    '관리자',      '시스템 전체 관리')
ON CONFLICT (role_id) DO NOTHING;

-- 역할별 메뉴 권한 매핑
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print)
SELECT 'ROLE_USER', menu_id, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE FROM platform_v3.cm_menu
ON CONFLICT (role_id, menu_id) DO NOTHING;

INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print)
SELECT 'ROLE_ADMIN', menu_id, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE FROM platform_v3.cm_menu
ON CONFLICT (role_id, menu_id) DO NOTHING;
