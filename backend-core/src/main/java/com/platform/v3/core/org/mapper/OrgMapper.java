package com.platform.v3.core.org.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface OrgMapper {

    List<Map<String, Object>> selectDeptTree(@Param("parentDeptId") Long parentDeptId);

    Map<String, Object> selectDeptById(@Param("deptId") Long deptId);

    List<Map<String, Object>> selectEmployees(@Param("deptId") Long deptId,
                                              @Param("keyword") String keyword,
                                              @Param("status") String status);

    Map<String, Object> selectEmployeeById(@Param("employeeId") Long employeeId);

    List<Map<String, Object>> selectApproverCandidates(@Param("keyword") String keyword,
                                                       @Param("deptId") Long deptId);

    Map<String, Object> selectApproverByRole(@Param("role") String role,
                                             @Param("drafterId") Long drafterId);

    Map<String, Object> selectDeptHead(@Param("deptId") Long deptId);

    /**
     * Keycloak preferred_username 으로 org_employee 를 조회하여
     * employee_id / employee_no / dept_id / dept_name / position_name / position_level 을 반환.
     * v3 의 identity 매핑 핵심 — BFF `/api/bff/identity/me` 와
     * DataSetController `currentUser` 정규화에서 사용.
     */
    Map<String, Object> findEmployeeByKeycloakUserId(@Param("keycloakUserId") String keycloakUserId);

    /** employee_no 로 조회 — NotificationService 가 userNo → employee_id 변환 시 사용. */
    Map<String, Object> findEmployeeByNo(@Param("employeeNo") String employeeNo);
}
