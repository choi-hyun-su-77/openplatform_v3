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
 * Phase 14 트랙 6 — 알림 채널 환경설정 (Notify Preference).
 *
 * <p>service:
 * <ul>
 *   <li>{@code ux/getNotifyPref} — 본인 매트릭스 (카테고리×채널)</li>
 *   <li>{@code ux/saveNotifyPref}— 매트릭스 일괄 저장 (UPSERT)</li>
 * </ul>
 *
 * <p>채널: {@link #CHANNELS} 3종, 카테고리: {@link #CATEGORIES} 6종.
 *
 * <p>설정이 없는 사용자에 대한 기본값은 {@link NotificationService} 분기에서:
 * PORTAL=ON, EMAIL=OFF, MESSENGER=OFF (UI 첫 로드 시에도 동일 fallback).
 */
@Service
public class NotifyPrefService {

    private static final Logger log = LoggerFactory.getLogger(NotifyPrefService.class);

    public static final List<String> CATEGORIES = List.of(
            "APPROVAL", "BOARD", "CALENDAR", "MENTION", "ROOM", "LEAVE"
    );
    public static final List<String> CHANNELS = List.of("PORTAL", "EMAIL", "MESSENGER");

    /** 채널별 기본 활성 여부 — DB 미설정 시 fallback. */
    public static boolean defaultEnabled(String channel) {
        return "PORTAL".equals(channel);
    }

    private final UxMapper uxMapper;

    public NotifyPrefService(UxMapper uxMapper) {
        this.uxMapper = uxMapper;
    }

    @DataSetServiceMapping("ux/getNotifyPref")
    public Map<String, Object> getNotifyPref(Map<String, Object> datasets, String currentUser) {
        List<Map<String, Object>> existing = uxMapper.selectNotifyPref(currentUser);

        // 매트릭스 fill — DB 에 없는 (category, channel) 조합은 기본값으로 채워서 반환.
        java.util.Set<String> existingKeys = new java.util.HashSet<>();
        for (Map<String, Object> r : existing) {
            existingKeys.add(r.get("category") + "|" + r.get("channel"));
        }

        java.util.List<Map<String, Object>> result = new java.util.ArrayList<>(existing);
        for (String cat : CATEGORIES) {
            for (String ch : CHANNELS) {
                if (!existingKeys.contains(cat + "|" + ch)) {
                    Map<String, Object> filled = new HashMap<>();
                    filled.put("employeeNo", currentUser);
                    filled.put("category", cat);
                    filled.put("channel", ch);
                    filled.put("enabled", defaultEnabled(ch));
                    result.add(filled);
                }
            }
        }
        return Map.of(
                "ds_notifyPref", DataSetSupport.rows(result),
                "ds_meta",       Map.of(
                        "categories", CATEGORIES,
                        "channels",   CHANNELS
                )
        );
    }

    /**
     * 매트릭스 일괄 저장.
     * 입력: ds_notifyPref.rows = [{category, channel, enabled}, ...]
     */
    @DataSetServiceMapping("ux/saveNotifyPref")
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> saveNotifyPref(Map<String, Object> datasets, String currentUser) {
        Object dsObj = datasets.get("ds_notifyPref");
        if (!(dsObj instanceof Map)) {
            throw BusinessException.badRequest("ds_notifyPref 필수", "ds_notifyPref");
        }
        Map<String, Object> ds = (Map<String, Object>) dsObj;
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());

        int saved = 0;
        for (Map<String, Object> row : rows) {
            String category = DataSetSupport.toStr(row.get("category"));
            String channel  = DataSetSupport.toStr(row.get("channel"));
            if (category == null || channel == null) continue;
            if (!CATEGORIES.contains(category) || !CHANNELS.contains(channel)) continue;

            Object enabledObj = row.get("enabled");
            boolean enabled = enabledObj instanceof Boolean b ? b
                    : enabledObj != null && Boolean.parseBoolean(String.valueOf(enabledObj));

            Map<String, Object> upsert = new HashMap<>();
            upsert.put("employeeNo", currentUser);
            upsert.put("category", category);
            upsert.put("channel", channel);
            upsert.put("enabled", enabled);
            uxMapper.upsertNotifyPref(upsert);
            saved++;
        }
        log.info("saveNotifyPref: user={} saved={}", currentUser, saved);
        return Map.of("success", true, "saved", saved);
    }

    /**
     * NotificationService 가 채널 분기 시 호출하는 헬퍼.
     * @return DB 에 row 가 없으면 {@link #defaultEnabled(String)} 으로 fallback.
     */
    public boolean isChannelEnabled(String employeeNo, String category, String channel) {
        if (employeeNo == null || category == null || channel == null) return defaultEnabled(channel);
        try {
            Map<String, Object> row = uxMapper.selectNotifyPrefOne(employeeNo, category, channel);
            if (row == null) return defaultEnabled(channel);
            Object enabled = row.get("enabled");
            if (enabled instanceof Boolean b) return b;
            return Boolean.parseBoolean(String.valueOf(enabled));
        } catch (Exception e) {
            log.debug("isChannelEnabled lookup failed emp={} cat={} ch={}: {}",
                    employeeNo, category, channel, e.getMessage());
            return defaultEnabled(channel);
        }
    }
}
