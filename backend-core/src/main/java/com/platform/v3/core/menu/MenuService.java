package com.platform.v3.core.menu;

import com.platform.v3.core.common.DataSetSupport;
import com.platform.v3.core.dataset.DataSetServiceMapping;
import com.platform.v3.core.menu.mapper.MenuMapper;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class MenuService {

    private final MenuMapper menuMapper;

    public MenuService(MenuMapper menuMapper) {
        this.menuMapper = menuMapper;
    }

    @DataSetServiceMapping("menu/searchByUser")
    public Map<String, Object> searchByUser(Map<String, Object> datasets, String currentUser) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        List<String> roles = auth == null
                ? List.of("ROLE_USER")
                : auth.getAuthorities().stream()
                      .map(Object::toString)
                      .collect(Collectors.toList());
        if (roles.isEmpty()) roles = List.of("ROLE_USER");
        List<Map<String, Object>> menus = menuMapper.selectMenusByRoles(roles);
        return Map.of("ds_menus", DataSetSupport.rows(menus));
    }
}
