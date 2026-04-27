package com.platform.v3.bff.port;

import java.util.List;
import java.util.Map;

/**
 * Identity 도메인 (Keycloak) 포트.
 *
 * <h2>관리자 콘솔 확장</h2>
 * Phase 14 트랙 5 에서 사용자 CRUD / 활성토글 / 비번리셋 4 메서드 추가.
 * backend-core {@code AdminService} 가 BFF REST 를 통해 호출.
 */
public interface IdentityPort {
    Map<String, Object> getMe(String accessToken);
    List<String> getRoles(String accessToken);
    Map<String, Object> getUserById(String userId);

    // ─── Phase 14 Track 5: Admin Console ─────────────────────────────────
    /**
     * Keycloak 사용자 신규 생성.
     * @param request {username, email, firstName, lastName?, password?, roles?(List&lt;String&gt;)}
     * @return {userId, username}
     */
    Map<String, Object> createUser(Map<String, Object> request);

    /**
     * Keycloak 사용자 정보 수정 (이메일/이름/역할).
     * @param username Keycloak preferred_username
     * @param request {email?, firstName?, lastName?, roles?(List&lt;String&gt;)}
     */
    Map<String, Object> updateUser(String username, Map<String, Object> request);

    /**
     * 사용자 활성/비활성 토글.
     * @param username Keycloak preferred_username
     * @param active true=활성, false=비활성
     */
    Map<String, Object> setActive(String username, boolean active);

    /**
     * 임시 비밀번호 발급 (다음 로그인 시 변경 강제).
     * @param username Keycloak preferred_username
     * @param temporaryPassword 임시 비밀번호 (기본 "temp123!")
     */
    Map<String, Object> resetPassword(String username, String temporaryPassword);
}
