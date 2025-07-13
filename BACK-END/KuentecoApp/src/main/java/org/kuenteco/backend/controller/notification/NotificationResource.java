package org.kuenteco.backend.controller.notification;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import org.kuenteco.backend.exception.ApiResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Notification", description = "API para la gestión de notificaciones")
public interface NotificationResource {

    @Operation(
            summary = "Obtener todas las notificaciones",
            description = "Recupera todas las notificaciones del usuario autenticado",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Lista de notificaciones",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Notificaciones obtenidas correctamente\", \"data\": [ { \"id\": 1, \"title\": \"Nueva notificación\" } ] }")))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.HEADER,
                        name = "Authorization",
                        description = "Token JWT para autenticación",
                        required = true)
            })
    @GetMapping
    ResponseEntity<?> getAllNotifications(HttpServletRequest request);

    @Operation(
            summary = "Obtener notificaciones por rango de fechas",
            description =
                    "Recupera notificaciones del usuario dentro de un rango de fechas específico",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Notificaciones en el rango de fechas",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Notificaciones del usuario en rango de fechas obtenidas correctamente\", \"data\": [] }")))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "fromDate",
                        description = "Fecha de inicio (formato: yyyy-MM-dd'T'HH:mm:ss)",
                        required = true),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "toDate",
                        description = "Fecha final (formato: yyyy-MM-dd'T'HH:mm:ss)",
                        required = true),
                @Parameter(
                        in = ParameterIn.HEADER,
                        name = "Authorization",
                        description = "Token JWT para autenticación",
                        required = true)
            })
    @GetMapping("/range")
    ResponseEntity<?> getNotificationsByDateRange(
            @RequestParam LocalDateTime fromDate,
            @RequestParam LocalDateTime toDate,
            HttpServletRequest request);

    @Operation(
            summary = "Buscar notificaciones por palabra clave",
            description =
                    "Busca notificaciones del usuario que contengan la palabra clave especificada",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Resultados de búsqueda",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Búsqueda de notificaciones del usuario completada\", \"data\": [] }")))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "keyword",
                        description = "Palabra clave para buscar en las notificaciones",
                        required = true),
                @Parameter(
                        in = ParameterIn.HEADER,
                        name = "Authorization",
                        description = "Token JWT para autenticación",
                        required = true)
            })
    @GetMapping("/search")
    ResponseEntity<?> searchNotificationsByUserId(
            @RequestParam String keyword, HttpServletRequest request);
}
