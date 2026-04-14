package com.platform.v3.core.i18n.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface I18nMapper {
    List<Map<String, Object>> selectMessages(@Param("locale") String locale,
                                             @Param("type") String type);
}
