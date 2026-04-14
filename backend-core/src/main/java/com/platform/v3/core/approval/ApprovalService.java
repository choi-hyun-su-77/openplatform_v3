package com.platform.v3.core.approval;

import com.platform.v3.core.approval.mapper.ApprovalMapper;
import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.notification.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 결재 도메인 서비스 — DB(ap_document / ap_approval_line) 기반.
 * 상신 / 승인 / 반려 시 NotificationService.notify() 로 SSE 알림 트리거.
 */
@Service
public class ApprovalService {

    private static final Logger log = LoggerFactory.getLogger(ApprovalService.class);

    private final ApprovalMapper approvalMapper;
    private final NotificationService notificationService;

    public ApprovalService(ApprovalMapper approvalMapper, NotificationService notificationService) {
        this.approvalMapper = approvalMapper;
        this.notificationService = notificationService;
    }

    @DataSetServiceMapping("approval/searchInbox")
    public Map<String, Object> searchInbox(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String boxType = DataSetSupport.toStr(search.get("boxType"));
        String userNo = DataSetSupport.toStr(search.getOrDefault("userNo", "E0032"));
        String keyword = DataSetSupport.toStr(search.get("keyword"));
        if (boxType == null) boxType = "PENDING";
        List<Map<String, Object>> rows = approvalMapper.selectInbox(boxType, userNo, keyword);
        return Map.of("ds_inbox", DataSetSupport.rows(rows));
    }

    @DataSetServiceMapping("approval/searchDetail")
    public Map<String, Object> searchDetail(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long docId = DataSetSupport.toLong(search.get("docId"));
        if (docId == null) throw BusinessException.badRequest("docId required", "docId");
        Map<String, Object> doc = approvalMapper.selectDetail(docId);
        if (doc == null) throw BusinessException.notFound("문서를 찾을 수 없습니다: " + docId);
        List<Map<String, Object>> line = approvalMapper.selectApprovalLine(docId);
        return Map.of(
                "ds_doc",  DataSetSupport.rows(List.of(doc)),
                "ds_line", DataSetSupport.rows(line)
        );
    }

    @DataSetServiceMapping("approval/searchFormTemplates")
    public Map<String, Object> searchFormTemplates(Map<String, Object> datasets, String currentUser) {
        return Map.of("ds_forms", DataSetSupport.rows(approvalMapper.selectFormTemplates()));
    }

    @DataSetServiceMapping("approval/submitDocument")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> submitDocument(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_doc");
        if (ds == null) throw BusinessException.badRequest("ds_doc required", "ds_doc");
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
        if (rows.isEmpty()) throw BusinessException.badRequest("no document rows", null);

        Map<String, Object> row = new HashMap<>(rows.get(0));
        row.putIfAbsent("status", "PENDING");
        row.putIfAbsent("drafterNo", currentUser);
        row.putIfAbsent("drafterName", currentUser);
        approvalMapper.insertDocument(row);
        Long docId = DataSetSupport.toLong(row.get("docId"));

        Long amount = DataSetSupport.toLong(row.get("amount"));
        String formCode = DataSetSupport.toStr(row.get("formCode"));
        List<Map<String, Object>> approvers = approvalMapper.selectApproversForDocFromDmn(amount, formCode);
        int step = 1;
        for (Map<String, Object> ap : approvers) {
            Map<String, Object> line = new HashMap<>();
            line.put("docId", docId);
            line.put("stepOrder", step++);
            line.put("approverNo", ap.get("approverNo"));
            line.put("approverName", ap.get("approverName"));
            line.put("role", ap.get("positionName"));
            line.put("status", "PENDING");
            approvalMapper.insertApprovalLine(line);

            if (step == 2) {
                notificationService.notify(
                        docId, 10L, "APPROVAL", "WEB",
                        "결재 요청 — " + row.get("docTitle"),
                        row.get("drafterName") + "님이 기안했습니다"
                );
            }
        }

        log.info("결재 상신 완료: docId={}, approvers={}", docId, approvers.size());
        return Map.of("docId", docId, "approvers", approvers.size());
    }

    @DataSetServiceMapping("approval/approve")
    @Transactional
    public Map<String, Object> approve(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long lineId = DataSetSupport.toLong(search.get("lineId"));
        Long docId = DataSetSupport.toLong(search.get("docId"));
        String comment = DataSetSupport.toStr(search.get("comment"));
        if (lineId == null || docId == null) {
            throw BusinessException.badRequest("lineId/docId required", null);
        }
        approvalMapper.updateApprovalLineStatus(lineId, "APPROVED", comment);

        List<Map<String, Object>> lines = approvalMapper.selectApprovalLine(docId);
        boolean allApproved = lines.stream().allMatch(l -> "APPROVED".equals(l.get("status")));
        if (allApproved) {
            approvalMapper.updateDocumentStatus(docId, "APPROVED");
            Map<String, Object> doc = approvalMapper.selectDetail(docId);
            notificationService.notify(
                    docId, 10L, "APPROVAL", "WEB",
                    "결재 승인 — " + doc.get("docTitle"),
                    "전결 완료되었습니다"
            );
        } else {
            approvalMapper.updateDocumentStatus(docId, "IN_PROGRESS");
        }
        return Map.of("success", true, "allApproved", allApproved);
    }

    @DataSetServiceMapping("approval/reject")
    @Transactional
    public Map<String, Object> reject(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long lineId = DataSetSupport.toLong(search.get("lineId"));
        Long docId = DataSetSupport.toLong(search.get("docId"));
        String comment = DataSetSupport.toStr(search.get("comment"));
        if (lineId == null || docId == null) {
            throw BusinessException.badRequest("lineId/docId required", null);
        }
        approvalMapper.updateApprovalLineStatus(lineId, "REJECTED", comment);
        approvalMapper.updateDocumentStatus(docId, "REJECTED");
        Map<String, Object> doc = approvalMapper.selectDetail(docId);
        notificationService.notify(
                docId, 10L, "APPROVAL", "WEB",
                "결재 반려 — " + doc.get("docTitle"),
                comment != null ? comment : "반려됨"
        );
        return Map.of("success", true);
    }
}
