package com.platform.v3.core.attendance;

import com.platform.v3.core.attendance.mapper.AttendanceMapper;
import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 근태 도메인 — at_attendance UNIQUE(employee_no, work_date) 기반.
 *
 * 5 services:
 *   attendance/checkIn          (오늘 INSERT 또는 check_in_at UPDATE)
 *   attendance/checkOut         (work_minutes 자동 계산)
 *   attendance/searchToday      (오늘 row 또는 null)
 *   attendance/searchMyMonth    (yearMonth='2026-04')
 *   attendance/searchTeamDaily  (deptId, workDate — 부서장)
 */
@Service
public class AttendanceService {

    private static final Logger log = LoggerFactory.getLogger(AttendanceService.class);
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ISO_LOCAL_DATE;

    private final AttendanceMapper attendanceMapper;

    public AttendanceService(AttendanceMapper attendanceMapper) {
        this.attendanceMapper = attendanceMapper;
    }

    @DataSetServiceMapping("attendance/checkIn")
    @Transactional
    public Map<String, Object> checkIn(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank()) {
            throw BusinessException.forbidden("로그인이 필요합니다");
        }
        String today = LocalDate.now().format(DATE_FMT);
        Map<String, Object> existing = attendanceMapper.selectToday(currentUser, today);
        if (existing == null) {
            Map<String, Object> row = new HashMap<>();
            row.put("employeeNo", currentUser);
            row.put("workDate", today);
            row.put("status", "NORMAL");
            attendanceMapper.insertCheckIn(row);
            log.info("출근(insert): emp={}, date={}", currentUser, today);
            return Map.of("success", true, "checkInAt", OffsetDateTime.now().toString());
        }
        // 이미 row 가 있는 경우: check_in_at 이 비어있으면 UPDATE, 아니면 NO-OP
        if (existing.get("checkInAt") == null && existing.get("check_in_at") == null) {
            Long attId = DataSetSupport.toLong(
                    existing.getOrDefault("attendanceId", existing.get("attendance_id"))
            );
            attendanceMapper.updateCheckIn(attId);
            log.info("출근(update): emp={}, date={}, attId={}", currentUser, today, attId);
            return Map.of("success", true, "checkInAt", OffsetDateTime.now().toString());
        }
        log.info("출근 중복 무시: emp={}, date={}", currentUser, today);
        return Map.of("success", false, "message", "이미 출근 처리되었습니다");
    }

    @DataSetServiceMapping("attendance/checkOut")
    @Transactional
    public Map<String, Object> checkOut(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank()) {
            throw BusinessException.forbidden("로그인이 필요합니다");
        }
        String today = LocalDate.now().format(DATE_FMT);
        Map<String, Object> row = attendanceMapper.selectToday(currentUser, today);
        if (row == null) {
            throw BusinessException.badRequest("출근 기록이 없습니다", null);
        }
        Object inAtRaw = row.getOrDefault("checkInAt", row.get("check_in_at"));
        if (inAtRaw == null) {
            throw BusinessException.badRequest("출근하지 않았습니다", null);
        }
        Long attId = DataSetSupport.toLong(
                row.getOrDefault("attendanceId", row.get("attendance_id"))
        );
        OffsetDateTime checkInAt = parseOffsetDt(inAtRaw);
        OffsetDateTime now = OffsetDateTime.now();
        int workMinutes = (int) Duration.between(checkInAt, now).toMinutes();
        if (workMinutes < 0) workMinutes = 0;
        attendanceMapper.updateCheckOut(attId, workMinutes);
        log.info("퇴근: emp={}, date={}, minutes={}", currentUser, today, workMinutes);
        return Map.of("success", true, "checkOutAt", now.toString(), "workMinutes", workMinutes);
    }

    @DataSetServiceMapping("attendance/searchToday")
    public Map<String, Object> searchToday(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank()) {
            return Map.of("ds_today", DataSetSupport.rows(List.of()));
        }
        String today = LocalDate.now().format(DATE_FMT);
        Map<String, Object> row = attendanceMapper.selectToday(currentUser, today);
        if (row == null) {
            return Map.of("ds_today", DataSetSupport.rows(List.of()));
        }
        return Map.of("ds_today", DataSetSupport.rows(List.of(row)));
    }

    @DataSetServiceMapping("attendance/searchMyMonth")
    public Map<String, Object> searchMyMonth(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String yearMonth = DataSetSupport.toStr(search.get("yearMonth"));
        if (yearMonth == null || yearMonth.isBlank()) {
            yearMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        }
        if (currentUser == null || currentUser.isBlank()) {
            return Map.of("ds_month", DataSetSupport.rows(List.of()));
        }
        List<Map<String, Object>> rows = attendanceMapper.selectMyMonth(currentUser, yearMonth);
        return Map.of("ds_month", DataSetSupport.rows(rows));
    }

    @DataSetServiceMapping("attendance/searchTeamDaily")
    public Map<String, Object> searchTeamDaily(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long deptId = DataSetSupport.toLong(search.get("deptId"));
        String workDate = DataSetSupport.toStr(search.get("workDate"));
        if (deptId == null) throw BusinessException.badRequest("deptId required", "deptId");
        if (workDate == null || workDate.isBlank()) {
            workDate = LocalDate.now().format(DATE_FMT);
        }
        List<Map<String, Object>> rows = attendanceMapper.selectTeamDaily(deptId, workDate);
        return Map.of("ds_team", DataSetSupport.rows(rows));
    }

    // ============================================================
    // helper
    // ============================================================
    private OffsetDateTime parseOffsetDt(Object raw) {
        if (raw == null) return null;
        if (raw instanceof OffsetDateTime odt) return odt;
        if (raw instanceof java.sql.Timestamp ts) {
            return ts.toInstant().atOffset(OffsetDateTime.now().getOffset());
        }
        if (raw instanceof java.util.Date d) {
            return d.toInstant().atOffset(OffsetDateTime.now().getOffset());
        }
        if (raw instanceof java.time.Instant i) {
            return i.atOffset(OffsetDateTime.now().getOffset());
        }
        try {
            return OffsetDateTime.parse(raw.toString());
        } catch (Exception e) {
            log.warn("parseOffsetDt 실패: {}", raw);
            return OffsetDateTime.now();
        }
    }
}
