package com.platform.v3.bff.adapter;

import com.platform.v3.bff.port.VideoPort;
import io.jsonwebtoken.Jwts;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.spec.SecretKeySpec;
import java.util.Date;
import java.util.Map;

/**
 * LiveKit JWT 발급 어댑터.
 * LiveKit 은 서버 측에서 HS256 JWT 를 발급하여 클라이언트에 전달.
 */
@Component
public class LiveKitAdapter implements VideoPort {

    private final String apiKey;
    private final String apiSecret;

    public LiveKitAdapter(
            @Value("${bff.livekit.api-key}") String apiKey,
            @Value("${bff.livekit.api-secret}") String apiSecret) {
        this.apiKey = apiKey;
        this.apiSecret = apiSecret;
    }

    @Override
    public Map<String, Object> createRoom(String roomName, String ownerUser) {
        // LiveKit 의 방은 첫 접속 시 자동 생성됨. 메타데이터만 반환.
        return Map.of("room", roomName, "owner", ownerUser, "autoCreate", true);
    }

    @Override
    public String issueToken(String roomName, String userName, boolean canPublish) {
        long now = System.currentTimeMillis();
        long exp = now + 6 * 60 * 60 * 1000L; // 6h
        Map<String, Object> video = Map.of(
                "room", roomName,
                "roomJoin", true,
                "canPublish", canPublish,
                "canSubscribe", true
        );
        return Jwts.builder()
                .issuer(apiKey)
                .subject(userName)
                .issuedAt(new Date(now))
                .expiration(new Date(exp))
                .claim("name", userName)
                .claim("video", video)
                .signWith(new SecretKeySpec(apiSecret.getBytes(), "HmacSHA256"))
                .compact();
    }

    @Override
    public Map<String, Object> getRoom(String roomName) {
        return Map.of("room", roomName, "stub", true);
    }

    @Override
    public void deleteRoom(String roomName) {
        // TODO: LiveKit RoomService 호출
    }
}
