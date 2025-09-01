package org.kuenteco.backend.controller.subscription;

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
import jakarta.validation.Valid;
import java.security.Principal;
import java.util.Map;
import org.kuenteco.backend.dto.subscription.request.CreateSubscriptionRequestDTO;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;

@Tag(
        name = "Subscriptions",
        description = "Endpoints para la gestión de suscripciones de pago con Mercado Pago")
public interface SubscriptionResource {

    @Operation(
            summary = "Crear nueva suscripción",
            description =
                    """
            Crea una nueva suscripción de pago recurrente en Mercado Pago para el usuario autenticado.

            **Tipos de suscripción disponibles:**
            - **BASIC**: Plan básico con funcionalidades limitadas
            - **STANDARD**: Plan estándar con funcionalidades intermedias
            - **PREMIUM**: Plan premium con todas las funcionalidades

            **Proceso:**
            1. Se crea la preaprobación en Mercado Pago
            2. Se retorna un init_point para completar el pago
            3. El usuario debe acceder al init_point para autorizar los pagos recurrentes
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Suscripción creada exitosamente",
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
                                                        name = "Suscripción creada",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 201,
                        "success": true,
                        "message": "Suscripción creada exitosamente",
                        "data": {
                            "subscriptionId": 1,
                            "preapprovalId": "2c9380847a5b2fab017a5b37a7d10dc6",
                            "initPoint": "https://www.mercadopago.com.co/subscriptions/checkout?preapproval_id=2c9380847a5b2fab017a5b37a7d10dc6",
                            "externalReference": "SUBS_2024_001",
                            "subscriptionType": "PREMIUM",
                            "monthlyAmount": 29.99,
                            "status": "pending",
                            "createdAt": "2024-01-15T10:30:00",
                            "nextPaymentDate": "2024-02-15T10:30:00"
                        },
                        "path": "/v1/subscription/add"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de solicitud inválidos",
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
                                                        name = "Tipo de suscripción requerido",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 400,
                        "error": "Bad Request",
                        "message": "El tipo de suscripción es requerido",
                        "path": "/v1/subscription/add"
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
                        "path": "/v1/subscription/add"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "409",
                        description = "El usuario ya tiene una suscripción activa",
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
                                                        name = "Suscripción duplicada",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 409,
                        "error": "Conflict",
                        "message": "El usuario ya tiene una suscripción activa",
                        "path": "/v1/subscription/add"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor o de Mercado Pago",
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
                        "message": "Error al crear suscripción en Mercado Pago",
                        "path": "/v1/subscription/add"
                    }
                    """)))
            })
    @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "Datos de la suscripción a crear",
            required = true,
            content =
                    @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = CreateSubscriptionRequestDTO.class),
                            examples = {
                                @ExampleObject(
                                        name = "Suscripción Premium",
                                        value =
                                                """
                    {
                        "subscriptionType": "PREMIUM",
                        "backUrl": "https://miapp.com/subscription/success"
                    }
                    """),
                                @ExampleObject(
                                        name = "Suscripción Básica",
                                        value =
                                                """
                    {
                        "subscriptionType": "BASIC"
                    }
                    """)
                            }))
    ResponseEntity<?> createSubscription(
            @Parameter(hidden = true) @Valid @RequestBody CreateSubscriptionRequestDTO dto,
            @Parameter(hidden = true) Principal principal,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Obtener detalles de suscripción específica",
            description =
                    """
            Obtiene los detalles completos de una suscripción específica del usuario autenticado.

            **Información incluida:**
            - Estado de la suscripción y preaprobación
            - Detalles de pago (método, últimos dígitos de tarjeta)
            - Fechas importantes (inicio, próximo pago, expiración)
            - Configuración de renovación automática
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Detalles de suscripción obtenidos exitosamente",
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
                                                        name = "Suscripción activa",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 200,
                        "success": true,
                        "message": "Suscripción obtenida exitosamente",
                        "data": {
                            "subscriptionId": 1,
                            "preapprovalId": "2c9380847a5b2fab017a5b37a7d10dc6",
                            "subscriptionType": "PREMIUM",
                            "monthlyAmount": 29.99,
                            "subscriptionState": "ACTIVE",
                            "preapprovalStatus": "authorized",
                            "startDate": "2024-01-15T10:30:00",
                            "expirationDate": "2025-01-15T10:30:00",
                            "nextPaymentDate": "2024-02-15T10:30:00",
                            "isAutoRenewable": true,
                            "paymentMethodId": "visa",
                            "cardLastFourDigits": "1234",
                            "cardBrand": "visa"
                        },
                        "path": "/v1/subscription/2c9380847a5b2fab017a5b37a7d10dc6"
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
                        "path": "/v1/subscription/2c9380847a5b2fab017a5b37a7d10dc6"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "403",
                        description = "Suscripción no pertenece al usuario autenticado",
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
                                                        name = "Acceso denegado",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 403,
                        "error": "Forbidden",
                        "message": "No tiene permisos para acceder a esta suscripción",
                        "path": "/v1/subscription/2c9380847a5b2fab017a5b37a7d10dc6"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Suscripción no encontrada",
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
                                                        name = "Suscripción no encontrada",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 404,
                        "error": "Not Found",
                        "message": "Suscripción no encontrada",
                        "path": "/v1/subscription/2c9380847a5b2fab017a5b37a7d10dc6"
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
                        "message": "Error al obtener detalles de la suscripción",
                        "path": "/v1/subscription/2c9380847a5b2fab017a5b37a7d10dc6"
                    }
                    """)))
            })
    @Parameter(
            name = "preapprovalId",
            description = "ID de la preaprobación de Mercado Pago asociada a la suscripción",
            required = true,
            example = "2c9380847a5b2fab017a5b37a7d10dc6",
            in = ParameterIn.PATH)
    ResponseEntity<?> getSubscription(
            @PathVariable String preapprovalId,
            @Parameter(hidden = true) Principal principal,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Obtener historial de pagos de suscripción",
            description =
                    """
            Obtiene el historial completo de pagos de una suscripción específica del usuario autenticado.

            **Información de cada pago:**
            - ID del pago y estado actual
            - Monto y moneda del pago
            - Método de pago utilizado
            - Fechas de creación y aprobación
            - Detalles del estado del pago
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Historial de pagos obtenido exitosamente",
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
                                                        name = "Historial de pagos",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 200,
                        "success": true,
                        "message": "Historial de pagos obtenido exitosamente",
                        "data": [
                            {
                                "paymentId": "12345678901",
                                "amount": 29.99,
                                "currencyId": "COP",
                                "status": "approved",
                                "statusDetail": "accredited",
                                "paymentMethodId": "visa",
                                "dateCreated": "2024-01-15T10:30:00",
                                "dateApproved": "2024-01-15T10:31:00",
                                "description": "Suscripción Premium - Enero 2024"
                            },
                            {
                                "paymentId": "12345678902",
                                "amount": 29.99,
                                "currencyId": "COP",
                                "status": "approved",
                                "statusDetail": "accredited",
                                "paymentMethodId": "visa",
                                "dateCreated": "2024-02-15T10:30:00",
                                "dateApproved": "2024-02-15T10:31:00",
                                "description": "Suscripción Premium - Febrero 2024"
                            }
                        ],
                        "path": "/v1/subscription/2c9380847a5b2fab017a5b37a7d10dc6/payment-history"
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
                        "path": "/v1/subscription/2c9380847a5b2fab017a5b37a7d10dc6/payment-history"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "403",
                        description = "Suscripción no pertenece al usuario autenticado",
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
                                                        name = "Acceso denegado",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 403,
                        "error": "Forbidden",
                        "message": "No tiene permisos para acceder a esta suscripción",
                        "path": "/v1/subscription/2c9380847a5b2fab017a5b37a7d10dc6/payment-history"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Suscripción no encontrada",
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
                                                        name = "Suscripción no encontrada",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 404,
                        "error": "Not Found",
                        "message": "Suscripción no encontrada",
                        "path": "/v1/subscription/2c9380847a5b2fab017a5b37a7d10dc6/payment-history"
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
                        "message": "Error al obtener el historial de pagos",
                        "path": "/v1/subscription/2c9380847a5b2fab017a5b37a7d10dc6/payment-history"
                    }
                    """)))
            })
    @Parameter(
            name = "preapprovalId",
            description = "ID de la preaprobación de Mercado Pago asociada a la suscripción",
            required = true,
            example = "2c9380847a5b2fab017a5b37a7d10dc6",
            in = ParameterIn.PATH)
    ResponseEntity<?> getPaymentHistory(
            @PathVariable String preapprovalId,
            @Parameter(hidden = true) Principal principal,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Obtener mis suscripciones",
            description =
                    """
            Obtiene todas las suscripciones del usuario autenticado.

            **Funcionalidad:**
            - Retorna la suscripción activa del usuario (si existe)
            - Incluye toda la información de estado y configuración
            - Útil para verificar el estado actual del plan del usuario
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Suscripciones del usuario obtenidas exitosamente",
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
                                                    name = "Usuario con suscripción",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 200,
                            "success": true,
                            "message": "Suscripciones obtenidas exitosamente",
                            "data": {
                                "subscriptionId": 1,
                                "preapprovalId": "2c9380847a5b2fab017a5b37a7d10dc6",
                                "subscriptionType": "PREMIUM",
                                "monthlyAmount": 29.99,
                                "subscriptionState": "ACTIVE",
                                "preapprovalStatus": "authorized",
                                "startDate": "2024-01-15T10:30:00",
                                "expirationDate": "2025-01-15T10:30:00",
                                "nextPaymentDate": "2024-02-15T10:30:00",
                                "isAutoRenewable": true,
                                "paymentMethodId": "visa",
                                "cardLastFourDigits": "1234",
                                "cardBrand": "visa"
                            },
                            "path": "/v1/subscription"
                        }
                        """),
                                            @ExampleObject(
                                                    name = "Usuario sin suscripción",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 200,
                            "success": true,
                            "message": "Suscripciones obtenidas exitosamente",
                            "data": null,
                            "path": "/v1/subscription"
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
                        "path": "/v1/subscription"
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
                        "message": "Error al obtener las suscripciones del usuario",
                        "path": "/v1/subscription"
                    }
                    """)))
            })
    ResponseEntity<?> getMySubscriptions(@Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Webhook unificado de Mercado Pago",
            description =
                    """
            Endpoint para recibir notificaciones de webhooks de Mercado Pago sobre eventos relacionados con suscripciones y pagos.

            **⚠️ IMPORTANTE:** Este endpoint es exclusivamente para uso interno del sistema y Mercado Pago.

            **Tipos de webhooks soportados:**
            - `subscription_preapproval`: Cambios en el estado de preaprobaciones
            - `subscription_authorized_payment`: Pagos autorizados de suscripciones
            - `payment`: Eventos generales de pagos
            - Webhooks genéricos de otros tipos de eventos

            **Proceso de validación:**
            1. Se valida la autenticidad del webhook usando headers de seguridad
            2. Se procesa el evento según su tipo
            3. Se actualiza el estado correspondiente en la base de datos
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Webhook procesado correctamente",
                        content =
                                @Content(
                                        mediaType = "text/plain",
                                        examples = @ExampleObject(value = "OK"))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Webhook inválido o no autorizado",
                        content =
                                @Content(
                                        mediaType = "text/plain",
                                        examples = @ExampleObject(value = "UNAUTHORIZED"))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno al procesar el webhook",
                        content = @Content(mediaType = "text/plain"))
            })
    ResponseEntity<String> handleWebhook(
            @Parameter(
                            description = "Datos de la notificación enviada por Mercado Pago",
                            required = true,
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            examples =
                                                    @ExampleObject(
                                                            name = "Webhook de preapproval",
                                                            value =
                                                                    """
                    {
                        "action": "created",
                        "type": "subscription_preapproval",
                        "data": {
                            "id": "2c9380847a5b2fab017a5b37a7d10dc6"
                        }
                    }
                    """)))
                    @RequestBody
                    Map<String, Object> notification,
            @Parameter(
                            description =
                                    "Headers HTTP de la petición para validación de seguridad",
                            required = true)
                    @RequestHeader
                    Map<String, String> headers);

    @Operation(
            summary = "Webhook genérico de Mercado Pago",
            description =
                    """
            Endpoint alternativo para recibir webhooks genéricos de Mercado Pago que no encajan en las categorías específicas.

            **⚠️ IMPORTANTE:** Este endpoint es exclusivamente para uso interno del sistema y Mercado Pago.

            **Funcionalidad:**
            - Procesa webhooks de tipos no específicos
            - Realiza la misma validación de seguridad que el webhook principal
            - Registra la información para análisis posterior
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Webhook genérico procesado correctamente",
                        content =
                                @Content(
                                        mediaType = "text/plain",
                                        examples = {
                                            @ExampleObject(name = "Procesado", value = "OK"),
                                            @ExampleObject(name = "Inválido", value = "INVALID")
                                        })),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno al procesar el webhook genérico",
                        content = @Content(mediaType = "text/plain"))
            })
    ResponseEntity<String> handleGenericWebhook(
            @Parameter(
                            description =
                                    "Datos de la notificación genérica enviada por Mercado Pago",
                            required = true)
                    @RequestBody
                    Map<String, Object> notification,
            @Parameter(
                            description =
                                    "Headers HTTP de la petición para validación de seguridad",
                            required = true)
                    @RequestHeader
                    Map<String, String> headers);
}
