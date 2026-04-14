package com.platform.v3.bff.adapter;

import com.platform.v3.bff.port.MessagingPort;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

/**
 * Mattermost REST API 어댑터.
 * Keycloak Federation(GitLab OAuth 트릭)으로 발급된 사용자 토큰을 Bearer 로 전달.
 * 미구현 메서드는 Phase 10에서 실제 Mattermost API 호출로 채움.
 */
@Component
public class MattermostAdapter implements MessagingPort {

    private final WebClient client;

    public MattermostAdapter(@Value("${bff.mattermost.base-url}") String baseUrl) {
        this.client = WebClient.builder().baseUrl(baseUrl).build();
    }

    @Override
    public List<Map<String, Object>> listChannels(String userToken) {
        // TODO Phase 10: GET /api/v4/users/me/channels with Bearer
        return List.of();
    }

    @Override
    public List<Map<String, Object>> listMessages(String channelId, String userToken, int limit) {
        return List.of();
    }

    @Override
    public Map<String, Object> postMessage(String channelId, String text, String userToken) {
        return Map.of("channelId", channelId, "text", text, "stub", true);
    }

    @Override
    public Map<String, Object> createDirectChannel(String otherUserId, String userToken) {
        return Map.of("otherUserId", otherUserId, "stub", true);
    }

    @Override
    public String unreadBadge(String userToken) {
        return "0";
    }
}
