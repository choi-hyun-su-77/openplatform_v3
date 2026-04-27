package com.platform.v3.core.room.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 회의실 예약 (Room Booking) MyBatis 매퍼.
 *
 * 테이블 prefix: rm_*
 *  - rm_room    : 회의실 마스터
 *  - rm_booking : 예약
 */
@Mapper
public interface RoomMapper {

    // ── 회의실 마스터 ──

    List<Map<String, Object>> selectRooms(@Param("keyword") String keyword,
                                          @Param("minCapacity") Integer minCapacity,
                                          @Param("hasVideo") Boolean hasVideo);

    Map<String, Object> selectRoomById(@Param("roomId") Long roomId);

    /**
     * from~to 사이에 예약이 없는(또는 일부만 있는) 활성 회의실 목록.
     * 충돌이 없는 회의실만 (LEFT JOIN ... WHERE booking_id IS NULL).
     */
    List<Map<String, Object>> selectAvailableRooms(@Param("from") String from,
                                                   @Param("to") String to,
                                                   @Param("minCapacity") Integer minCapacity,
                                                   @Param("hasVideo") Boolean hasVideo);

    // ── 예약 ──

    List<Map<String, Object>> selectBookings(@Param("roomId") Long roomId,
                                             @Param("from") String from,
                                             @Param("to") String to);

    /**
     * 본인 예약 목록.
     * scope = "UPCOMING" 이면 end_at >= NOW(), "PAST" 면 end_at < NOW().
     */
    List<Map<String, Object>> selectMyBookings(@Param("bookerNo") String bookerNo,
                                               @Param("scope") String scope);

    Map<String, Object> selectBookingById(@Param("bookingId") Long bookingId);

    /**
     * 시간 충돌 체크. 같은 room_id 에서 [start_at, end_at) 가 [from, to) 와 겹치는
     * BOOKED 상태 예약 개수.
     * excludeBookingId != null 이면 해당 예약은 제외 (수정 시 자기 자신 제외).
     */
    int countConflicts(@Param("roomId") Long roomId,
                       @Param("from") String from,
                       @Param("to") String to,
                       @Param("excludeBookingId") Long excludeBookingId);

    void insertBooking(Map<String, Object> row);

    void updateBookingStatus(@Param("bookingId") Long bookingId,
                             @Param("status") String status);

    /**
     * livekit_room 컬럼 갱신. has_video=TRUE 인 회의실의 예약은 booking_id 가
     * 발급된 후 룸 이름("rm-{bookingId}")을 사후 기록한다.
     */
    void updateLivekitRoom(@Param("bookingId") Long bookingId,
                           @Param("livekitRoom") String livekitRoom);
}
