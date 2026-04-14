-- 공통코드, 다국어, 알림 스키마

CREATE TABLE IF NOT EXISTS platform_v3.cm_code (
    group_cd    VARCHAR(32) NOT NULL,
    code        VARCHAR(32) NOT NULL,
    code_name   VARCHAR(128) NOT NULL,
    sort_order  INT NOT NULL DEFAULT 0,
    use_yn      CHAR(1) NOT NULL DEFAULT 'Y',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (group_cd, code)
);

CREATE TABLE IF NOT EXISTS platform_v3.cm_i18n_message (
    msg_key    VARCHAR(128) NOT NULL,
    locale     VARCHAR(16) NOT NULL,
    msg_type   VARCHAR(32) NOT NULL,
    message    TEXT NOT NULL,
    PRIMARY KEY (msg_key, locale)
);

CREATE INDEX IF NOT EXISTS idx_i18n_type ON platform_v3.cm_i18n_message(locale, msg_type);

CREATE TABLE IF NOT EXISTS platform_v3.cm_notification (
    notification_id   BIGSERIAL PRIMARY KEY,
    recipient_id      BIGINT NOT NULL,
    doc_id            BIGINT,
    notification_type VARCHAR(32) NOT NULL,
    channel           VARCHAR(32),
    title             VARCHAR(256),
    content           TEXT,
    is_read           CHAR(1) NOT NULL DEFAULT 'N',
    read_at           TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notif_recipient ON platform_v3.cm_notification(recipient_id, is_read, created_at DESC);

-- 시드 i18n
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
    ('menu.dashboard', 'ko', 'MENU', '대시보드'),
    ('menu.approval',  'ko', 'MENU', '전자결재'),
    ('menu.board',     'ko', 'MENU', '게시판'),
    ('menu.calendar',  'ko', 'MENU', '캘린더'),
    ('menu.org',       'ko', 'MENU', '조직도'),
    ('menu.messenger', 'ko', 'MENU', '메신저'),
    ('menu.mail',      'ko', 'MENU', '메일'),
    ('menu.wiki',      'ko', 'MENU', '위키'),
    ('menu.video',     'ko', 'MENU', '화상회의'),
    ('menu.dashboard', 'en', 'MENU', 'Dashboard'),
    ('menu.approval',  'en', 'MENU', 'Approval'),
    ('menu.board',     'en', 'MENU', 'Board'),
    ('menu.calendar',  'en', 'MENU', 'Calendar'),
    ('menu.org',       'en', 'MENU', 'Organization'),
    ('menu.messenger', 'en', 'MENU', 'Messenger'),
    ('menu.mail',      'en', 'MENU', 'Mail'),
    ('menu.wiki',      'en', 'MENU', 'Wiki'),
    ('menu.video',     'en', 'MENU', 'Video')
ON CONFLICT (msg_key, locale) DO NOTHING;
