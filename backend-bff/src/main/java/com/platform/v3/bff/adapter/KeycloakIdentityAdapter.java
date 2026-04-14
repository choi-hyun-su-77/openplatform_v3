package com.platform.v3.bff.adapter;

import com.platform.v3.bff.port.IdentityPort;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

@Component
public class KeycloakIdentityAdapter implements IdentityPort {

    private final WebClient client;
    private final String realm;

    public KeycloakIdentityAdapter(
            @Value("${bff.keycloak.admin-url}") String adminUrl,
            @Value("${bff.keycloak.realm}") String realm) {
        this.client = WebClient.builder().baseUrl(adminUrl).build();
        this.realm = realm;
    }

    @Override
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
        return Map.of("userId", userId, "stub", true);
    }
}
