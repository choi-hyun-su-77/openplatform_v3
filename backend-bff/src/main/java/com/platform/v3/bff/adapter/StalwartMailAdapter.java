package com.platform.v3.bff.adapter;

import com.platform.v3.bff.port.MailPort;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * Stalwart JMAP 어댑터 — 서비스 계정(admin) 으로 JMAP 호출,
 * accountId 를 사용자별로 바꿔 메일함을 프록시한다.
 *
 * Stalwart JMAP 엔드포인트: POST /jmap (RFC 8620)
 */
@Component
public class StalwartMailAdapter implements MailPort {

    private static final Logger log = LoggerFactory.getLogger(StalwartMailAdapter.class);

    private final WebClient client;
    private final String adminUser;
    private final String adminPass;

    public StalwartMailAdapter(@Value("${bff.stalwart.base-url}") String baseUrl,
                               @Value("${bff.stalwart.admin-user}") String adminUser,
                               @Value("${bff.stalwart.admin-pass}") String adminPass) {
        this.adminUser = adminUser;
        this.adminPass = adminPass;
        this.client = WebClient.builder()
                .baseUrl(baseUrl)
                .defaultHeader(HttpHeaders.AUTHORIZATION,
                        "Basic " + Base64.getEncoder().encodeToString(
                                (adminUser + ":" + adminPass).getBytes(StandardCharsets.UTF_8)))
                .build();
    }

    @Override
    public Map<String, Object> getSession(String accountId) {
        try {
            Map<String, Object> session = client.get()
                    .uri("/.well-known/jmap")
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();
            return session != null ? session : Map.of();
        } catch (Exception e) {
            log.warn("JMAP getSession failed: {}", e.getMessage());
            return Map.of("error", e.getMessage());
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> listMailboxes(String accountId) {
        Map<String, Object> request = jmapRequest(accountId, "Mailbox/get", Map.of());
        Map<String, Object> response = callJmap(request);
        return extractRows(response, "Mailbox/get");
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> listEmails(String accountId, String mailboxId, int limit, int offset) {
        // Step 1: Email/query to get IDs
        Map<String, Object> filter = new LinkedHashMap<>();
        if (mailboxId != null && !mailboxId.isBlank()) {
            filter.put("inMailbox", mailboxId);
        }
        Map<String, Object> queryArgs = new LinkedHashMap<>();
        queryArgs.put("filter", filter);
        queryArgs.put("sort", List.of(Map.of("property", "receivedAt", "isAscending", false)));
        queryArgs.put("limit", limit);
        queryArgs.put("position", offset);

        Map<String, Object> queryReq = jmapRequest(accountId, "Email/query", queryArgs);
        Map<String, Object> queryResp = callJmap(queryReq);
        List<String> ids = extractIds(queryResp, "Email/query");
        if (ids.isEmpty()) return List.of();

        // Step 2: Email/get for details
        Map<String, Object> getArgs = new LinkedHashMap<>();
        getArgs.put("ids", ids);
        getArgs.put("properties", List.of("id", "subject", "from", "to", "receivedAt", "size",
                "keywords", "hasAttachment", "preview", "mailboxIds"));
        Map<String, Object> getReq = jmapRequest(accountId, "Email/get", getArgs);
        Map<String, Object> getResp = callJmap(getReq);
        return extractRows(getResp, "Email/get");
    }

    @Override
    @SuppressWarnings("unchecked")
    public Map<String, Object> getEmail(String accountId, String emailId) {
        Map<String, Object> args = new LinkedHashMap<>();
        args.put("ids", List.of(emailId));
        args.put("properties", List.of("id", "subject", "from", "to", "cc", "bcc", "replyTo",
                "receivedAt", "sentAt", "size", "keywords", "hasAttachment",
                "textBody", "htmlBody", "bodyValues", "attachments"));
        args.put("fetchTextBodyValues", true);
        args.put("fetchHTMLBodyValues", true);
        Map<String, Object> req = jmapRequest(accountId, "Email/get", args);
        Map<String, Object> resp = callJmap(req);
        List<Map<String, Object>> rows = extractRows(resp, "Email/get");
        return rows.isEmpty() ? Map.of("error", "not found") : rows.get(0);
    }

    @Override
    @SuppressWarnings("unchecked")
    public Map<String, Object> sendEmail(String accountId, Map<String, Object> payload) {
        // Email/set + EmailSubmission/set
        String draftId = "draft1";
        Map<String, Object> create = new LinkedHashMap<>();
        create.put(draftId, buildEmailObject(payload));

        List<List<Object>> methodCalls = new ArrayList<>();
        methodCalls.add(List.of("Email/set", Map.of("accountId", resolveAccountId(accountId), "create", create), "a"));
        methodCalls.add(List.of("EmailSubmission/set", Map.of(
                "accountId", resolveAccountId(accountId),
                "create", Map.of("sub1", Map.of("emailId", "#draft1"))
        ), "b"));

        Map<String, Object> request = Map.of("using", jmapUsing(), "methodCalls", methodCalls);
        Map<String, Object> resp = callJmap(request);
        return Map.of("success", true, "response", resp);
    }

    @Override
    public Map<String, Object> saveDraft(String accountId, Map<String, Object> payload) {
        Map<String, Object> emailObj = buildEmailObject(payload);
        emailObj.put("keywords", Map.of("$draft", true));
        Map<String, Object> create = Map.of("draft1", emailObj);
        Map<String, Object> args = Map.of("accountId", resolveAccountId(accountId), "create", create);
        Map<String, Object> req = Map.of("using", jmapUsing(), "methodCalls", List.of(List.of("Email/set", args, "a")));
        return callJmap(req);
    }

    @Override
    public void markRead(String accountId, String emailId) {
        Map<String, Object> update = Map.of(emailId, Map.of("keywords/$seen", true));
        Map<String, Object> args = Map.of("accountId", resolveAccountId(accountId), "update", update);
        Map<String, Object> req = Map.of("using", jmapUsing(), "methodCalls", List.of(List.of("Email/set", args, "a")));
        callJmap(req);
    }

    // ===== Helpers =====

    private Map<String, Object> jmapRequest(String accountId, String method, Map<String, Object> extraArgs) {
        Map<String, Object> args = new LinkedHashMap<>(extraArgs);
        args.put("accountId", resolveAccountId(accountId));
        return Map.of("using", jmapUsing(), "methodCalls", List.of(List.of(method, args, "r1")));
    }

    private List<String> jmapUsing() {
        return List.of("urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail", "urn:ietf:params:jmap:submission");
    }

    private String resolveAccountId(String accountId) {
        // Stalwart 에서 accountId 는 보통 이메일 주소 또는 admin 계정의 ID
        // 서비스 계정 방식이므로 admin 의 accountId 를 사용하되, accountId 파라미터로 사용자 지정 가능
        return accountId != null && !accountId.isBlank() ? accountId : adminUser;
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> callJmap(Map<String, Object> request) {
        try {
            return client.post()
                    .uri("/jmap")
                    .bodyValue(request)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();
        } catch (WebClientResponseException e) {
            log.warn("JMAP call failed: {} {}", e.getStatusCode(), e.getResponseBodyAsString());
            return Map.of("error", e.getMessage());
        } catch (Exception e) {
            log.warn("JMAP call error: {}", e.getMessage());
            return Map.of("error", e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> extractRows(Map<String, Object> response, String methodName) {
        try {
            List<List<Object>> calls = (List<List<Object>>) response.get("methodResponses");
            if (calls == null || calls.isEmpty()) return List.of();
            for (List<Object> call : calls) {
                if (call.size() >= 2 && methodName.equals(call.get(0))) {
                    Map<String, Object> data = (Map<String, Object>) call.get(1);
                    List<Map<String, Object>> list = (List<Map<String, Object>>) data.get("list");
                    return list != null ? list : List.of();
                }
            }
        } catch (Exception e) {
            log.warn("extractRows failed for {}: {}", methodName, e.getMessage());
        }
        return List.of();
    }

    @SuppressWarnings("unchecked")
    private List<String> extractIds(Map<String, Object> response, String methodName) {
        try {
            List<List<Object>> calls = (List<List<Object>>) response.get("methodResponses");
            if (calls == null || calls.isEmpty()) return List.of();
            for (List<Object> call : calls) {
                if (call.size() >= 2 && methodName.equals(call.get(0))) {
                    Map<String, Object> data = (Map<String, Object>) call.get(1);
                    List<String> ids = (List<String>) data.get("ids");
                    return ids != null ? ids : List.of();
                }
            }
        } catch (Exception e) {
            log.warn("extractIds failed for {}: {}", methodName, e.getMessage());
        }
        return List.of();
    }

    private Map<String, Object> buildEmailObject(Map<String, Object> payload) {
        Map<String, Object> email = new LinkedHashMap<>();
        email.put("from", List.of(Map.of("email", payload.getOrDefault("from", adminUser + "@v3.local"))));
        Object to = payload.get("to");
        if (to instanceof String) {
            email.put("to", List.of(Map.of("email", to)));
        } else if (to instanceof List) {
            email.put("to", to);
        }
        email.put("subject", payload.getOrDefault("subject", "(No Subject)"));
        String body = (String) payload.getOrDefault("body", "");
        String bodyType = (String) payload.getOrDefault("bodyType", "text/plain");
        email.put("bodyValues", Map.of("1", Map.of("value", body)));
        if ("text/html".equals(bodyType)) {
            email.put("htmlBody", List.of(Map.of("partId", "1", "type", "text/html")));
        } else {
            email.put("textBody", List.of(Map.of("partId", "1", "type", "text/plain")));
        }
        return email;
    }
}
