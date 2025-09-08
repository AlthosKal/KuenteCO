package org.kuenteco.backend.service.notification;

import java.time.LocalDateTime;

public interface NotificationService {
    Object getAllNotifications();

    Object getNotificationsByDateRange(LocalDateTime fromDate, LocalDateTime toDate);
}
