package org.kuenteco.backend.controller.notification;

import jakarta.servlet.http.HttpServletRequest;
import java.sql.Timestamp;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.notification.NotificationService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/notification")
@AllArgsConstructor
public class NotificationController {

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
            @RequestParam Timestamp fromDate,
            @RequestParam Timestamp toDate,
            HttpServletRequest request) {

        Object notifications = notificationService.getNotificationsByDateRange(fromDate, toDate);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Notificaciones del usuario en rango de fechas obtenidas correctamente",
                        notifications,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/search")
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
