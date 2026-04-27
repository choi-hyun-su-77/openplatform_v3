package com.platform.v3.core.attendance.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface AttendanceMapper {

    /** 오늘 row 조회 (없으면 null) */
    Map<String, Object> selectToday(@Param("employeeNo") String employeeNo,
                                    @Param("workDate") String workDate);

    /** 출근 INSERT (today row 가 없을 때) */
    void insertCheckIn(Map<String, Object> row);

    /** 출근 UPDATE (이미 row 가 있을 때 — 이론상 발생 안 하지만 멱등 처리) */
    void updateCheckIn(@Param("attendanceId") Long attendanceId);

    /** 퇴근 UPDATE (work_minutes 자동 계산) */
    void updateCheckOut(@Param("attendanceId") Long attendanceId,
                        @Param("workMinutes") Integer workMinutes);

    /** 월별 출근 목록 (employeeNo + yearMonth='2026-04') */
    List<Map<String, Object>> selectMyMonth(@Param("employeeNo") String employeeNo,
                                            @Param("yearMonth") String yearMonth);

    /** 팀(부서) 일별 출근 — 부서장 전용 */
    List<Map<String, Object>> selectTeamDaily(@Param("deptId") Long deptId,
                                              @Param("workDate") String workDate);

    /** 휴가 승인 시 해당일 status='LEAVE' 갱신 (없으면 INSERT) */
    void upsertLeaveDay(@Param("employeeNo") String employeeNo,
                        @Param("workDate") String workDate);
}
