package com.platform.v3.core.approval.flowable;

import com.platform.v3.core.approval.mapper.ApprovalMapper;
import com.platform.v3.core.notification.NotificationService;
import org.flowable.engine.delegate.DelegateExecution;
import org.flowable.engine.delegate.JavaDelegate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * 결재 완료 델리게이트 — 전결 endEvent 에서 호출.
 * 문서 상태 APPROVED 로 전이 + 기안자에게 승인 알림.
 */
@Component("approvalCompleteDelegate")
public class ApprovalCompleteDelegate implements JavaDelegate {

    private static final Logger log = LoggerFactory.getLogger(ApprovalCompleteDelegate.class);

    private final ApprovalMapper approvalMapper;
    private final NotificationService notificationService;

    public ApprovalCompleteDelegate(ApprovalMapper approvalMapper, NotificationService notificationService) {
        this.approvalMapper = approvalMapper;
        this.notificationService = notificationService;
    }

    @Override
    public void execute(DelegateExecution execution) {
        Object docIdVar = execution.getVariable("docId");
        if (docIdVar == null) {
            log.warn("docId missing — skip");
            return;
        }
        Long docId = Long.valueOf(docIdVar.toString());
        approvalMapper.updateDocumentStatus(docId, "APPROVED");

        Object drafterIdVar = execution.getVariable("drafterId");
        Long drafterId = drafterIdVar == null ? 10L : Long.valueOf(drafterIdVar.toString());

        log.info("결재 완료: docId={}", docId);
        notificationService.notify(docId, drafterId, "APPROVAL", "WEB",
                "결재 승인 완료", "전결 완료되었습니다");
    }
}
