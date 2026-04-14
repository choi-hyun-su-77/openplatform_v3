package com.platform.v3.core.code;

import com.platform.v3.core.code.mapper.CodeMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class CodeService {

    private final CodeMapper codeMapper;

    public CodeService(CodeMapper codeMapper) {
        this.codeMapper = codeMapper;
    }

    public Map<String, List<Map<String, Object>>> getCodesByGroups(List<String> groups) {
        if (groups == null || groups.isEmpty()) return Map.of();
        List<Map<String, Object>> rows = codeMapper.selectCodesByGroups(groups);
        Map<String, List<Map<String, Object>>> result = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            String groupCd = (String) row.get("groupCd");
            result.computeIfAbsent(groupCd, k -> new ArrayList<>()).add(row);
        }
        return result;
    }
}
