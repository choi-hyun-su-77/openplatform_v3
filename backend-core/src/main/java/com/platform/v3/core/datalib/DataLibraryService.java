package com.platform.v3.core.datalib;

import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.datalib.mapper.DataLibraryMapper;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.org.mapper.OrgMapper;
import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.RemoveObjectArgs;
import io.minio.http.Method;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * 자료실 (Document Library) DataSet 서비스 — Phase 14 트랙 3.
 *
 * <p>9개 service 노출:
 * <ul>
 *   <li>{@code datalib/listFolders}    — 사용자 권한 필터링된 폴더 트리</li>
 *   <li>{@code datalib/listFiles}      — 폴더 내 파일 목록</li>
 *   <li>{@code datalib/createFolder}   — 폴더 생성 (scope/owner 권한 체크)</li>
 *   <li>{@code datalib/renameFolder}   — 폴더 이름 변경</li>
 *   <li>{@code datalib/deleteFolder}   — 폴더 삭제 (하위 비어있을 때만)</li>
 *   <li>{@code datalib/uploadMeta}     — UI 의 presigned PUT 완료 후 메타 INSERT</li>
 *   <li>{@code datalib/searchFiles}    — 키워드 + 태그 통합 검색 (접근 가능 폴더 한정)</li>
 *   <li>{@code datalib/getDownloadUrl} — presigned GET URL + 다운로드 카운트++ </li>
 *   <li>{@code datalib/deleteFile}     — uploader 또는 admin 만, MinIO 객체까지 제거</li>
 *   <li>{@code datalib/moveFile}       — 폴더 변경 (양 쪽 모두 권한 체크)</li>
 * </ul>
 *
 * <p>권한 모델 ({@link #canAccessFolder}):
 * <ul>
 *   <li>{@code COMPANY}  — 누구나 R, 관리자/MGR 만 W</li>
 *   <li>{@code DEPT}     — owner_dept_id 일치 시 RW, 외부 차단</li>
 *   <li>{@code PERSONAL} — owner_no 일치 시 RW, 외부 차단</li>
 * </ul>
 *
 * <p>presigned URL: backend-core 에서 직접 {@link MinioClient} 빈 사용
 * (BFF 호출 오버헤드 회피, BoardService 메타-only 패턴 + 자료실 특화).
 */
@Service
public class DataLibraryService {

    private static final Logger log = LoggerFactory.getLogger(DataLibraryService.class);

    private final DataLibraryMapper mapper;
    private final OrgMapper orgMapper;
    private final MinioClient minio;
    private final String bucket;

    public DataLibraryService(DataLibraryMapper mapper,
                              OrgMapper orgMapper,
                              MinioClient minio,
                              @Value("${minio.bucket}") String bucket) {
        this.mapper = mapper;
        this.orgMapper = orgMapper;
        this.minio = minio;
        this.bucket = bucket;
    }

    // ============================================================
    // 폴더
    // ============================================================

    @DataSetServiceMapping("datalib/listFolders")
    public Map<String, Object> listFolders(Map<String, Object> datasets, String currentUser) {
        Long deptId = resolveDeptId(currentUser);
        List<Map<String, Object>> folders =
                mapper.selectAccessibleFolders(currentUser, deptId);
        return Map.of("ds_folders", DataSetSupport.rows(folders));
    }

    @DataSetServiceMapping("datalib/listFiles")
    public Map<String, Object> listFiles(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long folderId = DataSetSupport.toLong(search.get("folderId"));
        String keyword = DataSetSupport.toStr(search.get("keyword"));
        String tag = DataSetSupport.toStr(search.get("tag"));
        if (folderId == null) {
            throw BusinessException.badRequest("folderId가 필요합니다.", "folderId");
        }
        if (!canAccessFolder(folderId, currentUser, false)) {
            throw BusinessException.forbidden("이 폴더의 파일에 접근할 수 없습니다.");
        }
        return Map.of("ds_files",
                DataSetSupport.rows(mapper.selectFiles(folderId, keyword, tag)));
    }

    @DataSetServiceMapping("datalib/createFolder")
    @Transactional
    public Map<String, Object> createFolder(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long parentId = DataSetSupport.toLong(search.get("parentId"));
        String folderName = DataSetSupport.toStr(search.get("folderName"));
        String scope = DataSetSupport.toStr(search.get("scope"));
        if (folderName == null || folderName.isBlank()) {
            throw BusinessException.badRequest("폴더명이 필요합니다.", "folderName");
        }

        Map<String, Object> row = new HashMap<>();
        row.put("parentId", parentId);
        row.put("folderName", folderName.trim());

        // scope 가 명시되지 않은 경우 부모 폴더에서 상속.
        if (scope == null || scope.isBlank()) {
            if (parentId == null) {
                throw BusinessException.badRequest("scope 또는 parentId 중 하나는 필요합니다.", "scope");
            }
            Map<String, Object> parent = mapper.selectFolderById(parentId);
            if (parent == null) {
                throw BusinessException.notFound("부모 폴더를 찾을 수 없습니다.");
            }
            scope = String.valueOf(parent.get("scope"));
            row.put("ownerDeptId", parent.get("ownerDeptId"));
            row.put("ownerNo", parent.get("ownerNo"));
        } else {
            // scope 명시 — 사용자 정보 기준으로 owner 자동 할당.
            switch (scope) {
                case "COMPANY" -> {
                    if (!isAdmin()) {
                        throw BusinessException.forbidden("회사 공용 폴더는 관리자만 생성할 수 있습니다.");
                    }
                }
                case "DEPT" -> {
                    Long deptId = resolveDeptId(currentUser);
                    if (deptId == null) {
                        throw BusinessException.badRequest("부서 정보가 없어 부서 폴더를 만들 수 없습니다.", "deptId");
                    }
                    row.put("ownerDeptId", deptId);
                }
                case "PERSONAL" -> row.put("ownerNo", currentUser);
                default -> throw BusinessException.badRequest("알 수 없는 scope: " + scope, "scope");
            }
        }
        row.put("scope", scope);

        // 부모 폴더 권한 체크 (있을 때).
        if (parentId != null && !canAccessFolder(parentId, currentUser, true)) {
            throw BusinessException.forbidden("부모 폴더에 쓰기 권한이 없습니다.");
        }

        mapper.insertFolder(row);
        log.info("자료실 폴더 생성: id={}, name={}, scope={}, by={}",
                row.get("folderId"), folderName, scope, currentUser);
        return Map.of("success", true, "folderId", row.get("folderId"));
    }

    @DataSetServiceMapping("datalib/renameFolder")
    @Transactional
    public Map<String, Object> renameFolder(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long folderId = DataSetSupport.toLong(search.get("folderId"));
        String folderName = DataSetSupport.toStr(search.get("folderName"));
        if (folderId == null || folderName == null || folderName.isBlank()) {
            throw BusinessException.badRequest("folderId/folderName 필수", null);
        }
        if (!canAccessFolder(folderId, currentUser, true)) {
            throw BusinessException.forbidden("폴더 변경 권한이 없습니다.");
        }
        mapper.updateFolderName(folderId, folderName.trim());
        return Map.of("success", true);
    }

    @DataSetServiceMapping("datalib/deleteFolder")
    @Transactional
    public Map<String, Object> deleteFolder(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long folderId = DataSetSupport.toLong(search.get("folderId"));
        if (folderId == null) {
            throw BusinessException.badRequest("folderId가 필요합니다.", "folderId");
        }
        if (folderId == 1L) {
            throw BusinessException.forbidden("회사 공용 루트 폴더는 삭제할 수 없습니다.");
        }
        if (!canAccessFolder(folderId, currentUser, true)) {
            throw BusinessException.forbidden("폴더 삭제 권한이 없습니다.");
        }
        if (mapper.countChildFolders(folderId) > 0 || mapper.countFolderFiles(folderId) > 0) {
            throw BusinessException.badRequest("하위 폴더 또는 파일이 남아 있어 삭제할 수 없습니다.", null);
        }
        mapper.deleteFolder(folderId);
        log.info("자료실 폴더 삭제: id={}, by={}", folderId, currentUser);
        return Map.of("success", true);
    }

    // ============================================================
    // 파일
    // ============================================================

    /**
     * 업로드 메타 등록 — UI 가 BFF presigned PUT 으로 MinIO 에 업로드 완료 후 호출.
     * <p>입력: ds_search.{folderId, fileName, objectKey, sizeBytes, mimeType, tags?}
     */
    @DataSetServiceMapping("datalib/uploadMeta")
    @Transactional
    public Map<String, Object> uploadMeta(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long folderId = DataSetSupport.toLong(search.get("folderId"));
        String fileName = DataSetSupport.toStr(search.get("fileName"));
        String objectKey = DataSetSupport.toStr(search.get("objectKey"));
        Long sizeBytes = DataSetSupport.toLong(search.get("sizeBytes"));
        String mimeType = DataSetSupport.toStr(search.get("mimeType"));
        String tags = DataSetSupport.toStr(search.get("tags"));

        if (folderId == null || fileName == null || objectKey == null) {
            throw BusinessException.badRequest("folderId/fileName/objectKey 필수", null);
        }
        if (!canAccessFolder(folderId, currentUser, true)) {
            throw BusinessException.forbidden("이 폴더에 업로드 권한이 없습니다.");
        }

        Map<String, Object> row = new HashMap<>();
        row.put("folderId", folderId);
        row.put("fileName", fileName);
        row.put("objectKey", objectKey);
        row.put("sizeBytes", sizeBytes != null ? sizeBytes : 0L);
        row.put("mimeType", mimeType);
        row.put("tags", tags);
        row.put("uploaderNo", currentUser);
        mapper.insertFile(row);
        return Map.of("success", true, "fileId", row.get("fileId"));
    }

    @DataSetServiceMapping("datalib/searchFiles")
    public Map<String, Object> searchFiles(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String keyword = DataSetSupport.toStr(search.get("keyword"));
        String tag = DataSetSupport.toStr(search.get("tag"));
        Long deptId = resolveDeptId(currentUser);
        return Map.of("ds_files",
                DataSetSupport.rows(mapper.searchFiles(currentUser, deptId, keyword, tag)));
    }

    /**
     * presigned GET URL 발급 + download_count 증가.
     * 권한: 폴더 R 가능자.
     */
    @DataSetServiceMapping("datalib/getDownloadUrl")
    @Transactional
    public Map<String, Object> getDownloadUrl(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long fileId = DataSetSupport.toLong(search.get("fileId"));
        if (fileId == null) {
            throw BusinessException.badRequest("fileId가 필요합니다.", "fileId");
        }
        Map<String, Object> file = mapper.selectFileById(fileId);
        if (file == null) {
            throw BusinessException.notFound("파일을 찾을 수 없습니다.");
        }
        Long folderId = DataSetSupport.toLong(file.get("folderId"));
        if (!canAccessFolder(folderId, currentUser, false)) {
            throw BusinessException.forbidden("이 파일을 다운로드할 수 없습니다.");
        }
        String objectKey = String.valueOf(file.get("objectKey"));

        String url;
        try {
            url = minio.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
                    .method(Method.GET)
                    .bucket(bucket)
                    .object(objectKey)
                    .expiry(600, TimeUnit.SECONDS)
                    .build());
        } catch (Exception e) {
            log.error("MinIO presigned GET 발급 실패: {}", objectKey, e);
            throw new RuntimeException("다운로드 URL 발급 실패: " + e.getMessage(), e);
        }

        mapper.incrementDownloadCount(fileId);
        return Map.of(
                "success", true,
                "url", url,
                "fileName", file.get("fileName")
        );
    }

    /**
     * 파일 삭제 — uploader 또는 admin 만. MinIO 객체까지 제거.
     */
    @DataSetServiceMapping("datalib/deleteFile")
    @Transactional
    public Map<String, Object> deleteFile(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long fileId = DataSetSupport.toLong(search.get("fileId"));
        if (fileId == null) {
            throw BusinessException.badRequest("fileId가 필요합니다.", "fileId");
        }
        Map<String, Object> file = mapper.selectFileById(fileId);
        if (file == null) {
            throw BusinessException.notFound("파일을 찾을 수 없습니다.");
        }
        String uploader = String.valueOf(file.get("uploaderNo"));
        if (!uploader.equals(currentUser) && !isAdmin()) {
            throw BusinessException.forbidden("업로더 또는 관리자만 삭제할 수 있습니다.");
        }
        String objectKey = String.valueOf(file.get("objectKey"));

        mapper.deleteFile(fileId);

        // MinIO 객체 삭제 — 실패해도 DB 는 commit (orphan 객체는 향후 sweep). warn 로그.
        try {
            minio.removeObject(RemoveObjectArgs.builder()
                    .bucket(bucket)
                    .object(objectKey)
                    .build());
        } catch (Exception e) {
            log.warn("MinIO 객체 삭제 실패 (orphan 가능): {} — {}", objectKey, e.getMessage());
        }
        log.info("자료실 파일 삭제: fileId={}, by={}", fileId, currentUser);
        return Map.of("success", true);
    }

    /**
     * 파일 이동 — 원 폴더 RW + 대상 폴더 RW 모두 필요.
     */
    @DataSetServiceMapping("datalib/moveFile")
    @Transactional
    public Map<String, Object> moveFile(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        Long fileId = DataSetSupport.toLong(search.get("fileId"));
        Long targetFolderId = DataSetSupport.toLong(search.get("targetFolderId"));
        if (fileId == null || targetFolderId == null) {
            throw BusinessException.badRequest("fileId/targetFolderId 필수", null);
        }
        Map<String, Object> file = mapper.selectFileById(fileId);
        if (file == null) {
            throw BusinessException.notFound("파일을 찾을 수 없습니다.");
        }
        Long sourceFolderId = DataSetSupport.toLong(file.get("folderId"));
        if (!canAccessFolder(sourceFolderId, currentUser, true)
                || !canAccessFolder(targetFolderId, currentUser, true)) {
            throw BusinessException.forbidden("원본/대상 폴더 양쪽 모두 쓰기 권한이 필요합니다.");
        }
        mapper.updateFileFolder(fileId, targetFolderId);
        return Map.of("success", true);
    }

    // ============================================================
    // Private helpers
    // ============================================================

    /**
     * 폴더 접근 가능 여부 판정.
     *
     * @param folderId    대상 폴더
     * @param employeeNo  현재 사용자 사번
     * @param needWrite   true=쓰기(생성/수정/삭제) 권한도 검증, false=읽기만
     */
    private boolean canAccessFolder(Long folderId, String employeeNo, boolean needWrite) {
        if (folderId == null) return false;
        Map<String, Object> folder = mapper.selectFolderById(folderId);
        if (folder == null) return false;
        if (isAdmin()) return true;

        String scope = String.valueOf(folder.get("scope"));
        switch (scope) {
            case "COMPANY":
                if (!needWrite) return true;
                // COMPANY 폴더는 관리자/MGR 만 W. (admin 은 위에서 처리됨)
                return hasRole("ROLE_MGR");
            case "DEPT": {
                Long ownerDeptId = DataSetSupport.toLong(folder.get("ownerDeptId"));
                Long myDeptId = resolveDeptId(employeeNo);
                if (ownerDeptId == null || myDeptId == null) return false;
                return ownerDeptId.equals(myDeptId);
            }
            case "PERSONAL": {
                String ownerNo = String.valueOf(folder.get("ownerNo"));
                return ownerNo != null && ownerNo.equals(employeeNo);
            }
            default:
                return false;
        }
    }

    private Long resolveDeptId(String employeeNo) {
        if (employeeNo == null || employeeNo.isBlank()) return null;
        try {
            Map<String, Object> emp = orgMapper.findEmployeeByNo(employeeNo);
            if (emp != null) return DataSetSupport.toLong(emp.get("deptId"));
        } catch (Exception ignore) {
        }
        return null;
    }

    private boolean isAdmin() {
        return hasRole("ROLE_ADMIN");
    }

    private boolean hasRole(String role) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return false;
        return auth.getAuthorities().stream()
                .map(Object::toString)
                .anyMatch(r -> r.equals(role));
    }
}
