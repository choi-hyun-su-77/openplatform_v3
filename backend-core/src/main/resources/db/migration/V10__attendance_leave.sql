-- V10: 근태(at_attendance) / 연차잔여(at_leave_balance) / 휴가신청(at_leave_request)
-- Phase 14 트랙 1 — Attendance & Leave
--
-- 모든 테이블은 CREATE IF NOT EXISTS 로 작성하여 클린 부팅 / 런타임 양쪽 지원.

-- ============================================================
-- 1. 출퇴근 일별 기록
-- ============================================================
CREATE TABLE IF NOT EXISTS platform_v3.at_attendance (
  attendance_id BIGSERIAL PRIMARY KEY,
  employee_no   VARCHAR(32) NOT NULL,
  work_date     DATE NOT NULL,
  check_in_at   TIMESTAMPTZ,
  check_out_at  TIMESTAMPTZ,
  work_minutes  INT,                  -- 자동 계산
  status        VARCHAR(16) NOT NULL DEFAULT 'NORMAL',  -- NORMAL|LATE|EARLY|ABSENT|HOLIDAY|LEAVE
  note          VARCHAR(256),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (employee_no, work_date)
);
CREATE INDEX IF NOT EXISTS idx_at_attendance_emp_date
  ON platform_v3.at_attendance(employee_no, work_date DESC);

-- ============================================================
-- 2. 연차 잔여 (연도별)
-- ============================================================
CREATE TABLE IF NOT EXISTS platform_v3.at_leave_balance (
  balance_id    BIGSERIAL PRIMARY KEY,
  employee_no   VARCHAR(32) NOT NULL,
  year          INT NOT NULL,
  total_days    NUMERIC(5,1) NOT NULL,    -- 부여 (15.0 등)
  used_days     NUMERIC(5,1) NOT NULL DEFAULT 0,
  carry_over    NUMERIC(5,1) NOT NULL DEFAULT 0,  -- 이월
  remaining     NUMERIC(5,1) GENERATED ALWAYS AS (total_days + carry_over - used_days) STORED,
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (employee_no, year)
);

-- ============================================================
-- 3. 휴가 신청 (결재 ap_document 와 1:1 매핑, form_code='LEAVE')
-- ============================================================
CREATE TABLE IF NOT EXISTS platform_v3.at_leave_request (
  request_id    BIGSERIAL PRIMARY KEY,
  doc_id        BIGINT REFERENCES platform_v3.ap_document(doc_id) ON DELETE SET NULL,
  employee_no   VARCHAR(32) NOT NULL,
  leave_type    VARCHAR(16) NOT NULL,     -- ANNUAL|HALF_AM|HALF_PM|SICK|FAMILY|UNPAID
  from_date     DATE NOT NULL,
  to_date       DATE NOT NULL,
  days          NUMERIC(4,1) NOT NULL,    -- 0.5 단위 (반차 0.5)
  reason        VARCHAR(512),
  status        VARCHAR(16) NOT NULL DEFAULT 'PENDING', -- PENDING|APPROVED|REJECTED|CANCELLED
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_at_leave_emp
  ON platform_v3.at_leave_request(employee_no, from_date DESC);
CREATE INDEX IF NOT EXISTS idx_at_leave_doc
  ON platform_v3.at_leave_request(doc_id);

-- ============================================================
-- 4. 시드 데이터 — 2026 연차 잔여 (admin 15일, user1~3 각 12일)
-- ============================================================
INSERT INTO platform_v3.at_leave_balance (employee_no, year, total_days) VALUES
  ('E0001', 2026, 15.0),
  ('E0002', 2026, 12.0),
  ('E0003', 2026, 12.0),
  ('E0004', 2026, 12.0)
ON CONFLICT DO NOTHING;
