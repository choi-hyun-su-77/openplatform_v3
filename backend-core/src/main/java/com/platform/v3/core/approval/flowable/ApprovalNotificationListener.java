package com.platform.v3.core.approval.flowable;

import com.platform.v3.core.notification.NotificationService;
import org.flowable.engine.delegate.DelegateExecution;
import org.flowable.engine.delegate.ExecutionListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * 결재 단계별 범용 알림 리스너 — 각 UserTask start 시점에 할당된 결재자에게 알림.
 */
@Component("approvalNotificationListener")
public class ApprovalNotificationListener implements ExecutionListener {

    private static final Logger log = LoggerFactory.getLogger(ApprovalNotificationListener.class);

    private final NotificationService notificationService;

    public ApprovalNotificationListener(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @Override
    public void notify(DelegateExecution execution) {
        Object docIdVar = execution.getVariable("docId");
        Object approverIdVar = execution.getVariable("currentApproverId");
        Object docTitleVar = execution.getVariable("docTitle");

        if (docIdVar == null || approverIdVar == null) {
            log.debug("skip — missing docId/approverId");
            return;
        }
        Long docId = Long.valueOf(docIdVar.toString());
        Long approverId = Long.valueOf(approverIdVar.toString());
        String title = docTitleVar == null ? "결재 문서" : docTitleVar.toString();

        notificationService.notify(docId, approverId, "APPROVAL", "WEB",
                "결재 요청 — " + title, "결재 차례입니다");
        log.info("결재자 알림 발송: docId={}, approverId={}", docId, approverId);
    }
}
