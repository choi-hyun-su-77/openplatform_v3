package com.platform.v3.core.leave;

import com.platform.v3.core.attendance.mapper.AttendanceMapper;
import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.leave.mapper.LeaveMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 휴가/연차 도메인.
 *
 * 5 services + 결재 연동 후크 2 (applyFromDoc, onDocApproved):
 *   leave/searchBalance        (year)
 *   leave/searchMyHistory      (year)
 *   leave/searchTeamCalendar   (from, to, deptId)
 *   leave/applyFromDoc         (결재 상신 직후 ApprovalService 가 호출 — at_leave_request INSERT)
 *   leave/onDocApproved        (Flowable listener 또는 ApprovalCompleteDelegate 가 호출 — used_days 차감 + status=APPROVED + at_attendance LEAVE 갱신)
 *
 * onDocApproved 멱등성: at_leave_request.status='APPROVED' 면 재호출 시 NO-OP.
 */
@Service
public class LeaveService {

    private static final Logger log = LoggerFactory.getLogger(LeaveService.class);
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ISO_LOCAL_DATE;

    private final LeaveMapper leaveMapper;
    private final AttendanceMapper attendanceMapper;

    public LeaveService(LeaveMapper leaveMapper, AttendanceMapper attendanceMapper) {
        this.leaveMapper = leaveMapper;
        this.attendanceMapper = attendanceMapper;
    }

    @DataSetServiceMapping("leave/searchBalance")
    public Map<String, Object> searchBalance(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Integer year = parseYear(search.get("year"));
        if (currentUser == null || currentUser.isBlank()) {
            return Map.of("ds_balance", DataSetSupport.rows(List.of()));
        }
        Map<String, Object> bal = leaveMapper.selectBalance(currentUser, year);
        if (bal == null) {
            // 없으면 0 부여 행을 임시 표시 (DB INSERT 는 안 함 — 관리자 운영 시드로 처리)
            Map<String, Object> empty = new HashMap<>();
            empty.put("employeeNo", currentUser);
            empty.put("year", year);
            empty.put("totalDays", 0.0);
            empty.put("usedDays", 0.0);
            empty.put("carryOver", 0.0);
            empty.put("remaining", 0.0);
            return Map.of("ds_balance", DataSetSupport.rows(List.of(empty)));
        }
        return Map.of("ds_balance", DataSetSupport.rows(List.of(bal)));
    }

    @DataSetServiceMapping("leave/searchMyHistory")
    public Map<String, Object> searchMyHistory(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Integer year = parseYear(search.get("year"));
        if (currentUser == null || currentUser.isBlank()) {
            return Map.of("ds_history", DataSetSupport.rows(List.of()));
        }
        List<Map<String, Object>> rows = leaveMapper.selectMyHistory(currentUser, year);
        return Map.of("ds_history", DataSetSupport.rows(rows));
    }

    @DataSetServiceMapping("leave/searchTeamCalendar")
    public Map<String, Object> searchTeamCalendar(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long deptId = DataSetSupport.toLong(search.get("deptId"));
        String from = DataSetSupport.toStr(search.get("from"));
        String to   = DataSetSupport.toStr(search.get("to"));
        if (deptId == null || from == null || to == null) {
            throw BusinessException.badRequest("deptId/from/to required", null);
        }
        List<Map<String, Object>> rows = leaveMapper.selectTeamCalendar(deptId, from, to);
        return Map.of("ds_calendar", DataSetSupport.rows(rows));
    }

    /**
     * 결재 상신(submitDocument) 직후 호출 — at_leave_request 한 건 INSERT.
     * ApprovalService.submitDocument 의 form_code='LEAVE' 분기에서 자동 트리거.
     *
     * @param docId       방금 생성된 ap_document.doc_id
     * @param employeeNo  기안자 사번 (= currentUser)
     * @param leaveType   ANNUAL|HALF_AM|HALF_PM|SICK|FAMILY|UNPAID
     * @param fromDate    'yyyy-MM-dd'
     * @param toDate      'yyyy-MM-dd'
     * @param daysOverride days 직접 지정 (null 이면 자동 계산)
     * @param reason      사유
     */
    @Transactional
    public Long applyFromDoc(Long docId, String employeeNo, String leaveType,
                             String fromDate, String toDate,
                             Double daysOverride, String reason) {
        if (docId == null || employeeNo == null || leaveType == null
                || fromDate == null || toDate == null) {
            throw BusinessException.badRequest(
                    "applyFromDoc: docId/employeeNo/leaveType/fromDate/toDate required", null);
        }
        double days = daysOverride != null
                ? daysOverride
                : calculateDays(leaveType, fromDate, toDate);
        Map<String, Object> row = new HashMap<>();
        row.put("docId", docId);
        row.put("employeeNo", employeeNo);
        row.put("leaveType", leaveType);
        row.put("fromDate", fromDate);
        row.put("toDate", toDate);
        row.put("days", days);
        row.put("reason", reason);
        row.put("status", "PENDING");
        leaveMapper.insertRequest(row);
        Long requestId = DataSetSupport.toLong(row.get("requestId"));
        log.info("휴가 신청 INSERT: requestId={}, docId={}, emp={}, type={}, days={}",
                requestId, docId, employeeNo, leaveType, days);
        return requestId;
    }

    /**
     * DataSet 형태의 applyFromDoc — 외부에서 단독 호출 가능 (테스트/관리자용).
     */
    @DataSetServiceMapping("leave/applyFromDoc")
    @Transactional
    public Map<String, Object> applyFromDocDs(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long docId = DataSetSupport.toLong(search.get("docId"));
        String leaveType = DataSetSupport.toStr(search.get("leaveType"));
        String fromDate = DataSetSupport.toStr(search.get("fromDate"));
        String toDate = DataSetSupport.toStr(search.get("toDate"));
        Double days = toDouble(search.get("days"));
        String reason = DataSetSupport.toStr(search.get("reason"));
        Long requestId = applyFromDoc(docId, currentUser, leaveType, fromDate, toDate, days, reason);
        return Map.of("success", true, "requestId", requestId);
    }

    /**
     * 결재 최종 승인 시 호출 — used_days 차감 + at_leave_request.status=APPROVED + at_attendance LEAVE 표시.
     * 이미 APPROVED 면 멱등 NO-OP.
     */
    @Transactional
    public Map<String, Object> onDocApproved(Long docId) {
        if (docId == null) {
            return Map.of("success", false, "message", "docId null");
        }
        Map<String, Object> req = leaveMapper.selectRequestByDoc(docId);
        if (req == null) {
            log.info("onDocApproved: at_leave_request 없음 (LEAVE 양식 아니거나 미INSERT) docId={}", docId);
            return Map.of("success", false, "message", "no leave request");
        }
        String status = String.valueOf(req.get("status"));
        if ("APPROVED".equals(status)) {
            log.info("onDocApproved: 이미 APPROVED — NO-OP docId={}", docId);
            return Map.of("success", true, "alreadyApproved", true);
        }
        Long requestId = DataSetSupport.toLong(
                req.getOrDefault("requestId", req.get("request_id"))
        );
        String employeeNo = String.valueOf(
                req.getOrDefault("employeeNo", req.get("employee_no"))
        );
        Object daysRaw = req.getOrDefault("days", req.get("days"));
        double days = toDouble(daysRaw) != null ? toDouble(daysRaw) : 0.0;
        Object fromObj = req.getOrDefault("fromDate", req.get("from_date"));
        Object toObj   = req.getOrDefault("toDate",   req.get("to_date"));
        String fromDate = toIsoDate(fromObj);
        String toDate   = toIsoDate(toObj);
        String leaveType = String.valueOf(
                req.getOrDefault("leaveType", req.get("leave_type"))
        );

        // 1) request status 변경
        leaveMapper.updateRequestStatus(requestId, "APPROVED");

        // 2) balance.used_days 차감 (UNPAID 는 미차감)
        if (!"UNPAID".equals(leaveType)) {
            int year = LocalDate.parse(fromDate, DATE_FMT).getYear();
            // balance row 가 없으면 0 부여로 INSERT 후 차감 (안전)
            Map<String, Object> bal = leaveMapper.selectBalance(employeeNo, year);
            if (bal == null) {
                Map<String, Object> insert = new HashMap<>();
                insert.put("employeeNo", employeeNo);
                insert.put("year", year);
                insert.put("totalDays", 0.0);
                leaveMapper.insertBalance(insert);
            }
            leaveMapper.addUsedDays(employeeNo, year, days);
        }

        // 3) at_attendance 의 from_date~to_date 영업일 status='LEAVE' 갱신
        markAttendanceLeave(employeeNo, fromDate, toDate, leaveType);

        log.info("onDocApproved 완료: docId={}, requestId={}, emp={}, days={}",
                docId, requestId, employeeNo, days);
        return Map.of("success", true, "days", days);
    }

    /**
     * Flowable / Test 가 직접 호출하는 DataSet 형태.
     */
    @DataSetServiceMapping("leave/onDocApproved")
    @Transactional
    public Map<String, Object> onDocApprovedDs(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long docId = DataSetSupport.toLong(search.get("docId"));
        return onDocApproved(docId);
    }

    // ============================================================
    // 영업일 계산 (cm_holiday + 주말 제외)
    // ============================================================
    public double calculateDays(String leaveType, String fromDate, String toDate) {
        if ("HALF_AM".equals(leaveType) || "HALF_PM".equals(leaveType)) {
            return 0.5;
        }
        LocalDate from = LocalDate.parse(fromDate, DATE_FMT);
        LocalDate to   = LocalDate.parse(toDate, DATE_FMT);
        if (to.isBefore(from)) {
            throw BusinessException.badRequest("toDate < fromDate", "toDate");
        }
        Set<String> holidays = new HashSet<>(
                leaveMapper.selectHolidaysBetween(fromDate, toDate)
        );
        int days = 0;
        LocalDate cur = from;
        while (!cur.isAfter(to)) {
            DayOfWeek dow = cur.getDayOfWeek();
            String key = cur.format(DATE_FMT);
            if (dow != DayOfWeek.SATURDAY && dow != DayOfWeek.SUNDAY && !holidays.contains(key)) {
                days++;
            }
            cur = cur.plusDays(1);
        }
        return (double) days;
    }

    /**
     * 기간 내 영업일 모두 at_attendance status='LEAVE' 로 갱신/INSERT.
     * (반차의 경우에도 해당일 단일 row 를 LEAVE 로 표시)
     */
    private void markAttendanceLeave(String employeeNo, String fromDate, String toDate, String leaveType) {
        LocalDate from = LocalDate.parse(fromDate, DATE_FMT);
        LocalDate to   = LocalDate.parse(toDate, DATE_FMT);
        Set<String> holidays = new HashSet<>(
                leaveMapper.selectHolidaysBetween(fromDate, toDate)
        );
        LocalDate cur = from;
        while (!cur.isAfter(to)) {
            DayOfWeek dow = cur.getDayOfWeek();
            String key = cur.format(DATE_FMT);
            if (dow != DayOfWeek.SATURDAY && dow != DayOfWeek.SUNDAY && !holidays.contains(key)) {
                attendanceMapper.upsertLeaveDay(employeeNo, key);
            }
            cur = cur.plusDays(1);
        }
    }

    // ============================================================
    // helpers
    // ============================================================
    private Integer parseYear(Object raw) {
        if (raw == null) return LocalDate.now().getYear();
        try {
            return Integer.parseInt(raw.toString());
        } catch (NumberFormatException e) {
            return LocalDate.now().getYear();
        }
    }

    private static Double toDouble(Object raw) {
        if (raw == null) return null;
        if (raw instanceof Number n) return n.doubleValue();
        try { return Double.parseDouble(raw.toString()); }
        catch (NumberFormatException e) { return null; }
    }

    private static String toIsoDate(Object raw) {
        if (raw == null) return null;
        if (raw instanceof java.sql.Date d) return d.toLocalDate().format(DATE_FMT);
        if (raw instanceof LocalDate ld) return ld.format(DATE_FMT);
        if (raw instanceof java.util.Date d) {
            return new java.sql.Date(d.getTime()).toLocalDate().format(DATE_FMT);
        }
        String s = raw.toString();
        // already 'yyyy-MM-dd' or 'yyyy-MM-dd...'
        return s.length() >= 10 ? s.substring(0, 10) : s;
    }
}
