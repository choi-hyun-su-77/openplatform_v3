-- 게시판 + 캘린더 스키마

CREATE TABLE IF NOT EXISTS platform_v3.bd_post (
    post_id     BIGSERIAL PRIMARY KEY,
    board_type  VARCHAR(32) NOT NULL,
    dept_id     BIGINT REFERENCES platform_v3.org_department(dept_id),
    title       VARCHAR(256) NOT NULL,
    content     TEXT,
    view_count  INT NOT NULL DEFAULT 0,
    is_pinned   CHAR(1) NOT NULL DEFAULT 'N',
    attachments JSONB,
    created_by  VARCHAR(64),
    updated_by  VARCHAR(64),
    deleted_by  VARCHAR(64),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_bd_post_type_dept ON platform_v3.bd_post(board_type, dept_id, deleted_at);
CREATE INDEX IF NOT EXISTS idx_bd_post_created  ON platform_v3.bd_post(created_at DESC);

CREATE TABLE IF NOT EXISTS platform_v3.cal_event (
    event_id    BIGSERIAL PRIMARY KEY,
    title       VARCHAR(256) NOT NULL,
    description TEXT,
    event_type  VARCHAR(16) NOT NULL, -- PERSONAL / DEPT / COMPANY
    owner_id    BIGINT,
    dept_id     BIGINT REFERENCES platform_v3.org_department(dept_id),
    start_dt    TIMESTAMPTZ NOT NULL,
    end_dt      TIMESTAMPTZ NOT NULL,
    all_day     BOOLEAN NOT NULL DEFAULT FALSE,
    color       VARCHAR(16),
    location    VARCHAR(256),
    created_by  VARCHAR(64),
    updated_by  VARCHAR(64),
    deleted_by  VARCHAR(64),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_cal_event_range ON platform_v3.cal_event(start_dt, end_dt);
CREATE INDEX IF NOT EXISTS idx_cal_event_owner ON platform_v3.cal_event(owner_id);
CREATE INDEX IF NOT EXISTS idx_cal_event_dept  ON platform_v3.cal_event(dept_id);
