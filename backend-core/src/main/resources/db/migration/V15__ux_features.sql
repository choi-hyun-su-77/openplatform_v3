-- V15 — Phase 14 트랙 6: UX 강화 (즐겨찾기 / 알림설정)
-- 통합검색은 별도 인덱스 테이블 없이 PG 의 ILIKE + UNION 으로 처리 (50명 규모면 충분).
-- 추후 필요 시 pg_trgm 또는 OpenSearch 추가.

-- ===========================================================================
-- 즐겨찾기 (Favorite) — 사용자별 메뉴/문서/사람 핀
-- ===========================================================================
CREATE TABLE IF NOT EXISTS platform_v3.ux_favorite (
    fav_id       BIGSERIAL PRIMARY KEY,
    employee_no  VARCHAR(32)  NOT NULL,
    target_type  VARCHAR(16)  NOT NULL,    -- MENU|POST|DOC|EMPLOYEE|FILE
    target_id    VARCHAR(64)  NOT NULL,
    label        VARCHAR(128),
    url          VARCHAR(256),
    icon         VARCHAR(32),
    sort_order   INT          NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (employee_no, target_type, target_id)
);

CREATE INDEX IF NOT EXISTS idx_ux_favorite_emp_sort
    ON platform_v3.ux_favorite(employee_no, sort_order);

-- ===========================================================================
-- 알림 채널 환경설정 (NotifyPref) — 카테고리×채널 매트릭스
-- ===========================================================================
CREATE TABLE IF NOT EXISTS platform_v3.ux_notify_pref (
    pref_id      BIGSERIAL PRIMARY KEY,
    employee_no  VARCHAR(32)  NOT NULL,
    category     VARCHAR(32)  NOT NULL,    -- APPROVAL|BOARD|CALENDAR|MENTION|ROOM|LEAVE
    channel      VARCHAR(16)  NOT NULL,    -- PORTAL|EMAIL|MESSENGER
    enabled      BOOLEAN      NOT NULL DEFAULT TRUE,
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (employee_no, category, channel)
);

CREATE INDEX IF NOT EXISTS idx_ux_notify_pref_emp_cat
    ON platform_v3.ux_notify_pref(employee_no, category);

-- ===========================================================================
-- 시드 — 검증용 즐겨찾기 5건 (admin 계정)
-- ===========================================================================
INSERT INTO platform_v3.ux_favorite (employee_no, target_type, target_id, label, url, icon, sort_order)
VALUES
    ('E0001', 'MENU', 'approval',  '결재함',     '/approval',  'pi pi-file-edit', 1),
    ('E0001', 'MENU', 'board',     '게시판',     '/board',     'pi pi-comment',   2),
    ('E0001', 'MENU', 'calendar',  '캘린더',     '/calendar',  'pi pi-calendar',  3),
    ('E0001', 'MENU', 'attendance','근태',       '/attendance','pi pi-clock',     4),
    ('E0001', 'MENU', 'datalib',   '자료실',     '/datalib',   'pi pi-folder',    5)
ON CONFLICT DO NOTHING;

-- ===========================================================================
-- 시드 — 검증용 알림 환경설정 (admin: 모든 카테고리 PORTAL=ON, EMAIL/MESSENGER=OFF)
-- ===========================================================================
INSERT INTO platform_v3.ux_notify_pref (employee_no, category, channel, enabled) VALUES
    ('E0001', 'APPROVAL', 'PORTAL',    TRUE),
    ('E0001', 'APPROVAL', 'EMAIL',     FALSE),
    ('E0001', 'APPROVAL', 'MESSENGER', FALSE),
    ('E0001', 'BOARD',    'PORTAL',    TRUE),
    ('E0001', 'BOARD',    'EMAIL',     FALSE),
    ('E0001', 'BOARD',    'MESSENGER', FALSE),
    ('E0001', 'CALENDAR', 'PORTAL',    TRUE),
    ('E0001', 'CALENDAR', 'EMAIL',     FALSE),
    ('E0001', 'CALENDAR', 'MESSENGER', FALSE),
    ('E0001', 'MENTION',  'PORTAL',    TRUE),
    ('E0001', 'MENTION',  'EMAIL',     FALSE),
    ('E0001', 'MENTION',  'MESSENGER', TRUE),
    ('E0001', 'ROOM',     'PORTAL',    TRUE),
    ('E0001', 'ROOM',     'EMAIL',     FALSE),
    ('E0001', 'ROOM',     'MESSENGER', FALSE),
    ('E0001', 'LEAVE',    'PORTAL',    TRUE),
    ('E0001', 'LEAVE',    'EMAIL',     TRUE),
    ('E0001', 'LEAVE',    'MESSENGER', FALSE)
ON CONFLICT DO NOTHING;
