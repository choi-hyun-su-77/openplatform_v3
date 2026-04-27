package com.platform.v3.core.datalib.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 자료실 (Document Library) 매퍼 — Phase 14 트랙 3.
 *
 * 폴더(dl_folder) + 파일(dl_file) CRUD + 권한 필터 (scope/owner) 검증용 조회.
 */
@Mapper
public interface DataLibraryMapper {

    // ── 폴더 ──

    /**
     * 사용자 권한으로 접근 가능한 폴더 트리 전체 조회.
     * - COMPANY 폴더: 모두 접근 가능
     * - DEPT 폴더: 사용자 부서 일치 시
     * - PERSONAL 폴더: 사용자 owner 일치 시
     * Service 단에서 트리로 재구성한다.
     */
    List<Map<String, Object>> selectAccessibleFolders(@Param("employeeNo") String employeeNo,
                                                      @Param("deptId") Long deptId);

    Map<String, Object> selectFolderById(@Param("folderId") Long folderId);

    void insertFolder(Map<String, Object> row);

    void updateFolderName(@Param("folderId") Long folderId,
                          @Param("folderName") String folderName);

    /** 하위 폴더/파일 카운트 — 삭제 가능 여부 판정 */
    int countChildFolders(@Param("folderId") Long folderId);
    int countFolderFiles(@Param("folderId") Long folderId);

    void deleteFolder(@Param("folderId") Long folderId);

    // ── 파일 ──

    List<Map<String, Object>> selectFiles(@Param("folderId") Long folderId,
                                          @Param("keyword") String keyword,
                                          @Param("tag") String tag);

    /** 키워드 + 태그 통합 검색 — 사용자 접근 가능 폴더로 한정. */
    List<Map<String, Object>> searchFiles(@Param("employeeNo") String employeeNo,
                                          @Param("deptId") Long deptId,
                                          @Param("keyword") String keyword,
                                          @Param("tag") String tag);

    Map<String, Object> selectFileById(@Param("fileId") Long fileId);

    void insertFile(Map<String, Object> row);

    void updateFileFolder(@Param("fileId") Long fileId,
                          @Param("folderId") Long folderId);

    void deleteFile(@Param("fileId") Long fileId);

    void incrementDownloadCount(@Param("fileId") Long fileId);
}
