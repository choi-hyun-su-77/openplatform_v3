package com.platform.v3.core.calendar;

import com.platform.v3.core.calendar.mapper.CalendarMapper;
import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class CalendarService {

    private final CalendarMapper calendarMapper;

    public CalendarService(CalendarMapper calendarMapper) {
        this.calendarMapper = calendarMapper;
    }

    @DataSetServiceMapping("calendar/searchEvents")
    public Map<String, Object> searchEvents(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
        return Map.of("ds_events", DataSetSupport.rows(
                calendarMapper.selectEvents(
                        DataSetSupport.toLong(s.get("ownerId")),
                        DataSetSupport.toLong(s.get("deptId")),
                        DataSetSupport.toStr(s.get("startDt")),
                        DataSetSupport.toStr(s.get("endDt")),
                        DataSetSupport.toStr(s.get("eventType"))
                )));
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
}
