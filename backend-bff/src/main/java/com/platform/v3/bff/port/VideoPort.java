package com.platform.v3.bff.port;

import java.util.Map;

public interface VideoPort {
    Map<String, Object> createRoom(String roomName, String ownerUser);
    String issueToken(String roomName, String userName, boolean canPublish);
    Map<String, Object> getRoom(String roomName);
    void deleteRoom(String roomName);
}
