-- V13: 업무일지 (Work Report) 도메인 — Phase 14 트랙 4
--
-- Phase 14 §6.2 SQL 기준. wr_daily 테이블 한 개 + UNIQUE(employee_no, report_date)
-- + 인덱스(employee_no, report_date DESC). PostgreSQL upsert 패턴(ON CONFLICT)을
-- service 단에서 활용하기 위한 베이스.
--
-- 시드는 트랙 4 §1.6 의 "최소 검증용 시드" 정책에 따라 5건 이내. 실제 운영자가
-- 즉시 직접 작성하므로 강한 시드는 두지 않는다 (admin 1건만 today 자동 미생성).

-- ============================================================
-- 1. 일일 업무 일지
-- ============================================================
CREATE TABLE IF NOT EXISTS platform_v3.wr_daily (
  report_id     BIGSERIAL PRIMARY KEY,
  employee_no   VARCHAR(32) NOT NULL,
  report_date   DATE        NOT NULL,
  done_today    TEXT,
  plan_tomorrow TEXT,
  issue         TEXT,
  mood          VARCHAR(16),                -- GOOD|NORMAL|BAD (선택)
  hours_worked  NUMERIC(4,1),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (employee_no, report_date)
);

CREATE INDEX IF NOT EXISTS idx_wr_daily_emp_date
  ON platform_v3.wr_daily(employee_no, report_date DESC);

-- 부서장 팀 뷰 (dept_id 기반 JOIN) 가속용 보조 인덱스 — report_date 단독.
CREATE INDEX IF NOT EXISTS idx_wr_daily_date
  ON platform_v3.wr_daily(report_date);

-- ============================================================
-- 2. 시드 — 검증용 4건 (admin/E0001 의 최근 3일치 + 동료 1건).
--    upsert 시 충돌 방지를 위해 ON CONFLICT DO NOTHING.
-- ============================================================
INSERT INTO platform_v3.wr_daily
  (employee_no, report_date, done_today, plan_tomorrow, issue, mood, hours_worked)
VALUES
  ('E0001', CURRENT_DATE - INTERVAL '2 day',
     '근태 모듈 코드 리뷰 / 회의실 예약 시드 작성',
     '업무일지 폼 디자인',
     NULL,
     'GOOD', 8.0),
  ('E0001', CURRENT_DATE - INTERVAL '1 day',
     '업무일지 V13 마이그레이션 / Service 골격',
     '팀 뷰 DataTable + DailyEditor 구현',
     '주간 보정 로직 검토 필요',
     'NORMAL', 8.5),
  ('E0002', CURRENT_DATE - INTERVAL '1 day',
     '결재 LEAVE 분기 테스트',
     '회의실 BookingDialog UI',
     NULL,
     'GOOD', 7.5),
  ('E0003', CURRENT_DATE - INTERVAL '1 day',
     '자료실 폴더 트리 권한 헬퍼 작성',
     '업로드 메타 검증 보강',
     '용량 정책 확인 필요',
     'NORMAL', 8.0)
ON CONFLICT (employee_no, report_date) DO NOTHING;
