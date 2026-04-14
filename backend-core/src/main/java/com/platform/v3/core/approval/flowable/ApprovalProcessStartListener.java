package com.platform.v3.core.approval.flowable;

import com.platform.v3.core.notification.NotificationService;
import org.flowable.engine.delegate.DelegateExecution;
import org.flowable.engine.delegate.ExecutionListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * 결재 프로세스 시작 리스너 — processInstance start 이벤트에서 호출.
 * 기안 시점에 기안자에게 "상신 완료" 알림을 발송.
 */
@Component("approvalProcessStartListener")
public class ApprovalProcessStartListener implements ExecutionListener {

    private static final Logger log = LoggerFactory.getLogger(ApprovalProcessStartListener.class);

    private final NotificationService notificationService;

    public ApprovalProcessStartListener(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @Override
    public void notify(DelegateExecution execution) {
        Object docIdVar = execution.getVariable("docId");
        Object drafterIdVar = execution.getVariable("drafterId");
        Object docTitleVar = execution.getVariable("docTitle");

        Long docId = docIdVar == null ? null : Long.valueOf(docIdVar.toString());
        Long drafterId = drafterIdVar == null ? 10L : Long.valueOf(drafterIdVar.toString());
        String title = docTitleVar == null ? "결재 문서" : docTitleVar.toString();

        log.info("결재 프로세스 시작: pid={}, docId={}, drafter={}", execution.getProcessInstanceId(), docId, drafterId);
        notificationService.notify(docId, drafterId, "APPROVAL", "WEB",
                "상신 완료 — " + title, "결재가 시작되었습니다");
    }
}
