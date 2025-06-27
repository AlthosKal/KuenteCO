package org.kuenteco.backend.repository.slave;

import java.sql.Timestamp;
import java.util.List;
import org.kuenteco.backend.entity.Notification;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface SlaveNotificationRepository extends JpaRepository<Notification, Integer> {

    List<Notification> findByUserOrderByDateSendDesc(User user);

    List<Notification> findByProfileOrderByDateSendDesc(Profile profile);

    @Query("SELECT COUNT(n) FROM Notification n WHERE n.user = :user")
    Long countByUser(User user);

    @Query("SELECT COUNT(n) FROM Notification n WHERE n.profile = :profile")
    Long countByProfile(Profile profile);

    @Query("SELECT n FROM Notification n WHERE n.user = :user AND n.dateSend >= CURRENT_TIMESTAMP - INTERVAL '1 day' ORDER BY n.dateSend DESC")
    List<Notification> findRecentByUser(User user);

    @Query("SELECT n FROM Notification n WHERE n.profile = :profile AND n.dateSend >= CURRENT_TIMESTAMP - INTERVAL '1 day' ORDER BY n.dateSend DESC")
    List<Notification> findRecentByProfile(Profile profile);

    @Query("SELECT n FROM Notification n WHERE n.user = :user AND n.dateSend >= :fromDate AND n.dateSend <= :toDate ORDER BY n.dateSend DESC")
    List<Notification> findByUserAndDateBetween(User user, Timestamp fromDate, Timestamp toDate);

    @Query("SELECT n FROM Notification n WHERE n.profile = :profile AND n.dateSend >= :fromDate AND n.dateSend <= :toDate ORDER BY n.dateSend DESC")
    List<Notification> findByProfileAndDateBetween(Profile profile, Timestamp fromDate, Timestamp toDate);

    @Query("SELECT n FROM Notification n WHERE n.user = :user AND (LOWER(n.content.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(n.content.body) LIKE LOWER(CONCAT('%', :keyword, '%'))) ORDER BY n.dateSend DESC")
    List<Notification> findByUserAndContentContaining(User user, String keyword);

    @Query("SELECT n FROM Notification n WHERE n.profile = :profile AND (LOWER(n.content.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(n.content.body) LIKE LOWER(CONCAT('%', :keyword, '%'))) ORDER BY n.dateSend DESC")
    List<Notification> findByProfileAndContentContaining(Profile profile, String keyword);

    @Query("SELECT COUNT(n) FROM Notification n WHERE n.user = :user AND n.dateSend >= :fromDate")
    Long countByUserAndDateAfter(User user, Timestamp fromDate);

    @Query("SELECT COUNT(n) FROM Notification n WHERE n.profile = :profile AND n.dateSend >= :fromDate")
    Long countByProfileAndDateAfter(Profile profile, Timestamp fromDate);
}
