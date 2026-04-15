package com.platform.v3.core.approval.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface ApprovalMapper {

    List<Map<String, Object>> selectInbox(@Param("boxType") String boxType,
                                          @Param("userNo") String userNo,
                                          @Param("keyword") String keyword);

    Map<String, Object> selectDetail(@Param("docId") Long docId);

    List<Map<String, Object>> selectApprovalLine(@Param("docId") Long docId);

    List<Map<String, Object>> selectFormTemplates();

    void insertDocument(Map<String, Object> row);

    void updateDocumentStatus(@Param("docId") Long docId,
                              @Param("status") String status);

    void insertApprovalLine(Map<String, Object> line);

    void updateApprovalLineStatus(@Param("lineId") Long lineId,
                                  @Param("status") String status,
                                  @Param("comment") String comment);

    int countPendingForUser(@Param("userNo") String userNo);

    List<Map<String, Object>> selectApproversForDocFromDmn(@Param("amount") Long amount,
                                                           @Param("formCode") String formCode);

    // ===== Phase A 신규 =====

    /** 첨부 파일 등록 */
    void insertAttachment(Map<String, Object> row);

    /** 문서의 첨부 목록 */
    List<Map<String, Object>> selectAttachmentsByDoc(@Param("docId") Long docId);

    /** 첨부 삭제 */
    void deleteAttachment(@Param("attachId") Long attachId);

    /** 감사 이력 기록 (SUBMIT/APPROVE/REJECT/WITHDRAW/RESUBMIT/DELEGATE) */
    void insertHistory(Map<String, Object> row);

    /** 문서 이력 조회 (상세 뷰 "이력" 탭) */
    List<Map<String, Object>> selectHistoryByDoc(@Param("docId") Long docId);

    /** 대결(delegate) 등록 */
    void insertDelegation(Map<String, Object> row);

    /** 특정 사용자의 활성 대결 정보 (오늘 날짜 기준) */
    Map<String, Object> selectActiveDelegation(@Param("delegatorNo") String delegatorNo);

    /** 재상신용: 기존 문서 복제 (parent_doc_id 설정하고 version 증가) */
    void cloneDocumentForResubmit(Map<String, Object> row);

    /** 문서 상태 + content/amount 동시 업데이트 (재상신 시) */
    void updateDocumentContent(@Param("docId") Long docId,
                               @Param("content") String content,
                               @Param("amount") Long amount,
                               @Param("docTitle") String docTitle);

    /** 문서 status='DRAFT' 로 변경하고 모든 라인 초기화 (회수) */
    void resetLinesForWithdraw(@Param("docId") Long docId);
}
