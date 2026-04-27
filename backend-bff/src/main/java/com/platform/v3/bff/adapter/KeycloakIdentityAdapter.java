package com.platform.v3.bff.adapter;

import com.platform.v3.bff.port.IdentityPort;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.net.URI;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Keycloak Admin REST 어댑터.
 *
 * <h2>토큰 발급 방식</h2>
 * <p>Phase 14 트랙 5 자율 결정: realm-management 클라이언트 client_credentials 가 realm-export 에 없으므로
 * Keycloak 의 기본 master realm 의 <code>admin-cli</code> public client 와 admin/admin 계정을
 * password grant 로 사용하여 admin token 을 발급한다.</p>
 *
 * <p>운영 환경에서는 service-account 가 활성화된 클라이언트(client_credentials grant)를 추가하고
 * 환경변수로 secret 을 주입해야 함 — warn.md 에 기록되어 있음.</p>
 */
@Component
public class KeycloakIdentityAdapter implements IdentityPort {

    private static final Logger log = LoggerFactory.getLogger(KeycloakIdentityAdapter.class);

    private final WebClient client;
    private final String realm;
    private final String adminUrl;
    private final String adminUser;
    private final String adminPass;
    private final String adminClientId;

    public KeycloakIdentityAdapter(
            @Value("${bff.keycloak.admin-url}") String adminUrl,
            @Value("${bff.keycloak.realm}") String realm,
            @Value("${bff.keycloak.admin-user:admin}") String adminUser,
            @Value("${bff.keycloak.admin-pass:admin}") String adminPass,
            @Value("${bff.keycloak.admin-client-id:admin-cli}") String adminClientId) {
        this.client = WebClient.builder().baseUrl(adminUrl).build();
        this.realm = realm;
        this.adminUrl = adminUrl;
        this.adminUser = adminUser;
        this.adminPass = adminPass;
        this.adminClientId = adminClientId;
    }

    @Override
    @SuppressWarnings("unchecked")
    public Map<String, Object> getMe(String accessToken) {
        return client.get()
                .uri("/realms/{realm}/protocol/openid-connect/userinfo", realm)
                .header("Authorization", "Bearer " + accessToken)
                .retrieve()
                .bodyToMono(Map.class)
                .map(m -> (Map<String, Object>) m)
                .onErrorReturn(Map.of("error", "keycloak unavailable"))
                .block();
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<String> getRoles(String accessToken) {
        Map<String, Object> me = getMe(accessToken);
        Object realmAccess = me.get("realm_access");
        if (realmAccess instanceof Map<?, ?> m && m.get("roles") instanceof List<?> roles) {
            return (List<String>) roles;
        }
        return List.of();
    }

    @Override
    public Map<String, Object> getUserById(String userId) {
        try {
            String token = adminToken();
            @SuppressWarnings("unchecked")
            Map<String, Object> result = (Map<String, Object>) client.get()
                    .uri("/admin/realms/{realm}/users/{userId}", realm, userId)
                    .header("Authorization", "Bearer " + token)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();
            return result == null ? Map.of("userId", userId, "stub", true) : result;
        } catch (Exception e) {
            log.warn("getUserById 실패 userId={}: {}", userId, e.getMessage());
            return Map.of("userId", userId, "error", e.getMessage());
        }
    }

    // ─── Phase 14 Track 5: Admin Console ────────────────────────────────────

    @Override
    public Map<String, Object> createUser(Map<String, Object> request) {
        String token = adminToken();
        String username = str(request.get("username"));
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("username required");
        }
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("username", username);
        body.put("email", str(request.get("email")));
        body.put("firstName", str(request.get("firstName")));
        body.put("lastName", str(request.get("lastName")));
        body.put("enabled", true);
        body.put("emailVerified", true);
        // 임시 비밀번호 — temporary=true 로 첫 로그인 시 변경 강제
        String pw = str(request.get("password"));
        if (pw != null && !pw.isBlank()) {
            body.put("credentials", List.of(Map.of(
                    "type", "password",
                    "value", pw,
                    "temporary", true
            )));
        }

        try {
            client.post()
                    .uri("/admin/realms/{realm}/users", realm)
                    .header("Authorization", "Bearer " + token)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(BodyInserters.fromValue(body))
                    .retrieve()
                    .toBodilessEntity()
                    .block();
        } catch (Exception e) {
            log.warn("Keycloak createUser 실패 username={}: {}", username, e.getMessage());
            throw new RuntimeException("Keycloak createUser 실패: " + e.getMessage(), e);
        }

        // 생성된 userId 조회 (username = unique)
        String userId = lookupUserIdByUsername(token, username);
        // role 할당 (있으면)
        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) request.getOrDefault("roles", List.of());
        if (userId != null && roles != null && !roles.isEmpty()) {
            assignRealmRoles(token, userId, roles);
        }
        return Map.of("userId", userId == null ? "" : userId, "username", username);
    }

    @Override
    public Map<String, Object> updateUser(String username, Map<String, Object> request) {
        String token = adminToken();
        String userId = lookupUserIdByUsername(token, username);
        if (userId == null) {
            throw new RuntimeException("Keycloak user not found: " + username);
        }
        Map<String, Object> body = new LinkedHashMap<>();
        if (request.get("email") != null) body.put("email", str(request.get("email")));
        if (request.get("firstName") != null) body.put("firstName", str(request.get("firstName")));
        if (request.get("lastName") != null) body.put("lastName", str(request.get("lastName")));
        try {
            client.put()
                    .uri("/admin/realms/{realm}/users/{userId}", realm, userId)
                    .header("Authorization", "Bearer " + token)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(BodyInserters.fromValue(body))
                    .retrieve()
                    .toBodilessEntity()
                    .block();
        } catch (Exception e) {
            log.warn("Keycloak updateUser 실패 username={}: {}", username, e.getMessage());
            throw new RuntimeException("Keycloak updateUser 실패: " + e.getMessage(), e);
        }
        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) request.get("roles");
        if (roles != null) {
            assignRealmRoles(token, userId, roles);
        }
        return Map.of("userId", userId, "username", username, "updated", true);
    }

    @Override
    public Map<String, Object> setActive(String username, boolean active) {
        String token = adminToken();
        String userId = lookupUserIdByUsername(token, username);
        if (userId == null) {
            throw new RuntimeException("Keycloak user not found: " + username);
        }
        try {
            client.put()
                    .uri("/admin/realms/{realm}/users/{userId}", realm, userId)
                    .header("Authorization", "Bearer " + token)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(BodyInserters.fromValue(Map.of("enabled", active)))
                    .retrieve()
                    .toBodilessEntity()
                    .block();
        } catch (Exception e) {
            log.warn("Keycloak setActive 실패 username={}: {}", username, e.getMessage());
            throw new RuntimeException("Keycloak setActive 실패: " + e.getMessage(), e);
        }
        return Map.of("username", username, "active", active);
    }

    @Override
    public Map<String, Object> resetPassword(String username, String temporaryPassword) {
        String token = adminToken();
        String userId = lookupUserIdByUsername(token, username);
        if (userId == null) {
            throw new RuntimeException("Keycloak user not found: " + username);
        }
        try {
            client.put()
                    .uri("/admin/realms/{realm}/users/{userId}/reset-password", realm, userId)
                    .header("Authorization", "Bearer " + token)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(BodyInserters.fromValue(Map.of(
                            "type", "password",
                            "value", temporaryPassword,
                            "temporary", true
                    )))
                    .retrieve()
                    .toBodilessEntity()
                    .block();
        } catch (Exception e) {
            log.warn("Keycloak resetPassword 실패 username={}: {}", username, e.getMessage());
            throw new RuntimeException("Keycloak resetPassword 실패: " + e.getMessage(), e);
        }
        return Map.of("username", username, "temporaryPassword", temporaryPassword);
    }

    // ─── 내부 유틸 ───────────────────────────────────────────────────────────

    /**
     * master realm 의 admin-cli public client 로 admin/admin password grant 발급.
     * (Phase 14 자율 결정 — realm-management client_credentials 가 realm-export 에 없음)
     */
    private String adminToken() {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            URI uri = URI.create(adminUrl + "/realms/master/protocol/openid-connect/token");
            @SuppressWarnings("unchecked")
            Map<String, Object> resp = (Map<String, Object>) client.post()
                    .uri(uri)
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(BodyInserters.fromFormData("grant_type", "password")
                            .with("client_id", adminClientId)
                            .with("username", adminUser)
                            .with("password", adminPass))
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();
            if (resp == null || resp.get("access_token") == null) {
                throw new RuntimeException("admin token empty");
            }
            return resp.get("access_token").toString();
        } catch (Exception e) {
            log.error("Keycloak admin token 발급 실패: {}", e.getMessage());
            throw new RuntimeException("Keycloak admin token 발급 실패: " + e.getMessage(), e);
        }
    }

    @SuppressWarnings("unchecked")
    private String lookupUserIdByUsername(String token, String username) {
        try {
            List<Map<String, Object>> users = (List<Map<String, Object>>) client.get()
                    .uri(b -> b.path("/admin/realms/{realm}/users")
                            .queryParam("username", username)
                            .queryParam("exact", "true")
                            .build(realm))
                    .header("Authorization", "Bearer " + token)
                    .retrieve()
                    .bodyToMono(List.class)
                    .block();
            if (users == null || users.isEmpty()) return null;
            Object id = users.get(0).get("id");
            return id == null ? null : id.toString();
        } catch (Exception e) {
            log.warn("lookupUserIdByUsername 실패 username={}: {}", username, e.getMessage());
            return null;
        }
    }

    /**
     * realm role 의 representation 을 가져와 사용자에게 일괄 할당한다.
     * 기존 role 은 재할당해도 무해 (Keycloak idempotent).
     */
    @SuppressWarnings("unchecked")
    private void assignRealmRoles(String token, String userId, List<String> roleNames) {
        if (roleNames == null || roleNames.isEmpty()) return;
        try {
            // role representation 조회
            List<Map<String, Object>> reps = new java.util.ArrayList<>();
            for (String name : roleNames) {
                String roleName = name == null ? null : name.replaceFirst("^ROLE_", "");
                if (roleName == null || roleName.isBlank()) continue;
                Map<String, Object> rep = (Map<String, Object>) client.get()
                        .uri("/admin/realms/{realm}/roles/{name}", realm, roleName)
                        .header("Authorization", "Bearer " + token)
                        .retrieve()
                        .bodyToMono(Map.class)
                        .onErrorReturn(new HashMap<>())
                        .block();
                if (rep != null && rep.get("id") != null) {
                    reps.add(rep);
                }
            }
            if (reps.isEmpty()) return;
            client.post()
                    .uri("/admin/realms/{realm}/users/{userId}/role-mappings/realm", realm, userId)
                    .header("Authorization", "Bearer " + token)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(BodyInserters.fromValue(reps))
                    .retrieve()
                    .toBodilessEntity()
                    .block();
        } catch (Exception e) {
            log.warn("assignRealmRoles 실패 userId={} roles={}: {}", userId, roleNames, e.getMessage());
        }
    }

    private static String str(Object o) {
        return o == null ? null : o.toString();
    }
}
