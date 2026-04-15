package com.platform.v3.bff.adapter;

import com.platform.v3.bff.port.MessagingPort;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

/**
 * Rocket.Chat REST API 어댑터.
 *
 * 인증 방식: Keycloak SSO 로 Rocket.Chat 에 로그인 후 발급되는 personal access token
 * 또는 관리자 토큰을 헤더로 전달. 사용자 범위 호출은 X-Auth-Token / X-User-Id 헤더 쌍 사용.
 *
 * 참고 엔드포인트 (v6.x):
 *  - GET  /api/v1/channels.list.joined
 *  - GET  /api/v1/channels.history?roomId=...
 *  - POST /api/v1/chat.postMessage   { channel, text }
 *  - POST /api/v1/im.create          { username }
 *  - GET  /api/v1/subscriptions.getAll   (unread badge용)
 *
 * 현재는 stub. Phase 10 에서 실제 호출로 구체화.
 */
@Component
public class RocketChatAdapter implements MessagingPort {

    private final WebClient client;

    public RocketChatAdapter(@Value("${bff.rocketchat.base-url}") String baseUrl) {
        this.client = WebClient.builder().baseUrl(baseUrl).build();
    }

    @Override
    public List<Map<String, Object>> listChannels(String userToken) {
        // TODO Phase 10: GET /api/v1/channels.list.joined
        return List.of();
    }

    @Override
    public List<Map<String, Object>> listMessages(String channelId, String userToken, int limit) {
        // TODO Phase 10: GET /api/v1/channels.history?roomId=...&count=...
        return List.of();
    }

    @Override
    public Map<String, Object> postMessage(String channelId, String text, String userToken) {
        // TODO Phase 10: POST /api/v1/chat.postMessage
        return Map.of("channelId", channelId, "text", text, "stub", true);
    }

    @Override
    public Map<String, Object> createDirectChannel(String otherUserId, String userToken) {
        // TODO Phase 10: POST /api/v1/im.create { username: otherUserId }
        return Map.of("otherUserId", otherUserId, "stub", true);
    }

    @Override
    public String unreadBadge(String userToken) {
        // TODO Phase 10: sum unread from /api/v1/subscriptions.getAll
        return "0";
    }
}
