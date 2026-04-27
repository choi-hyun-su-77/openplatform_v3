package com.platform.v3.core.admin.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 시스템 관리자 콘솔 (admin/*) 전용 MyBatis 매퍼.
 *
 * 기존 OrgMapper / MenuMapper / CodeMapper 와 SQL 의도가 비슷하지만
 * Admin 화면 전용으로 페이징·검색·CRUD 가 추가된 SQL 들을 한 파일(AdminMapper.xml) 로 통합한다.
 * 또한 모든 admin/* 호출을 자동 기록하는 sa_audit 테이블도 본 매퍼에서 다룬다.
 */
@Mapper
public interface AdminMapper {

    // ─── 사용자 (org_employee) ─────────────────────────────────────────────
    List<Map<String, Object>> selectUserList(@Param("keyword") String keyword,
                                             @Param("deptId") Long deptId,
                                             @Param("status") String status,
                                             @Param("offset") int offset,
                                             @Param("limit") int limit);

    long countUserList(@Param("keyword") String keyword,
                       @Param("deptId") Long deptId,
                       @Param("status") String status);

    Map<String, Object> selectUserById(@Param("employeeId") Long employeeId);

    Map<String, Object> selectUserByNo(@Param("employeeNo") String employeeNo);

    int insertUser(Map<String, Object> row);

    int updateUser(Map<String, Object> row);

    int updateUserStatus(@Param("employeeId") Long employeeId, @Param("status") String status);

    int updateUserKeycloakId(@Param("employeeId") Long employeeId,
                             @Param("keycloakUserId") String keycloakUserId);

    // ─── 부서 (org_department) ─────────────────────────────────────────────
    List<Map<String, Object>> selectDeptTreeAll();

    Map<String, Object> selectDeptById(@Param("deptId") Long deptId);

    int insertDept(Map<String, Object> row);

    int updateDept(Map<String, Object> row);

    int deleteDept(@Param("deptId") Long deptId);

    // ─── 메뉴 (cm_menu / cm_role_menu) ────────────────────────────────────
    List<Map<String, Object>> selectMenuListAll();

    Map<String, Object> selectMenuById(@Param("menuId") String menuId);

    int insertMenu(Map<String, Object> row);

    int updateMenu(Map<String, Object> row);

    int deleteMenu(@Param("menuId") String menuId);

    List<Map<String, Object>> selectPermissionMatrix();

    int deleteRoleMenu(@Param("roleId") String roleId, @Param("menuId") String menuId);

    int upsertRoleMenu(Map<String, Object> row);

    List<Map<String, Object>> selectRoles();

    // ─── 공통코드 (cm_code) ────────────────────────────────────────────────
    List<Map<String, Object>> selectCodeGroups();

    List<Map<String, Object>> selectCodeList(@Param("groupCd") String groupCd);

    int insertCode(Map<String, Object> row);

    int updateCode(Map<String, Object> row);

    int deleteCode(@Param("groupCd") String groupCd, @Param("code") String code);

    // ─── 감사 로그 (sa_audit) ──────────────────────────────────────────────
    int insertAudit(Map<String, Object> row);

    List<Map<String, Object>> selectAuditList(@Param("actorNo") String actorNo,
                                              @Param("action") String action,
                                              @Param("fromDate") String fromDate,
                                              @Param("toDate") String toDate,
                                              @Param("offset") int offset,
                                              @Param("limit") int limit);

    long countAuditList(@Param("actorNo") String actorNo,
                        @Param("action") String action,
                        @Param("fromDate") String fromDate,
                        @Param("toDate") String toDate);
}
