package com.platform.v3.core.common;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.util.Map;

/**
 * backend-core → backend-bff HTTP 호출 클라이언트.
 *
 * 각 도메인 서비스 (RoomService 등) 가 BFF 의 어댑터 (LiveKit/Stalwart/RocketChat) 를
 * 호출해야 할 때 사용한다. 인증은 service-to-service 호출이므로 토큰 없이 컨테이너
 * 네트워크 내에서 직접 통신 (BFF 측에서는 ROLE_SERVICE 로 우회 또는 비인증 endpoint 만 호출).
 *
 * 현재 사용처:
 *  - RoomService.reserve() → POST /api/bff/video/room (LiveKit 룸 메타 발급)
 *
 * BFF 가 다운되어도 회의실 예약 자체는 성공해야 하므로, 호출 실패 시 null 반환 +
 * 경고 로그 만 남긴다 (비즈니스 트랜잭션 롤백 안 함).
 */
@Component
public class BffClient {

    private static final Logger log = LoggerFactory.getLogger(BffClient.class);

    private final RestClient restClient;

    public BffClient(@Value("${bff.base-url:http://backend-bff:8080}") String baseUrl) {
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .defaultHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
                .build();
    }

    /**
     * LiveKit 룸 메타 발급 호출.
     * BFF /api/bff/video/room 은 보호된 엔드포인트이지만, dev 모드에서는
     * 룸 자동 생성(autoCreate=true) 메타만 반환하므로 실패해도 무방.
     *
     * @param roomName 룸 이름 (예: "rm-{bookingId}")
     * @param ownerUser 예약자 employee_no
     * @return BFF 응답 Map 또는 호출 실패 시 null
     */
    public Map<String, Object> createVideoRoom(String roomName, String ownerUser) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> resp = restClient.post()
                    .uri("/api/bff/video/room")
                    .body(Map.of("roomName", roomName, "ownerUser", ownerUser))
                    .retrieve()
                    .body(Map.class);
            return resp;
        } catch (RestClientException e) {
            log.warn("BFF createVideoRoom 호출 실패 (룸 자동 생성으로 폴백): roomName={} err={}",
                    roomName, e.getMessage());
            return null;
        }
    }

    /**
     * 알림 이메일 발송 (Phase 14 트랙 6).
     * BFF /api/bff/mail/send 는 JwtAuthenticationToken 기반으로 보호되어 있으므로
     * service-to-service 호출에서는 401 가능성이 있다 — 호출 실패 시 warn 로그만,
     * PORTAL 채널 발송은 정상 동작하므로 알림 자체는 손실되지 않는다.
     *
     * BFF 측에서 service-account 인증을 별도 추가하면 정상화됨 (warn.md 트랙 6 항목 참조).
     */
    public Map<String, Object> sendNotificationEmail(String toEmail, String subject, String body) {
        if (toEmail == null || toEmail.isBlank()) return null;
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> resp = restClient.post()
                    .uri("/api/bff/mail/send")
                    .body(Map.of(
                            "to", toEmail,
                            "subject", subject != null ? subject : "(알림)",
                            "body", body != null ? body : ""
                    ))
                    .retrieve()
                    .body(Map.class);
            return resp;
        } catch (RestClientException e) {
            log.warn("BFF sendNotificationEmail 호출 실패 (PORTAL 채널은 정상): to={} err={}",
                    toEmail, e.getMessage());
            return null;
        }
    }

    /**
     * 메신저 DM 발송 (Phase 14 트랙 6).
     *
     * <p><b>현재 미구현</b> — RocketChatAdapter 의 sendDirectMessage 메서드가 stub 이고
     * BFF 에 /api/bff/messenger/dm 엔드포인트가 없다. MESSENGER 채널은 비활성과 동등 취급.
     * Phase 10 (Rocket.Chat 실호출 구체화) 또는 별도 트랙에서 구현 예정.
     *
     * @return 항상 null (호출 실패와 동일 — NotificationService 가 warn 만 남기고 스킵)
     */
    public Map<String, Object> sendNotificationDm(String username, String message) {
        log.debug("sendNotificationDm: 미구현 (RocketChatAdapter.sendDm stub) — username={} msg={}",
                username, message);
        return null;
    }
}
