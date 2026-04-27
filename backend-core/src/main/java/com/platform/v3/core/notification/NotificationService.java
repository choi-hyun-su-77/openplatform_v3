package com.platform.v3.core.notification;

import com.platform.v3.core.common.BffClient;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.notification.mapper.NotificationMapper;
import com.platform.v3.core.org.mapper.OrgMapper;
import com.platform.v3.core.ux.NotifyPrefService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);
    private static final long SSE_TIMEOUT = 30 * 60 * 1000L;

    private final NotificationMapper notificationMapper;
    private final OrgMapper orgMapper;
    private final Map<Long, List<SseEmitter>> emitters = new ConcurrentHashMap<>();

    /**
     * Phase 14 트랙 6 — UX 알림 환경설정 (ux_notify_pref).
     * setter 주입(required=false): 트랙 6 이전 컴파일/통합 환경에서도 도메인이 동작하도록
     * (PORTAL=ON, EMAIL/MESSENGER=OFF 기본값으로 fallback).
     */
    private NotifyPrefService notifyPrefService;
    private BffClient bffClient;

    @Autowired(required = false)
    public void setNotifyPrefService(NotifyPrefService notifyPrefService) {
        this.notifyPrefService = notifyPrefService;
    }

    @Autowired(required = false)
    public void setBffClient(BffClient bffClient) {
        this.bffClient = bffClient;
    }

    public NotificationService(NotificationMapper notificationMapper, OrgMapper orgMapper) {
        this.notificationMapper = notificationMapper;
        this.orgMapper = orgMapper;
    }

    public SseEmitter subscribe(Long userId) {
        SseEmitter emitter = new SseEmitter(SSE_TIMEOUT);
        emitters.computeIfAbsent(userId, k -> new ArrayList<>()).add(emitter);
        emitter.onCompletion(() -> removeEmitter(userId, emitter));
        emitter.onTimeout(() -> removeEmitter(userId, emitter));
        emitter.onError(e -> removeEmitter(userId, emitter));
        try {
            int unreadCount = notificationMapper.countUnread(userId);
            emitter.send(SseEmitter.event().name("init").data(Map.of("unreadCount", unreadCount)));
        } catch (IOException e) {
            log.warn("SSE 초기 데이터 전송 실패: userId={}", userId);
        }
        return emitter;
    }

    public void sendEvent(Long userId, String eventName, Object data) {
        List<SseEmitter> userEmitters = emitters.get(userId);
        if (userEmitters == null || userEmitters.isEmpty()) return;
        List<SseEmitter> dead = new ArrayList<>();
        for (SseEmitter emitter : userEmitters) {
            try {
                emitter.send(SseEmitter.event().name(eventName).data(data));
            } catch (IOException e) {
                dead.add(emitter);
            }
        }
        userEmitters.removeAll(dead);
    }

    private void removeEmitter(Long userId, SseEmitter emitter) {
        List<SseEmitter> list = emitters.get(userId);
        if (list != null) list.remove(emitter);
    }

    @DataSetServiceMapping("notification/searchList")
    public Map<String, Object> searchNotifications(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long recipientId = DataSetSupport.toLong(search.get("recipientId"));
        boolean unreadOnly = Boolean.TRUE.equals(search.get("unreadOnly"));
        int limit = search.get("limit") != null ? ((Number) search.get("limit")).intValue() : 50;
        List<Map<String, Object>> rows = notificationMapper.selectNotifications(recipientId, unreadOnly, limit);
        int unread = notificationMapper.countUnread(recipientId);
        return Map.of(
                "ds_notifications", DataSetSupport.rows(rows),
                "ds_unreadCount", Map.of("count", unread)
        );
    }

    @DataSetServiceMapping("notification/markRead")
    @SuppressWarnings("unchecked")
    public Map<String, Object> markRead(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> ds = (Map<String, Object>) datasets.getOrDefault("ds_notification", Map.of());
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
        for (Map<String, Object> row : rows) {
            Long id = DataSetSupport.toLong(row.get("notificationId"));
            if (id != null) notificationMapper.markAsRead(id);
        }
        return Map.of("success", true);
    }

    @DataSetServiceMapping("notification/markAllRead")
    public Map<String, Object> markAllRead(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long recipientId = DataSetSupport.toLong(search.get("recipientId"));
        if (recipientId != null) notificationMapper.markAllAsRead(recipientId);
        return Map.of("success", true);
    }

    @DataSetServiceMapping("notification/getBadgeCount")
    public Map<String, Object> getBadgeCount(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long recipientId = DataSetSupport.toLong(search.get("recipientId"));
        int count = recipientId != null ? notificationMapper.countUnread(recipientId) : 0;
        return Map.of("ds_badge", DataSetSupport.rows(List.of(Map.of("count", count))));
    }

    public void notify(Long docId, Long recipientId, String type, String channel) {
        notify(docId, recipientId, type, channel, null, null);
    }

    public void notify(Long docId, Long recipientId, String type, String channel, String title, String content) {
        if (recipientId == null) {
            log.warn("notify skipped: recipientId=null docId={} title={}", docId, title);
            return;
        }
        Map<String, Object> row = new HashMap<>();
        row.put("docId", docId);
        row.put("recipientId", recipientId);
        row.put("notificationType", type);
        row.put("channel", channel);
        row.put("title", title);
        row.put("content", content);
        notificationMapper.insertNotification(row);
        sendEvent(recipientId, "notification", Map.of(
                "type", type,
                "docId", docId == null ? 0 : docId,
                "title", title == null ? "" : title,
                "unreadCount", notificationMapper.countUnread(recipientId)
        ));
    }

    /**
     * employee_no 문자열로 수신자를 지정하는 편의 메서드 (기존 시그니처 — 호환성 유지).
     * Phase 14 트랙 6 의 카테고리 분기가 없으므로 PORTAL(SSE) 채널만 발송한다.
     * <p>ApprovalService/BoardService 등 기존 호출자는 본 메서드를 변경 없이 사용한다.
     */
    public void notifyByUserNo(String recipientUserNo, Long docId, String type, String channel,
                               String title, String content) {
        notifyByUserNo(recipientUserNo, docId, type, channel, title, content, null);
    }

    /**
     * Phase 14 트랙 6 — 카테고리 인자 추가 오버로드.
     *
     * <p>category 가 null 이면 기존과 동일하게 PORTAL(SSE) 채널만 발송 (기존 호출자 호환).
     * <p>category 가 있으면 {@link NotifyPrefService} 로 사용자 환경설정 매트릭스를 조회하여
     * <ul>
     *   <li>PORTAL    enabled → SSE + DB insert (기존 동작)</li>
     *   <li>EMAIL     enabled → BFF /api/bff/mail/send 호출 (실패 시 warn)</li>
     *   <li>MESSENGER enabled → BffClient.sendNotificationDm (현재 stub, warn 후 스킵)</li>
     * </ul>
     *
     * @param category UX 카테고리 (APPROVAL|BOARD|CALENDAR|MENTION|ROOM|LEAVE) — null 가능
     */
    public void notifyByUserNo(String recipientUserNo, Long docId, String type, String channel,
                               String title, String content, String category) {
        if (recipientUserNo == null || recipientUserNo.isBlank()) {
            log.warn("notifyByUserNo skipped: recipientUserNo is blank docId={}", docId);
            return;
        }
        Map<String, Object> emp = orgMapper.findEmployeeByNo(recipientUserNo);
        if (emp == null) {
            log.warn("notifyByUserNo skipped: employee not found userNo={} docId={}", recipientUserNo, docId);
            return;
        }
        Long employeeId = DataSetSupport.toLong(
                emp.get("employee_id") != null ? emp.get("employee_id") : emp.get("employeeId"));

        // category 가 없거나 NotifyPrefService 미주입(트랙 6 이전 환경) 이면 기존 PORTAL 만 발송.
        if (category == null || notifyPrefService == null) {
            notify(docId, employeeId, type, channel, title, content);
            return;
        }

        // ─── PORTAL (SSE + DB insert) ─────────────────────────────────────
        if (notifyPrefService.isChannelEnabled(recipientUserNo, category, "PORTAL")) {
            notify(docId, employeeId, type, channel, title, content);
        } else {
            log.debug("PORTAL 채널 비활성 — userNo={} category={}", recipientUserNo, category);
        }

        // ─── EMAIL (BFF /api/bff/mail/send) ───────────────────────────────
        if (notifyPrefService.isChannelEnabled(recipientUserNo, category, "EMAIL")) {
            String toEmail = String.valueOf(emp.getOrDefault("email", ""));
            if (toEmail != null && !toEmail.isBlank() && bffClient != null) {
                String subject = title != null ? title : "[알림]";
                String body = (content != null ? content : "") + "\n\n— openplatform v3";
                bffClient.sendNotificationEmail(toEmail, subject, body);
            } else {
                log.warn("EMAIL 채널 enabled 이지만 발송 스킵 — userNo={} email={} bff={}",
                        recipientUserNo, toEmail, bffClient != null);
            }
        }

        // ─── MESSENGER (Rocket.Chat DM) ────────────────────────────────────
        // 현재 RocketChatAdapter.sendDm 미구현 — 활성이어도 warn 후 스킵.
        if (notifyPrefService.isChannelEnabled(recipientUserNo, category, "MESSENGER")) {
            String username = String.valueOf(emp.getOrDefault("keycloak_user_id",
                    emp.getOrDefault("keycloakUserId", recipientUserNo)));
            if (bffClient != null) {
                bffClient.sendNotificationDm(username, title + " - " + content);
            }
            log.warn("MESSENGER 채널은 RocketChatAdapter.sendDm 미구현 — userNo={} skipped",
                    recipientUserNo);
        }
    }
}
