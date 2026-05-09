package com.platform.v3.core.i18n;

import com.platform.v3.core.i18n.mapper.I18nMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class I18nService {

    private final I18nMapper i18nMapper;

    public I18nService(I18nMapper i18nMapper) {
        this.i18nMapper = i18nMapper;
    }

    public List<Map<String, Object>> getMessages(String locale, String type) {
        return i18nMapper.selectMessages(locale, type);
    }

    /**
     * 모든 msg_type 을 합쳐 labelId → text 의 단일 맵으로 반환.
     * useLabel.ts 의 t() 함수가 기대하는 응답 형태이며,
     * 화면 부트스트랩 시 1회 호출로 모든 라벨/버튼/메뉴/메시지/그리드 헤더 등을 캐시한다.
     */
    public Map<String, String> getLabelMap(String locale) {
        List<Map<String, Object>> rows = i18nMapper.selectMessages(locale, null);
        Map<String, String> map = new HashMap<>(rows.size() * 2);
        for (Map<String, Object> row : rows) {
            Object key = row.get("msgKey");
            Object message = row.get("message");
            if (key != null && message != null) {
                map.put(key.toString(), message.toString());
            }
        }
        return map;
    }
}
