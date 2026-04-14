package com.platform.v3.core.common;

import java.util.Collections;
import java.util.Map;

/**
 * DataSet 서비스 공통 유틸 — 입력 파싱 / 출력 포맷.
 */
public final class DataSetSupport {

    private DataSetSupport() {}

    @SuppressWarnings("unchecked")
    public static Map<String, Object> getSearchParams(Map<String, Object> datasets) {
        Object ds = datasets.get("ds_search");
        if (ds instanceof Map<?, ?> m) return (Map<String, Object>) m;
        return Collections.emptyMap();
    }

    @SuppressWarnings("unchecked")
    public static Map<String, Object> getDataset(Map<String, Object> datasets, String name) {
        Object ds = datasets.get(name);
        if (ds instanceof Map<?, ?> m) return (Map<String, Object>) m;
        return Collections.emptyMap();
    }

    public static Long toLong(Object val) {
        if (val == null) return null;
        if (val instanceof Number n) return n.longValue();
        try { return Long.parseLong(val.toString()); } catch (NumberFormatException e) { return null; }
    }

    public static String toStr(Object val) {
        return val == null ? null : val.toString();
    }

    public static Map<String, Object> rows(java.util.List<?> rows) {
        return Map.of("rows", rows, "totalCount", rows.size());
    }
}
