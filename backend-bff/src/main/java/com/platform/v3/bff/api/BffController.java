package com.platform.v3.bff.api;

import com.platform.v3.bff.port.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bff")
public class BffController {

    @Value("${livekit.public-ws-url:ws://localhost:19880}")
    private String livekitPublicWsUrl;

    private final IdentityPort identityPort;
    private final MessagingPort messagingPort;
    private final MailPort mailPort;
    private final WikiPort wikiPort;
    private final VideoPort videoPort;
    private final StoragePort storagePort;

    public BffController(IdentityPort identityPort,
                         MessagingPort messagingPort,
                         MailPort mailPort,
                         WikiPort wikiPort,
                         VideoPort videoPort,
                         StoragePort storagePort) {
        this.identityPort = identityPort;
        this.messagingPort = messagingPort;
        this.mailPort = mailPort;
        this.wikiPort = wikiPort;
        this.videoPort = videoPort;
        this.storagePort = storagePort;
    }

    @GetMapping("/identity/me")
    public Map<String, Object> me(JwtAuthenticationToken auth) {
        return identityPort.getMe(token(auth));
    }

    // ─── Phase 14 Track 5: Admin Identity (ROLE_ADMIN only) ──────────────────
    @PostMapping("/identity/users")
    public Map<String, Object> createUser(@RequestBody Map<String, Object> body, JwtAuthenticationToken auth) {
        requireAdmin(auth);
        return identityPort.createUser(body);
    }

    @PutMapping("/identity/users/{username}")
    public Map<String, Object> updateUser(@PathVariable String username,
                                          @RequestBody Map<String, Object> body,
                                          JwtAuthenticationToken auth) {
        requireAdmin(auth);
        return identityPort.updateUser(username, body);
    }

    @PutMapping("/identity/users/{username}/active")
    public Map<String, Object> setUserActive(@PathVariable String username,
                                             @RequestBody Map<String, Object> body,
                                             JwtAuthenticationToken auth) {
        requireAdmin(auth);
        boolean active = Boolean.TRUE.equals(body.get("active"));
        return identityPort.setActive(username, active);
    }

    @PostMapping("/identity/users/{username}/reset-password")
    public Map<String, Object> resetPassword(@PathVariable String username,
                                             @RequestBody Map<String, Object> body,
                                             JwtAuthenticationToken auth) {
        requireAdmin(auth);
        String temp = (String) body.getOrDefault("temporaryPassword", "temp123!");
        return identityPort.resetPassword(username, temp);
    }

    @SuppressWarnings("unchecked")
    private void requireAdmin(JwtAuthenticationToken auth) {
        if (auth == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        Jwt jwt = (Jwt) auth.getPrincipal();
        Map<String, Object> realmAccess = jwt.getClaimAsMap("realm_access");
        if (realmAccess != null) {
            Object roles = realmAccess.get("roles");
            if (roles instanceof List<?> list) {
                for (Object r : list) {
                    String s = String.valueOf(r);
                    if ("ROLE_ADMIN".equals(s) || "ADMIN".equals(s)) return;
                }
            }
        }
        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "ROLE_ADMIN required");
    }

    @GetMapping("/messenger/channels")
    public List<Map<String, Object>> channels(JwtAuthenticationToken auth) {
        return messagingPort.listChannels(token(auth));
    }

    @GetMapping("/messenger/messages")
    public List<Map<String, Object>> messages(@RequestParam String channelId,
                                              @RequestParam(defaultValue = "50") int limit,
                                              JwtAuthenticationToken auth) {
        return messagingPort.listMessages(channelId, token(auth), limit);
    }

    @PostMapping("/messenger/messages")
    public Map<String, Object> postMessage(@RequestBody Map<String, Object> body,
                                           JwtAuthenticationToken auth) {
        return messagingPort.postMessage((String) body.get("channelId"), (String) body.get("text"), token(auth));
    }

    @GetMapping("/mail/session")
    public Map<String, Object> mailSession(JwtAuthenticationToken auth) {
        return mailPort.getSession(mailAccountId(auth));
    }

    @GetMapping("/mail/mailboxes")
    public List<Map<String, Object>> mailboxes(JwtAuthenticationToken auth) {
        return mailPort.listMailboxes(mailAccountId(auth));
    }

    @GetMapping("/mail/emails")
    public List<Map<String, Object>> emails(@RequestParam(required = false) String mailboxId,
                                            @RequestParam(defaultValue = "50") int limit,
                                            @RequestParam(defaultValue = "0") int offset,
                                            JwtAuthenticationToken auth) {
        return mailPort.listEmails(mailAccountId(auth), mailboxId, limit, offset);
    }

    @GetMapping("/mail/email/{emailId}")
    public Map<String, Object> emailDetail(@PathVariable String emailId, JwtAuthenticationToken auth) {
        mailPort.markRead(mailAccountId(auth), emailId);
        return mailPort.getEmail(mailAccountId(auth), emailId);
    }

    @PostMapping("/mail/send")
    public Map<String, Object> sendMail(@RequestBody Map<String, Object> body, JwtAuthenticationToken auth) {
        return mailPort.sendEmail(mailAccountId(auth), body);
    }

    @PostMapping("/mail/draft")
    public Map<String, Object> saveDraft(@RequestBody Map<String, Object> body, JwtAuthenticationToken auth) {
        return mailPort.saveDraft(mailAccountId(auth), body);
    }

    /** Keycloak username → Stalwart accountId 매핑 (서비스 계정 방식) */
    private String mailAccountId(JwtAuthenticationToken auth) {
        return username(auth);
    }

    @GetMapping("/messenger/unread")
    public Map<String, Object> messengerUnread(JwtAuthenticationToken auth) {
        String count = messagingPort.unreadBadge(token(auth));
        return Map.of("unreadCount", Integer.parseInt(count));
    }

    @GetMapping("/wiki/search")
    public List<Map<String, Object>> wikiSearch(@RequestParam String keyword, JwtAuthenticationToken auth) {
        return wikiPort.searchPages(keyword, token(auth));
    }

    @GetMapping("/wiki/page")
    public Map<String, Object> wikiPage(@RequestParam String pageId, JwtAuthenticationToken auth) {
        return wikiPort.getPage(pageId, token(auth));
    }

    @PostMapping("/video/room")
    public Map<String, Object> createRoom(@RequestBody Map<String, Object> body, JwtAuthenticationToken auth) {
        return videoPort.createRoom((String) body.get("roomName"), username(auth));
    }

    @PostMapping("/video/token")
    public Map<String, Object> issueVideoToken(@RequestBody Map<String, Object> body, JwtAuthenticationToken auth) {
        String room = (String) body.get("roomName");
        boolean canPublish = Boolean.TRUE.equals(body.getOrDefault("canPublish", true));
        String token = videoPort.issueToken(room, username(auth), canPublish);
        return Map.of("token", token, "room", room, "wsUrl", livekitPublicWsUrl);
    }

    /**
     * 브라우저가 LiveKit 서버에 직접 연결할 WebSocket 엔드포인트를 반환한다.
     * 백엔드는 docker 내부 http://livekit:7880 을 알지만, 브라우저는 ws://localhost:19880 을
     * 사용해야 하므로 환경변수 LIVEKIT_PUBLIC_WS_URL 을 별도로 노출한다.
     */
    @GetMapping("/video/config")
    public Map<String, Object> videoConfig() {
        return Map.of("wsUrl", livekitPublicWsUrl);
    }

    @GetMapping("/storage/presigned")
    public Map<String, Object> presigned(@RequestParam String object,
                                         @RequestParam(defaultValue = "GET") String op,
                                         @RequestParam(defaultValue = "300") int expire) {
        String url = "PUT".equalsIgnoreCase(op)
                ? storagePort.presignedPutUrl(object, expire)
                : storagePort.presignedGetUrl(object, expire);
        return Map.of("url", url, "object", object);
    }

    private String token(JwtAuthenticationToken auth) {
        if (auth == null) return null;
        Jwt jwt = (Jwt) auth.getPrincipal();
        return jwt.getTokenValue();
    }

    private String username(JwtAuthenticationToken auth) {
        if (auth == null) return "anonymous";
        Jwt jwt = (Jwt) auth.getPrincipal();
        String u = jwt.getClaimAsString("preferred_username");
        return u != null ? u : jwt.getSubject();
    }
}
