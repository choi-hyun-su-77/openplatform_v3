package com.platform.v3.core.calendar.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface CalendarMapper {
    List<Map<String, Object>> selectEvents(@Param("ownerId") Long ownerId,
                                           @Param("deptId") Long deptId,
                                           @Param("startDt") String startDt,
                                           @Param("endDt") String endDt,
                                           @Param("eventType") String eventType);

    List<Map<String, Object>> selectTodayEvents(@Param("ownerId") Long ownerId,
                                                @Param("deptId") Long deptId);

    void insertEvent(Map<String, Object> row);
    void updateEvent(Map<String, Object> row);
    void deleteEvent(@Param("eventId") Long eventId, @Param("deletedBy") String deletedBy);

    // Phase C
    List<Map<String, Object>> selectHolidays(@Param("year") int year);
}
