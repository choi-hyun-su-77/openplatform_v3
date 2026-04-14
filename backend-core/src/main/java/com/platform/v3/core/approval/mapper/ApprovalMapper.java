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
}
