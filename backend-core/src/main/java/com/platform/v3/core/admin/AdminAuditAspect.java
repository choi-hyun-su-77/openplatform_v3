package com.platform.v3.core.admin;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.platform.v3.core.admin.mapper.AdminMapper;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 모든 admin/* DataSet 호출에 대한 감사 로그 자동 기록 AOP.
 *
 * <h2>동작</h2>
 * <ol>
 *   <li>{@link DataSetServiceMapping} 어노테이션이 붙은 모든 메서드를 가로챈다.</li>
 *   <li>{@code serviceName} 이 "admin/" 으로 시작하지 않으면 즉시 통과.</li>
 *   <li>메서드 정상 종료 후에만 sa_audit insert (예외 발생 시 audit 만 skip 하고 원 예외 propagate).</li>
 *   <li>actor_no = currentUser (DataSetController 가 정규화한 employee_no).</li>
 *   <li>action = serviceName 자체 (예: "admin/userSave").</li>
 *   <li>before_json = 인풋 datasets 의 JSON 직렬화.</li>
 *   <li>after_json = 메서드 반환값(Map) 의 JSON 직렬화.</li>
 *   <li>ip_addr = HttpServletRequest 에서 추출 (있으면).</li>
 * </ol>
 *
 * <h2>구현 노트</h2>
 * <ul>
 *   <li>auditMapper 가 내부적으로 호출하는 sa_audit insert 가 또 본 Aspect 에 잡히지 않도록
 *       ({@code admin/} 이 아닌 mapper 직접 호출이라 자동 제외.</li>
 *   <li>JSON 직렬화 실패해도 audit 만 skip — 원 메서드 결과는 그대로 반환.</li>
 * </ul>
 */
@Aspect
@Component
@Order(100)
public class AdminAuditAspect {

    private static final Logger log = LoggerFactory.getLogger(AdminAuditAspect.class);
    private static final ObjectMapper OM = new ObjectMapper();
    private static final String ADMIN_PREFIX = "admin/";
    private static final int MAX_JSON_LEN = 16_384; // 16KB 상한

    private final AdminMapper adminMapper;

    public AdminAuditAspect(AdminMapper adminMapper) {
        this.adminMapper = adminMapper;
    }

    @Around("@annotation(com.platform.v3.core.dataset.DataSetServiceMapping)")
    public Object audit(ProceedingJoinPoint pjp) throws Throwable {
        // 1) serviceName 추출
        String serviceName = extractServiceName(pjp);
        if (serviceName == null || !serviceName.startsWith(ADMIN_PREFIX)) {
            return pjp.proceed();
        }

        // 2) 인자 추출 (datasets, currentUser)
        Object[] args = pjp.getArgs();
        Map<String, Object> datasets = null;
        String currentUser = null;
        if (args.length >= 1 && args[0] instanceof Map<?, ?> m) {
            @SuppressWarnings("unchecked")
            Map<String, Object> cast = (Map<String, Object>) m;
            datasets = cast;
        }
        if (args.length >= 2 && args[1] instanceof String s) {
            currentUser = s;
        }

        // 3) proceed (예외는 그대로 propagate, audit 미기록)
        Object result = pjp.proceed();

        // 4) 정상 종료 시 sa_audit insert (실패해도 원 결과는 반환)
        try {
            insertAudit(serviceName, datasets, result, currentUser);
        } catch (Exception e) {
            log.warn("[admin-audit] insert 실패 service={} : {}", serviceName, e.getMessage());
        }
        return result;
    }

    private void insertAudit(String serviceName, Map<String, Object> datasets, Object result, String currentUser) {
        Map<String, Object> row = new HashMap<>();
        row.put("actorNo", currentUser != null ? currentUser : "unknown");
        row.put("actorName", resolveActorName(currentUser));
        row.put("action", serviceName);
        row.put("targetType", deriveTargetType(serviceName));
        row.put("targetId", deriveTargetId(datasets));
        row.put("beforeJson", toJson(datasets));
        row.put("afterJson", toJson(result));
        row.put("ipAddr", extractIp());
        adminMapper.insertAudit(row);
    }

    private String extractServiceName(ProceedingJoinPoint pjp) {
        try {
            MethodSignature sig = (MethodSignature) pjp.getSignature();
            Method method = sig.getMethod();
            DataSetServiceMapping ann = method.getAnnotation(DataSetServiceMapping.class);
            if (ann == null) {
                // 인터페이스 프록시일 가능성 — 실제 클래스에서 동일 시그니처 메서드 재조회
                Method real = pjp.getTarget().getClass()
                        .getMethod(method.getName(), method.getParameterTypes());
                ann = real.getAnnotation(DataSetServiceMapping.class);
            }
            return ann == null ? null : ann.value();
        } catch (Exception e) {
            return null;
        }
    }

    private String resolveActorName(String currentUser) {
        if (currentUser == null) return "unknown";
        // SecurityContext 의 JWT 에서 한국어 이름이 있으면 사용
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof org.springframework.security.oauth2.jwt.Jwt jwt) {
            String name = jwt.getClaimAsString("name");
            if (name != null && !name.isBlank()) return name;
            String preferred = jwt.getClaimAsString("preferred_username");
            if (preferred != null && !preferred.isBlank()) return preferred;
        }
        return currentUser;
    }

    /**
     * service name 에서 도메인 prefix 추출.
     * "admin/userSave" → "USER", "admin/deptTree" → "DEPT" 등.
     */
    private String deriveTargetType(String serviceName) {
        String tail = serviceName.substring(ADMIN_PREFIX.length()).toLowerCase();
        if (tail.startsWith("user")) return "USER";
        if (tail.startsWith("dept")) return "DEPT";
        if (tail.startsWith("menu")) return "MENU";
        if (tail.startsWith("perm")) return "PERMISSION";
        if (tail.startsWith("code")) return "CODE";
        if (tail.startsWith("audit")) return "AUDIT";
        return "ADMIN";
    }

    /**
     * datasets 에서 단일 PK 후보를 추출한다 (ds_search.xxx 우선, 없으면 ds_xxx.rows[0] 의 첫 PK).
     * 실패해도 null 반환 — audit 는 그대로 진행.
     */
    @SuppressWarnings("unchecked")
    private String deriveTargetId(Map<String, Object> datasets) {
        if (datasets == null) return null;
        // ds_search 우선
        Object ds = datasets.get("ds_search");
        if (ds instanceof Map<?, ?> m) {
            for (String key : new String[]{"employeeId", "deptId", "menuId", "groupCd", "code", "auditId"}) {
                Object v = m.get(key);
                if (v != null) return String.valueOf(v);
            }
        }
        // 다른 ds_* 의 rows[0]
        for (Map.Entry<String, Object> e : datasets.entrySet()) {
            if (e.getValue() instanceof Map<?, ?> dsMap) {
                Object rows = dsMap.get("rows");
                if (rows instanceof java.util.List<?> list && !list.isEmpty() && list.get(0) instanceof Map<?, ?> r) {
                    for (String key : new String[]{"employeeId", "deptId", "menuId", "groupCd"}) {
                        Object v = r.get(key);
                        if (v != null) return String.valueOf(v);
                    }
                }
            }
        }
        return null;
    }

    private String toJson(Object obj) {
        if (obj == null) return null;
        try {
            // 너무 큰 결과는 잘라서 저장 (truncate 표식 추가)
            String json = OM.writeValueAsString(obj);
            if (json.length() > MAX_JSON_LEN) {
                Map<String, Object> truncated = new LinkedHashMap<>();
                truncated.put("__truncated", true);
                truncated.put("__originalLength", json.length());
                truncated.put("preview", json.substring(0, MAX_JSON_LEN));
                return OM.writeValueAsString(truncated);
            }
            return json;
        } catch (JsonProcessingException e) {
            return null;
        }
    }

    private String extractIp() {
        try {
            ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs == null) return null;
            HttpServletRequest req = attrs.getRequest();
            String forwarded = req.getHeader("X-Forwarded-For");
            if (forwarded != null && !forwarded.isBlank()) {
                return forwarded.split(",")[0].trim();
            }
            return req.getRemoteAddr();
        } catch (Exception e) {
            return null;
        }
    }
}
