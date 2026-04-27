-- V11: 회의실 예약 (Room Booking) — Phase 14 트랙 2
--
-- rm_room   : 회의실 마스터 (시드 5개)
-- rm_booking: 예약 (시간 충돌 검증은 애플리케이션 레벨에서 수행)
--
-- has_video=TRUE 인 회의실에서 예약 시 backend-core → BFF /api/bff/video/room
-- 호출로 LiveKit 룸 메타가 발급된다.

CREATE TABLE IF NOT EXISTS platform_v3.rm_room (
    room_id      BIGSERIAL PRIMARY KEY,
    room_name    VARCHAR(64) NOT NULL UNIQUE,
    capacity     INT NOT NULL,
    location     VARCHAR(128),
    has_video    BOOLEAN NOT NULL DEFAULT FALSE,
    has_phone    BOOLEAN NOT NULL DEFAULT FALSE,
    amenities    TEXT,
    active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS platform_v3.rm_booking (
    booking_id    BIGSERIAL PRIMARY KEY,
    room_id       BIGINT NOT NULL REFERENCES platform_v3.rm_room(room_id),
    booker_no     VARCHAR(32) NOT NULL,
    title         VARCHAR(128) NOT NULL,
    start_at      TIMESTAMPTZ NOT NULL,
    end_at        TIMESTAMPTZ NOT NULL,
    attendees     TEXT,
    livekit_room  VARCHAR(64),
    status        VARCHAR(16) NOT NULL DEFAULT 'BOOKED',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (end_at > start_at)
);
CREATE INDEX IF NOT EXISTS idx_rm_booking_room_time
    ON platform_v3.rm_booking(room_id, start_at, end_at);
CREATE INDEX IF NOT EXISTS idx_rm_booking_booker
    ON platform_v3.rm_booking(booker_no);

-- 시드 5개
INSERT INTO platform_v3.rm_room (room_name, capacity, has_video, amenities) VALUES
    ('대회의실',     20, TRUE,  '프로젝터,화이트보드,스피커폰'),
    ('소회의실A',    8,  FALSE, '화이트보드'),
    ('소회의실B',    8,  TRUE,  'TV'),
    ('임원회의실',   12, TRUE,  '프로젝터,화이트보드,스피커폰'),
    ('화상회의실A',  6,  TRUE,  '카메라,스피커')
ON CONFLICT (room_name) DO NOTHING;
