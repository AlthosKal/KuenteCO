package org.kuenteco.backend.service.notification;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.entity.Notification;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.exception.exceptions.NotificationException;
import org.kuenteco.backend.mapper.NotificationMapper;
import org.kuenteco.backend.repository.slave.SlaveNotificationRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
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
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        return switch (role) {
            case ROLE_USER -> {
                User user =
                        slaveUserRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new NotificationException("Usuario no encontrado"));
                yield getUserNotifications(user);
            }
            case ROLE_PROFILE -> {
                Profile profile =
                        slaveProfileRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new NotificationException("Perfil no encontrado"));
                yield getProfileNotifications(profile);
            }
        };
    }

    @Override
    public Object getNotificationsByDateRange(LocalDateTime fromDate, LocalDateTime toDate) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        log.info("Obteniendo un rango especifico de notificaciones para: {}", email);

        return switch (role) {
            case ROLE_USER -> {
                User user =
                        slaveUserRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new NotificationException("Usuario no encontrado"));
                yield getUserNotificationsByRangeDate(user, fromDate, toDate);
            }
            case ROLE_PROFILE -> {
                Profile profile =
                        slaveProfileRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new NotificationException("Perfil no encontrado"));
                yield getProfileNotificationsByRangeDate(profile, fromDate, toDate);
            }
        };
    }

    @Override
    public Object searchNotifications(String keyword) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();
        log.info("Buscando notificaciones para: {}", email);

        return switch (role) {
            case ROLE_USER -> {
                User user =
                        slaveUserRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new NotificationException("Usuario no encontrado"));
                yield getUserNotificationsByContentContaining(user, keyword);
            }
            case ROLE_PROFILE -> {
                Profile profile =
                        slaveProfileRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new NotificationException("Perfil no encontrado"));
                yield getProfileNotificationsByContentContaining(profile, keyword);
            }
        };
    }

    // Método placeholder para integración con servicios externos
    //    private void sendNotificationToExternalServices(Notification notification) {
    // TODO: Implementar integración con:
    // - Servicio de email (SendGrid)
    // - Servicio de push notifications (Firebase)
    // - Servicio de SMS (Twilio)
    // }

    private Object getUserNotifications(User user) {
        List<Notification> notifications =
                slaveNotificationRepository.findByUserOrderByDateSendDesc(user);

        if (notifications.isEmpty()) {
            return "No tienes deudas registradas";
        }
        return notificationMapper.toDTOList(notifications);
    }

    private Object getUserNotificationsByRangeDate(
            User user, LocalDateTime fromDate, LocalDateTime toDate) {
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
            Profile profile, LocalDateTime fromDate, LocalDateTime toDate) {
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
