package org.kuenteco.backend.controller.notification;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(
        name = "Notifications",
        description = "Endpoints para la gestión y consulta de notificaciones del usuario")
public interface NotificationResource {

    @Operation(
            summary = "Obtener todas las notificaciones",
            description =
                    """
            Recupera todas las notificaciones del usuario autenticado ordenadas por fecha de envío descendente.

            **Funcionalidad por tipo de usuario:**
            - **ROLE_USER**: Obtiene notificaciones asociadas directamente al usuario
            - **ROLE_PROFILE**: Obtiene notificaciones asociadas al perfil empresarial
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Notificaciones obtenidas exitosamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "Con notificaciones",
                                                    description =
                                                            "Usuario con notificaciones existentes",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 200,
                            "success": true,
                            "message": "Notificaciones obtenidas correctamente",
                            "data": [
                                {
                                    "id": 1,
                                    "content": {
                                        "title": "Recordatorio de Pago",
                                        "body": "Tu pago de la tarjeta de crédito vence en 3 días",
                                        "date": "2024-01-15"
                                    },
                                    "dateSend": "2024-01-15T08:00:00"
                                },
                                {
                                    "id": 2,
                                    "content": {
                                        "title": "Presupuesto Excedido",
                                        "body": "Has superado el 80% de tu presupuesto mensual de entretenimiento",
                                        "date": "2024-01-14"
                                    },
                                    "dateSend": "2024-01-14T15:30:00"
                                }
                            ],
                            "path": "/v1/notification"
                        }
                        """),
                                            @ExampleObject(
                                                    name = "Sin notificaciones",
                                                    description =
                                                            "Usuario sin notificaciones registradas",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 200,
                            "success": true,
                            "message": "Notificaciones obtenidas correctamente",
                            "data": "No tienes deudas registradas",
                            "path": "/v1/notification"
                        }
                        """)
                                        })),
                @ApiResponse(
                        responseCode = "401",
                        description = "No autorizado - Token JWT inválido o expirado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Token inválido",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 401,
                        "error": "Unauthorized",
                        "message": "JWT token is expired",
                        "path": "/v1/notification"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Usuario o perfil no encontrado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "Usuario no encontrado",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 404,
                            "error": "Not Found",
                            "message": "Usuario no encontrado",
                            "path": "/v1/notification"
                        }
                        """),
                                            @ExampleObject(
                                                    name = "Perfil no encontrado",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 404,
                            "error": "Not Found",
                            "message": "Perfil no encontrado",
                            "path": "/v1/notification"
                        }
                        """)
                                        })),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Error interno",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 500,
                        "error": "Internal Server Error",
                        "message": "Error interno al obtener las notificaciones",
                        "path": "/v1/notification"
                    }
                    """)))
            })
    @GetMapping
    ResponseEntity<?> getAllNotifications(@Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Obtener notificaciones por rango de fechas",
            description =
                    """
            Recupera notificaciones del usuario autenticado dentro de un rango de fechas específico.

            **Formato de fechas:** ISO 8601 (yyyy-MM-dd'T'HH:mm:ss)
            **Ejemplo:** 2024-01-01T00:00:00

            Las notificaciones se filtran por el campo `dateSend` (fecha de envío).
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Notificaciones del rango de fechas obtenidas exitosamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "Con notificaciones en rango",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 200,
                            "success": true,
                            "message": "Notificaciones del usuario en rango de fechas obtenidas correctamente",
                            "data": [
                                {
                                    "id": 5,
                                    "content": {
                                        "title": "Meta de Ahorro Alcanzada",
                                        "body": "¡Felicitaciones! Has alcanzado el 100% de tu meta de ahorro mensual",
                                        "date": "2024-01-10"
                                    },
                                    "dateSend": "2024-01-10T09:15:00"
                                }
                            ],
                            "path": "/v1/notification/range"
                        }
                        """),
                                            @ExampleObject(
                                                    name = "Sin notificaciones en rango",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 200,
                            "success": true,
                            "message": "Notificaciones del usuario en rango de fechas obtenidas correctamente",
                            "data": "No tienes deudas registradas",
                            "path": "/v1/notification/range"
                        }
                        """)
                                        })),
                @ApiResponse(
                        responseCode = "400",
                        description = "Parámetros de fecha inválidos",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Formato de fecha inválido",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 400,
                        "error": "Bad Request",
                        "message": "Invalid date format. Use yyyy-MM-dd'T'HH:mm:ss",
                        "path": "/v1/notification/range"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "No autorizado - Token JWT inválido o expirado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Token inválido",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 401,
                        "error": "Unauthorized",
                        "message": "JWT token is expired",
                        "path": "/v1/notification/range"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Usuario o perfil no encontrado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Usuario no encontrado",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 404,
                        "error": "Not Found",
                        "message": "Usuario no encontrado",
                        "path": "/v1/notification/range"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Error interno",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 500,
                        "error": "Internal Server Error",
                        "message": "Error interno al obtener las notificaciones",
                        "path": "/v1/notification/range"
                    }
                    """)))
            })
    @Parameter(
            name = "fromDate",
            description = "Fecha de inicio del rango (formato ISO 8601: yyyy-MM-dd'T'HH:mm:ss)",
            required = true,
            example = "2024-01-01T00:00:00",
            in = ParameterIn.QUERY)
    @Parameter(
            name = "toDate",
            description = "Fecha final del rango (formato ISO 8601: yyyy-MM-dd'T'HH:mm:ss)",
            required = true,
            example = "2024-01-31T23:59:59",
            in = ParameterIn.QUERY)
    @GetMapping("/range")
    ResponseEntity<?> getNotificationsByDateRange(
            @RequestParam LocalDateTime fromDate,
            @RequestParam LocalDateTime toDate,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Buscar notificaciones por palabra clave",
            description =
                    """
            Busca notificaciones del usuario autenticado que contengan la palabra clave especificada en el título.

            **Funcionalidad:**
            - Búsqueda case-sensitive en el campo `title` de las notificaciones
            - Búsqueda por coincidencia parcial (contiene la palabra clave)
            - Ordenamiento por fecha de envío descendente

            **Ejemplos de búsqueda:**
            - "Pago" - encuentra notificaciones sobre pagos
            - "Presupuesto" - encuentra notificaciones sobre presupuestos
            - "Meta" - encuentra notificaciones sobre metas de ahorro
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Búsqueda de notificaciones completada exitosamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "Resultados encontrados",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 200,
                            "success": true,
                            "message": "Búsqueda de notificaciones del usuario completada",
                            "data": [
                                {
                                    "id": 3,
                                    "content": {
                                        "title": "Recordatorio de Pago",
                                        "body": "No olvides realizar el pago de tu tarjeta de crédito",
                                        "date": "2024-01-12"
                                    },
                                    "dateSend": "2024-01-12T07:30:00"
                                },
                                {
                                    "id": 7,
                                    "content": {
                                        "title": "Confirmación de Pago",
                                        "body": "Se ha procesado exitosamente el pago de tu factura de servicios",
                                        "date": "2024-01-08"
                                    },
                                    "dateSend": "2024-01-08T14:20:00"
                                }
                            ],
                            "path": "/v1/notification/search"
                        }
                        """),
                                            @ExampleObject(
                                                    name = "Sin resultados",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 200,
                            "success": true,
                            "message": "Búsqueda de notificaciones del usuario completada",
                            "data": "No tienes deudas registradas",
                            "path": "/v1/notification/search"
                        }
                        """)
                                        })),
                @ApiResponse(
                        responseCode = "400",
                        description = "Palabra clave inválida o vacía",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Palabra clave vacía",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 400,
                        "error": "Bad Request",
                        "message": "La palabra clave no puede estar vacía",
                        "path": "/v1/notification/search"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "No autorizado - Token JWT inválido o expirado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Token inválido",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 401,
                        "error": "Unauthorized",
                        "message": "JWT token is expired",
                        "path": "/v1/notification/search"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Usuario o perfil no encontrado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Usuario no encontrado",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 404,
                        "error": "Not Found",
                        "message": "Usuario no encontrado",
                        "path": "/v1/notification/search"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Error interno",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 500,
                        "error": "Internal Server Error",
                        "message": "Error interno al buscar las notificaciones",
                        "path": "/v1/notification/search"
                    }
                    """)))
            })
    @Parameter(
            name = "keyword",
            description =
                    "Palabra clave para buscar en el título de las notificaciones (case-sensitive)",
            required = true,
            example = "Pago",
            in = ParameterIn.QUERY)
    @GetMapping("/search")
    ResponseEntity<?> searchNotificationsByUserId(
            @RequestParam String keyword, @Parameter(hidden = true) HttpServletRequest request);
}
