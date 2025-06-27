package org.kuenteco.backend.service.logic.notification;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.logic.notification.NewNotificationDTO;
import org.kuenteco.backend.dto.logic.notification.NotificationDTO;
import org.kuenteco.backend.entity.Notification;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.extra.ContentNotification;
import org.kuenteco.backend.exception.CustomException;
import org.kuenteco.backend.repository.master.MasterNotificationRepository;
import org.kuenteco.backend.repository.master.MasterProfileRepository;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveNotificationRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@AllArgsConstructor
public class NotificationService {

    private final MasterNotificationRepository masterNotificationRepository;
    private final SlaveNotificationRepository slaveNotificationRepository;
    private final MasterUserRepository masterUserRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final MasterProfileRepository masterProfileRepository;
    private final SlaveProfileRepository slaveProfileRepository;

    @Transactional(readOnly = true)
    public List<NotificationDTO> getAllNotifications() {
        return slaveNotificationRepository.findAllOrderByDateSendDesc().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<NotificationDTO> getAllNotifications(Pageable pageable) {
        return slaveNotificationRepository
                .findAllOrderByDateSendDesc(pageable)
                .map(this::convertToDTO);
    }

    @Transactional(readOnly = true)
    public NotificationDTO getNotificationById(Integer id) {
        Notification notification =
                slaveNotificationRepository
                        .findById(id)
                        .orElseThrow(
                                () ->
                                        new CustomException(
                                                "Notificación no encontrada con ID: " + id,
                                                HttpStatus.NOT_FOUND));
        return convertToDTO(notification);
    }

    @Transactional(readOnly = true)
    public List<NotificationDTO> getNotificationsByUserId(String userId) {
        return slaveNotificationRepository.findByUserIdOrderByDateSendDesc(userId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<NotificationDTO> getNotificationsByUserId(String userId, Pageable pageable) {
        return slaveNotificationRepository
                .findByUserIdOrderByDateSendDesc(userId, pageable)
                .map(this::convertToDTO);
    }

    @Transactional(readOnly = true)
    public List<NotificationDTO> getNotificationsByProfileId(Integer profileId) {
        return slaveNotificationRepository.findByProfileIdOrderByDateSendDesc(profileId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<NotificationDTO> getNotificationsByProfileId(Integer profileId, Pageable pageable) {
        return slaveNotificationRepository
                .findByProfileIdOrderByDateSendDesc(profileId, pageable)
                .map(this::convertToDTO);
    }

    @Transactional(readOnly = true)
    public List<NotificationDTO> getRecentNotificationsByUserId(String userId) {
        return slaveNotificationRepository.findRecentByUserId(userId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<NotificationDTO> getRecentNotificationsByProfileId(Integer profileId) {
        return slaveNotificationRepository.findRecentByProfileId(profileId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<NotificationDTO> getNotificationsByUserIdAndDateRange(
            String userId, Timestamp fromDate, Timestamp toDate) {
        return slaveNotificationRepository
                .findByUserIdAndDateBetween(userId, fromDate, toDate)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<NotificationDTO> getNotificationsByProfileIdAndDateRange(
            Integer profileId, Timestamp fromDate, Timestamp toDate) {
        return slaveNotificationRepository
                .findByProfileIdAndDateBetween(profileId, fromDate, toDate)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<NotificationDTO> searchNotificationsByUserId(String userId, String keyword) {
        return slaveNotificationRepository
                .findByUserIdAndContentContaining(userId, keyword)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<NotificationDTO> searchNotificationsByProfileId(Integer profileId, String keyword) {
        return slaveNotificationRepository
                .findByProfileIdAndContentContaining(profileId, keyword)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Long getNotificationCountByUserId(String userId) {
        return slaveNotificationRepository.countByUserId(userId);
    }

    @Transactional(readOnly = true)
    public Long getNotificationCountByProfileId(Integer profileId) {
        return slaveNotificationRepository.countByProfileId(profileId);
    }

    @Transactional(readOnly = true)
    public Long getRecentNotificationCountByUserId(String userId) {
        Timestamp yesterday = Timestamp.valueOf(LocalDateTime.now().minusDays(1));
        return slaveNotificationRepository.countByUserIdAndDateAfter(userId, yesterday);
    }

    @Transactional(readOnly = true)
    public Long getRecentNotificationCountByProfileId(Integer profileId) {
        Timestamp yesterday = Timestamp.valueOf(LocalDateTime.now().minusDays(1));
        return slaveNotificationRepository.countByProfileIdAndDateAfter(profileId, yesterday);
    }

    @Transactional
    public NotificationDTO createNotification(NewNotificationDTO newNotificationDTO) {
        validateNewNotification(newNotificationDTO);

        Notification notification = convertToEntity(newNotificationDTO);
        Notification savedNotification = masterNotificationRepository.save(notification);

        // Aquí se podría integrar con servicios de envío (email, push, SMS)
        // sendNotificationToExternalServices(savedNotification);

        return convertToDTO(savedNotification);
    }

    @Transactional
    public List<NotificationDTO> createNotifications(List<NewNotificationDTO> newNotificationsDTO) {
        return newNotificationsDTO.stream()
                .map(this::createNotification)
                .collect(Collectors.toList());
    }

    @Transactional
    public NotificationDTO updateNotification(NotificationDTO notificationDTO) {
        Notification existingNotification =
                slaveNotificationRepository
                        .findById(notificationDTO.getId())
                        .orElseThrow(
                                () ->
                                        new CustomException(
                                                "Notificación no encontrada con ID: "
                                                        + notificationDTO.getId(),
                                                HttpStatus.NOT_FOUND));

        updateNotificationFromDTO(existingNotification, notificationDTO);
        Notification savedNotification = masterNotificationRepository.save(existingNotification);
        return convertToDTO(savedNotification);
    }

    @Transactional
    public void deleteNotification(Integer id) {
        if (!slaveNotificationRepository.existsById(id)) {
            throw new CustomException(
                    "Notificación no encontrada con ID: " + id, HttpStatus.NOT_FOUND);
        }
        masterNotificationRepository.deleteById(id);
    }

    @Transactional
    public void deleteAllNotificationsByUserId(String userId) {
        masterNotificationRepository.deleteAllByUserId(userId);
    }

    @Transactional
    public void deleteAllNotificationsByProfileId(Integer profileId) {
        masterNotificationRepository.deleteAllByProfileId(profileId);
    }

    @Transactional
    public void deleteOldNotifications(int daysOld) {
        Timestamp cutoffDate = Timestamp.valueOf(LocalDateTime.now().minusDays(daysOld));
        masterNotificationRepository.deleteOldNotifications(cutoffDate);
    }

    // Métodos de conveniencia para crear notificaciones específicas
    @Transactional
    public NotificationDTO createBudgetExceededNotification(
            String userId, Integer profileId, String categoryName, double spent, double budget) {
        ContentNotification content =
                new ContentNotification(
                        "Presupuesto Excedido",
                        String.format(
                                "Has excedido el presupuesto asignado para la categoría %s. Gastado: $%.2f, Presupuesto: $%.2f",
                                categoryName, spent, budget),
                        LocalDateTime.now().toString());

        NewNotificationDTO dto = new NewNotificationDTO();
        dto.setUserId(userId);
        dto.setProfileId(profileId);
        dto.setContent(content);
        dto.setDateSend(new Timestamp(System.currentTimeMillis()));

        return createNotification(dto);
    }

    @Transactional
    public NotificationDTO createDebtReminderNotification(
            String userId,
            Integer profileId,
            String debtName,
            String dueDate,
            double pendingAmount) {
        ContentNotification content =
                new ContentNotification(
                        "Recordatorio de Deuda",
                        String.format(
                                "Tu deuda \"%s\" vence el %s. Monto pendiente: $%.2f. Por favor, realiza el pago.",
                                debtName, dueDate, pendingAmount),
                        LocalDateTime.now().toString());

        NewNotificationDTO dto = new NewNotificationDTO();
        dto.setUserId(userId);
        dto.setProfileId(profileId);
        dto.setContent(content);
        dto.setDateSend(new Timestamp(System.currentTimeMillis()));

        return createNotification(dto);
    }

    @Transactional
    public NotificationDTO createTransactionAlertNotification(
            String userId, Integer profileId, String message) {
        ContentNotification content =
                new ContentNotification(
                        "Alerta de Transacción", message, LocalDateTime.now().toString());

        NewNotificationDTO dto = new NewNotificationDTO();
        dto.setUserId(userId);
        dto.setProfileId(profileId);
        dto.setContent(content);
        dto.setDateSend(new Timestamp(System.currentTimeMillis()));

        return createNotification(dto);
    }

    private void validateNewNotification(NewNotificationDTO newNotificationDTO) {
        // Validar que tenga usuario o perfil, pero no ambos
        if ((newNotificationDTO.getUserId() == null && newNotificationDTO.getProfileId() == null)
                || (newNotificationDTO.getUserId() != null
                        && newNotificationDTO.getProfileId() != null)) {
            throw new CustomException(
                    "La notificación debe estar asociada a un usuario O a un perfil, pero no a ambos",
                    HttpStatus.BAD_REQUEST);
        }

        // Validar que el usuario existe si se proporciona
        if (newNotificationDTO.getUserId() != null) {
            if (!slaveUserRepository.existsById(newNotificationDTO.getUserId())) {
                throw new CustomException(
                        "Usuario no encontrado con ID: " + newNotificationDTO.getUserId(),
                        HttpStatus.NOT_FOUND);
            }
        }

        // Validar que el perfil existe si se proporciona
        if (newNotificationDTO.getProfileId() != null) {
            if (!slaveProfileRepository.existsById(newNotificationDTO.getProfileId())) {
                throw new CustomException(
                        "Perfil no encontrado con ID: " + newNotificationDTO.getProfileId(),
                        HttpStatus.NOT_FOUND);
            }
        }

        // Validar contenido
        if (newNotificationDTO.getContent() == null
                || newNotificationDTO.getContent().getTitle() == null
                || newNotificationDTO.getContent().getTitle().trim().isEmpty()) {
            throw new CustomException(
                    "El título de la notificación es obligatorio", HttpStatus.BAD_REQUEST);
        }
    }

    private Notification convertToEntity(NewNotificationDTO dto) {
        Notification notification = new Notification();
        notification.setContent(dto.getContent());
        notification.setDateSend(dto.getDateSend());

        if (dto.getUserId() != null) {
            User user =
                    slaveUserRepository
                            .findById(dto.getUserId())
                            .orElseThrow(
                                    () ->
                                            new CustomException(
                                                    "Usuario no encontrado", HttpStatus.NOT_FOUND));
            notification.setUser(user);
        }

        if (dto.getProfileId() != null) {
            Profile profile =
                    slaveProfileRepository
                            .findById(dto.getProfileId())
                            .orElseThrow(
                                    () ->
                                            new CustomException(
                                                    "Perfil no encontrado", HttpStatus.NOT_FOUND));
            notification.setProfile(profile);
        }

        return notification;
    }

    private void updateNotificationFromDTO(Notification notification, NotificationDTO dto) {
        notification.setContent(dto.getContent());
        notification.setDateSend(dto.getDateSend());
    }

    private NotificationDTO convertToDTO(Notification notification) {
        NotificationDTO dto = new NotificationDTO();
        dto.setId(notification.getId());
        dto.setContent(notification.getContent());
        dto.setDateSend(notification.getDateSend());

        if (notification.getUser() != null) {
            dto.setUserId(notification.getUser().getId());
        }

        if (notification.getProfile() != null) {
            dto.setProfileId(notification.getProfile().getId());
        }

        return dto;
    }

    // Método placeholder para integración con servicios externos
    private void sendNotificationToExternalServices(Notification notification) {
        // TODO: Implementar integración con:
        // - Servicio de email (SendGrid, Amazon SES, etc.)
        // - Servicio de push notifications (Firebase, etc.)
        // - Servicio de SMS (Twilio, etc.)
    }
}
