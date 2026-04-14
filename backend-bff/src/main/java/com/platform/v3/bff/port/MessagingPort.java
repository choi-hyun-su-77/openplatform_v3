package com.platform.v3.bff.port;

import java.util.List;
import java.util.Map;

public interface MessagingPort {
    List<Map<String, Object>> listChannels(String userToken);
    List<Map<String, Object>> listMessages(String channelId, String userToken, int limit);
    Map<String, Object> postMessage(String channelId, String text, String userToken);
    Map<String, Object> createDirectChannel(String otherUserId, String userToken);
    String unreadBadge(String userToken);
}
