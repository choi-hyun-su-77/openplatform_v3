package com.platform.v3.bff.port;

import java.util.List;
import java.util.Map;

public interface WikiPort {
    List<Map<String, Object>> searchPages(String keyword, String userToken);
    Map<String, Object> getPage(String pageId, String userToken);
    Map<String, Object> savePage(Map<String, Object> payload, String userToken);
    List<Map<String, Object>> getHistory(String pageId, String userToken);
}
