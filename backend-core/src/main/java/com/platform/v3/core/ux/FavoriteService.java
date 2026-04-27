package com.platform.v3.core.ux;

import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.ux.mapper.UxMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Phase 14 트랙 6 — 즐겨찾기 (FavoriteRail / PageFavorites).
 *
 * <p>service 4 종:
 * <ul>
 *   <li>{@code ux/listFavorites} — 본인 즐겨찾기 (sort_order 오름차순)</li>
 *   <li>{@code ux/addFavorite}   — 즐겨찾기 추가 (UNIQUE 충돌 시 메타만 갱신)</li>
 *   <li>{@code ux/removeFavorite}— 즐겨찾기 삭제 (본인 것만)</li>
 *   <li>{@code ux/reorder}       — 정렬 일괄 갱신 (favIds 배열 입력)</li>
 * </ul>
 */
@Service
public class FavoriteService {

    private static final Logger log = LoggerFactory.getLogger(FavoriteService.class);

    private static final int MAX_FAVORITES = 50;

    private final UxMapper uxMapper;

    public FavoriteService(UxMapper uxMapper) {
        this.uxMapper = uxMapper;
    }

    @DataSetServiceMapping("ux/listFavorites")
    public Map<String, Object> listFavorites(Map<String, Object> datasets, String currentUser) {
        List<Map<String, Object>> rows = uxMapper.selectFavorites(currentUser);
        return Map.of("ds_favorites", DataSetSupport.rows(rows));
    }

    @DataSetServiceMapping("ux/addFavorite")
    @Transactional
    public Map<String, Object> addFavorite(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String targetType = DataSetSupport.toStr(search.get("targetType"));
        String targetId   = DataSetSupport.toStr(search.get("targetId"));
        String label      = DataSetSupport.toStr(search.get("label"));
        String url        = DataSetSupport.toStr(search.get("url"));
        String icon       = DataSetSupport.toStr(search.get("icon"));

        if (targetType == null || targetId == null) {
            throw BusinessException.badRequest("targetType/targetId 필수", null);
        }

        // sort_order 는 현재 최대값 + 1 (말미 추가)
        List<Map<String, Object>> existing = uxMapper.selectFavorites(currentUser);
        if (existing.size() >= MAX_FAVORITES) {
            throw BusinessException.badRequest("즐겨찾기는 최대 " + MAX_FAVORITES + "개까지 등록할 수 있습니다.", null);
        }
        int nextSort = existing.stream()
                .mapToInt(r -> {
                    Object so = r.get("sortOrder");
                    return so instanceof Number n ? n.intValue() : 0;
                })
                .max()
                .orElse(0) + 1;

        Map<String, Object> row = new HashMap<>();
        row.put("employeeNo", currentUser);
        row.put("targetType", targetType);
        row.put("targetId", targetId);
        row.put("label", label);
        row.put("url", url);
        row.put("icon", icon);
        row.put("sortOrder", nextSort);
        uxMapper.insertFavorite(row);

        return Map.of("success", true, "favId", row.get("favId"));
    }

    @DataSetServiceMapping("ux/removeFavorite")
    @Transactional
    public Map<String, Object> removeFavorite(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long favId = DataSetSupport.toLong(search.get("favId"));
        if (favId == null) throw BusinessException.badRequest("favId 필수", "favId");

        int deleted = uxMapper.deleteFavorite(favId, currentUser);
        if (deleted == 0) {
            log.warn("removeFavorite: 본인 소유 아닌 favId={} (currentUser={})", favId, currentUser);
        }
        return Map.of("success", deleted > 0);
    }

    /**
     * 정렬 일괄 갱신.
     * 입력 형태:
     *   ds_search.favIds = [3, 1, 2]    → fav_id 3 → sort_order 1, fav_id 1 → 2, fav_id 2 → 3
     */
    @DataSetServiceMapping("ux/reorder")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> reorder(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Object raw = search.get("favIds");
        if (!(raw instanceof List)) {
            throw BusinessException.badRequest("favIds 배열 필수", "favIds");
        }
        List<Object> ids = (List<Object>) raw;

        // 본인 즐겨찾기 ID 집합 — 권한 검증 (다른 사용자 fav 의 sort_order 변경 차단)
        List<Map<String, Object>> mine = uxMapper.selectFavorites(currentUser);
        java.util.Set<Long> mineIds = new java.util.HashSet<>();
        for (Map<String, Object> r : mine) {
            Long id = DataSetSupport.toLong(r.get("favId"));
            if (id != null) mineIds.add(id);
        }

        int order = 1;
        int updated = 0;
        for (Object idObj : ids) {
            Long favId = DataSetSupport.toLong(idObj);
            if (favId == null || !mineIds.contains(favId)) continue;
            uxMapper.updateFavoriteSort(favId, order++);
            updated++;
        }
        return Map.of("success", true, "updated", updated);
    }
}
