package com.platform.v3.bff.port;

import java.util.List;
import java.util.Map;

public interface MailPort {
    /** JMAP Session → accountId + mailbox 목록 */
    Map<String, Object> getSession(String accountId);

    /** 메일함 목록 (INBOX, Sent, Drafts, Trash 등) */
    List<Map<String, Object>> listMailboxes(String accountId);

    /** 메일 목록 (mailboxId 기준, limit/offset) */
    List<Map<String, Object>> listEmails(String accountId, String mailboxId, int limit, int offset);

    /** 메일 상세 (본문 포함) */
    Map<String, Object> getEmail(String accountId, String emailId);

    /** 메일 발송 */
    Map<String, Object> sendEmail(String accountId, Map<String, Object> payload);

    /** 임시저장 */
    Map<String, Object> saveDraft(String accountId, Map<String, Object> payload);

    /** 읽음 처리 */
    void markRead(String accountId, String emailId);
}
