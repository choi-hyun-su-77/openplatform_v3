package com.platform.v3.core.ux;

import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.org.mapper.OrgMapper;
import com.platform.v3.core.ux.mapper.UxMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Phase 14 트랙 6 — 통합 검색 (Unified Search).
 *
 * <p>service: {@code ux/search}
 * <ul>
 *     <li>입력: ds_search.{ q, types? } — types CSV: POST,DOC,EMP,FILE (기본 전부)</li>
 *     <li>출력: {ds_posts, ds_docs, ds_employees, ds_files} — 각 LIMIT 10</li>
 * </ul>
 *
 * <p>50 명 규모 회사 대상 ILIKE + UNION 조회로 충분 (응답 SLA 200ms 미만 목표).
 * 추후 100 명+ 규모로 커지면 PG pg_trgm GIN 인덱스 또는 OpenSearch 도입.
 */
@Service
public class SearchService {

    private static final Logger log = LoggerFactory.getLogger(SearchService.class);

    private static final Set<String> ALL_TYPES = Set.of("POST", "DOC", "EMP", "FILE");

    private final UxMapper uxMapper;
    private final OrgMapper orgMapper;

    public SearchService(UxMapper uxMapper, OrgMapper orgMapper) {
        this.uxMapper = uxMapper;
        this.orgMapper = orgMapper;
    }

    @DataSetServiceMapping("ux/search")
    public Map<String, Object> search(Map<String, Object> datasets, String currentUser) {
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String q = DataSetSupport.toStr(search.get("q"));
        if (q == null || q.trim().length() < 1) {
            return emptyResult();
        }
        q = q.trim();

        // 검색 대상 타입 파싱 (CSV) — 비어있으면 전부.
        String typesCsv = DataSetSupport.toStr(search.get("types"));
        Set<String> types = parseTypes(typesCsv);

        // 사용자 컨텍스트(부서/사번) 조회 — 결재/파일 권한 필터링용.
        String employeeNo = currentUser;
        Long deptId = null;
        try {
            Map<String, Object> me = orgMapper.findEmployeeByNo(currentUser);
            if (me == null) me = orgMapper.findEmployeeByKeycloakUserId(currentUser);
            if (me != null) {
                deptId = DataSetSupport.toLong(me.get("deptId"));
                Object empNo = me.get("employeeNo");
                if (empNo != null) employeeNo = String.valueOf(empNo);
            }
        } catch (Exception e) {
            log.debug("search: 사용자 컨텍스트 조회 실패 — currentUser={} : {}", currentUser, e.getMessage());
        }

        List<Map<String, Object>> posts     = types.contains("POST")  ? uxMapper.searchPosts(q)                          : List.of();
        List<Map<String, Object>> docs      = types.contains("DOC")   ? uxMapper.searchDocs(q, employeeNo)               : List.of();
        List<Map<String, Object>> employees = types.contains("EMP")   ? uxMapper.searchEmployees(q)                      : List.of();
        List<Map<String, Object>> files     = types.contains("FILE")  ? uxMapper.searchFiles(q, deptId, employeeNo)      : List.of();

        return Map.of(
                "ds_posts",     DataSetSupport.rows(posts),
                "ds_docs",      DataSetSupport.rows(docs),
                "ds_employees", DataSetSupport.rows(employees),
                "ds_files",     DataSetSupport.rows(files)
        );
    }

    // ─── helpers ───────────────────────────────────────────────────────────

    private Set<String> parseTypes(String csv) {
        if (csv == null || csv.trim().isEmpty()) return ALL_TYPES;
        Set<String> result = new HashSet<>();
        for (String t : csv.split(",")) {
            String norm = t.trim().toUpperCase();
            if (ALL_TYPES.contains(norm)) result.add(norm);
        }
        return result.isEmpty() ? ALL_TYPES : result;
    }

    private Map<String, Object> emptyResult() {
        return Map.of(
                "ds_posts",     DataSetSupport.rows(List.of()),
                "ds_docs",      DataSetSupport.rows(List.of()),
                "ds_employees", DataSetSupport.rows(List.of()),
                "ds_files",     DataSetSupport.rows(List.of())
        );
    }
}
