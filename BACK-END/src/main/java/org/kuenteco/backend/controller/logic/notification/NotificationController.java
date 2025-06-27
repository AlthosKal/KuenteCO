package org.kuenteco.backend.controller.logic.notification;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.sql.Timestamp;
import java.util.List;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.logic.notification.NewNotificationDTO;
import org.kuenteco.backend.dto.logic.notification.NotificationDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.logic.notification.NotificationService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/notification")
@AllArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<?> getAllNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            HttpServletRequest request) {

        if (size == 0) {
            // Si size es 0, devolver todas las notificaciones sin paginación
            List<NotificationDTO> notifications = notificationService.getAllNotifications();
            return new ResponseEntity<>(
                    ApiResponse.ok(
                            "Notificaciones obtenidas correctamente",
                            notifications,
                            request.getRequestURI()),
                    HttpStatus.OK);
        } else {
            // Con paginación
            Pageable pageable = PageRequest.of(page, size);
            Page<NotificationDTO> notifications = notificationService.getAllNotifications(pageable);
            return new ResponseEntity<>(
                    ApiResponse.ok(
                            "Notificaciones obtenidas correctamente",
                            notifications,
                            request.getRequestURI()),
                    HttpStatus.OK);
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getNotificationById(
            @PathVariable Integer id, HttpServletRequest request) {
        NotificationDTO notification = notificationService.getNotificationById(id);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificación obtenida correctamente",
                        notification,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getNotificationsByUserId(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            HttpServletRequest request) {

        if (size == 0) {
            List<NotificationDTO> notifications =
                    notificationService.getNotificationsByUserId(userId);
            return new ResponseEntity<>(
                    ApiResponse.ok(
                            "Notificaciones del usuario obtenidas correctamente",
                            notifications,
                            request.getRequestURI()),
                    HttpStatus.OK);
        } else {
            Pageable pageable = PageRequest.of(page, size);
            Page<NotificationDTO> notifications =
                    notificationService.getNotificationsByUserId(userId, pageable);
            return new ResponseEntity<>(
                    ApiResponse.ok(
                            "Notificaciones del usuario obtenidas correctamente",
                            notifications,
                            request.getRequestURI()),
                    HttpStatus.OK);
        }
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<?> getNotificationsByProfileId(
            @PathVariable Integer profileId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            HttpServletRequest request) {

        if (size == 0) {
            List<NotificationDTO> notifications =
                    notificationService.getNotificationsByProfileId(profileId);
            return new ResponseEntity<>(
                    ApiResponse.ok(
                            "Notificaciones del perfil obtenidas correctamente",
                            notifications,
                            request.getRequestURI()),
                    HttpStatus.OK);
        } else {
            Pageable pageable = PageRequest.of(page, size);
            Page<NotificationDTO> notifications =
                    notificationService.getNotificationsByProfileId(profileId, pageable);
            return new ResponseEntity<>(
                    ApiResponse.ok(
                            "Notificaciones del perfil obtenidas correctamente",
                            notifications,
                            request.getRequestURI()),
                    HttpStatus.OK);
        }
    }

    @GetMapping("/user/{userId}/recent")
    public ResponseEntity<?> getRecentNotificationsByUserId(
            @PathVariable String userId, HttpServletRequest request) {
        List<NotificationDTO> notifications =
                notificationService.getRecentNotificationsByUserId(userId);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificaciones recientes del usuario obtenidas correctamente",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/profile/{profileId}/recent")
    public ResponseEntity<?> getRecentNotificationsByProfileId(
            @PathVariable Integer profileId, HttpServletRequest request) {
        List<NotificationDTO> notifications =
                notificationService.getRecentNotificationsByProfileId(profileId);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificaciones recientes del perfil obtenidas correctamente",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/user/{userId}/range")
    public ResponseEntity<?> getNotificationsByUserIdAndDateRange(
            @PathVariable String userId,
            @RequestParam Timestamp fromDate,
            @RequestParam Timestamp toDate,
            HttpServletRequest request) {

        List<NotificationDTO> notifications =
                notificationService.getNotificationsByUserIdAndDateRange(userId, fromDate, toDate);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificaciones del usuario en rango de fechas obtenidas correctamente",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/profile/{profileId}/range")
    public ResponseEntity<?> getNotificationsByProfileIdAndDateRange(
            @PathVariable Integer profileId,
            @RequestParam Timestamp fromDate,
            @RequestParam Timestamp toDate,
            HttpServletRequest request) {

        List<NotificationDTO> notifications =
                notificationService.getNotificationsByProfileIdAndDateRange(
                        profileId, fromDate, toDate);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificaciones del perfil en rango de fechas obtenidas correctamente",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/user/{userId}/search")
    public ResponseEntity<?> searchNotificationsByUserId(
            @PathVariable String userId, @RequestParam String keyword, HttpServletRequest request) {

        List<NotificationDTO> notifications =
                notificationService.searchNotificationsByUserId(userId, keyword);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Búsqueda de notificaciones del usuario completada",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/profile/{profileId}/search")
    public ResponseEntity<?> searchNotificationsByProfileId(
            @PathVariable Integer profileId,
            @RequestParam String keyword,
            HttpServletRequest request) {

        List<NotificationDTO> notifications =
                notificationService.searchNotificationsByProfileId(profileId, keyword);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Búsqueda de notificaciones del perfil completada",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/user/{userId}/count")
    public ResponseEntity<?> getNotificationCountByUserId(
            @PathVariable String userId, HttpServletRequest request) {
        Long count = notificationService.getNotificationCountByUserId(userId);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Conteo de notificaciones del usuario obtenido correctamente",
                        count,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/profile/{profileId}/count")
    public ResponseEntity<?> getNotificationCountByProfileId(
            @PathVariable Integer profileId, HttpServletRequest request) {
        Long count = notificationService.getNotificationCountByProfileId(profileId);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Conteo de notificaciones del perfil obtenido correctamente",
                        count,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/user/{userId}/count/recent")
    public ResponseEntity<?> getRecentNotificationCountByUserId(
            @PathVariable String userId, HttpServletRequest request) {
        Long count = notificationService.getRecentNotificationCountByUserId(userId);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Conteo de notificaciones recientes del usuario obtenido correctamente",
                        count,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/profile/{profileId}/count/recent")
    public ResponseEntity<?> getRecentNotificationCountByProfileId(
            @PathVariable Integer profileId, HttpServletRequest request) {
        Long count = notificationService.getRecentNotificationCountByProfileId(profileId);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Conteo de notificaciones recientes del perfil obtenido correctamente",
                        count,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/add")
    public ResponseEntity<?> createNotification(
            @Valid @RequestBody NewNotificationDTO newNotificationDTO, HttpServletRequest request) {
        NotificationDTO createdNotification =
                notificationService.createNotification(newNotificationDTO);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificación creada correctamente",
                        createdNotification,
                        request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/batch/add")
    public ResponseEntity<?> createNotifications(
            @Valid @RequestBody List<NewNotificationDTO> newNotificationsDTO,
            HttpServletRequest request) {
        List<NotificationDTO> createdNotifications =
                notificationService.createNotifications(newNotificationsDTO);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificaciones creadas correctamente",
                        createdNotifications,
                        request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PatchMapping("/update")
    public ResponseEntity<?> updateNotification(
            @Valid @RequestBody NotificationDTO notificationDTO, HttpServletRequest request) {
        NotificationDTO updatedNotification =
                notificationService.updateNotification(notificationDTO);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificación actualizada correctamente",
                        updatedNotification,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteNotification(
            @PathVariable Integer id, HttpServletRequest request) {
        notificationService.deleteNotification(id);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificación eliminada correctamente", null, request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/batch")
    public ResponseEntity<?> deleteNotifications(
            @RequestParam List<Integer> ids, HttpServletRequest request) {
        ids.forEach(notificationService::deleteNotification);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        String.format("%d notificaciones eliminadas correctamente", ids.size()),
                        null,
                        request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/user/{userId}/all")
    public ResponseEntity<?> deleteAllNotificationsByUserId(
            @PathVariable String userId, HttpServletRequest request) {
        notificationService.deleteAllNotificationsByUserId(userId);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Todas las notificaciones del usuario eliminadas correctamente",
                        null,
                        request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/profile/{profileId}/all")
    public ResponseEntity<?> deleteAllNotificationsByProfileId(
            @PathVariable Integer profileId, HttpServletRequest request) {
        notificationService.deleteAllNotificationsByProfileId(profileId);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Todas las notificaciones del perfil eliminadas correctamente",
                        null,
                        request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/cleanup")
    public ResponseEntity<?> deleteOldNotifications(
            @RequestParam(defaultValue = "90") int daysOld, HttpServletRequest request) {
        notificationService.deleteOldNotifications(daysOld);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        String.format(
                                "Notificaciones más antiguas que %d días eliminadas correctamente",
                                daysOld),
                        null,
                        request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    // Endpoints para crear notificaciones específicas
    @PostMapping("/budget-exceeded")
    public ResponseEntity<?> createBudgetExceededNotification(
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) Integer profileId,
            @RequestParam String categoryName,
            @RequestParam double spent,
            @RequestParam double budget,
            HttpServletRequest request) {

        NotificationDTO notification =
                notificationService.createBudgetExceededNotification(
                        userId, profileId, categoryName, spent, budget);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificación de presupuesto excedido creada correctamente",
                        notification,
                        request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/debt-reminder")
    public ResponseEntity<?> createDebtReminderNotification(
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) Integer profileId,
            @RequestParam String debtName,
            @RequestParam String dueDate,
            @RequestParam double pendingAmount,
            HttpServletRequest request) {

        NotificationDTO notification =
                notificationService.createDebtReminderNotification(
                        userId, profileId, debtName, dueDate, pendingAmount);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificación de recordatorio de deuda creada correctamente",
                        notification,
                        request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/transaction-alert")
    public ResponseEntity<?> createTransactionAlertNotification(
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) Integer profileId,
            @RequestParam String message,
            HttpServletRequest request) {

        NotificationDTO notification =
                notificationService.createTransactionAlertNotification(userId, profileId, message);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Alerta de transacción creada correctamente",
                        notification,
                        request.getRequestURI()),
                HttpStatus.CREATED);
    }
}
