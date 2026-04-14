package com.platform.v3.core.notification.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface NotificationMapper {

    List<Map<String, Object>> selectNotifications(@Param("recipientId") Long recipientId,
                                                  @Param("unreadOnly") boolean unreadOnly,
                                                  @Param("limit") int limit);

    int countUnread(@Param("recipientId") Long recipientId);

    void markAsRead(@Param("notificationId") Long notificationId);

    void markAllAsRead(@Param("recipientId") Long recipientId);

    void insertNotification(Map<String, Object> notification);
}
