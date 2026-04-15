package com.platform.v3.core.org;

import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.org.mapper.OrgMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class OrgService {

    private static final Logger log = LoggerFactory.getLogger(OrgService.class);

    private final OrgMapper orgMapper;

    public OrgService(OrgMapper orgMapper) {
        this.orgMapper = orgMapper;
    }

    @DataSetServiceMapping("org/searchDeptTree")
    public Map<String, Object> searchDeptTree(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long parentDeptId = DataSetSupport.toLong(search.get("parentDeptId"));
        List<Map<String, Object>> flat = orgMapper.selectDeptTree(parentDeptId);
        List<Map<String, Object>> tree = buildTree(flat);
        return Map.of(
                "ds_deptTree", DataSetSupport.rows(tree),
                "ds_deptList", DataSetSupport.rows(flat)
        );
    }

    @DataSetServiceMapping("org/searchEmployees")
    public Map<String, Object> searchEmployees(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long deptId = DataSetSupport.toLong(search.get("deptId"));
        String keyword = DataSetSupport.toStr(search.get("keyword"));
        String status = DataSetSupport.toStr(search.get("status"));
        return Map.of("ds_employees", DataSetSupport.rows(orgMapper.selectEmployees(deptId, keyword, status)));
    }

    @DataSetServiceMapping("org/searchApprovers")
    public Map<String, Object> searchApprovers(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String keyword = DataSetSupport.toStr(search.get("keyword"));
        Long deptId = DataSetSupport.toLong(search.get("deptId"));
        return Map.of("ds_approvers", DataSetSupport.rows(orgMapper.selectApproverCandidates(keyword, deptId)));
    }

    /**
     * 로그인 사용자 본인의 org_employee 정보 반환.
     * DataSetController 가 이미 Keycloak username → employee_no 로 정규화했으므로
     * currentUser 는 employee_no (예: "E0001") 또는 Keycloak username (fallback) 둘 중 하나.
     * 두 경우 모두 처리 — 먼저 employee_no 로 조회, 실패 시 keycloak_user_id 로 재시도.
     *
     * BFF `/api/bff/identity/me` 가 이 서비스를 호출하여 employeeNo/employeeId/deptId 등을 병합한다.
     */
    @DataSetServiceMapping("org/findMyEmployee")
    public Map<String, Object> findMyEmployee(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank() || "anonymous".equals(currentUser)) {
            return Map.of("ds_me", DataSetSupport.rows(List.of()));
        }
        Map<String, Object> emp = orgMapper.findEmployeeByNo(currentUser);
        if (emp == null) {
            emp = orgMapper.findEmployeeByKeycloakUserId(currentUser);
        }
        if (emp == null) {
            return Map.of("ds_me", DataSetSupport.rows(List.of()));
        }
        return Map.of("ds_me", DataSetSupport.rows(List.of(emp)));
    }

    public List<Map<String, Object>> resolveApproversByRoles(List<String> roles, Long drafterId) {
        List<Map<String, Object>> resolved = new ArrayList<>();
        for (String role : roles) {
            Map<String, Object> approver = orgMapper.selectApproverByRole(role, drafterId);
            if (approver != null) {
                approver.put("role", role);
                resolved.add(approver);
            } else {
                log.warn("역할 '{}' 에 해당하는 결재자 없음 (drafterId={})", role, drafterId);
            }
        }
        return resolved;
    }

    private List<Map<String, Object>> buildTree(List<Map<String, Object>> flat) {
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
}
