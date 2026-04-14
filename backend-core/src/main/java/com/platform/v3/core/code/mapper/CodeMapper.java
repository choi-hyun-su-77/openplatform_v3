package com.platform.v3.core.code.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface CodeMapper {
    List<Map<String, Object>> selectCodesByGroups(@Param("groups") List<String> groups);
}
