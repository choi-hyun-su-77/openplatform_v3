package com.platform.v3.core.calendar;

import com.platform.v3.core.calendar.mapper.CalendarMapper;
import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.leave.mapper.LeaveMapper;
import com.platform.v3.core.room.mapper.RoomMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Year;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CalendarService {

    private final CalendarMapper calendarMapper;

    // Phase 14 트랙 8: leave + room booking 캘린더 UNION (옵셔널 — 트랙 1/2 미배포 환경 호환)
    private LeaveMapper leaveMapper;
    private RoomMapper roomMapper;

    public CalendarService(CalendarMapper calendarMapper) {
        this.calendarMapper = calendarMapper;
    }

    @Autowired(required = false)
    public void setLeaveMapper(LeaveMapper leaveMapper) { this.leaveMapper = leaveMapper; }

    @Autowired(required = false)
    public void setRoomMapper(RoomMapper roomMapper) { this.roomMapper = roomMapper; }

    @DataSetServiceMapping("calendar/searchEvents")
    public Map<String, Object> searchEvents(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
        Long deptId = DataSetSupport.toLong(s.get("deptId"));
        String startDt = DataSetSupport.toStr(s.get("startDt"));
        String endDt = DataSetSupport.toStr(s.get("endDt"));

        List<Map<String, Object>> events = new ArrayList<>(calendarMapper.selectEvents(
                DataSetSupport.toLong(s.get("ownerId")),
                deptId,
                startDt,
                endDt,
                DataSetSupport.toStr(s.get("eventType"))
        ));

        // 휴가 (APPROVED) — 부서/기간 매칭
        if (leaveMapper != null && deptId != null && startDt != null && endDt != null) {
            try {
                for (Map<String, Object> r : leaveMapper.selectTeamCalendar(deptId, startDt, endDt)) {
                    Map<String, Object> ev = new HashMap<>();
                    ev.put("eventId", "L-" + r.get("requestId"));
                    ev.put("title", "[휴가] " + r.get("employeeName") + " (" + r.get("leaveType") + ")");
                    ev.put("startDt", r.get("fromDate"));
                    ev.put("endDt", r.get("toDate"));
                    ev.put("scope", "LEAVE");
                    ev.put("color", "#10b981");
                    ev.put("sourceType", "LEAVE");
                    ev.put("readonly", true);
                    events.add(ev);
                }
            } catch (Exception ignored) { /* 트랙 1 미배포 시 무시 */ }
        }

        // 회의실 예약 — 본인 + 본 부서 (currentUser 의 booking 만 단순 노출)
        if (roomMapper != null && currentUser != null) {
            try {
                for (Map<String, Object> r : roomMapper.selectMyBookings(currentUser, "ALL")) {
                    Map<String, Object> ev = new HashMap<>();
                    ev.put("eventId", "R-" + r.get("bookingId"));
                    ev.put("title", "[회의] " + r.get("title") + " @ " + r.get("roomName"));
                    ev.put("startDt", r.get("startAt"));
                    ev.put("endDt", r.get("endAt"));
                    ev.put("scope", "ROOM");
                    ev.put("color", "#f97316");
                    ev.put("sourceType", "ROOM");
                    ev.put("readonly", true);
                    events.add(ev);
                }
            } catch (Exception ignored) { /* 트랙 2 미배포 시 무시 */ }
        }

        return Map.of("ds_events", DataSetSupport.rows(events));
    }

    @DataSetServiceMapping("calendar/searchToday")
    public Map<String, Object> searchToday(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
        return Map.of("ds_todayEvents", DataSetSupport.rows(
                calendarMapper.selectTodayEvents(
                        DataSetSupport.toLong(s.get("ownerId")),
                        DataSetSupport.toLong(s.get("deptId"))
                )));
    }

    @DataSetServiceMapping("calendar/saveEvents")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> saveEvents(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_events");
        if (ds == null) throw BusinessException.badRequest("ds_events가 필요합니다.", "ds_events");
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
        for (Map<String, Object> row : rows) {
            String rowType = DataSetSupport.toStr(row.get("_rowType"));
            switch (rowType == null ? "" : rowType) {
                case "C" -> { row.put("createdBy", currentUser); calendarMapper.insertEvent(row); }
                case "U" -> { row.put("updatedBy", currentUser); calendarMapper.updateEvent(row); }
                case "D" -> calendarMapper.deleteEvent(DataSetSupport.toLong(row.get("eventId")), currentUser);
                default -> {}
            }
        }
        return Map.of("success", true);
    }

    @DataSetServiceMapping("calendar/deleteEvent")
    @Transactional
    public Map<String, Object> deleteEvent(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long eventId = DataSetSupport.toLong(search.get("eventId"));
        if (eventId == null) throw BusinessException.badRequest("eventId required", "eventId");
        calendarMapper.deleteEvent(eventId, currentUser);
        return Map.of("success", true);
    }

    @DataSetServiceMapping("calendar/searchHolidays")
    public Map<String, Object> searchHolidays(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Integer year = search.get("year") != null ? ((Number) search.get("year")).intValue() : Year.now().getValue();
        return Map.of("ds_holidays", DataSetSupport.rows(calendarMapper.selectHolidays(year)));
    }
}
