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
}
