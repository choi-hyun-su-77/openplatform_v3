package com.platform.v3.core.board.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface BoardMapper {
    List<Map<String, Object>> selectPosts(@Param("boardType") String boardType,
                                          @Param("keyword") String keyword,
                                          @Param("deptId") Long deptId);

    Map<String, Object> selectPostById(@Param("postId") Long postId);

    void incrementViewCount(@Param("postId") Long postId);

    void insertPost(Map<String, Object> row);

    void updatePost(Map<String, Object> row);

    void deletePost(@Param("postId") Long postId, @Param("deletedBy") String deletedBy);

    // Phase B 확장
    List<Map<String, Object>> selectComments(@Param("postId") Long postId);

    void insertComment(Map<String, Object> row);

    void softDeleteComment(@Param("commentId") Long commentId);

    List<Map<String, Object>> selectAttachments(@Param("postId") Long postId);

    void insertAttachment(Map<String, Object> row);

    void deleteAttachment(@Param("attachId") Long attachId);

    int countComments(@Param("postId") Long postId);
}
