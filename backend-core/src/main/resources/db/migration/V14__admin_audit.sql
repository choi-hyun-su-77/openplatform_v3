-- V14 — 시스템 관리자 감사 로그
-- Phase 14 Track 5: Admin Console
--
-- 모든 admin/* DataSet 호출이 자동으로 sa_audit 테이블에 기록된다.
-- AdminAuditAspect (Spring AOP @Around) 가 정상 종료된 호출에 한해 insert.

CREATE TABLE IF NOT EXISTS platform_v3.sa_audit (
    audit_id     BIGSERIAL PRIMARY KEY,
    actor_no     VARCHAR(32) NOT NULL,
    actor_name   VARCHAR(64) NOT NULL,
    action       VARCHAR(64) NOT NULL,    -- DataSet serviceName 자체 (예: admin/userSave)
    target_type  VARCHAR(32),
    target_id    VARCHAR(64),
    before_json  JSONB,
    after_json   JSONB,
    ip_addr      VARCHAR(45),
    acted_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sa_audit_actor_time
    ON platform_v3.sa_audit(actor_no, acted_at DESC);

CREATE INDEX IF NOT EXISTS idx_sa_audit_target
    ON platform_v3.sa_audit(target_type, target_id);

CREATE INDEX IF NOT EXISTS idx_sa_audit_action_time
    ON platform_v3.sa_audit(action, acted_at DESC);

-- 시드 5건 — 검증용 더미 (clean boot 직후에도 PageAudit 화면에 데이터가 보이도록)
INSERT INTO platform_v3.sa_audit (actor_no, actor_name, action, target_type, target_id, after_json)
VALUES
    ('E0001', '관리자', 'admin/system_init',  'SYSTEM', 'BOOT',     '{"phase":"14","track":"5"}'::jsonb),
    ('E0001', '관리자', 'admin/userList',     'USER',   '-',         '{"note":"seed"}'::jsonb),
    ('E0001', '관리자', 'admin/menuList',     'MENU',   '-',         '{"note":"seed"}'::jsonb),
    ('E0001', '관리자', 'admin/codeGroupList','CODE',   '-',         '{"note":"seed"}'::jsonb),
    ('E0001', '관리자', 'admin/deptTree',     'DEPT',   '-',         '{"note":"seed"}'::jsonb)
ON CONFLICT DO NOTHING;
