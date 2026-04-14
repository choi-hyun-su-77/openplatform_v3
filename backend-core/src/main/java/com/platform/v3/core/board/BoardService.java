package com.platform.v3.core.board;

import com.platform.v3.core.board.mapper.BoardMapper;
import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.notification.NotificationService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class BoardService {

    private final BoardMapper boardMapper;
    private final NotificationService notificationService;

    public BoardService(BoardMapper boardMapper, NotificationService notificationService) {
        this.boardMapper = boardMapper;
        this.notificationService = notificationService;
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
        return Map.of("ds_post", DataSetSupport.rows(List.of(post)));
    }

    @DataSetServiceMapping("board/savePosts")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> savePosts(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_posts");
        if (ds == null) throw BusinessException.badRequest("ds_posts가 필요합니다.", "ds_posts");
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
        for (Map<String, Object> row : rows) {
            String rowType = DataSetSupport.toStr(row.get("_rowType"));
            switch (rowType == null ? "" : rowType) {
                case "C" -> {
                    row.put("createdBy", currentUser);
                    boardMapper.insertPost(row);
                    // 공지 등록 시 전체 알림 (데모: user1 에게만)
                    if ("NOTICE".equals(row.get("boardType"))) {
                        notificationService.notify(null, 10L, "BOARD", "WEB",
                                "새 공지: " + row.get("title"),
                                "admin 이 공지를 등록했습니다");
                    }
                }
                case "U" -> { row.put("updatedBy", currentUser); boardMapper.updatePost(row); }
                case "D" -> boardMapper.deletePost(DataSetSupport.toLong(row.get("postId")), currentUser);
                default -> {}
            }
        }
        return Map.of("success", true);
    }
}
