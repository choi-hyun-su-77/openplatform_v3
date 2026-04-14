package com.platform.v3.core.i18n;

import com.platform.v3.core.i18n.mapper.I18nMapper;
import org.springframework.stereotype.Service;

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
}
