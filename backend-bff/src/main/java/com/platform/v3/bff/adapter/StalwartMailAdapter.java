package com.platform.v3.bff.adapter;

import com.platform.v3.bff.port.MailPort;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

/**
 * Stalwart JMAP/REST 어댑터. Phase 11 에서 실제 JMAP 호출로 구체화.
 */
@Component
public class StalwartMailAdapter implements MailPort {

    private final WebClient client;

    public StalwartMailAdapter(@Value("${bff.stalwart.base-url}") String baseUrl) {
        this.client = WebClient.builder().baseUrl(baseUrl).build();
    }

    @Override
    public List<Map<String, Object>> listMailbox(String userToken, String folder, int limit) {
        return List.of();
    }

    @Override
    public Map<String, Object> getThread(String threadId, String userToken) {
        return Map.of("threadId", threadId, "stub", true);
    }

    @Override
    public Map<String, Object> sendMail(Map<String, Object> payload, String userToken) {
        return Map.of("stub", true, "payload", payload);
    }

    @Override
    public Map<String, Object> saveDraft(Map<String, Object> payload, String userToken) {
        return Map.of("stub", true);
    }

    @Override
    public void markRead(String messageId, String userToken) {
    }
}
