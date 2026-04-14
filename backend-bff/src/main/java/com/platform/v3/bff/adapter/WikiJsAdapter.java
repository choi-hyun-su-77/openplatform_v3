package com.platform.v3.bff.adapter;

import com.platform.v3.bff.port.WikiPort;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

/**
 * Wiki.js GraphQL 어댑터. Phase 11 에서 GraphQL 쿼리 바인딩.
 */
@Component
public class WikiJsAdapter implements WikiPort {

    private final WebClient client;

    public WikiJsAdapter(@Value("${bff.wikijs.base-url}") String baseUrl) {
        this.client = WebClient.builder().baseUrl(baseUrl).build();
    }

    @Override
    public List<Map<String, Object>> searchPages(String keyword, String userToken) {
        return List.of();
    }

    @Override
    public Map<String, Object> getPage(String pageId, String userToken) {
        return Map.of("pageId", pageId, "stub", true);
    }

    @Override
    public Map<String, Object> savePage(Map<String, Object> payload, String userToken) {
        return Map.of("stub", true);
    }

    @Override
    public List<Map<String, Object>> getHistory(String pageId, String userToken) {
        return List.of();
    }
}
