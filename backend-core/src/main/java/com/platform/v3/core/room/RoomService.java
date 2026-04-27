package com.platform.v3.core.room;

import com.platform.v3.core.calendar.mapper.CalendarMapper;
import com.platform.v3.core.common.BffClient;
import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.notification.NotificationService;
import com.platform.v3.core.org.mapper.OrgMapper;
import com.platform.v3.core.room.mapper.RoomMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * 회의실 예약 (Room Booking) 도메인 서비스 — Phase 14 트랙 2.
 *
 * 7 개 DataSet 서비스:
 *   room/searchRooms      — 활성 회의실 목록
 *   room/searchAvailable  — from~to 기준 가용 회의실
 *   room/searchBookings   — 예약 목록 (회의실/기간)
 *   room/searchMyBookings — 본인 예약 (UPCOMING|PAST)
 *   room/reserve          — 예약 등록 (충돌 검증 + LiveKit + 알림 + 캘린더 등록)
 *   room/cancel           — 예약 취소 (본인 또는 관리자)
 *   room/checkConflict    — 충돌 여부 단건 체크
 *
 * 예약 시 핵심 트랜잭션 (RoomService.reserve):
 *   1. 충돌 검증 (countConflicts > 0 이면 BusinessException)
 *   2. rm_booking INSERT (livekit_room 은 has_video=TRUE 일 때 "rm-{bookingId}" 형태로 사후 갱신)
 *   3. has_video=TRUE 면 BFF /api/bff/video/room 호출 (LiveKitAdapter.createRoom — autoCreate)
 *   4. 참석자 each NotificationService.notifyByUserNo (employee_no 기반)
 *   5. 본인 cal_event 자동 INSERT (회의실 예약 = 본인 캘린더 일정)
 */
@Service
public class RoomService {

    private static final Logger log = LoggerFactory.getLogger(RoomService.class);

    private final RoomMapper roomMapper;
    private final NotificationService notificationService;
    private final OrgMapper orgMapper;
    private final CalendarMapper calendarMapper;
    private final BffClient bffClient;

    public RoomService(RoomMapper roomMapper,
                       NotificationService notificationService,
                       OrgMapper orgMapper,
                       CalendarMapper calendarMapper,
                       BffClient bffClient) {
        this.roomMapper = roomMapper;
        this.notificationService = notificationService;
        this.orgMapper = orgMapper;
        this.calendarMapper = calendarMapper;
        this.bffClient = bffClient;
    }

    // ==========================================================
    // 조회 계열
    // ==========================================================

    @DataSetServiceMapping("room/searchRooms")
    public Map<String, Object> searchRooms(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
        String keyword = DataSetSupport.toStr(s.get("keyword"));
        Integer minCapacity = s.get("minCapacity") == null ? null
                : ((Number) s.get("minCapacity")).intValue();
        Boolean hasVideo = s.get("hasVideo") == null ? null
                : Boolean.TRUE.equals(s.get("hasVideo"));
        return Map.of("ds_rooms", DataSetSupport.rows(
                roomMapper.selectRooms(keyword, minCapacity, hasVideo)));
    }

    @DataSetServiceMapping("room/searchAvailable")
    public Map<String, Object> searchAvailable(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
        String from = DataSetSupport.toStr(s.get("from"));
        String to   = DataSetSupport.toStr(s.get("to"));
        if (from == null || to == null) {
            throw BusinessException.badRequest("from/to required", "from");
        }
        Integer minCapacity = s.get("minCapacity") == null ? null
                : ((Number) s.get("minCapacity")).intValue();
        Boolean hasVideo = s.get("hasVideo") == null ? null
                : Boolean.TRUE.equals(s.get("hasVideo"));
        return Map.of("ds_rooms", DataSetSupport.rows(
                roomMapper.selectAvailableRooms(from, to, minCapacity, hasVideo)));
    }

    @DataSetServiceMapping("room/searchBookings")
    public Map<String, Object> searchBookings(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
        Long roomId = DataSetSupport.toLong(s.get("roomId"));
        String from = DataSetSupport.toStr(s.get("from"));
        String to   = DataSetSupport.toStr(s.get("to"));
        return Map.of("ds_bookings", DataSetSupport.rows(
                roomMapper.selectBookings(roomId, from, to)));
    }

    @DataSetServiceMapping("room/searchMyBookings")
    public Map<String, Object> searchMyBookings(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
        String scope = DataSetSupport.toStr(s.getOrDefault("scope", "UPCOMING"));
        return Map.of("ds_bookings", DataSetSupport.rows(
                roomMapper.selectMyBookings(currentUser, scope)));
    }

    @DataSetServiceMapping("room/checkConflict")
    public Map<String, Object> checkConflict(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
        Long roomId = DataSetSupport.toLong(s.get("roomId"));
        String from = DataSetSupport.toStr(s.get("from"));
        String to   = DataSetSupport.toStr(s.get("to"));
        Long excludeBookingId = DataSetSupport.toLong(s.get("excludeBookingId"));
        if (roomId == null || from == null || to == null) {
            throw BusinessException.badRequest("roomId/from/to required", null);
        }
        int conflicts = roomMapper.countConflicts(roomId, from, to, excludeBookingId);
        return Map.of("conflict", conflicts > 0, "count", conflicts);
    }

    // ==========================================================
    // 변경 계열
    // ==========================================================

    /**
     * 예약 등록.
     *
     * 입력 (datasets.ds_search):
     *   roomId, title, startAt(ISO), endAt(ISO),
     *   attendees (CSV employee_no),
     *   hasVideo (boolean — UI 가 회의실 정보 기반으로 전달하지만 DB 의 rm_room.has_video 가 권위)
     */
    @DataSetServiceMapping("room/reserve")
    @Transactional
    public Map<String, Object> reserve(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
        Long roomId = DataSetSupport.toLong(s.get("roomId"));
        String title = DataSetSupport.toStr(s.get("title"));
        String startAt = DataSetSupport.toStr(s.get("startAt"));
        String endAt = DataSetSupport.toStr(s.get("endAt"));
        String attendees = DataSetSupport.toStr(s.get("attendees"));

        if (roomId == null) throw BusinessException.badRequest("roomId required", "roomId");
        if (title == null || title.isBlank()) throw BusinessException.badRequest("title required", "title");
        if (startAt == null || endAt == null) {
            throw BusinessException.badRequest("startAt/endAt required", "startAt");
        }

        Map<String, Object> room = roomMapper.selectRoomById(roomId);
        if (room == null) throw BusinessException.notFound("회의실을 찾을 수 없습니다: " + roomId);
        boolean hasVideo = Boolean.TRUE.equals(room.get("has_video"));

        // 1. 충돌 검증
        int conflicts = roomMapper.countConflicts(roomId, startAt, endAt, null);
        if (conflicts > 0) {
            throw BusinessException.badRequest(
                    "선택한 시간에 이미 예약이 있습니다. 다른 시간을 선택하세요.", "startAt");
        }

        // 2. rm_booking INSERT
        Map<String, Object> row = new HashMap<>();
        row.put("roomId", roomId);
        row.put("bookerNo", currentUser);
        row.put("title", title);
        row.put("startAt", startAt);
        row.put("endAt", endAt);
        row.put("attendees", attendees);
        row.put("status", "BOOKED");
        // livekit_room 은 booking_id 가 발급된 후 결정 → 우선 null 로 INSERT
        row.put("livekitRoom", null);
        roomMapper.insertBooking(row);
        Long bookingId = DataSetSupport.toLong(row.get("bookingId"));

        // 3. has_video=true 면 BFF LiveKitAdapter.createRoom 호출 + livekit_room 컬럼 갱신
        String livekitRoomName = null;
        if (hasVideo) {
            livekitRoomName = "rm-" + bookingId;
            Map<String, Object> bffResp = bffClient.createVideoRoom(livekitRoomName, currentUser);
            if (bffResp == null) {
                // BFF 호출 실패 — LiveKit 룸은 첫 접속 시 자동 생성되므로 폴백 가능 (warn)
                log.warn("BFF createVideoRoom 실패 — 자동 생성 폴백: bookingId={} room={}",
                        bookingId, livekitRoomName);
            }
            roomMapper.updateLivekitRoom(bookingId, livekitRoomName);
        }

        // 4. 참석자 each notifyByUserNo
        if (attendees != null && !attendees.isBlank()) {
            String[] empNos = attendees.split(",");
            for (String empNo : empNos) {
                String trimmed = empNo.trim();
                if (trimmed.isBlank() || trimmed.equals(currentUser)) continue;
                notificationService.notifyByUserNo(
                        trimmed, bookingId, "ROOM_BOOKING", "WEB",
                        "회의 초대: " + title,
                        room.get("room_name") + " " + formatTime(startAt) + " ~ " + formatTime(endAt)
                );
            }
        }

        // 5. 본인 cal_event INSERT (PERSONAL 일정)
        Map<String, Object> me = orgMapper.findEmployeeByNo(currentUser);
        Long ownerId = me == null ? null : DataSetSupport.toLong(me.get("employee_id"));
        Long deptId  = me == null ? null : DataSetSupport.toLong(me.get("dept_id"));
        Map<String, Object> calRow = new HashMap<>();
        calRow.put("title", "[회의실] " + title + " (" + room.get("room_name") + ")");
        calRow.put("description", "회의실 예약 자동 등록 — bookingId=" + bookingId);
        calRow.put("eventType", "PERSONAL");
        calRow.put("ownerId", ownerId);
        calRow.put("deptId", deptId);
        calRow.put("startDt", startAt);
        calRow.put("endDt", endAt);
        calRow.put("allDay", false);
        calRow.put("color", "#06b6d4");
        calRow.put("location", room.get("room_name"));
        calRow.put("createdBy", currentUser);
        try {
            calendarMapper.insertEvent(calRow);
        } catch (Exception e) {
            log.warn("회의실 예약의 캘린더 자동 등록 실패 (booking 은 성공): {}", e.getMessage());
        }

        log.info("회의실 예약 완료: bookingId={} room={} booker={} hasVideo={}",
                bookingId, room.get("room_name"), currentUser, hasVideo);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("bookingId", bookingId);
        result.put("livekitRoom", livekitRoomName);
        result.put("hasVideo", hasVideo);
        return result;
    }

    @DataSetServiceMapping("room/cancel")
    @Transactional
    public Map<String, Object> cancel(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
        Long bookingId = DataSetSupport.toLong(s.get("bookingId"));
        if (bookingId == null) throw BusinessException.badRequest("bookingId required", "bookingId");

        Map<String, Object> booking = roomMapper.selectBookingById(bookingId);
        if (booking == null) throw BusinessException.notFound("예약을 찾을 수 없습니다: " + bookingId);

        String bookerNo = DataSetSupport.toStr(booking.get("booker_no"));
        boolean isAdmin = isAdminUser(currentUser);
        if (!isAdmin && (bookerNo == null || !bookerNo.equals(currentUser))) {
            throw BusinessException.forbidden("본인 예약만 취소할 수 있습니다.");
        }

        roomMapper.updateBookingStatus(bookingId, "CANCELLED");
        log.info("회의실 예약 취소: bookingId={} by {}", bookingId, currentUser);

        return Map.of("success", true, "bookingId", bookingId);
    }

    // ==========================================================
    // 헬퍼
    // ==========================================================

    /**
     * Keycloak 역할 기반 admin 판정. currentUser 는 employee_no 이므로 OrgMapper 로 조회.
     * 단순히 "E0001"(admin 시드) 또는 position_level 등으로 판정. 정밀 권한 검증은
     * 향후 SecurityContext 또는 RoleResolver 도입 시 강화.
     */
    private boolean isAdminUser(String employeeNo) {
        if (employeeNo == null) return false;
        // 시드 admin 사용자
        if (Arrays.asList("E0001", "admin").contains(employeeNo)) return true;
        Map<String, Object> emp = orgMapper.findEmployeeByNo(employeeNo);
        if (emp == null) return false;
        Object level = emp.get("position_level");
        if (level instanceof Number n && n.intValue() >= 90) return true;
        Object posName = emp.get("position_name");
        return posName != null && posName.toString().contains("관리자");
    }

    private String formatTime(String iso) {
        if (iso == null) return "";
        try {
            OffsetDateTime t = OffsetDateTime.parse(iso);
            return String.format("%02d/%02d %02d:%02d",
                    t.getMonthValue(), t.getDayOfMonth(),
                    t.getHour(), t.getMinute());
        } catch (Exception e) {
            return iso;
        }
    }
}
