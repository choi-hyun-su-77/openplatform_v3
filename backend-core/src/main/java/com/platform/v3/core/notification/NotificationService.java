package com.platform.v3.core.notification;

import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.notification.mapper.NotificationMapper;
import com.platform.v3.core.org.mapper.OrgMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
     * employee_no 문자열로 수신자를 지정하는 편의 메서드.
     * OrgMapper 로 employee_id 를 조회하여 {@link #notify(Long, Long, String, String, String, String)} 호출.
     * ApprovalService/BoardService 등 도메인 서비스는 drafter_no / approver_no (문자열) 만 갖고 있으므로
     * 이 메서드로 SSE 수신자 ID 를 명시적으로 매핑한다.
     */
    public void notifyByUserNo(String recipientUserNo, Long docId, String type, String channel,
                               String title, String content) {
        if (recipientUserNo == null || recipientUserNo.isBlank()) {
            log.warn("notifyByUserNo skipped: recipientUserNo is blank docId={}", docId);
            return;
        }
        Map<String, Object> emp = orgMapper.findEmployeeByNo(recipientUserNo);
        if (emp == null) {
            log.warn("notifyByUserNo skipped: employee not found userNo={} docId={}", recipientUserNo, docId);
            return;
        }
        Long employeeId = DataSetSupport.toLong(emp.get("employee_id"));
        notify(docId, employeeId, type, channel, title, content);
    }
}
