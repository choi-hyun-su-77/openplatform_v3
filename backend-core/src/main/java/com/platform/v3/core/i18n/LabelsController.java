package com.platform.v3.core.i18n;

import com.platform.v3.core.common.ApiResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/labels")
public class LabelsController {

    private final I18nService i18nService;

    public LabelsController(I18nService i18nService) {
        this.i18nService = i18nService;
    }

    @GetMapping
    public ApiResponse<Map<String, String>> getLabels(@RequestParam(defaultValue = "ko") String locale) {
        return ApiResponse.ok(i18nService.getLabelMap(locale));
    }
}
