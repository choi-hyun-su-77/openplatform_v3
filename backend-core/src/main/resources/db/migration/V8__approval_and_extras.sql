-- V8: 결재(approval) / 게시판 첨부·댓글 / 공휴일 / 대결 등 확장 스키마
--
-- 대부분 CREATE TABLE IF NOT EXISTS 사용 — 런타임에서 이미 생성된 DB 와
-- 클린 부팅 양쪽 모두 지원.

-- ============================================================
-- 1. 결재 도메인
-- ============================================================

CREATE TABLE IF NOT EXISTS platform_v3.ap_document (
    doc_id       BIGSERIAL PRIMARY KEY,
    doc_title    VARCHAR(256) NOT NULL,
    form_code    VARCHAR(32)  NOT NULL,
    drafter_no   VARCHAR(32)  NOT NULL,
    drafter_name VARCHAR(64)  NOT NULL,
    drafter_dept VARCHAR(64),
    status       VARCHAR(16)  NOT NULL,  -- DRAFT|PENDING|IN_PROGRESS|APPROVED|REJECTED
    content      TEXT,
    amount       BIGINT,                 -- 결재 금액 (DMN 결재선 규칙 키)
    parent_doc_id BIGINT,                -- 재상신 시 원본 참조
    version      INT NOT NULL DEFAULT 1,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- 런타임 DB 에 amount/parent_doc_id/version 이 없을 수 있으므로 안전하게 ADD
ALTER TABLE platform_v3.ap_document
    ADD COLUMN IF NOT EXISTS amount BIGINT;
ALTER TABLE platform_v3.ap_document
    ADD COLUMN IF NOT EXISTS parent_doc_id BIGINT;
ALTER TABLE platform_v3.ap_document
    ADD COLUMN IF NOT EXISTS version INT NOT NULL DEFAULT 1;

CREATE INDEX IF NOT EXISTS idx_ap_document_drafter
    ON platform_v3.ap_document(drafter_no);
CREATE INDEX IF NOT EXISTS idx_ap_document_status
    ON platform_v3.ap_document(status);
CREATE INDEX IF NOT EXISTS idx_ap_document_form
    ON platform_v3.ap_document(form_code);

CREATE TABLE IF NOT EXISTS platform_v3.ap_approval_line (
    line_id       BIGSERIAL PRIMARY KEY,
    doc_id        BIGINT NOT NULL REFERENCES platform_v3.ap_document(doc_id) ON DELETE CASCADE,
    step_order    INTEGER NOT NULL,
    approver_no   VARCHAR(32) NOT NULL,
    approver_name VARCHAR(64) NOT NULL,
    role          VARCHAR(32),
    status        VARCHAR(16) NOT NULL DEFAULT 'PENDING',  -- PENDING|APPROVED|REJECTED|SKIPPED
    comment       TEXT,
    acted_at      TIMESTAMPTZ,
    acted_by_no   VARCHAR(32)  -- 대결 시 실제 결재자 (approver_no 는 지정된 자)
);

ALTER TABLE platform_v3.ap_approval_line
    ADD COLUMN IF NOT EXISTS acted_by_no VARCHAR(32);

CREATE INDEX IF NOT EXISTS idx_ap_line_doc
    ON platform_v3.ap_approval_line(doc_id);
CREATE INDEX IF NOT EXISTS idx_ap_line_approver
    ON platform_v3.ap_approval_line(approver_no);

-- 결재 첨부 파일 (MinIO presigned 대상)
CREATE TABLE IF NOT EXISTS platform_v3.ap_attachment (
    attach_id    BIGSERIAL PRIMARY KEY,
    doc_id       BIGINT NOT NULL REFERENCES platform_v3.ap_document(doc_id) ON DELETE CASCADE,
    object_key   VARCHAR(512) NOT NULL,   -- MinIO 오브젝트 키 (approval/{docId}/{filename})
    filename     VARCHAR(256) NOT NULL,
    size_bytes   BIGINT NOT NULL,
    mime_type    VARCHAR(128),
    uploader_no  VARCHAR(32) NOT NULL,
    uploaded_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ap_attachment_doc
    ON platform_v3.ap_attachment(doc_id);

-- 대결(delegate) — 부재 기간 동안 결재 위임
CREATE TABLE IF NOT EXISTS platform_v3.ap_delegation (
    delegation_id  BIGSERIAL PRIMARY KEY,
    delegator_no   VARCHAR(32) NOT NULL,  -- 원래 결재자 (부재자)
    delegatee_no   VARCHAR(32) NOT NULL,  -- 대리 결재자
    reason         VARCHAR(256),
    from_date      DATE NOT NULL,
    to_date        DATE NOT NULL,
    active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ap_delegation_delegator
    ON platform_v3.ap_delegation(delegator_no, active, from_date, to_date);

-- 결재 액션 이력 (감사 로그)
CREATE TABLE IF NOT EXISTS platform_v3.ap_history (
    history_id   BIGSERIAL PRIMARY KEY,
    doc_id       BIGINT NOT NULL REFERENCES platform_v3.ap_document(doc_id) ON DELETE CASCADE,
    line_id      BIGINT,
    action       VARCHAR(32) NOT NULL,    -- SUBMIT|APPROVE|REJECT|WITHDRAW|RESUBMIT|DELEGATE
    actor_no     VARCHAR(32) NOT NULL,
    actor_name   VARCHAR(64) NOT NULL,
    comment      TEXT,
    acted_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ap_history_doc
    ON platform_v3.ap_history(doc_id);

-- ============================================================
-- 2. 게시판 확장 — 댓글 / 첨부
-- ============================================================

CREATE TABLE IF NOT EXISTS platform_v3.bd_comment (
    comment_id   BIGSERIAL PRIMARY KEY,
    post_id      BIGINT NOT NULL,         -- bd_post FK (런타임에 이미 있을 수 있음)
    parent_id    BIGINT,                  -- 대댓글 (null=루트)
    content      TEXT NOT NULL,
    author_no    VARCHAR(32) NOT NULL,
    author_name  VARCHAR(64) NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted      BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS idx_bd_comment_post
    ON platform_v3.bd_comment(post_id);
CREATE INDEX IF NOT EXISTS idx_bd_comment_parent
    ON platform_v3.bd_comment(parent_id);

CREATE TABLE IF NOT EXISTS platform_v3.bd_attachment (
    attach_id    BIGSERIAL PRIMARY KEY,
    post_id      BIGINT NOT NULL,
    object_key   VARCHAR(512) NOT NULL,
    filename     VARCHAR(256) NOT NULL,
    size_bytes   BIGINT NOT NULL,
    mime_type    VARCHAR(128),
    uploader_no  VARCHAR(32) NOT NULL,
    uploaded_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_bd_attachment_post
    ON platform_v3.bd_attachment(post_id);

-- ============================================================
-- 3. 캘린더 확장 — 공휴일
-- ============================================================

CREATE TABLE IF NOT EXISTS platform_v3.cm_holiday (
    holiday_id   BIGSERIAL PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    holiday_name VARCHAR(64) NOT NULL,
    holiday_type VARCHAR(16) NOT NULL DEFAULT 'PUBLIC',  -- PUBLIC|COMPANY|CUSTOM
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2026 주요 한국 공휴일 (minimal seed — 실제 운영은 API 동기화)
INSERT INTO platform_v3.cm_holiday (holiday_date, holiday_name, holiday_type) VALUES
    ('2026-01-01', '신정',         'PUBLIC'),
    ('2026-02-17', '설날',         'PUBLIC'),
    ('2026-02-18', '설날',         'PUBLIC'),
    ('2026-02-19', '설날',         'PUBLIC'),
    ('2026-03-01', '삼일절',       'PUBLIC'),
    ('2026-05-05', '어린이날',     'PUBLIC'),
    ('2026-05-24', '부처님오신날', 'PUBLIC'),
    ('2026-06-06', '현충일',       'PUBLIC'),
    ('2026-08-15', '광복절',       'PUBLIC'),
    ('2026-09-25', '추석',         'PUBLIC'),
    ('2026-09-26', '추석',         'PUBLIC'),
    ('2026-09-27', '추석',         'PUBLIC'),
    ('2026-10-03', '개천절',       'PUBLIC'),
    ('2026-10-09', '한글날',       'PUBLIC'),
    ('2026-12-25', '성탄절',       'PUBLIC')
ON CONFLICT (holiday_date) DO NOTHING;

-- ============================================================
-- 4. 공통 코드 — 결재 양식 (FORM_CODE) seed
-- ============================================================

-- cm_code 스키마가 V3 에서 정의되어 있다고 가정 (group_cd / code / code_name / sort_order / use_yn)
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn) VALUES
    ('FORM_CODE', 'LEAVE',    '휴가신청서',    1, 'Y'),
    ('FORM_CODE', 'EXPENSE',  '지출결의서',    2, 'Y'),
    ('FORM_CODE', 'PURCHASE', '구매요청서',    3, 'Y'),
    ('FORM_CODE', 'BIZTRIP',  '출장신청서',    4, 'Y'),
    ('FORM_CODE', 'CONTRACT', '계약검토서',    5, 'Y'),
    ('FORM_CODE', 'HR',       '인사품의서',    6, 'Y'),
    ('FORM_CODE', 'IT',       'IT자산신청',    7, 'Y')
ON CONFLICT DO NOTHING;

INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn) VALUES
    ('BOARD_TYPE', 'NOTICE',  '공지사항', 1, 'Y'),
    ('BOARD_TYPE', 'GENERAL', '일반',     2, 'Y'),
    ('BOARD_TYPE', 'FREE',    '자유',     3, 'Y'),
    ('BOARD_TYPE', 'DEPT',    '부서',     4, 'Y')
ON CONFLICT DO NOTHING;
