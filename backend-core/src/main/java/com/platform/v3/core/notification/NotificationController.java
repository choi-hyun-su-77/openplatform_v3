package com.platform.v3.core.notification;

import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.org.mapper.OrgMapper;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Map;

@RestController
@RequestMapping("/api/notification")
public class NotificationController {

    private final NotificationService notificationService;
    private final OrgMapper orgMapper;

    public NotificationController(NotificationService notificationService, OrgMapper orgMapper) {
        this.notificationService = notificationService;
        this.orgMapper = orgMapper;
    }

    /**
     * SSE 구독. ?token= 쿼리 파라미터는 SseTokenFilter 에 의해 Authorization 헤더로 변환됨.
     * JWT 인증 후 preferred_username → employee_id 로 매핑하여 구독.
     */
    @GetMapping(value = "/subscribe", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter subscribe(@AuthenticationPrincipal Jwt jwt,
                                @RequestParam(required = false) Long userId) {
        Long employeeId = resolveEmployeeId(jwt, userId);
        return notificationService.subscribe(employeeId);
    }

    private Long resolveEmployeeId(Jwt jwt, Long fallbackUserId) {
        if (jwt != null) {
            String username = jwt.getClaimAsString("preferred_username");
            if (username != null) {
                Map<String, Object> emp = orgMapper.findEmployeeByKeycloakUserId(username);
                if (emp != null) {
                    return DataSetSupport.toLong(emp.get("employeeId"));
                }
            }
        }
        return fallbackUserId;
    }
}
