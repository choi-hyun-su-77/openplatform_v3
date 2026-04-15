package com.platform.v3.core.dataset;

import com.platform.v3.core.common.ApiResponse;
import com.platform.v3.core.org.mapper.OrgMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/dataset")
public class DataSetController {

    private static final Logger log = LoggerFactory.getLogger(DataSetController.class);

    private final DataSetService dataSetService;
    private final OrgMapper orgMapper;

    public DataSetController(DataSetService dataSetService, OrgMapper orgMapper) {
        this.dataSetService = dataSetService;
        this.orgMapper = orgMapper;
    }

    @PostMapping("/search")
    public ApiResponse<Map<String, Object>> search(
            @RequestBody Map<String, Object> body,
            Authentication authentication
    ) {
        String serviceName = (String) body.get("serviceName");
        Map<String, Object> datasets = extractDatasets(body);
        String user = currentUser(authentication);
        return ApiResponse.ok(dataSetService.search(serviceName, datasets, user));
    }

    @PostMapping("/save")
    public ApiResponse<Map<String, Object>> save(
            @RequestBody Map<String, Object> body,
            Authentication authentication
    ) {
        String serviceName = (String) body.get("serviceName");
        Map<String, Object> datasets = extractDatasets(body);
        String user = currentUser(authentication);
        return ApiResponse.ok(dataSetService.save(serviceName, datasets, user));
    }

    @PostMapping("/search-save")
    public ApiResponse<Map<String, Object>> searchAfterSave(
            @RequestBody Map<String, Object> body,
            Authentication authentication
    ) {
        String saveName = (String) body.get("saveServiceName");
        String searchName = (String) body.get("searchServiceName");
        Map<String, Object> datasets = extractDatasets(body);
        String user = currentUser(authentication);
        return ApiResponse.ok(dataSetService.searchAfterSave(saveName, searchName, datasets, user));
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> extractDatasets(Map<String, Object> body) {
        Object datasets = body.get("datasets");
        if (datasets instanceof Map<?, ?> m) return (Map<String, Object>) m;
        Map<String, Object> copy = new HashMap<>(body);
        copy.remove("serviceName");
        copy.remove("saveServiceName");
        copy.remove("searchServiceName");
        return copy;
    }

    /**
     * Authentication 에서 currentUser 를 추출하고 employee_no 로 정규화한다.
     *
     * 1) Keycloak JWT 의 preferred_username 을 읽음
     * 2) org_employee.keycloak_user_id = username 으로 매칭되는 employee_no 조회
     * 3) 매칭 성공 시 employee_no 반환, 실패 시 username 그대로 반환 (fallback)
     *
     * 이후 도메인 서비스 (@DataSetServiceMapping) 는 currentUser 가 항상
     * employee_no (예: "E0001") 라고 가정할 수 있다.
     */
    private String currentUser(Authentication auth) {
        if (auth == null) return "anonymous";
        Object principal = auth.getPrincipal();
        String username = null;
        if (principal instanceof Jwt jwt) {
            username = jwt.getClaimAsString("preferred_username");
            if (username == null) username = jwt.getSubject();
        } else {
            username = auth.getName();
        }
        if (username == null || username.isBlank()) return "anonymous";
        try {
            Map<String, Object> emp = orgMapper.findEmployeeByKeycloakUserId(username);
            if (emp != null) {
                // MyBatis camelCase 매핑이 활성화돼 있으면 employeeNo, 아니면 employee_no
                Object empNo = emp.get("employeeNo");
                if (empNo == null) empNo = emp.get("employee_no");
                if (empNo != null) {
                    log.debug("currentUser 정규화: {} → {}", username, empNo);
                    return empNo.toString();
                }
            }
        } catch (Exception e) {
            log.warn("currentUser keycloak→employee_no 매핑 실패 username={}: {}", username, e.getMessage());
        }
        return username; // fallback
    }
}
