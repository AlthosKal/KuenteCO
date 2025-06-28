package org.kuenteco.backend.service.notification;

import java.sql.Timestamp;

public interface NotificationService {
    Object getAllNotifications();

    Object getNotificationsByDateRange(Timestamp fromDate, Timestamp toDate);

    Object searchNotifications(String keyword);
}
