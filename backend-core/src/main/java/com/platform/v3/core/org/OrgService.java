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
