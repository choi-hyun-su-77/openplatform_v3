package com.platform.v3.bff.port;

import java.util.List;
import java.util.Map;

public interface IdentityPort {
    Map<String, Object> getMe(String accessToken);
    List<String> getRoles(String accessToken);
    Map<String, Object> getUserById(String userId);
}
