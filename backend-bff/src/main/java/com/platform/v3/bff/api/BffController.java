package com.platform.v3.bff.api;

import com.platform.v3.bff.port.*;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bff")
public class BffController {

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

    @GetMapping("/mail/mailbox")
    public List<Map<String, Object>> mailbox(@RequestParam(defaultValue = "INBOX") String folder,
                                             @RequestParam(defaultValue = "50") int limit,
                                             JwtAuthenticationToken auth) {
        return mailPort.listMailbox(token(auth), folder, limit);
    }

    @PostMapping("/mail/send")
    public Map<String, Object> sendMail(@RequestBody Map<String, Object> body,
                                        JwtAuthenticationToken auth) {
        return mailPort.sendMail(body, token(auth));
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
        return Map.of("token", token, "room", room);
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
