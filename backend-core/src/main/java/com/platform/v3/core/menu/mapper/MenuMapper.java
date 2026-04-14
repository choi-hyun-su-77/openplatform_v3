package com.platform.v3.core.menu.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface MenuMapper {
    List<Map<String, Object>> selectMenusByRoles(@Param("roles") List<String> roles);
}
