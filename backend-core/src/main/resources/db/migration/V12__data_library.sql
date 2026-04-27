-- V12: 자료실 (Document Library) 도메인 — Phase 14 트랙 3
--
-- 본 마이그레이션은 Phase 14 §5 "트랙 3 — 자료실(Document Library)" 의 §5.2 SQL
-- 을 기준으로 작성되었다. 폴더 트리 + 파일 테이블 + 시드 (회사 공용 루트 + 시드
-- 부서별 폴더) 까지 포함한다.

-- ============================================================
-- 1. 폴더 (계층)
-- ============================================================

CREATE TABLE IF NOT EXISTS platform_v3.dl_folder (
    folder_id     BIGSERIAL PRIMARY KEY,
    parent_id     BIGINT REFERENCES platform_v3.dl_folder(folder_id) ON DELETE CASCADE,
    folder_name   VARCHAR(128) NOT NULL,
    scope         VARCHAR(16)  NOT NULL,    -- COMPANY|DEPT|PERSONAL
    owner_dept_id BIGINT,                   -- DEPT scope 일 때
    owner_no      VARCHAR(32),              -- PERSONAL scope 일 때
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_dl_folder_parent ON platform_v3.dl_folder(parent_id);
CREATE INDEX IF NOT EXISTS idx_dl_folder_scope  ON platform_v3.dl_folder(scope);
CREATE INDEX IF NOT EXISTS idx_dl_folder_dept   ON platform_v3.dl_folder(owner_dept_id);
CREATE INDEX IF NOT EXISTS idx_dl_folder_owner  ON platform_v3.dl_folder(owner_no);

-- ============================================================
-- 2. 파일
-- ============================================================

CREATE TABLE IF NOT EXISTS platform_v3.dl_file (
    file_id        BIGSERIAL PRIMARY KEY,
    folder_id      BIGINT NOT NULL REFERENCES platform_v3.dl_folder(folder_id) ON DELETE CASCADE,
    file_name      VARCHAR(256) NOT NULL,
    object_key     VARCHAR(512) NOT NULL,    -- minio: datalib/{folderId}/{filename}
    size_bytes     BIGINT NOT NULL,
    mime_type      VARCHAR(128),
    tags           VARCHAR(256),             -- CSV
    uploader_no    VARCHAR(32) NOT NULL,
    uploaded_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    download_count INT NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_dl_file_folder   ON platform_v3.dl_file(folder_id);
CREATE INDEX IF NOT EXISTS idx_dl_file_name     ON platform_v3.dl_file(file_name);
CREATE INDEX IF NOT EXISTS idx_dl_file_uploader ON platform_v3.dl_file(uploader_no);

-- ============================================================
-- 3. 시드 — COMPANY 루트 (id=1) + 부서별 자동 폴더
-- ============================================================

-- 3-1. 회사 공용 루트 (folder_id 강제 1)
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope)
VALUES (1, NULL, '회사 공용', 'COMPANY')
ON CONFLICT (folder_id) DO NOTHING;

-- 3-1b. 시퀀스 보정 — folder_id=1 강제 INSERT 시 BIGSERIAL 시퀀스가 advance 되지 않으므로
--       다음 자동 SERIAL INSERT(2, 3) 와 PK 충돌. 즉시 nextval 을 max+1 로 강제.
SELECT setval(
    'platform_v3.dl_folder_folder_id_seq',
    GREATEST((SELECT COALESCE(MAX(folder_id), 0) FROM platform_v3.dl_folder), 1),
    true
);

-- 3-2. 회사 공용 하위 — 공통 폴더 3개 (관리자 운영 가이드 따라 미리 생성)
--      회사 공용 루트의 자식이며 누구나 읽기, 관리자만 쓰기.
INSERT INTO platform_v3.dl_folder (parent_id, folder_name, scope)
SELECT 1, name, 'COMPANY'
FROM (VALUES ('규정/정책'), ('양식/서식'), ('교육자료')) AS v(name)
WHERE NOT EXISTS (
    SELECT 1 FROM platform_v3.dl_folder
    WHERE parent_id = 1 AND folder_name = v.name AND scope = 'COMPANY'
);

-- 3-3. 부서별 폴더 자동 생성 — org_department 의 leaf 단계 부서들 (level 3 팀 단위)
--      각 부서 단위로 DEPT scope 의 root 폴더 1개 생성. parent_id=NULL 로 트리의 형제 루트.
INSERT INTO platform_v3.dl_folder (parent_id, folder_name, scope, owner_dept_id)
SELECT NULL, d.dept_name, 'DEPT', d.dept_id
FROM platform_v3.org_department d
WHERE d.dept_level = 3
  AND NOT EXISTS (
      SELECT 1 FROM platform_v3.dl_folder f
      WHERE f.scope = 'DEPT' AND f.owner_dept_id = d.dept_id AND f.parent_id IS NULL
  );
