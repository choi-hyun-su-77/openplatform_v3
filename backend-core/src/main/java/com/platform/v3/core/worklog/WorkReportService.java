package com.platform.v3.core.worklog;

import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.org.mapper.OrgMapper;
import com.platform.v3.core.worklog.mapper.WorkReportMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 업무일지 (Work Report) DataSet 서비스 — Phase 14 트랙 4 (§6).
 *
 * 5 services:
 *   worklog/saveDaily         (UNIQUE 제약 활용 upsert — 같은 날짜 재저장 시 update)
 *   worklog/searchMyWeek      (입력 weekStart 가 월요일이 아니면 자동 보정)
 *   worklog/searchTeamDaily   (부서장/ADMIN 전용)
 *   worklog/searchTeamWeekly  (부서장/ADMIN 전용)
 *   worklog/searchMonth       (본인 월별)
 *
 * 부서장 판정 (selectTeamDaily/selectTeamWeekly 진입 가드):
 *   1) ROLE_ADMIN 또는 ROLE_MGR 보유 → 통과
 *   2) currentUser 가 deptId 의 selectDeptHead 결과(position_level 최저)와 동일 → 통과
 *   3) currentUser 의 position_level 이 부서장 임계치(80) 이상 (1=CEO 가장 높음, 9=사원)
 *      — 한국 직급 체계 기본 매핑: 임원=10/10대 / 부장=20 / 차장=30 / 과장=40 / 대리=50
 *      현 시드(team head 가 부장-차장-과장 단위) 기준 position_level 이 작을수록(낮은 숫자)
 *      높은 직급. 따라서 *팀원 조회는 50 이하* 통과 — 너무 헐겁지 않게 본인 부서 한정 조합.
 *      *주의*: 합리적 기본값. 실제 인사 정책에 맞는 정확한 임계치는 트랙 5 PageDepts 의
 *      dept_manager_no 도입 시 그쪽으로 이관. 그 전까지는 (1)+(2) 가 1차 가드, (3) 은 fallback.
 */
@Service
public class WorkReportService {

    private static final Logger log = LoggerFactory.getLogger(WorkReportService.class);
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ISO_LOCAL_DATE;

    /**
     * 직급 레벨 임계치 — position_level 이 이 값 이하이면 "부서장 권한" 으로 간주.
     * org_position 시드 기준: CEO=1, 임원=2~9, 부장=10~19, 차장=20~29, 과장=30~39, 대리=40~49, 사원=50+.
     * 합리적 기본값: 30 (과장) 이하 → 자기 부서 팀 뷰 가능.
     */
    private static final int DEPT_HEAD_LEVEL_THRESHOLD = 30;

    private final WorkReportMapper mapper;
    private final OrgMapper orgMapper;

    public WorkReportService(WorkReportMapper mapper, OrgMapper orgMapper) {
        this.mapper = mapper;
        this.orgMapper = orgMapper;
    }

    // ============================================================
    // saveDaily — upsert
    // ============================================================
    @DataSetServiceMapping("worklog/saveDaily")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> saveDaily(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank() || "anonymous".equals(currentUser)) {
            throw BusinessException.forbidden("로그인이 필요합니다");
        }

        // ds_search 또는 ds_daily.rows[0] 둘 다 허용 — UI 호환성을 높임
        Map<String, Object> input = DataSetSupport.getSearchParams(datasets);
        if (input == null || input.isEmpty()) {
            Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_daily");
            if (ds != null) {
                List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
                if (!rows.isEmpty()) input = rows.get(0);
            }
        }
        if (input == null || input.isEmpty()) {
            throw BusinessException.badRequest("ds_search 또는 ds_daily 가 필요합니다", null);
        }

        String reportDate = DataSetSupport.toStr(input.get("reportDate"));
        if (reportDate == null || reportDate.isBlank()) {
            reportDate = LocalDate.now().format(DATE_FMT);
        } else {
            // 'YYYY-MM-DD' 또는 ISO 시각 — 앞 10자만 사용
            reportDate = normalizeDate(reportDate);
        }

        Map<String, Object> row = new HashMap<>();
        row.put("employeeNo", currentUser);
        row.put("reportDate", reportDate);
        row.put("doneToday", DataSetSupport.toStr(input.get("doneToday")));
        row.put("planTomorrow", DataSetSupport.toStr(input.get("planTomorrow")));
        row.put("issue", DataSetSupport.toStr(input.get("issue")));
        String mood = DataSetSupport.toStr(input.get("mood"));
        if (mood != null && !mood.isBlank()
                && !"GOOD".equals(mood) && !"NORMAL".equals(mood) && !"BAD".equals(mood)) {
            mood = null;
        }
        row.put("mood", mood);
        row.put("hoursWorked", parseHours(input.get("hoursWorked")));

        mapper.upsertDaily(row);
        log.info("worklog/saveDaily upsert: emp={}, date={}, reportId={}",
                currentUser, reportDate, row.get("reportId"));
        return Map.of(
                "success", true,
                "reportId", row.get("reportId"),
                "reportDate", reportDate
        );
    }

    // ============================================================
    // searchMyWeek — 본인 주간
    // ============================================================
    @DataSetServiceMapping("worklog/searchMyWeek")
    public Map<String, Object> searchMyWeek(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank() || "anonymous".equals(currentUser)) {
            return Map.of(
                    "ds_week", DataSetSupport.rows(List.of()),
                    "ds_dates", DataSetSupport.rows(List.of())
            );
        }
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String weekStartRaw = DataSetSupport.toStr(search.get("weekStart"));
        LocalDate weekStart = normalizeWeekStart(weekStartRaw);
        String weekStartStr = weekStart.format(DATE_FMT);

        List<Map<String, Object>> rows = mapper.selectMyWeek(currentUser, weekStartStr);

        // dot 표시 / 디버그용 — 작성된 날짜만
        List<Map<String, Object>> dates = new ArrayList<>(rows.size());
        for (Map<String, Object> r : rows) {
            Map<String, Object> d = new HashMap<>();
            d.put("reportDate", r.get("reportDate"));
            dates.add(d);
        }

        return Map.of(
                "ds_week", DataSetSupport.rows(rows),
                "ds_dates", DataSetSupport.rows(dates),
                "ds_meta", DataSetSupport.rows(List.of(Map.of("weekStart", weekStartStr)))
        );
    }

    // ============================================================
    // searchMonth — 본인 월별 (mini 캘린더 dot 용)
    // ============================================================
    @DataSetServiceMapping("worklog/searchMonth")
    public Map<String, Object> searchMonth(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank() || "anonymous".equals(currentUser)) {
            return Map.of(
                    "ds_month", DataSetSupport.rows(List.of()),
                    "ds_dates", DataSetSupport.rows(List.of())
            );
        }
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String yearMonth = DataSetSupport.toStr(search.get("yearMonth"));
        if (yearMonth == null || yearMonth.isBlank()) {
            yearMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        }
        List<Map<String, Object>> rows = mapper.selectMonth(currentUser, yearMonth);
        List<Map<String, Object>> dates = mapper.selectMyWrittenDates(currentUser, yearMonth);
        return Map.of(
                "ds_month", DataSetSupport.rows(rows),
                "ds_dates", DataSetSupport.rows(dates)
        );
    }

    // ============================================================
    // searchTeamDaily — 부서장 / ADMIN
    // ============================================================
    @DataSetServiceMapping("worklog/searchTeamDaily")
    public Map<String, Object> searchTeamDaily(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long deptId = DataSetSupport.toLong(search.get("deptId"));
        String reportDate = DataSetSupport.toStr(search.get("reportDate"));
        if (reportDate == null || reportDate.isBlank()) {
            reportDate = LocalDate.now().format(DATE_FMT);
        } else {
            reportDate = normalizeDate(reportDate);
        }

        // deptId 미지정 → 본인 부서 자동 사용
        if (deptId == null) {
            deptId = resolveMyDeptId(currentUser);
            if (deptId == null) {
                throw BusinessException.badRequest("deptId 가 필요합니다", "deptId");
            }
        }

        guardManagerOrAdmin(currentUser, deptId);

        List<Map<String, Object>> rows = mapper.selectTeamDaily(deptId, reportDate);
        return Map.of(
                "ds_team", DataSetSupport.rows(rows),
                "ds_meta", DataSetSupport.rows(List.of(Map.of(
                        "deptId", deptId, "reportDate", reportDate
                )))
        );
    }

    // ============================================================
    // searchTeamWeekly — 부서장 / ADMIN
    // ============================================================
    @DataSetServiceMapping("worklog/searchTeamWeekly")
    public Map<String, Object> searchTeamWeekly(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long deptId = DataSetSupport.toLong(search.get("deptId"));
        String weekStartRaw = DataSetSupport.toStr(search.get("weekStart"));

        if (deptId == null) {
            deptId = resolveMyDeptId(currentUser);
            if (deptId == null) {
                throw BusinessException.badRequest("deptId 가 필요합니다", "deptId");
            }
        }
        guardManagerOrAdmin(currentUser, deptId);

        LocalDate weekStart = normalizeWeekStart(weekStartRaw);
        String weekStartStr = weekStart.format(DATE_FMT);

        List<Map<String, Object>> raw = mapper.selectTeamWeekly(deptId, weekStartStr);

        // 직원별 weekday 매트릭스로 재구성: 한 행 = { employeeNo, employeeName, mon, tue, wed, thu, fri, sat, sun }
        // 각 요일 셀은 해당 일의 row(또는 null) - UI 가 클릭 시 read-only 다이얼로그로 펼침.
        Map<String, Map<String, Object>> matrix = new LinkedHashMap<>();
        for (Map<String, Object> r : raw) {
            String empNo = DataSetSupport.toStr(r.get("employeeNo"));
            Map<String, Object> bucket = matrix.get(empNo);
            if (bucket == null) {
                bucket = new LinkedHashMap<>();
                bucket.put("employeeNo", empNo);
                bucket.put("employeeName", r.get("employeeName"));
                bucket.put("deptId", r.get("deptId"));
                // 7일치 슬롯 초기화 (mon..sun)
                String[] keys = {"mon", "tue", "wed", "thu", "fri", "sat", "sun"};
                for (String k : keys) bucket.put(k, null);
                matrix.put(empNo, bucket);
            }
            Object reportDateObj = r.get("reportDate");
            if (reportDateObj != null) {
                LocalDate d = parseLocalDate(reportDateObj);
                if (d != null) {
                    int diff = (int) (d.toEpochDay() - weekStart.toEpochDay());
                    if (diff >= 0 && diff < 7) {
                        String dayKey = weekDayKey(diff);
                        Map<String, Object> cell = new HashMap<>();
                        cell.put("reportId", r.get("reportId"));
                        cell.put("reportDate", reportDateObj);
                        cell.put("doneToday", r.get("doneToday"));
                        cell.put("planTomorrow", r.get("planTomorrow"));
                        cell.put("issue", r.get("issue"));
                        cell.put("mood", r.get("mood"));
                        cell.put("hoursWorked", r.get("hoursWorked"));
                        cell.put("updatedAt", r.get("updatedAt"));
                        bucket.put(dayKey, cell);
                    }
                }
            }
        }

        List<Map<String, Object>> matrixRows = new ArrayList<>(matrix.values());
        return Map.of(
                "ds_team", DataSetSupport.rows(matrixRows),
                "ds_raw", DataSetSupport.rows(raw),
                "ds_meta", DataSetSupport.rows(List.of(Map.of(
                        "deptId", deptId, "weekStart", weekStartStr
                )))
        );
    }

    // ============================================================
    // helpers
    // ============================================================

    /**
     * 주간 시작 정규화 — ISO 주(월요일 시작).
     * 입력이 null/공백 → 오늘 기준 월요일.
     * 입력이 월요일이 아니면 그 주의 월요일로 보정.
     */
    private LocalDate normalizeWeekStart(String raw) {
        LocalDate base;
        if (raw == null || raw.isBlank()) {
            base = LocalDate.now();
        } else {
            try {
                base = LocalDate.parse(normalizeDate(raw));
            } catch (Exception e) {
                log.warn("weekStart 파싱 실패 — 오늘로 폴백: {}", raw);
                base = LocalDate.now();
            }
        }
        DayOfWeek dow = base.getDayOfWeek();
        // ISO: MONDAY=1 .. SUNDAY=7. 월요일까지 뒤로 (value-1)일 빼기.
        int offset = dow.getValue() - DayOfWeek.MONDAY.getValue();
        if (offset < 0) offset += 7;
        return base.minusDays(offset);
    }

    private String normalizeDate(String s) {
        if (s == null) return null;
        // 'YYYY-MM-DD' 또는 ISO datetime 처리
        if (s.length() >= 10) return s.substring(0, 10);
        return s;
    }

    private LocalDate parseLocalDate(Object raw) {
        if (raw == null) return null;
        try {
            if (raw instanceof LocalDate ld) return ld;
            if (raw instanceof java.sql.Date sd) return sd.toLocalDate();
            if (raw instanceof java.util.Date d) {
                return d.toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDate();
            }
            String s = raw.toString();
            return LocalDate.parse(s.length() > 10 ? s.substring(0, 10) : s);
        } catch (Exception e) {
            log.warn("parseLocalDate 실패: {}", raw);
            return null;
        }
    }

    private String weekDayKey(int idx) {
        switch (idx) {
            case 0: return "mon";
            case 1: return "tue";
            case 2: return "wed";
            case 3: return "thu";
            case 4: return "fri";
            case 5: return "sat";
            case 6: return "sun";
            default: return "_";
        }
    }

    private BigDecimal parseHours(Object raw) {
        if (raw == null) return null;
        if (raw instanceof BigDecimal bd) return bd;
        if (raw instanceof Number n) return BigDecimal.valueOf(n.doubleValue());
        try {
            String s = raw.toString().trim();
            if (s.isEmpty()) return null;
            return new BigDecimal(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** 본인 부서 ID 조회 — currentUser 는 employee_no (정규화됨) 또는 keycloak username. */
    private Long resolveMyDeptId(String currentUser) {
        if (currentUser == null || currentUser.isBlank()) return null;
        try {
            Map<String, Object> emp = orgMapper.findEmployeeByNo(currentUser);
            if (emp == null) emp = orgMapper.findEmployeeByKeycloakUserId(currentUser);
            if (emp == null) return null;
            return DataSetSupport.toLong(emp.getOrDefault("deptId", emp.get("dept_id")));
        } catch (Exception e) {
            log.warn("resolveMyDeptId 실패: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 부서장 / ADMIN 가드 — 통과하지 못하면 BusinessException.forbidden.
     *
     * 우선순위:
     *   (1) ROLE_ADMIN / ROLE_MGR 보유 → 통과 (트랙 5 권한 매트릭스 기준)
     *   (2) currentUser 가 deptId 의 dept head → 통과
     *   (3) currentUser 의 position_level 이 임계치 이하 + 본인 부서면 통과
     */
    private void guardManagerOrAdmin(String currentUser, Long deptId) {
        if (hasRole("ROLE_ADMIN") || hasRole("ROLE_MGR")) return;

        if (currentUser == null || currentUser.isBlank()) {
            throw BusinessException.forbidden("FORBIDDEN");
        }
        if (deptId == null) {
            throw BusinessException.forbidden("FORBIDDEN");
        }

        // (2) dept head 매칭
        try {
            Map<String, Object> head = orgMapper.selectDeptHead(deptId);
            if (head != null) {
                Object headEmpId = head.get("employeeId");
                Map<String, Object> me = orgMapper.findEmployeeByNo(currentUser);
                if (me == null) me = orgMapper.findEmployeeByKeycloakUserId(currentUser);
                if (me != null && headEmpId != null) {
                    Object myEmpId = me.getOrDefault("employeeId", me.get("employee_id"));
                    if (headEmpId.toString().equals(String.valueOf(myEmpId))) {
                        return;
                    }
                }

                // (3) position_level 임계치 + 본인 부서
                if (me != null) {
                    Long myDeptId = DataSetSupport.toLong(me.getOrDefault("deptId", me.get("dept_id")));
                    Long myPosLv = DataSetSupport.toLong(
                            me.getOrDefault("positionLevel", me.get("position_level"))
                    );
                    if (myDeptId != null && myDeptId.equals(deptId)
                            && myPosLv != null && myPosLv <= DEPT_HEAD_LEVEL_THRESHOLD) {
                        return;
                    }
                }
            }
        } catch (Exception e) {
            log.warn("guardManagerOrAdmin head 조회 실패: {}", e.getMessage());
        }

        throw BusinessException.forbidden("FORBIDDEN");
    }

    private boolean hasRole(String role) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return false;
        return auth.getAuthorities().stream()
                .map(Object::toString)
                .anyMatch(r -> r.equals(role));
    }
}
