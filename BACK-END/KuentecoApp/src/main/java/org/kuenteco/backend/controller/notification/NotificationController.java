package org.kuenteco.backend.controller.notification;

import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.notification.NotificationService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controlador REST para la gestión de notificaciones del usuario.
 *
 * <p>Este controlador maneja todas las operaciones relacionadas con las notificaciones, incluyendo:
 * - Consulta de todas las notificaciones del usuario - Filtrado de notificaciones por rango de
 * fechas - Búsqueda de notificaciones por palabra clave en el título
 *
 * <p>Soporta tanto usuarios individuales (ROLE_USER) como perfiles empresariales (ROLE_PROFILE).
 *
 * @author KuenteCO Team
 * @version 1.0
 * @since 2024
 */
@Slf4j
@RestController
@RequestMapping("/v1/notification")
@RequiredArgsConstructor
public class NotificationController implements NotificationResource {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<?> getAllNotifications(HttpServletRequest request) {
        Object notifications = notificationService.getAllNotifications();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificaciones obtenidas correctamente",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/range")
    public ResponseEntity<?> getNotificationsByDateRange(
            @RequestParam LocalDateTime fromDate,
            @RequestParam LocalDateTime toDate,
            HttpServletRequest request) {

        Object notifications = notificationService.getNotificationsByDateRange(fromDate, toDate);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificaciones del usuario en rango de fechas obtenidas correctamente",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }
}
