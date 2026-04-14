package com.platform.v3.core.i18n;

import com.platform.v3.core.common.ApiResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/i18n")
public class I18nController {

    private final I18nService i18nService;

    public I18nController(I18nService i18nService) {
        this.i18nService = i18nService;
    }

    @GetMapping("/{locale}")
    public ApiResponse<List<Map<String, Object>>> getMessages(
            @PathVariable String locale,
            @RequestParam(required = false) String type) {
        return ApiResponse.ok(i18nService.getMessages(locale, type));
    }
}
