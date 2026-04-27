package com.platform.v3.core.admin;

import com.platform.v3.core.admin.mapper.AdminMapper;
import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 시스템 관리자 콘솔 (admin/*) 도메인 서비스.
 *
 * <h2>개요</h2>
 * <ul>
 *   <li>모든 메서드는 ROLE_ADMIN 만 접근 — {@link #requireAdmin()} 가 내부에서 검사한다.</li>
 *   <li>모든 admin/* DataSet 호출은 {@link AdminAuditAspect} 에 의해 자동 sa_audit insert 된다.</li>
 *   <li>사용자 추가/수정/비활성/비번리셋 은 BFF /api/bff/identity/* 를 호출하여 Keycloak 측 동기화.</li>
 * </ul>
 *
 * <h2>네임스페이스</h2>
 * 모든 서비스 이름은 "admin/" 접두사. (12+ 개)
 */
@Service
public class AdminService {

    private static final Logger log = LoggerFactory.getLogger(AdminService.class);

    private static final int DEFAULT_LIMIT = 50;
    private static final int MAX_LIMIT = 500;
    private static final String DEFAULT_PASSWORD = "temp123!";

    private final AdminMapper adminMapper;
    private final RestTemplate restTemplate;
    private final String bffBaseUrl;

    public AdminService(AdminMapper adminMapper,
                        @Value("${bff.base-url:http://backend-bff:19091}") String bffBaseUrl) {
        this.adminMapper = adminMapper;
        this.bffBaseUrl = bffBaseUrl;
        this.restTemplate = new RestTemplate();
    }

    // ========================================================================
    // 사용자 관리
    // ========================================================================

    @DataSetServiceMapping("admin/userList")
    public Map<String, Object> userList(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String keyword = DataSetSupport.toStr(search.get("keyword"));
        Long deptId = DataSetSupport.toLong(search.get("deptId"));
        String status = DataSetSupport.toStr(search.get("status"));
        int[] page = parsePaging(search);
        List<Map<String, Object>> rows = adminMapper.selectUserList(keyword, deptId, status, page[0], page[1]);
        long total = adminMapper.countUserList(keyword, deptId, status);
        return Map.of(
                "ds_users", Map.of("rows", rows, "totalCount", total)
        );
    }

    @DataSetServiceMapping("admin/userSave")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> userSave(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_user");
        if (ds == null) throw BusinessException.badRequest("ds_user required", "ds_user");
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
        if (rows.isEmpty()) throw BusinessException.badRequest("no user rows", null);

        Map<String, Object> row = new HashMap<>(rows.get(0));
        Long employeeId = DataSetSupport.toLong(row.get("employeeId"));
        String employeeNo = DataSetSupport.toStr(row.get("employeeNo"));
        String employeeName = DataSetSupport.toStr(row.get("employeeName"));
        String email = DataSetSupport.toStr(row.get("email"));
        String username = DataSetSupport.toStr(row.get("keycloakUserId"));

        // List<String> roles → realm role 추가용 (UI MultiSelect)
        List<String> roles = (List<String>) row.getOrDefault("roles", List.of());

        if (employeeId == null) {
            // INSERT — Keycloak 사용자도 함께 생성
            if (employeeNo == null || employeeName == null) {
                throw BusinessException.badRequest("employeeNo/employeeName required", null);
            }
            if (adminMapper.selectUserByNo(employeeNo) != null) {
                throw BusinessException.duplicate("이미 존재하는 사번: " + employeeNo, "employeeNo");
            }
            adminMapper.insertUser(row);
            employeeId = DataSetSupport.toLong(row.get("employeeId"));
            log.info("[admin] employee inserted: id={} no={}", employeeId, employeeNo);

            // Keycloak 사용자 생성 (실패해도 DB row 는 유지 — warn 로그)
            if (username != null && !username.isBlank()) {
                try {
                    Map<String, Object> req = new HashMap<>();
                    req.put("username", username);
                    req.put("email", email);
                    req.put("firstName", employeeName);
                    req.put("password", DEFAULT_PASSWORD);
                    req.put("roles", roles);
                    Map<String, Object> kcResp = bffPost("/api/bff/identity/users", req);
                    Object kcUserId = kcResp == null ? null : kcResp.get("userId");
                    log.info("[admin] keycloak user created: username={} userId={}", username, kcUserId);
                } catch (Exception e) {
                    log.warn("[admin] keycloak createUser 실패 username={}: {}", username, e.getMessage());
                }
            }
        } else {
            // UPDATE
            adminMapper.updateUser(row);
            log.info("[admin] employee updated: id={}", employeeId);

            if (username != null && !username.isBlank()) {
                try {
                    Map<String, Object> req = new HashMap<>();
                    req.put("username", username);
                    req.put("email", email);
                    req.put("firstName", employeeName);
                    req.put("roles", roles);
                    bffPut("/api/bff/identity/users/" + username, req);
                } catch (Exception e) {
                    log.warn("[admin] keycloak updateUser 실패 username={}: {}", username, e.getMessage());
                }
            }
        }

        Map<String, Object> saved = adminMapper.selectUserById(employeeId);
        return Map.of("ds_user", DataSetSupport.rows(saved == null ? List.of() : List.of(saved)));
    }

    @DataSetServiceMapping("admin/userToggleActive")
    @Transactional
    public Map<String, Object> userToggleActive(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long employeeId = DataSetSupport.toLong(search.get("employeeId"));
        if (employeeId == null) throw BusinessException.badRequest("employeeId required", "employeeId");
        Map<String, Object> emp = adminMapper.selectUserById(employeeId);
        if (emp == null) throw BusinessException.notFound("employee not found: " + employeeId);

        String currentStatus = DataSetSupport.toStr(emp.get("status"));
        String next = "ACTIVE".equalsIgnoreCase(currentStatus) ? "INACTIVE" : "ACTIVE";
        adminMapper.updateUserStatus(employeeId, next);

        String username = DataSetSupport.toStr(emp.get("keycloakUserId"));
        if (username != null && !username.isBlank()) {
            try {
                Map<String, Object> req = Map.of("active", "ACTIVE".equals(next));
                bffPut("/api/bff/identity/users/" + username + "/active", req);
            } catch (Exception e) {
                log.warn("[admin] keycloak setActive 실패 username={}: {}", username, e.getMessage());
            }
        }
        return Map.of("status", next, "employeeId", employeeId);
    }

    @DataSetServiceMapping("admin/userResetPwd")
    public Map<String, Object> userResetPwd(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long employeeId = DataSetSupport.toLong(search.get("employeeId"));
        if (employeeId == null) throw BusinessException.badRequest("employeeId required", "employeeId");
        Map<String, Object> emp = adminMapper.selectUserById(employeeId);
        if (emp == null) throw BusinessException.notFound("employee not found: " + employeeId);

        String username = DataSetSupport.toStr(emp.get("keycloakUserId"));
        if (username == null || username.isBlank()) {
            throw BusinessException.badRequest("Keycloak username (keycloakUserId) 미설정", "keycloakUserId");
        }
        try {
            bffPost("/api/bff/identity/users/" + username + "/reset-password",
                    Map.of("temporaryPassword", DEFAULT_PASSWORD));
        } catch (Exception e) {
            log.warn("[admin] keycloak resetPassword 실패 username={}: {}", username, e.getMessage());
            throw BusinessException.badRequest("Keycloak 비밀번호 재설정 실패: " + e.getMessage(), null);
        }
        return Map.of("temporaryPassword", DEFAULT_PASSWORD, "username", username);
    }

    // ========================================================================
    // 부서 관리
    // ========================================================================

    @DataSetServiceMapping("admin/deptTree")
    public Map<String, Object> deptTree(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        List<Map<String, Object>> flat = adminMapper.selectDeptTreeAll();
        return Map.of(
                "ds_deptTree", DataSetSupport.rows(buildDeptTree(flat)),
                "ds_deptList", DataSetSupport.rows(flat)
        );
    }

    @DataSetServiceMapping("admin/deptSave")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> deptSave(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_dept");
        if (ds == null) throw BusinessException.badRequest("ds_dept required", "ds_dept");
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
        if (rows.isEmpty()) throw BusinessException.badRequest("no dept rows", null);

        Map<String, Object> row = new HashMap<>(rows.get(0));
        Long deptId = DataSetSupport.toLong(row.get("deptId"));
        String rowType = DataSetSupport.toStr(row.get("_rowType"));
        if ("D".equalsIgnoreCase(rowType)) {
            if (deptId == null) throw BusinessException.badRequest("deptId required for delete", "deptId");
            adminMapper.deleteDept(deptId);
            return Map.of("deleted", deptId);
        }
        if (deptId == null) {
            adminMapper.insertDept(row);
            deptId = DataSetSupport.toLong(row.get("deptId"));
        } else {
            adminMapper.updateDept(row);
        }
        Map<String, Object> saved = adminMapper.selectDeptById(deptId);
        return Map.of("ds_dept", DataSetSupport.rows(saved == null ? List.of() : List.of(saved)));
    }

    // ========================================================================
    // 메뉴 관리
    // ========================================================================

    @DataSetServiceMapping("admin/menuList")
    public Map<String, Object> menuList(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        List<Map<String, Object>> flat = adminMapper.selectMenuListAll();
        List<Map<String, Object>> roles = adminMapper.selectRoles();
        List<Map<String, Object>> matrix = adminMapper.selectPermissionMatrix();
        return Map.of(
                "ds_menus", DataSetSupport.rows(flat),
                "ds_menuTree", DataSetSupport.rows(buildMenuTree(flat)),
                "ds_roles", DataSetSupport.rows(roles),
                "ds_permissions", DataSetSupport.rows(matrix)
        );
    }

    @DataSetServiceMapping("admin/menuSave")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> menuSave(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_menu");
        if (ds == null) throw BusinessException.badRequest("ds_menu required", "ds_menu");
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
        if (rows.isEmpty()) throw BusinessException.badRequest("no menu rows", null);

        Map<String, Object> row = new HashMap<>(rows.get(0));
        String menuId = DataSetSupport.toStr(row.get("menuId"));
        if (menuId == null || menuId.isBlank()) throw BusinessException.badRequest("menuId required", "menuId");

        Map<String, Object> existing = adminMapper.selectMenuById(menuId);
        if (existing == null) {
            adminMapper.insertMenu(row);
        } else {
            adminMapper.updateMenu(row);
        }
        return Map.of("ds_menu", DataSetSupport.rows(List.of(adminMapper.selectMenuById(menuId))));
    }

    @DataSetServiceMapping("admin/menuDelete")
    @Transactional
    public Map<String, Object> menuDelete(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String menuId = DataSetSupport.toStr(search.get("menuId"));
        if (menuId == null || menuId.isBlank()) throw BusinessException.badRequest("menuId required", "menuId");
        adminMapper.deleteMenu(menuId);
        return Map.of("deleted", menuId);
    }

    @DataSetServiceMapping("admin/permSave")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> permSave(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_permissions");
        if (ds == null) throw BusinessException.badRequest("ds_permissions required", "ds_permissions");
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
        int affected = 0;
        for (Map<String, Object> r : rows) {
            String rowType = DataSetSupport.toStr(r.get("_rowType"));
            String roleId = DataSetSupport.toStr(r.get("roleId"));
            String menuId = DataSetSupport.toStr(r.get("menuId"));
            if (roleId == null || menuId == null) continue;
            if ("D".equalsIgnoreCase(rowType)) {
                affected += adminMapper.deleteRoleMenu(roleId, menuId);
            } else {
                affected += adminMapper.upsertRoleMenu(r);
            }
        }
        return Map.of("affected", affected);
    }

    // ========================================================================
    // 공통코드 관리
    // ========================================================================

    @DataSetServiceMapping("admin/codeGroupList")
    public Map<String, Object> codeGroupList(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        return Map.of("ds_groups", DataSetSupport.rows(adminMapper.selectCodeGroups()));
    }

    @DataSetServiceMapping("admin/codeList")
    public Map<String, Object> codeList(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String groupCd = DataSetSupport.toStr(search.get("groupCd"));
        return Map.of("ds_codes", DataSetSupport.rows(adminMapper.selectCodeList(groupCd)));
    }

    @DataSetServiceMapping("admin/codeSave")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> codeSave(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_codes");
        if (ds == null) throw BusinessException.badRequest("ds_codes required", "ds_codes");
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
        int affected = 0;
        for (Map<String, Object> r : rows) {
            String rowType = DataSetSupport.toStr(r.get("_rowType"));
            String groupCd = DataSetSupport.toStr(r.get("groupCd"));
            String code = DataSetSupport.toStr(r.get("code"));
            if (groupCd == null || code == null) continue;
            if ("D".equalsIgnoreCase(rowType)) {
                affected += adminMapper.deleteCode(groupCd, code);
            } else {
                affected += adminMapper.insertCode(r);
            }
        }
        return Map.of("affected", affected);
    }

    @DataSetServiceMapping("admin/codeDelete")
    @Transactional
    public Map<String, Object> codeDelete(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String groupCd = DataSetSupport.toStr(search.get("groupCd"));
        String code = DataSetSupport.toStr(search.get("code"));
        if (groupCd == null || code == null) {
            throw BusinessException.badRequest("groupCd/code required", null);
        }
        int n = adminMapper.deleteCode(groupCd, code);
        return Map.of("deleted", n);
    }

    // ========================================================================
    // 감사 로그
    // ========================================================================

    @DataSetServiceMapping("admin/auditSearch")
    public Map<String, Object> auditSearch(Map<String, Object> datasets, String currentUser) {
        requireAdmin();
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String actorNo = DataSetSupport.toStr(search.get("actorNo"));
        String action = DataSetSupport.toStr(search.get("action"));
        String fromDate = DataSetSupport.toStr(search.get("fromDate"));
        String toDate = DataSetSupport.toStr(search.get("toDate"));
        int[] page = parsePaging(search);
        List<Map<String, Object>> rows = adminMapper.selectAuditList(actorNo, action, fromDate, toDate, page[0], page[1]);
        long total = adminMapper.countAuditList(actorNo, action, fromDate, toDate);
        return Map.of(
                "ds_audit", Map.of("rows", rows, "totalCount", total)
        );
    }

    // ========================================================================
    // 권한 검사 / 트리 빌더 / 페이징
    // ========================================================================

    /**
     * SecurityContext 의 Authentication 으로부터 ROLE_ADMIN 권한을 검사한다.
     * 비ROLE_ADMIN 호출 시 BusinessException("FORBIDDEN") throw.
     */
    private void requireAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw BusinessException.forbidden("ROLE_ADMIN required");
        }
        for (GrantedAuthority a : auth.getAuthorities()) {
            String name = a.getAuthority();
            if ("ROLE_ADMIN".equals(name)) return;
        }
        throw BusinessException.forbidden("ROLE_ADMIN required");
    }

    private int[] parsePaging(Map<String, Object> search) {
        int page = 0;
        int size = DEFAULT_LIMIT;
        Long p = DataSetSupport.toLong(search.get("page"));
        Long s = DataSetSupport.toLong(search.get("size"));
        if (p != null) page = Math.max(0, p.intValue());
        if (s != null) size = Math.min(MAX_LIMIT, Math.max(1, s.intValue()));
        return new int[]{ page * size, size };
    }

    private List<Map<String, Object>> buildDeptTree(List<Map<String, Object>> flat) {
        Map<Object, Map<String, Object>> index = new LinkedHashMap<>();
        List<Map<String, Object>> roots = new ArrayList<>();
        for (Map<String, Object> row : flat) {
            Map<String, Object> node = new LinkedHashMap<>(row);
            node.put("children", new ArrayList<Map<String, Object>>());
            index.put(row.get("deptId"), node);
        }
        for (Map<String, Object> row : flat) {
            Object parentId = row.get("parentDeptId");
            Map<String, Object> node = index.get(row.get("deptId"));
            if (parentId != null && index.containsKey(parentId)) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> children = (List<Map<String, Object>>) index.get(parentId).get("children");
                children.add(node);
            } else {
                roots.add(node);
            }
        }
        return roots;
    }

    private List<Map<String, Object>> buildMenuTree(List<Map<String, Object>> flat) {
        Map<Object, Map<String, Object>> index = new LinkedHashMap<>();
        List<Map<String, Object>> roots = new ArrayList<>();
        for (Map<String, Object> row : flat) {
            Map<String, Object> node = new LinkedHashMap<>(row);
            node.put("children", new ArrayList<Map<String, Object>>());
            index.put(row.get("menuId"), node);
        }
        for (Map<String, Object> row : flat) {
            Object parentId = row.get("parentMenuId");
            Map<String, Object> node = index.get(row.get("menuId"));
            if (parentId != null && index.containsKey(parentId)) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> children = (List<Map<String, Object>>) index.get(parentId).get("children");
                children.add(node);
            } else {
                roots.add(node);
            }
        }
        return roots;
    }

    // ========================================================================
    // BFF 호출 헬퍼 (Keycloak Admin REST 위임)
    // ========================================================================

    @SuppressWarnings("unchecked")
    private Map<String, Object> bffPost(String path, Map<String, Object> body) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        propagateAuthHeader(headers);
        HttpEntity<Map<String, Object>> req = new HttpEntity<>(body, headers);
        ResponseEntity<Map> resp = restTemplate.exchange(bffBaseUrl + path, HttpMethod.POST, req, Map.class);
        return resp.getBody() == null ? Map.of() : (Map<String, Object>) resp.getBody();
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> bffPut(String path, Map<String, Object> body) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        propagateAuthHeader(headers);
        HttpEntity<Map<String, Object>> req = new HttpEntity<>(body, headers);
        ResponseEntity<Map> resp = restTemplate.exchange(bffBaseUrl + path, HttpMethod.PUT, req, Map.class);
        return resp.getBody() == null ? Map.of() : (Map<String, Object>) resp.getBody();
    }

    /**
     * 현재 Authentication 의 JWT bearer 토큰을 Authorization 헤더로 전파한다.
     * (BFF 도 동일 Realm 의 토큰을 검증하므로 ROLE_ADMIN 이 BFF 측에서 재검증된다.)
     */
    private void propagateAuthHeader(HttpHeaders headers) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return;
        Object cred = auth.getCredentials();
        Object principal = auth.getPrincipal();
        String token = null;
        if (principal instanceof org.springframework.security.oauth2.jwt.Jwt jwt) {
            token = jwt.getTokenValue();
        } else if (cred instanceof String s) {
            token = s;
        }
        if (token != null && !token.isBlank()) {
            headers.setBearerAuth(token);
        }
    }
}
