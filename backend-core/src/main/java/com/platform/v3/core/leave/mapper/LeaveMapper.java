package com.platform.v3.core.leave.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface LeaveMapper {

    /** 연차 잔여 (employeeNo + year) — 없으면 null */
    Map<String, Object> selectBalance(@Param("employeeNo") String employeeNo,
                                      @Param("year") Integer year);

    /** 연차 잔여 행 신규 (year/total_days) */
    void insertBalance(Map<String, Object> row);

    /** used_days 증가 (멱등 보호 — 동일 differential 호출 안 됨, 상위에서 status 체크) */
    void addUsedDays(@Param("employeeNo") String employeeNo,
                     @Param("year") Integer year,
                     @Param("addDays") Double addDays);

    /** 본인 휴가 신청 이력 (year) */
    List<Map<String, Object>> selectMyHistory(@Param("employeeNo") String employeeNo,
                                              @Param("year") Integer year);

    /** docId 로 휴가신청 단건 */
    Map<String, Object> selectRequestByDoc(@Param("docId") Long docId);

    /** 휴가 신청 INSERT (결재 상신 후) */
    void insertRequest(Map<String, Object> row);

    /** 휴가 신청 status 변경 (PENDING → APPROVED 등) */
    void updateRequestStatus(@Param("requestId") Long requestId,
                             @Param("status") String status);

    /** 팀 캘린더용 — 부서·기간 휴가 표시 */
    List<Map<String, Object>> selectTeamCalendar(@Param("deptId") Long deptId,
                                                 @Param("from") String from,
                                                 @Param("to") String to);

    /** 영업일 계산용 — 기간 내 공휴일 목록 */
    List<String> selectHolidaysBetween(@Param("from") String from,
                                       @Param("to") String to);
}
