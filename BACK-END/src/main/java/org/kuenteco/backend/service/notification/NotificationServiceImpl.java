package org.kuenteco.backend.service.notification;

import java.sql.Timestamp;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.entity.Notification;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.exception.exceptions.NotificationException;
import org.kuenteco.backend.mapper.NotificationMapper;
import org.kuenteco.backend.repository.slave.SlaveNotificationRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@AllArgsConstructor
public class NotificationServiceImpl implements NotificationService {
    private final SlaveNotificationRepository slaveNotificationRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final SlaveProfileRepository slaveProfileRepository;
    private final NotificationMapper notificationMapper;

    @Override
    public Object getAllNotifications() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        log.info("Obteniendo notificaciones para: {}", email);

        User user = slaveUserRepository.findByEmail(email).orElse(null);
        if (user != null) {
            log.info("Usuario encontrado: {}", email);
            return getUserNotifications(user);
        }

        Profile profile = slaveProfileRepository.findByEmail(email).orElse(null);
        if (profile != null) {
            log.info("Perfil encontrado: {}", email);
            return getProfileNotifications(profile);
        }
        throw new NotificationException("Usuario o perfil no encontrado" + email);
    }

    @Override
    public Object getNotificationsByDateRange(Timestamp fromDate, Timestamp toDate) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        log.info("Obteniendo un rango especifico de notificaciones para: {}", email);

        User user = slaveUserRepository.findByEmail(email).orElse(null);
        if (user != null) {
            log.info("Usuario encontrado: {}", email);
            return getUserNotificationsByRangeDate(user, fromDate, toDate);
        }

        Profile profile = slaveProfileRepository.findByEmail(email).orElse(null);
        if (profile != null) {
            log.info("Perfil encontrado: {}", email);
            return getProfileNotificationsByRangeDate(profile, fromDate, toDate);
        }
        throw new NotificationException("Usuario o perfil no encontrado" + email);
    }

    @Override
    public Object searchNotifications(String keyword) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        log.info("Buscando notificaciones para: {}", email);

        User user = slaveUserRepository.findByEmail(email).orElse(null);
        if (user != null) {
            log.info("Usuario encontrado: {}", email);
            return getUserNotificationsByContentContaining(user, keyword);
        }

        Profile profile = slaveProfileRepository.findByEmail(email).orElse(null);
        if (profile != null) {
            log.info("Perfil encontrado: {}", email);
            return getProfileNotificationsByContentContaining(profile, keyword);
        }
        throw new NotificationException("Usuario o perfil no encontrado" + email);
    }

    // Método placeholder para integración con servicios externos
    private void sendNotificationToExternalServices(Notification notification) {
        // TODO: Implementar integración con:
        // - Servicio de email (SendGrid)
        // - Servicio de push notifications (Firebase)
        // - Servicio de SMS (Twilio)
    }

    private Object getUserNotifications(User user) {
        List<Notification> notifications =
                slaveNotificationRepository.findByUserOrderByDateSendDesc(user);

        if (notifications.isEmpty()) {
            return "No tienes deudas registradas";
        }
        return notificationMapper.toDTOList(notifications);
    }

    private Object getUserNotificationsByRangeDate(
            User user, Timestamp fromDate, Timestamp toDate) {
        List<Notification> notifications =
                slaveNotificationRepository.findByUserAndDateSendBetween(
                        user, fromDate, toDate); // findByUserAndDateBetween

        if (notifications.isEmpty()) {
            return "No tienes deudas registradas";
        }
        return notificationMapper.toDTOList(notifications);
    }

    private Object getUserNotificationsByContentContaining(User user, String keyword) {
        List<Notification> notifications =
                slaveNotificationRepository.findByUserAndTitleContaining(user, keyword);

        if (notifications.isEmpty()) {
            return "No tienes deudas registradas";
        }
        return notificationMapper.toDTOList(notifications);
    }

    private Object getProfileNotifications(Profile profile) {
        List<Notification> notifications =
                slaveNotificationRepository.findByProfileOrderByDateSendDesc(profile);

        if (notifications.isEmpty()) {
            return "No tienes deudas registradas";
        }
        return notificationMapper.toDTOList(notifications);
    }

    private Object getProfileNotificationsByRangeDate(
            Profile profile, Timestamp fromDate, Timestamp toDate) {
        List<Notification> notifications =
                slaveNotificationRepository.findByProfileAfterAndDateSendBetween(
                        profile, fromDate, toDate);

        if (notifications.isEmpty()) {
            return "No tienes deudas registradas";
        }
        return notificationMapper.toDTOList(notifications);
    }

    private Object getProfileNotificationsByContentContaining(Profile profile, String keyword) {
        List<Notification> notifications =
                slaveNotificationRepository.findByProfileAndTitleContaining(profile, keyword);

        if (notifications.isEmpty()) {
            return "No tienes deudas registradas";
        }
        return notificationMapper.toDTOList(notifications);
    }
}
