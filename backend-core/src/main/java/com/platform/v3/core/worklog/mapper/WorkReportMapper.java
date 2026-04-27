package com.platform.v3.core.worklog.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 업무일지 (Work Report) MyBatis Mapper — Phase 14 트랙 4.
 *
 * wr_daily UNIQUE(employee_no, report_date) 를 활용한 upsert 패턴이 핵심.
 * 부서장(또는 ADMIN)이 호출하는 search* 들은 service 레이어에서 권한 체크 후
 * 호출되며, mapper 자체는 단순 SELECT 만 수행한다.
 */
@Mapper
public interface WorkReportMapper {

    /**
     * upsert (ON CONFLICT (employee_no, report_date) DO UPDATE).
     * row 에 employeeNo / reportDate / doneToday / planTomorrow / issue / mood / hoursWorked 입력.
     */
    void upsertDaily(Map<String, Object> row);

    /** 단건 조회 (없으면 null). */
    Map<String, Object> selectOne(@Param("employeeNo") String employeeNo,
                                  @Param("reportDate") String reportDate);

    /** 본인 주간 (weekStart=월요일, +6일). */
    List<Map<String, Object>> selectMyWeek(@Param("employeeNo") String employeeNo,
                                           @Param("weekStart") String weekStart);

    /** 본인 월별. yearMonth='2026-04' (TO_CHAR 매칭). */
    List<Map<String, Object>> selectMonth(@Param("employeeNo") String employeeNo,
                                          @Param("yearMonth") String yearMonth);

    /** 부서원 일별 — 행=직원, 1일치. */
    List<Map<String, Object>> selectTeamDaily(@Param("deptId") Long deptId,
                                              @Param("reportDate") String reportDate);

    /** 부서원 주간 — 행=직원x날짜 (월~금 5일치). */
    List<Map<String, Object>> selectTeamWeekly(@Param("deptId") Long deptId,
                                               @Param("weekStart") String weekStart);

    /** 작성된 날짜 목록 (mini 캘린더 dot 표시용). yearMonth='2026-04'. */
    List<Map<String, Object>> selectMyWrittenDates(@Param("employeeNo") String employeeNo,
                                                   @Param("yearMonth") String yearMonth);
}
