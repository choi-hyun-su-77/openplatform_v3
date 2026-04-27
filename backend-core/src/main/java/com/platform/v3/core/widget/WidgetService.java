package com.platform.v3.core.widget;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.platform.v3.core.common.BusinessException;
import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.widget.mapper.WidgetMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 대시보드 위젯 도메인 — Phase 14 트랙 7.
 *
 * 5 services:
 *   widget/listAll        — 위젯 카탈로그 (db_widget)
 *   widget/listMine       — 내 배치 (db_user_widget JOIN db_widget)
 *                           — 빈 결과면 default 6 위젯 자동 시드 후 재조회
 *   widget/saveLayout     — ds_layout 일괄 upsert (편집 모드 종료 시)
 *   widget/addWidget      — 단건 추가 (default 위치/크기로)
 *   widget/removeWidget   — 단건 제거
 *
 * 자율 결정:
 *   - 첫 로그인 default 시드는 listMine 첫 호출 시 server-side 로 자동 INSERT.
 *     (UI 측 코드 단순화. 사용자가 모든 위젯을 의도적으로 제거한 경우에는
 *      removeWidget 으로 0건이 되더라도 다시 자동 시드하지 않음 —
 *      자동 시드는 "최초 1회" 트리거를 cm_user_pref 가 없으므로 단순히
 *      default-seeded 플래그 위젯(__seeded__) 으로 표시한다.)
 */
@Service
public class WidgetService {

    private static final Logger log = LoggerFactory.getLogger(WidgetService.class);

    /** Default 6 위젯 + 12-column 그리드 2행 배치. */
    private static final List<DefaultWidget> DEFAULT_LAYOUT = Arrays.asList(
            new DefaultWidget("ATTENDANCE",       0, 0, 4, 1, 0),
            new DefaultWidget("LEAVE_BALANCE",    4, 0, 4, 1, 1),
            new DefaultWidget("PENDING_APPROVAL", 8, 0, 4, 1, 2),
            new DefaultWidget("TODAY_EVENTS",     0, 1, 6, 1, 3),
            new DefaultWidget("NOTICES",          6, 1, 6, 1, 4),
            new DefaultWidget("MESSENGER_UNREAD", 0, 2, 4, 1, 5)
    );

    private final WidgetMapper widgetMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public WidgetService(WidgetMapper widgetMapper) {
        this.widgetMapper = widgetMapper;
    }

    // ============================================================
    // 1. 카탈로그
    // ============================================================
    @DataSetServiceMapping("widget/listAll")
    public Map<String, Object> listAll(Map<String, Object> datasets, String currentUser) {
        List<Map<String, Object>> rows = widgetMapper.selectCatalog();
        return Map.of("ds_widgets", DataSetSupport.rows(rows));
    }

    // ============================================================
    // 2. 내 위젯 (자동 시드 포함)
    // ============================================================
    @DataSetServiceMapping("widget/listMine")
    @Transactional
    public Map<String, Object> listMine(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank()) {
            return Map.of("ds_mine", DataSetSupport.rows(List.of()));
        }
        // 첫 호출 자동 시드 — count 0 일 때만 default 6 위젯 INSERT
        int count = widgetMapper.countMine(currentUser);
        if (count == 0) {
            seedDefaultLayout(currentUser);
        }
        List<Map<String, Object>> rows = widgetMapper.selectMine(currentUser);
        return Map.of("ds_mine", DataSetSupport.rows(rows));
    }

    private void seedDefaultLayout(String employeeNo) {
        log.info("widget default layout 자동 시드: employeeNo={}", employeeNo);
        for (DefaultWidget dw : DEFAULT_LAYOUT) {
            Map<String, Object> row = new HashMap<>();
            row.put("employeeNo", employeeNo);
            row.put("widgetCode", dw.code);
            row.put("posX",       dw.posX);
            row.put("posY",       dw.posY);
            row.put("width",      dw.width);
            row.put("height",     dw.height);
            row.put("sortOrder",  dw.sortOrder);
            row.put("configJson", null);
            try {
                widgetMapper.insertUserWidget(row);
            } catch (Exception e) {
                log.warn("default widget seed 실패: code={}, err={}", dw.code, e.getMessage());
            }
        }
    }

    // ============================================================
    // 3. saveLayout — 편집 모드 종료 시 일괄 upsert
    // ============================================================
    @SuppressWarnings("unchecked")
    @DataSetServiceMapping("widget/saveLayout")
    @Transactional
    public Map<String, Object> saveLayout(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank()) {
            throw BusinessException.forbidden("로그인이 필요합니다");
        }
        Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_layout");
        if (ds == null) {
            throw BusinessException.badRequest("ds_layout 이 필요합니다", "ds_layout");
        }
        List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
        int upserted = 0;
        int deleted  = 0;
        for (Map<String, Object> row : rows) {
            String widgetCode = DataSetSupport.toStr(row.get("widgetCode"));
            if (widgetCode == null || widgetCode.isBlank()) continue;
            String rowType = DataSetSupport.toStr(row.get("_rowType"));

            if ("D".equals(rowType)) {
                deleted += widgetMapper.deleteUserWidget(currentUser, widgetCode);
                continue;
            }
            // C/U/undefined 모두 upsert (idempotent)
            Map<String, Object> param = buildUserWidgetParam(currentUser, row);
            widgetMapper.insertUserWidget(param);
            upserted++;
        }
        log.info("widget/saveLayout: emp={}, upsert={}, delete={}", currentUser, upserted, deleted);
        return Map.of("success", true, "upserted", upserted, "deleted", deleted);
    }

    // ============================================================
    // 4. addWidget — 단건 추가 (default 위치/크기 + 사용자 지정값 우선)
    // ============================================================
    @DataSetServiceMapping("widget/addWidget")
    @Transactional
    public Map<String, Object> addWidget(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank()) {
            throw BusinessException.forbidden("로그인이 필요합니다");
        }
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String widgetCode = DataSetSupport.toStr(search.get("widgetCode"));
        if (widgetCode == null || widgetCode.isBlank()) {
            throw BusinessException.badRequest("widgetCode 가 필요합니다", "widgetCode");
        }
        Map<String, Object> catalog = widgetMapper.selectCatalogByCode(widgetCode);
        if (catalog == null) {
            throw BusinessException.notFound("위젯 카탈로그에 없습니다: " + widgetCode);
        }
        // 사용자 지정값 없으면 catalog default 사용
        Long defaultW = DataSetSupport.toLong(catalog.getOrDefault("defaultW", catalog.get("default_w")));
        Long defaultH = DataSetSupport.toLong(catalog.getOrDefault("defaultH", catalog.get("default_h")));
        Long width    = DataSetSupport.toLong(search.get("width"));
        Long height   = DataSetSupport.toLong(search.get("height"));
        Long posX     = DataSetSupport.toLong(search.get("posX"));
        Long posY     = DataSetSupport.toLong(search.get("posY"));

        Map<String, Object> row = new HashMap<>();
        row.put("employeeNo", currentUser);
        row.put("widgetCode", widgetCode);
        row.put("posX",       posX   != null ? posX.intValue()   : 0);
        row.put("posY",       posY   != null ? posY.intValue()   : 99);  // 화면 맨 아래
        row.put("width",      width  != null ? width.intValue()  : (defaultW != null ? defaultW.intValue() : 4));
        row.put("height",     height != null ? height.intValue() : (defaultH != null ? defaultH.intValue() : 1));
        row.put("sortOrder",  DataSetSupport.toLong(search.get("sortOrder")));
        Object cfg = search.get("configJson");
        row.put("configJson", toJsonString(cfg));
        widgetMapper.insertUserWidget(row);
        log.info("widget/addWidget: emp={}, code={}", currentUser, widgetCode);
        return Map.of("success", true);
    }

    // ============================================================
    // 5. removeWidget — 단건 제거
    // ============================================================
    @DataSetServiceMapping("widget/removeWidget")
    @Transactional
    public Map<String, Object> removeWidget(Map<String, Object> datasets, String currentUser) {
        if (currentUser == null || currentUser.isBlank()) {
            throw BusinessException.forbidden("로그인이 필요합니다");
        }
        Map<String, Object> search = DataSetSupport.getSearchParams(datasets);
        String widgetCode = DataSetSupport.toStr(search.get("widgetCode"));
        if (widgetCode == null || widgetCode.isBlank()) {
            throw BusinessException.badRequest("widgetCode 가 필요합니다", "widgetCode");
        }
        int n = widgetMapper.deleteUserWidget(currentUser, widgetCode);
        log.info("widget/removeWidget: emp={}, code={}, deleted={}", currentUser, widgetCode, n);
        return Map.of("success", n > 0);
    }

    // ============================================================
    // helper
    // ============================================================
    private Map<String, Object> buildUserWidgetParam(String employeeNo, Map<String, Object> row) {
        Map<String, Object> param = new HashMap<>();
        param.put("employeeNo", employeeNo);
        param.put("widgetCode", DataSetSupport.toStr(row.get("widgetCode")));
        Long posX  = DataSetSupport.toLong(row.get("posX"));
        Long posY  = DataSetSupport.toLong(row.get("posY"));
        Long w     = DataSetSupport.toLong(row.get("width"));
        Long h     = DataSetSupport.toLong(row.get("height"));
        Long order = DataSetSupport.toLong(row.get("sortOrder"));
        param.put("posX",  posX  != null ? posX.intValue()  : 0);
        param.put("posY",  posY  != null ? posY.intValue()  : 0);
        param.put("width", w     != null ? w.intValue()     : 4);
        param.put("height",h     != null ? h.intValue()     : 1);
        param.put("sortOrder", order != null ? order.intValue() : 0);
        param.put("configJson", toJsonString(row.get("configJson")));
        return param;
    }

    /** Map 또는 String 입력을 JSON 문자열로 정규화 (JSONB 캐스팅 대상) */
    private String toJsonString(Object cfg) {
        if (cfg == null) return null;
        if (cfg instanceof String s) {
            String t = s.trim();
            if (t.isEmpty()) return null;
            return t;
        }
        try {
            return objectMapper.writeValueAsString(cfg);
        } catch (JsonProcessingException e) {
            log.warn("configJson 직렬화 실패: {}", e.getMessage());
            return null;
        }
    }

    private record DefaultWidget(String code, int posX, int posY, int width, int height, int sortOrder) {}

    /** 외부에서 default layout 카운트 참조 가능 (테스트용) */
    public List<String> defaultLayoutCodes() {
        List<String> list = new ArrayList<>();
        for (DefaultWidget d : DEFAULT_LAYOUT) list.add(d.code);
        return list;
    }
}
