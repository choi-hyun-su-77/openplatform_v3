package com.platform.v3.core.code;

import com.platform.v3.core.common.ApiResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/codes")
public class CodeController {

    private final CodeService codeService;

    public CodeController(CodeService codeService) {
        this.codeService = codeService;
    }

    @GetMapping
    public ApiResponse<Map<String, List<Map<String, Object>>>> getCodesByGroups(
            @RequestParam List<String> groups) {
        return ApiResponse.ok(codeService.getCodesByGroups(groups));
    }
}
