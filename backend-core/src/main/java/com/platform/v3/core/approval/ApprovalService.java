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
                // 첫 결재자(step=1) 에게 SSE 알림
                notificationService.notifyByUserNo(
                        String.valueOf(ap.get("approverNo")),
                        docId, "APPROVAL", "WEB",
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
            notificationService.notifyByUserNo(
                    String.valueOf(doc.get("drafterNo")),
                    docId, "APPROVAL", "WEB",
                    "결재 승인 — " + doc.get("docTitle"),
                    "전결 완료되었습니다"
            );
        } else {
            approvalMapper.updateDocumentStatus(docId, "IN_PROGRESS");
            // 다음 단계 결재자에게 알림
            lines.stream()
                    .filter(l -> "PENDING".equals(l.get("status")))
                    .min((a, b) -> DataSetSupport.toLong(a.get("stepOrder")).compareTo(DataSetSupport.toLong(b.get("stepOrder"))))
                    .ifPresent(next -> {
                        Map<String, Object> doc = approvalMapper.selectDetail(docId);
                        notificationService.notifyByUserNo(
                                String.valueOf(next.get("approverNo")),
                                docId, "APPROVAL", "WEB",
                                "결재 요청 — " + doc.get("docTitle"),
                                "결재 차례입니다"
                        );
                    });
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
        notificationService.notifyByUserNo(
                String.valueOf(doc.get("drafterNo")),
                docId, "APPROVAL", "WEB",
                "결재 반려 — " + doc.get("docTitle"),
                comment != null ? comment : "반려됨"
        );
        recordHistory(docId, lineId, "REJECT", currentUser, comment);
        return Map.of("success", true);
    }

    // ============================================================
    // Phase A 신규 액션: withdraw / resubmit / delegate / countPending
    // ============================================================

    /**
     * 회수 — 기안자가 PENDING/IN_PROGRESS 상태의 자기 문서를 DRAFT 로 되돌림.
     * 결재선 status 도 모두 PENDING 으로 초기화 (재상신 시 재사용 가능).
     */
    @DataSetServiceMapping("approval/withdraw")
    @Transactional
    public Map<String, Object> withdraw(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long docId = DataSetSupport.toLong(search.get("docId"));
        if (docId == null) throw BusinessException.badRequest("docId required", "docId");

        Map<String, Object> doc = approvalMapper.selectDetail(docId);
        if (doc == null) throw BusinessException.notFound("문서를 찾을 수 없습니다: " + docId);
        if (!String.valueOf(doc.get("drafterNo")).equals(currentUser)) {
            throw BusinessException.forbidden("기안자만 회수할 수 있습니다");
        }
        String status = String.valueOf(doc.get("status"));
        if (!"PENDING".equals(status) && !"IN_PROGRESS".equals(status)) {
            throw BusinessException.badRequest("회수 가능한 상태가 아닙니다: " + status, "status");
        }

        approvalMapper.updateDocumentStatus(docId, "DRAFT");
        approvalMapper.resetLinesForWithdraw(docId);
        recordHistory(docId, null, "WITHDRAW", currentUser, null);
        log.info("결재 회수: docId={}, by={}", docId, currentUser);
        return Map.of("success", true);
    }

    /**
     * 재상신 — REJECTED 문서를 복제하여 새 문서 생성, 결재선 재산출, PENDING 으로 시작.
     * 원본은 그대로 유지 (parent_doc_id 로 추적).
     */
    @DataSetServiceMapping("approval/resubmit")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> resubmit(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long sourceDocId = DataSetSupport.toLong(search.get("docId"));
        if (sourceDocId == null) throw BusinessException.badRequest("docId required", "docId");
        String newContent = DataSetSupport.toStr(search.get("content"));
        Long newAmount = DataSetSupport.toLong(search.get("amount"));
        String newTitle = DataSetSupport.toStr(search.get("docTitle"));

        Map<String, Object> source = approvalMapper.selectDetail(sourceDocId);
        if (source == null) throw BusinessException.notFound("원본 문서 없음: " + sourceDocId);
        if (!String.valueOf(source.get("drafterNo")).equals(currentUser)) {
            throw BusinessException.forbidden("기안자만 재상신할 수 있습니다");
        }
        if (!"REJECTED".equals(String.valueOf(source.get("status")))) {
            throw BusinessException.badRequest("REJECTED 상태에서만 재상신 가능합니다", "status");
        }

        Map<String, Object> cloneRow = new HashMap<>();
        cloneRow.put("sourceDocId", sourceDocId);
        cloneRow.put("content", newContent);
        cloneRow.put("amount", newAmount);
        approvalMapper.cloneDocumentForResubmit(cloneRow);
        Long newDocId = DataSetSupport.toLong(cloneRow.get("docId"));

        if (newTitle != null) {
            approvalMapper.updateDocumentContent(newDocId, null, null, newTitle);
        }

        // 결재선 재산출
        Long amount = newAmount != null ? newAmount : DataSetSupport.toLong(source.get("amount"));
        String formCode = DataSetSupport.toStr(source.get("formCode"));
        List<Map<String, Object>> approvers = approvalMapper.selectApproversForDocFromDmn(amount, formCode);
        int step = 1;
        for (Map<String, Object> ap : approvers) {
            Map<String, Object> line = new HashMap<>();
            line.put("docId", newDocId);
            line.put("stepOrder", step++);
            line.put("approverNo", ap.get("approverNo"));
            line.put("approverName", ap.get("approverName"));
            line.put("role", ap.get("positionName"));
            line.put("status", "PENDING");
            approvalMapper.insertApprovalLine(line);
        }
        if (!approvers.isEmpty()) {
            notificationService.notifyByUserNo(
                    String.valueOf(approvers.get(0).get("approverNo")),
                    newDocId, "APPROVAL", "WEB",
                    "결재 요청(재상신) — " + source.get("docTitle"),
                    source.get("drafterName") + "님이 재상신했습니다"
            );
        }
        recordHistory(newDocId, null, "RESUBMIT", currentUser, "원본 docId=" + sourceDocId);
        log.info("결재 재상신: source={}, new={}", sourceDocId, newDocId);
        return Map.of("success", true, "newDocId", newDocId, "approvers", approvers.size());
    }

    /**
     * 대결 등록 — 부재 기간 동안 다른 사용자가 대신 결재하도록 위임.
     * approve/reject 에서 acted_by_no 에 실제 결재자(대리인) 기록은 후속 작업.
     */
    @DataSetServiceMapping("approval/delegate")
    @Transactional
    public Map<String, Object> delegate(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String delegatee = DataSetSupport.toStr(search.get("delegateeNo"));
        String reason = DataSetSupport.toStr(search.get("reason"));
        String fromDate = DataSetSupport.toStr(search.get("fromDate"));
        String toDate = DataSetSupport.toStr(search.get("toDate"));
        if (delegatee == null || fromDate == null || toDate == null) {
            throw BusinessException.badRequest("delegateeNo/fromDate/toDate 필수", null);
        }
        Map<String, Object> row = new HashMap<>();
        row.put("delegatorNo", currentUser);
        row.put("delegateeNo", delegatee);
        row.put("reason", reason);
        row.put("fromDate", fromDate);
        row.put("toDate", toDate);
        approvalMapper.insertDelegation(row);
        log.info("대결 등록: {} → {} ({}~{})", currentUser, delegatee, fromDate, toDate);
        return Map.of("success", true);
    }

    /**
     * 첨부 등록 — UI 가 MinIO presigned PUT 으로 업로드 완료 후 BFF/이 메서드에 메타 저장.
     * 입력: ds_search.{docId, objectKey, filename, sizeBytes, mimeType}
     */
    @DataSetServiceMapping("approval/uploadAttachment")
    @Transactional
    public Map<String, Object> uploadAttachment(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long docId = DataSetSupport.toLong(search.get("docId"));
        String objectKey = DataSetSupport.toStr(search.get("objectKey"));
        String filename = DataSetSupport.toStr(search.get("filename"));
        Long sizeBytes = DataSetSupport.toLong(search.get("sizeBytes"));
        String mimeType = DataSetSupport.toStr(search.get("mimeType"));
        if (docId == null || objectKey == null || filename == null) {
            throw BusinessException.badRequest("docId/objectKey/filename 필수", null);
        }
        Map<String, Object> row = new HashMap<>();
        row.put("docId", docId);
        row.put("objectKey", objectKey);
        row.put("filename", filename);
        row.put("sizeBytes", sizeBytes != null ? sizeBytes : 0L);
        row.put("mimeType", mimeType);
        row.put("uploaderNo", currentUser);
        approvalMapper.insertAttachment(row);
        return Map.of("success", true, "attachId", row.get("attachId"));
    }

    /** 첨부 목록 — 상세 다이얼로그 "첨부" 탭에서 호출 */
    @DataSetServiceMapping("approval/listAttachments")
    public Map<String, Object> listAttachments(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long docId = DataSetSupport.toLong(search.get("docId"));
        if (docId == null) throw BusinessException.badRequest("docId required", "docId");
        return Map.of("ds_attachments", DataSetSupport.rows(approvalMapper.selectAttachmentsByDoc(docId)));
    }

    /** 미결 결재 카운트 — 대시보드 위젯 / 헤더 벨 용 */
    @DataSetServiceMapping("approval/countPending")
    public Map<String, Object> countPending(Map<String, Object> datasets, String currentUser) {
        int count = approvalMapper.countPendingForUser(currentUser);
        return Map.of("ds_count", DataSetSupport.rows(List.of(Map.of("count", count))));
    }

    /** 결재 이력 조회 (상세 다이얼로그 "이력" 탭) */
    @DataSetServiceMapping("approval/searchHistory")
    public Map<String, Object> searchHistory(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long docId = DataSetSupport.toLong(search.get("docId"));
        if (docId == null) throw BusinessException.badRequest("docId required", "docId");
        return Map.of("ds_history", DataSetSupport.rows(approvalMapper.selectHistoryByDoc(docId)));
    }

    // ============================================================
    // Helpers
    // ============================================================

    private void recordHistory(Long docId, Long lineId, String action, String actorNo, String comment) {
        try {
            Map<String, Object> emp = null;
            try {
                // ApprovalMapper 에는 employee 조회가 없으므로 actorName 은 currentUser 그대로
                // OrgMapper 를 별도로 주입하지 않고 단순 문자열 처리
            } catch (Exception ignore) {}
            Map<String, Object> row = new HashMap<>();
            row.put("docId", docId);
            row.put("lineId", lineId);
            row.put("action", action);
            row.put("actorNo", actorNo);
            row.put("actorName", actorNo);  // TODO: name lookup if available
            row.put("comment", comment);
            approvalMapper.insertHistory(row);
        } catch (Exception e) {
            log.warn("history 기록 실패 docId={} action={}: {}", docId, action, e.getMessage());
        }
    }
}
