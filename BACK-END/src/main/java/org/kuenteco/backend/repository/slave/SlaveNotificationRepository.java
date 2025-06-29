package org.kuenteco.backend.repository.slave;

import java.time.LocalDateTime;
import java.util.List;
import org.kuenteco.backend.entity.Notification;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveNotificationRepository extends JpaRepository<Notification, Integer> {

    List<Notification> findByUserOrderByDateSendDesc(User user);

    List<Notification> findByProfileOrderByDateSendDesc(Profile profile);

    List<Notification> findByUserAndTitleContaining(User user, String contentTitle);

    List<Notification> findByUserAndDateSendBetween(
            User user, LocalDateTime dateSendAfter, LocalDateTime dateSendBefore);

    List<Notification> findByProfileAfterAndDateSendBetween(
            Profile profileAfter, LocalDateTime dateSendAfter, LocalDateTime dateSendBefore);

    List<Notification> findByProfileAndTitleContaining(Profile profile, String contentTitle);
}
