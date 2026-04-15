package com.platform.v3.bff.port;

import java.util.List;
import java.util.Map;

/**
 * 알림 센터 Port.
 *
 * 다운스트림 구현체(backend-core /api/notification SSE, 또는 외부 push 서비스)에
 * 의존하지 않도록 BFF 수준에서 추상화한다. 현재 adapter 는 backend-core 로
 * HTTP 위임하는 패스스루 형태.
 */
public interface NotificationPort {

    /** 사용자의 미확인 알림 목록 (최신순 N개). */
    List<Map<String, Object>> listRecent(String bearerToken, int limit);

    /** 알림 단건을 읽음 처리. */
    Map<String, Object> markRead(String notificationId, String bearerToken);

    /** 전체 읽음 처리. */
    Map<String, Object> markAllRead(String bearerToken);

    /** 미확인 알림 카운트 (dashboard 위젯용). */
    long unreadCount(String bearerToken);
}
