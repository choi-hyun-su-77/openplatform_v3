-- V16: 대시보드 위젯 시스템 — Phase 14 트랙 7
--
-- Phase 14 §9.2 SQL 기준.
-- 두 테이블:
--   db_widget       — 위젯 카탈로그 (widget_code PK, default size, category)
--   db_user_widget  — 사용자별 위젯 배치/설정 (employee_no + widget_code UNIQUE)
--
-- 시드:
--   - 9개 위젯 카탈로그 (ATTENDANCE / LEAVE_BALANCE / PENDING_APPROVAL / TODAY_EVENTS /
--     NOTICES / MESSENGER_UNREAD / MY_ROOMS / TEAM_WORKLOG / CHART_LEAVE_USAGE)
--   - db_user_widget 시드는 두지 않는다 — 첫 listMine 호출 시 server-side 자동 시드.

-- ============================================================
-- 1. 위젯 카탈로그
-- ============================================================
CREATE TABLE IF NOT EXISTS platform_v3.db_widget (
    widget_code  VARCHAR(32)  PRIMARY KEY,    -- ATTENDANCE|LEAVE_BALANCE|PENDING_APPROVAL|...
    title        VARCHAR(64)  NOT NULL,
    description  VARCHAR(256),
    default_w    INT          NOT NULL DEFAULT 1,    -- grid columns 1~12 (CSS Grid 기준)
    default_h    INT          NOT NULL DEFAULT 1,    -- grid rows 1~3
    category     VARCHAR(32),                        -- WORK|PERSONAL|TEAM
    active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 2. 사용자별 위젯 배치
-- ============================================================
CREATE TABLE IF NOT EXISTS platform_v3.db_user_widget (
    id           BIGSERIAL    PRIMARY KEY,
    employee_no  VARCHAR(32)  NOT NULL,
    widget_code  VARCHAR(32)  NOT NULL REFERENCES platform_v3.db_widget(widget_code) ON DELETE CASCADE,
    pos_x        INT          NOT NULL DEFAULT 0,    -- grid column start (0~11)
    pos_y        INT          NOT NULL DEFAULT 0,    -- grid row start (0~)
    width        INT          NOT NULL DEFAULT 3,    -- 1~12
    height       INT          NOT NULL DEFAULT 1,    -- 1~3
    config_json  JSONB,
    sort_order   INT          NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_db_user_widget UNIQUE (employee_no, widget_code)
);

CREATE INDEX IF NOT EXISTS idx_db_user_widget_emp
    ON platform_v3.db_user_widget(employee_no);

-- ============================================================
-- 3. 위젯 카탈로그 시드 (9건)
-- ============================================================
-- default_w 는 CSS Grid 12-column 기준. 화면 폭 1280px 가정 시
--   1=좁은 카드, 2=절반의 절반, 3=¼, 4=⅓, 6=½, 8=⅔, 12=full
INSERT INTO platform_v3.db_widget (widget_code, title, description, default_w, default_h, category) VALUES
    ('ATTENDANCE',         '출퇴근',          '오늘 출/퇴근 + 근무시간',                4, 1, 'PERSONAL'),
    ('LEAVE_BALANCE',      '연차 잔여',       '잔여/총 일수 도넛',                       4, 1, 'PERSONAL'),
    ('PENDING_APPROVAL',   '미결 결재',       '내 미결 결재 카운트',                     4, 1, 'WORK'),
    ('TODAY_EVENTS',       '오늘 일정',       '오늘 캘린더 이벤트',                      6, 1, 'WORK'),
    ('NOTICES',            '최근 공지',       '게시판 NOTICE 5건',                       6, 1, 'WORK'),
    ('MESSENGER_UNREAD',   '메신저',          'Rocket.Chat unread DM',                   4, 1, 'WORK'),
    ('MY_ROOMS',           '다가오는 회의',   '내 회의실 예약 3건',                      6, 1, 'WORK'),
    ('TEAM_WORKLOG',       '팀 업무일지',     '부서원 5명 × 오늘 업무일지 (부서장)',     12, 1, 'TEAM'),
    ('CHART_LEAVE_USAGE',  '연차 사용 추이',  '월별 연차 사용 막대 그래프',              6, 2, 'PERSONAL')
ON CONFLICT (widget_code) DO UPDATE
   SET title       = EXCLUDED.title,
       description = EXCLUDED.description,
       default_w   = EXCLUDED.default_w,
       default_h   = EXCLUDED.default_h,
       category    = EXCLUDED.category,
       updated_at  = NOW();
