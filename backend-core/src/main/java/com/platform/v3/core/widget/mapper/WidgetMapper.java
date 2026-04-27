package com.platform.v3.core.widget.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 대시보드 위젯 매퍼 — db_widget(카탈로그) + db_user_widget(사용자 배치).
 */
@Mapper
public interface WidgetMapper {

    // ── 카탈로그 ──

    /** 활성 위젯 카탈로그 전체 (widget_code 오름차순) */
    List<Map<String, Object>> selectCatalog();

    /** 카탈로그 단건 (FK 검증 / addWidget 시 default size 조회) */
    Map<String, Object> selectCatalogByCode(@Param("widgetCode") String widgetCode);

    // ── 사용자 배치 ──

    /** 내 위젯 (배치/사이즈/config + 카탈로그 title/category 조인) */
    List<Map<String, Object>> selectMine(@Param("employeeNo") String employeeNo);

    /** 단건 INSERT — UNIQUE 위반 시 update */
    int insertUserWidget(Map<String, Object> row);

    /** 위치/크기/config 업데이트 */
    int updateUserWidget(Map<String, Object> row);

    /** 단건 삭제 (employeeNo + widgetCode) */
    int deleteUserWidget(@Param("employeeNo") String employeeNo,
                         @Param("widgetCode") String widgetCode);

    /** 사용자 위젯 행이 0건인지 확인 — 첫 로그인 자동 시드 트리거 */
    int countMine(@Param("employeeNo") String employeeNo);
}
