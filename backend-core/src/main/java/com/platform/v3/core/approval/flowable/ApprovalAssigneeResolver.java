package com.platform.v3.core.approval.flowable;

import com.platform.v3.core.approval.mapper.ApprovalMapper;
import org.flowable.engine.delegate.DelegateExecution;
import org.flowable.engine.delegate.JavaDelegate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

/**
 * 결재자 자동 해석 델리게이트 — BusinessRuleTask 대체용.
 * amount/formCode 변수를 읽어 ApprovalMapper.selectApproversForDocFromDmn() 호출 → approverList 변수 저장.
 */
@Component("approvalAssigneeResolver")
public class ApprovalAssigneeResolver implements JavaDelegate {

    private static final Logger log = LoggerFactory.getLogger(ApprovalAssigneeResolver.class);

    private final ApprovalMapper approvalMapper;

    public ApprovalAssigneeResolver(ApprovalMapper approvalMapper) {
        this.approvalMapper = approvalMapper;
    }

    @Override
    public void execute(DelegateExecution execution) {
        Object amountVar = execution.getVariable("amount");
        Object formCodeVar = execution.getVariable("formCode");
        Long amount = amountVar == null ? null : Long.valueOf(amountVar.toString());
        String formCode = formCodeVar == null ? null : formCodeVar.toString();

        List<Map<String, Object>> approvers = approvalMapper.selectApproversForDocFromDmn(amount, formCode);
        execution.setVariable("approverList", approvers);
        execution.setVariable("approverCount", approvers.size());

        if (!approvers.isEmpty()) {
            execution.setVariable("firstApproverNo", approvers.get(0).get("approverNo"));
            execution.setVariable("firstApproverName", approvers.get(0).get("approverName"));
        }
        log.info("결재자 해석 완료: amount={}, formCode={}, count={}", amount, formCode, approvers.size());
    }
}
