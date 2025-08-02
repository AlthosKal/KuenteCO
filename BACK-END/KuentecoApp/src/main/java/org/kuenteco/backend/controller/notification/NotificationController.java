package org.kuenteco.backend.controller.notification;

import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.notification.NotificationService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controlador REST para la gestión de notificaciones
 *
 * <p>Este controlador maneja las operaciones relacionadas con las notificaciones, incluyendo la
 * consulta, búsqueda y filtrado por fechas.
 *
 * @author KuenteCO Team
 * @version 1.0
 * @since 2024
 */
@RestController
@RequestMapping("/v1/notification")
@AllArgsConstructor
public class NotificationController implements NotificationResource {

    private final NotificationService notificationService;

    /**
     * Obtiene todas las notificaciones del usuario autenticado
     *
     * @param request La petición HTTP que contiene el token de autenticación
     * @return ResponseEntity con la lista de notificaciones
     */
    @Override
    public ResponseEntity<?> getAllNotifications(HttpServletRequest request) {
        Object notifications = notificationService.getAllNotifications();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificaciones obtenidas correctamente",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    /**
     * Obtiene notificaciones del usuario filtradas por rango de fechas
     *
     * @param fromDate Fecha de inicio del rango
     * @param toDate Fecha final del rango
     * @param request La petición HTTP que contiene el token de autenticación
     * @return ResponseEntity con las notificaciones del rango especificado
     */
    @Override
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

    /**
     * Busca notificaciones del usuario por palabra clave
     *
     * @param keyword Palabra clave para buscar en las notificaciones
     * @param request La petición HTTP que contiene el token de autenticación
     * @return ResponseEntity con los resultados de la búsqueda
     */
    @Override
    public ResponseEntity<?> searchNotificationsByUserId(
            @RequestParam String keyword, HttpServletRequest request) {

        Object notifications = notificationService.searchNotifications(keyword);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Búsqueda de notificaciones del usuario completada",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }
}
