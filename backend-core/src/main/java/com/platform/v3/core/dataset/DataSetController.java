package com.platform.v3.core.dataset;

import com.platform.v3.core.common.ApiResponse;
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

    private final DataSetService dataSetService;

    public DataSetController(DataSetService dataSetService) {
        this.dataSetService = dataSetService;
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

    private String currentUser(Authentication auth) {
        if (auth == null) return "anonymous";
        Object principal = auth.getPrincipal();
        if (principal instanceof Jwt jwt) {
            String username = jwt.getClaimAsString("preferred_username");
            return username != null ? username : jwt.getSubject();
        }
        return auth.getName();
    }
}
