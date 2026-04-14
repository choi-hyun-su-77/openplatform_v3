-- openplatform_v3 baseline schema (flyway)
-- 실제 테이블 정의는 v1 분석 후 Phase 6~9 에서 도메인별 마이그레이션으로 추가.

CREATE TABLE IF NOT EXISTS platform_v3.meta_version (
    id SERIAL PRIMARY KEY,
    version VARCHAR(32) NOT NULL,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    description TEXT
);

INSERT INTO platform_v3.meta_version (version, description) VALUES ('3.0.0', 'baseline');
