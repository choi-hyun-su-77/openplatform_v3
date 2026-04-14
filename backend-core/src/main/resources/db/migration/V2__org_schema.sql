-- org (조직) 스키마

CREATE TABLE IF NOT EXISTS platform_v3.org_department (
    dept_id         BIGSERIAL PRIMARY KEY,
    dept_code       VARCHAR(32) NOT NULL UNIQUE,
    dept_name       VARCHAR(128) NOT NULL,
    parent_dept_id  BIGINT REFERENCES platform_v3.org_department(dept_id),
    dept_level      INT NOT NULL DEFAULT 1,
    sort_order      INT NOT NULL DEFAULT 0,
    use_yn          CHAR(1) NOT NULL DEFAULT 'Y',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS platform_v3.org_position (
    position_id     BIGSERIAL PRIMARY KEY,
    position_code   VARCHAR(32) NOT NULL UNIQUE,
    position_name   VARCHAR(64) NOT NULL,
    position_level  INT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS platform_v3.org_employee (
    employee_id      BIGSERIAL PRIMARY KEY,
    employee_no      VARCHAR(32) NOT NULL UNIQUE,
    employee_name    VARCHAR(64) NOT NULL,
    dept_id          BIGINT NOT NULL REFERENCES platform_v3.org_department(dept_id),
    position_id      BIGINT NOT NULL REFERENCES platform_v3.org_position(position_id),
    email            VARCHAR(128),
    phone            VARCHAR(32),
    keycloak_user_id VARCHAR(64) UNIQUE,
    hire_date        DATE,
    status           VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_org_employee_dept ON platform_v3.org_employee(dept_id);
CREATE INDEX IF NOT EXISTS idx_org_employee_keycloak ON platform_v3.org_employee(keycloak_user_id);

-- 시드 데이터 (개발용)
INSERT INTO platform_v3.org_position (position_code, position_name, position_level) VALUES
    ('CEO', '대표이사', 1),
    ('DIV_HEAD', '본부장', 2),
    ('TEAM_LEAD', '팀장', 3),
    ('MANAGER', '과장', 4),
    ('STAFF', '사원', 5)
ON CONFLICT (position_code) DO NOTHING;

INSERT INTO platform_v3.org_department (dept_code, dept_name, parent_dept_id, dept_level, sort_order) VALUES
    ('HQ', '본사', NULL, 1, 1)
ON CONFLICT (dept_code) DO NOTHING;
