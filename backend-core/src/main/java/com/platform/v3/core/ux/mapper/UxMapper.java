package com.platform.v3.core.ux.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * Phase 14 트랙 6 — UX 강화 (즐겨찾기 / 알림설정 / 통합검색) 전용 매퍼.
 *
 * <p>3 개 도메인을 한 매퍼로 모은다 (테이블 prefix 가 모두 {@code ux_*} 이고,
 * 검색은 별도 인덱스 테이블 없이 기존 도메인 테이블을 ILIKE 로 횡단 조회).
 */
@Mapper
public interface UxMapper {

    // ─── 즐겨찾기 (ux_favorite) ───────────────────────────────────────────
    List<Map<String, Object>> selectFavorites(@Param("employeeNo") String employeeNo);

    Map<String, Object> selectFavoriteById(@Param("favId") Long favId);

    int insertFavorite(Map<String, Object> row);

    int updateFavoriteSort(@Param("favId") Long favId, @Param("sortOrder") int sortOrder);

    int deleteFavorite(@Param("favId") Long favId, @Param("employeeNo") String employeeNo);

    // ─── 알림 환경설정 (ux_notify_pref) ───────────────────────────────────
    List<Map<String, Object>> selectNotifyPref(@Param("employeeNo") String employeeNo);

    /** UPSERT 한 행 (employee_no + category + channel UNIQUE). */
    int upsertNotifyPref(Map<String, Object> row);

    /**
     * 채널 활성 여부 단일 조회 — NotificationService 분기에서 사용.
     * 미설정(row 없음) 일 때는 service 단에서 PORTAL 기본 ON / 그 외 기본 OFF 로 fallback.
     */
    Map<String, Object> selectNotifyPrefOne(@Param("employeeNo") String employeeNo,
                                            @Param("category") String category,
                                            @Param("channel") String channel);

    // ─── 통합 검색 (4 도메인 UNION 대신 4 query 합산) ────────────────────
    List<Map<String, Object>> searchPosts(@Param("keyword") String keyword);

    List<Map<String, Object>> searchDocs(@Param("keyword") String keyword,
                                         @Param("userNo") String userNo);

    List<Map<String, Object>> searchEmployees(@Param("keyword") String keyword);

    List<Map<String, Object>> searchFiles(@Param("keyword") String keyword,
                                          @Param("deptId") Long deptId,
                                          @Param("employeeNo") String employeeNo);
}
