package com.platform.v3.core.board;

import com.platform.v3.core.board.mapper.BoardMapper;
import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.notification.NotificationService;
import com.platform.v3.core.org.mapper.OrgMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class BoardService {

    private final BoardMapper boardMapper;
    private final NotificationService notificationService;
    private final OrgMapper orgMapper;

    public BoardService(BoardMapper boardMapper, NotificationService notificationService, OrgMapper orgMapper) {
        this.boardMapper = boardMapper;
        this.notificationService = notificationService;
        this.orgMapper = orgMapper;
    }

    @DataSetServiceMapping("board/searchPosts")
    public Map<String, Object> searchPosts(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String boardType = DataSetSupport.toStr(search.get("boardType"));
        String keyword = DataSetSupport.toStr(search.get("keyword"));
        Long deptId = DataSetSupport.toLong(search.get("deptId"));
        return Map.of("ds_posts", DataSetSupport.rows(boardMapper.selectPosts(boardType, keyword, deptId)));
    }

    @DataSetServiceMapping("board/searchDetail")
    public Map<String, Object> searchDetail(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long postId = DataSetSupport.toLong(search.get("postId"));
        if (postId == null) throw BusinessException.badRequest("postId가 필요합니다.", "postId");
        boardMapper.incrementViewCount(postId);
        Map<String, Object> post = boardMapper.selectPostById(postId);
        if (post == null) throw BusinessException.notFound("게시글을 찾을 수 없습니다.");
        List<Map<String, Object>> comments = boardMapper.selectComments(postId);
        List<Map<String, Object>> attachments = boardMapper.selectAttachments(postId);
        return Map.of(
                "ds_post", DataSetSupport.rows(List.of(post)),
                "ds_comments", DataSetSupport.rows(comments),
                "ds_attachments", DataSetSupport.rows(attachments)
        );
    }

    @DataSetServiceMapping("board/savePosts")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> savePosts(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_posts");
        if (ds == null) throw BusinessException.badRequest("ds_posts가 필요합니다.", "ds_posts");
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());

        String authorName = resolveAuthorName(currentUser);

        for (Map<String, Object> row : rows) {
            String rowType = DataSetSupport.toStr(row.get("_rowType"));
            switch (rowType == null ? "" : rowType) {
                case "C" -> {
                    row.put("createdBy", currentUser);
                    boardMapper.insertPost(row);
                    if ("NOTICE".equals(row.get("boardType"))) {
                        notificationService.notifyByUserNo(
                                currentUser, null, "BOARD", "WEB",
                                "새 공지: " + row.get("title"),
                                authorName + "님이 공지를 등록했습니다"
                        );
                    }
                }
                case "U" -> { row.put("updatedBy", currentUser); boardMapper.updatePost(row); }
                case "D" -> boardMapper.deletePost(DataSetSupport.toLong(row.get("postId")), currentUser);
                default -> {}
            }
        }
        return Map.of("success", true);
    }

    @DataSetServiceMapping("board/deletePost")
    @Transactional
    public Map<String, Object> deletePost(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long postId = DataSetSupport.toLong(search.get("postId"));
        if (postId == null) throw BusinessException.badRequest("postId required", "postId");
        Map<String, Object> post = boardMapper.selectPostById(postId);
        if (post == null) throw BusinessException.notFound("게시글을 찾을 수 없습니다.");
        if (!String.valueOf(post.get("createdBy")).equals(currentUser)) {
            throw BusinessException.forbidden("작성자만 삭제할 수 있습니다");
        }
        boardMapper.deletePost(postId, currentUser);
        return Map.of("success", true);
    }

    // ===== 댓글 =====

    @DataSetServiceMapping("board/listComments")
    public Map<String, Object> listComments(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long postId = DataSetSupport.toLong(search.get("postId"));
        if (postId == null) throw BusinessException.badRequest("postId required", "postId");
        return Map.of("ds_comments", DataSetSupport.rows(boardMapper.selectComments(postId)));
    }

    @DataSetServiceMapping("board/saveComment")
    @Transactional
    public Map<String, Object> saveComment(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long postId = DataSetSupport.toLong(search.get("postId"));
        Long parentId = DataSetSupport.toLong(search.get("parentId"));
        String content = DataSetSupport.toStr(search.get("content"));
        if (postId == null || content == null || content.isBlank()) {
            throw BusinessException.badRequest("postId/content 필수", null);
        }
        String authorName = resolveAuthorName(currentUser);
        Map<String, Object> row = new HashMap<>();
        row.put("postId", postId);
        row.put("parentId", parentId);
        row.put("content", content);
        row.put("authorNo", currentUser);
        row.put("authorName", authorName);
        boardMapper.insertComment(row);
        return Map.of("success", true, "commentId", row.get("commentId"));
    }

    @DataSetServiceMapping("board/deleteComment")
    @Transactional
    public Map<String, Object> deleteComment(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long commentId = DataSetSupport.toLong(search.get("commentId"));
        if (commentId == null) throw BusinessException.badRequest("commentId required", "commentId");
        boardMapper.softDeleteComment(commentId);
        return Map.of("success", true);
    }

    // ===== 첨부 =====

    @DataSetServiceMapping("board/uploadAttachment")
    @Transactional
    public Map<String, Object> uploadAttachment(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long postId = DataSetSupport.toLong(search.get("postId"));
        String objectKey = DataSetSupport.toStr(search.get("objectKey"));
        String filename = DataSetSupport.toStr(search.get("filename"));
        Long sizeBytes = DataSetSupport.toLong(search.get("sizeBytes"));
        String mimeType = DataSetSupport.toStr(search.get("mimeType"));
        if (postId == null || objectKey == null || filename == null) {
            throw BusinessException.badRequest("postId/objectKey/filename 필수", null);
        }
        Map<String, Object> row = new HashMap<>();
        row.put("postId", postId);
        row.put("objectKey", objectKey);
        row.put("filename", filename);
        row.put("sizeBytes", sizeBytes != null ? sizeBytes : 0L);
        row.put("mimeType", mimeType);
        row.put("uploaderNo", currentUser);
        boardMapper.insertAttachment(row);
        return Map.of("success", true, "attachId", row.get("attachId"));
    }

    private String resolveAuthorName(String userNo) {
        try {
            Map<String, Object> emp = orgMapper.findEmployeeByNo(userNo);
            if (emp != null && emp.get("employeeName") != null) {
                return String.valueOf(emp.get("employeeName"));
            }
        } catch (Exception ignore) {}
        return userNo;
    }
}
