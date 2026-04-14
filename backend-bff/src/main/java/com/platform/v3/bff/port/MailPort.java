package com.platform.v3.bff.port;

import java.util.List;
import java.util.Map;

public interface MailPort {
    List<Map<String, Object>> listMailbox(String userToken, String folder, int limit);
    Map<String, Object> getThread(String threadId, String userToken);
    Map<String, Object> sendMail(Map<String, Object> payload, String userToken);
    Map<String, Object> saveDraft(Map<String, Object> payload, String userToken);
    void markRead(String messageId, String userToken);
}
