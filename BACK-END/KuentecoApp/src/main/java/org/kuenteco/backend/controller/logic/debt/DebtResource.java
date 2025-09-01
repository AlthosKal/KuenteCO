package org.kuenteco.backend.controller.logic.debt;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import org.kuenteco.backend.dto.logic.debt.DebtDTO;
import org.kuenteco.backend.dto.logic.debt.DebtPaymentDTO;
import org.kuenteco.backend.dto.logic.debt.DebtSummaryDTO;
import org.kuenteco.backend.dto.logic.debt.NewDebtDTO;
import org.kuenteco.backend.enums.StateDebt;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Debts", description = "API para la gestión completa de deudas y control de pagos")
public interface DebtResource {

    @Operation(
            summary = "Obtener todas las deudas",
            description =
                    "Recupera una lista completa de todas las deudas del usuario con filtros opcionales por fechas y tipo",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Deudas obtenidas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Deudas obtenidas correctamente",
                          "data": [
                            {
                              "id": 1,
                              "name": "Préstamo Personal",
                              "totalAmount": 10000.00,
                              "pendingAmount": 8500.00,
                              "paidAmount": 1500.00,
                              "startDate": "2024-01-15T10:00:00Z",
                              "expirationDate": "2024-12-15T23:59:59Z",
                              "state": "ACTIVE",
                              "daysToExpiry": 150,
                              "monthlyPayment": 850.00,
                              "progressPercentage": 15.0
                            },
                            {
                              "id": 2,
                              "name": "Tarjeta de Crédito",
                              "totalAmount": 3500.00,
                              "pendingAmount": 2800.00,
                              "paidAmount": 700.00,
                              "startDate": "2024-01-01T00:00:00Z",
                              "expirationDate": "2024-03-01T23:59:59Z",
                              "state": "OVERDUE",
                              "daysToExpiry": -15,
                              "monthlyPayment": 280.00,
                              "progressPercentage": 20.0
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para filtrar deudas (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para filtrar deudas (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de deuda para filtrar",
                        schema =
                                @Schema(
                                        type = "string",
                                        allowableValues = {
                                            "ACTIVE",
                                            "PAID",
                                            "OVERDUE",
                                            "CANCELLED"
                                        },
                                        example = "ACTIVE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping
    ResponseEntity<?> getAllDebts(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener deudas por estado",
            description =
                    "Recupera todas las deudas filtradas por su estado específico (ACTIVE, PAID, OVERDUE, CANCELLED)",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Deudas filtradas por estado obtenidas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Deudas filtradas por estado obtenidas correctamente",
                          "data": [
                            {
                              "id": 1,
                              "name": "Préstamo Personal",
                              "totalAmount": 10000.00,
                              "pendingAmount": 8500.00,
                              "paidAmount": 1500.00,
                              "startDate": "2024-01-15T10:00:00Z",
                              "expirationDate": "2024-12-15T23:59:59Z",
                              "state": "ACTIVE",
                              "daysToExpiry": 150,
                              "interestRate": 15.5,
                              "lastPaymentDate": "2024-01-30T14:30:00Z"
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/state/ACTIVE"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Estado de deuda inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Estado de deuda inválido: INVALID_STATE. Estados válidos: ACTIVE, PAID, OVERDUE, CANCELLED",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/state/INVALID_STATE"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/state/ACTIVE"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/state/ACTIVE"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "state",
                        description = "Estado de la deuda para filtrar",
                        required = true,
                        schema =
                                @Schema(
                                        type = "string",
                                        allowableValues = {
                                            "ACTIVE",
                                            "PAID",
                                            "OVERDUE",
                                            "CANCELLED"
                                        },
                                        example = "ACTIVE")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para filtrar deudas (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para filtrar deudas (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo adicional de filtro para aplicar",
                        schema =
                                @Schema(
                                        type = "string",
                                        allowableValues = {"HIGH_AMOUNT", "LOW_AMOUNT", "PRIORITY"},
                                        example = "HIGH_AMOUNT"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/state/{state}")
    ResponseEntity<?> getDebtsByState(
            @PathVariable StateDebt state,
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener deudas vencidas",
            description =
                    "Recupera todas las deudas que han superado su fecha de vencimiento y requieren atención inmediata",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Deudas vencidas obtenidas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Deudas vencidas obtenidas correctamente",
                          "data": [
                            {
                              "id": 2,
                              "name": "Tarjeta de Crédito",
                              "totalAmount": 3500.00,
                              "pendingAmount": 2800.00,
                              "paidAmount": 700.00,
                              "startDate": "2024-01-01T00:00:00Z",
                              "expirationDate": "2024-03-01T23:59:59Z",
                              "state": "OVERDUE",
                              "daysPastDue": 15,
                              "lateFee": 175.00,
                              "totalWithFees": 2975.00,
                              "urgencyLevel": "HIGH"
                            },
                            {
                              "id": 5,
                              "name": "Crédito Educativo",
                              "totalAmount": 20000.00,
                              "pendingAmount": 15000.00,
                              "paidAmount": 5000.00,
                              "startDate": "2022-09-01T00:00:00Z",
                              "expirationDate": "2024-01-10T23:59:59Z",
                              "state": "OVERDUE",
                              "daysPastDue": 5,
                              "lateFee": 300.00,
                              "totalWithFees": 15300.00,
                              "urgencyLevel": "MEDIUM"
                            }
                          ],
                          "totalOverdueAmount": 18275.00,
                          "totalLateFees": 475.00,
                          "overdueCount": 2,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/overdue"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/overdue"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/overdue"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description =
                                "Fecha de inicio para filtrar deudas vencidas (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description =
                                "Fecha de fin para filtrar deudas vencidas (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de análisis de deudas vencidas",
                        schema =
                                @Schema(
                                        type = "string",
                                        allowableValues = {"WITH_FEES", "CRITICAL_ONLY", "SUMMARY"},
                                        example = "WITH_FEES"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/overdue")
    ResponseEntity<?> getOverdueDebts(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener deudas próximas a vencer",
            description =
                    "Recupera todas las deudas que vencerán dentro del número de días especificado para planificación de pagos",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Deudas próximas a vencer obtenidas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Deudas próximas a vencer obtenidas correctamente",
                          "data": [
                            {
                              "id": 7,
                              "name": "Crédito Celular",
                              "totalAmount": 1200.00,
                              "pendingAmount": 800.00,
                              "paidAmount": 400.00,
                              "startDate": "2024-03-15T00:00:00Z",
                              "expirationDate": "2024-09-15T23:59:59Z",
                              "state": "ACTIVE",
                              "daysToExpiry": 5,
                              "minimumPayment": 160.00,
                              "suggestedPayment": 200.00,
                              "priorityLevel": "HIGH"
                            },
                            {
                              "id": 18,
                              "name": "Financiamiento Bici",
                              "totalAmount": 1500.00,
                              "pendingAmount": 800.00,
                              "paidAmount": 700.00,
                              "startDate": "2024-02-20T00:00:00Z",
                              "expirationDate": "2024-10-20T23:59:59Z",
                              "state": "ACTIVE",
                              "daysToExpiry": 7,
                              "minimumPayment": 100.00,
                              "suggestedPayment": 150.00,
                              "priorityLevel": "MEDIUM"
                            }
                          ],
                          "totalUpcomingAmount": 1600.00,
                          "averageDaysToExpiry": 6,
                          "upcomingCount": 2,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/expiring-soon"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Número de días inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "El número de días debe ser un valor positivo entre 1 y 365",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/expiring-soon"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/expiring-soon"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/expiring-soon"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "days",
                        description = "Número de días para buscar deudas próximas a vencer",
                        required = true,
                        schema =
                                @Schema(
                                        type = "integer",
                                        minimum = "1",
                                        maximum = "365",
                                        example = "7")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para filtrar deudas (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para filtrar deudas (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de análisis de vencimiento",
                        schema =
                                @Schema(
                                        type = "string",
                                        allowableValues = {
                                            "WITH_SUGGESTIONS",
                                            "CRITICAL_ONLY",
                                            "ALL"
                                        },
                                        example = "WITH_SUGGESTIONS"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/expiring-soon")
    ResponseEntity<?> getDebtsExpiringInDays(
            @RequestParam("days") Integer days,
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener monto total pendiente",
            description =
                    "Calcula y retorna el monto total de todas las deudas pendientes del usuario",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Total pendiente obtenido correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(type = "number", format = "currency"),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Total pendiente del usuario obtenido correctamente",
                          "data": {
                            "totalPendingAmount": 245750.50,
                            "totalDebts": 15,
                            "activeDebts": 12,
                            "overdueDebts": 2,
                            "paidDebts": 1,
                            "averageDebtAmount": 16383.37,
                            "biggestDebt": {
                              "name": "Hipoteca",
                              "amount": 174000.00
                            },
                            "smallestDebt": {
                              "name": "Financiamiento Bici",
                              "amount": 800.00
                            },
                            "monthlyCommitment": 8950.75
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/total-pending"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/total-pending"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/total-pending"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description =
                                "Fecha de inicio para calcular total pendiente (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description =
                                "Fecha de fin para calcular total pendiente (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de cálculo para el total pendiente",
                        schema =
                                @Schema(
                                        type = "string",
                                        allowableValues = {
                                            "SIMPLE",
                                            "WITH_DETAILS",
                                            "WITH_PROJECTIONS"
                                        },
                                        example = "WITH_DETAILS"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/total-pending")
    ResponseEntity<?> getTotalPendingAmount(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener resumen ejecutivo de deudas",
            description =
                    "Genera un reporte consolidado con estadísticas clave, análisis de riesgo y recomendaciones de pago",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Resumen de deudas generado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = DebtSummaryDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Resumen de deudas generado correctamente",
                          "data": {
                            "totalDebtAmount": 300000.00,
                            "totalPendingAmount": 245750.50,
                            "totalPaidAmount": 54249.50,
                            "totalDebtsCount": 15,
                            "paymentProgress": 18.08,
                            "debtsByState": {
                              "active": 12,
                              "paid": 1,
                              "overdue": 2,
                              "cancelled": 0
                            },
                            "monthlyCommitment": 8950.75,
                            "averageInterestRate": 16.75,
                            "debtToIncomeRatio": 35.5,
                            "creditUtilization": 72.3,
                            "riskLevel": "MEDIUM",
                            "topDebts": [
                              {"name": "Hipoteca", "amount": 174000.00, "priority": "LOW"},
                              {"name": "Crédito Educativo Extra", "amount": 12000.00, "priority": "HIGH"},
                              {"name": "Préstamo Personal", "amount": 8500.00, "priority": "MEDIUM"}
                            ],
                            "recommendations": [
                              "Priorizar el pago de deudas vencidas para evitar penalizaciones",
                              "Considerar consolidar deudas con tasas de interés superiores al 18%",
                              "Establecer un fondo de emergencia para evitar nuevas deudas"
                            ],
                            "nextPaymentsDue": [
                              {"debtName": "Crédito Celular", "amount": 160.00, "dueDate": "2024-01-20T23:59:59Z"},
                              {"debtName": "Tarjeta Premium", "amount": 450.00, "dueDate": "2024-01-25T23:59:59Z"}
                            ]
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/report/summary"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/report/summary"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/report/summary"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para el resumen (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para el resumen (formato ISO 8601)",
                        schema =
                                @Schema(
                                        type = "string",
                                        format = "date-time",
                                        example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de resumen para generar",
                        schema =
                                @Schema(
                                        type = "string",
                                        allowableValues = {
                                            "EXECUTIVE",
                                            "DETAILED",
                                            "RISK_ANALYSIS",
                                            "PAYMENT_PLAN"
                                        },
                                        example = "EXECUTIVE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/report/summary")
    ResponseEntity<?> getDebtSummaryReport(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Crear nueva deuda",
            description =
                    "Registra una nueva deuda en el sistema con validaciones completas y cálculo automático de métricas de pago",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Deuda creada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Deuda creada correctamente",
                          "data": {
                            "transactionId": 1,
                            "name": "Préstamo Personal",
                            "totalAmount": 10000.00,
                            "pendingAmount": 10000.00,
                            "startDate": "2024-01-15T10:00:00Z",
                            "expirationDate": "2024-12-15T23:59:59Z",
                            "state": "ACTIVE"
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos",
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
                                                    name = "Campos requeridos",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El nombre de la deuda es obligatorio",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Monto inválido",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El monto total debe ser un valor monetario válido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Fechas inválidas",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "La fecha de vencimiento debe ser posterior a la fecha de inicio",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Transacción no encontrada",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "No se encontró la transacción con ID: 999",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/add"
                        }
                    """)
                                        })),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "409",
                        description = "Deuda duplicada",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Ya existe una deuda con el nombre 'Préstamo Personal' para esta transacción",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/add"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/add"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = NewDebtDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Nueva deuda",
                                                            value =
                                                                    """
                        {
                          "transactionId": 1,
                          "name": "Préstamo Personal",
                          "totalAmount": 10000.00,
                          "pendingAmount": 10000.00,
                          "startDate": "2024-01-15T10:00:00",
                          "expirationDate": "2024-12-15T23:59:59",
                          "state": "ACTIVE"
                        }
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/add")
    ResponseEntity<?> addDebt(
            @Valid @RequestBody NewDebtDTO dto,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Crear múltiples deudas",
            description =
                    "Registra múltiples deudas en el sistema de forma eficiente con validación individual y procesamiento en lote",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Deudas creadas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Deudas creadas correctamente",
                          "data": [
                            {
                              "transactionId": 1,
                              "name": "Tarjeta de Crédito",
                              "totalAmount": 3500.00,
                              "pendingAmount": 3500.00,
                              "startDate": "2024-01-01T00:00:00Z",
                              "expirationDate": "2024-03-01T23:59:59Z",
                              "state": "ACTIVE"
                            },
                            {
                              "transactionId": 2,
                              "name": "Préstamo Vehicular",
                              "totalAmount": 25000.00,
                              "pendingAmount": 25000.00,
                              "startDate": "2024-01-10T09:00:00Z",
                              "expirationDate": "2026-01-10T23:59:59Z",
                              "state": "ACTIVE"
                            }
                          ],
                          "totalAmount": 28500.00,
                          "createdCount": 2,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos en una o más deudas",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error en deuda índice 2: El monto total debe ser un valor monetario válido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch/add"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch/add"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(
                                                            implementation = NewDebtDTO.class,
                                                            type = "array"),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Múltiples deudas",
                                                            value =
                                                                    """
                        [
                          {
                            "transactionId": 1,
                            "name": "Tarjeta de Crédito",
                            "totalAmount": 3500.00,
                            "pendingAmount": 3500.00,
                            "startDate": "2024-01-01T00:00:00",
                            "expirationDate": "2024-03-01T23:59:59",
                            "state": "ACTIVE"
                          },
                          {
                            "transactionId": 2,
                            "name": "Préstamo Vehicular",
                            "totalAmount": 25000.00,
                            "pendingAmount": 25000.00,
                            "startDate": "2024-01-10T09:00:00",
                            "expirationDate": "2026-01-10T23:59:59",
                            "state": "ACTIVE"
                          }
                        ]
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/batch/add")
    ResponseEntity<?> addDebts(
            @Valid @RequestBody List<NewDebtDTO> dto,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Actualizar deuda existente",
            description =
                    "Actualiza los datos de una deuda existente con validaciones y recalculo automático de métricas",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Deuda actualizada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Deuda actualizada correctamente",
                          "data": {
                            "id": 1,
                            "name": "Préstamo Personal Actualizado",
                            "totalAmount": 10000.00,
                            "pendingAmount": 8000.00,
                            "startDate": "2024-01-15T10:00:00Z",
                            "expirationDate": "2024-12-15T23:59:59Z",
                            "state": "ACTIVE"
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos",
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
                                                    name = "ID requerido",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El ID de la deuda es obligatorio",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/update"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Monto pendiente mayor que total",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El monto pendiente no puede ser mayor que el monto total de la deuda",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/update"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Estado inválido",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "No se puede cambiar el estado de una deuda pagada",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/update"
                        }
                    """)
                                        })),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Deuda no encontrada",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Deuda no encontrada con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/update"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/update"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = DebtDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Actualizar deuda",
                                                            value =
                                                                    """
                        {
                          "id": 1,
                          "name": "Préstamo Personal Actualizado",
                          "totalAmount": 10000.00,
                          "pendingAmount": 8000.00,
                          "startDate": "2024-01-15T10:00:00",
                          "expirationDate": "2024-12-15T23:59:59",
                          "state": "ACTIVE"
                        }
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PatchMapping("/update")
    ResponseEntity<?> updateDebt(
            @Valid @RequestBody DebtDTO dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Actualizar múltiples deudas",
            description =
                    "Actualiza múltiples deudas existentes de forma eficiente con validación individual",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Deudas actualizadas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Deudas actualizadas correctamente",
                          "data": [
                            {
                              "id": 1,
                              "name": "Préstamo Personal - Cuota Enero",
                              "totalAmount": 10000.00,
                              "pendingAmount": 7500.00,
                              "startDate": "2024-01-15T10:00:00Z",
                              "expirationDate": "2024-12-15T23:59:59Z",
                              "state": "ACTIVE"
                            }
                          ],
                          "updatedCount": 1,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos en una o más deudas",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error en deuda índice 0: El ID de la deuda es obligatorio",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Una o más deudas no encontradas",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Deudas no encontradas con IDs: [5, 8, 12]",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch/update"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch/update"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(
                                                            implementation = DebtDTO.class,
                                                            type = "array"),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Múltiples actualizaciones",
                                                            value =
                                                                    """
                        [
                          {
                            "id": 1,
                            "name": "Préstamo Personal - Cuota Enero",
                            "totalAmount": 10000.00,
                            "pendingAmount": 7500.00,
                            "startDate": "2024-01-15T10:00:00",
                            "expirationDate": "2024-12-15T23:59:59",
                            "state": "ACTIVE"
                          }
                        ]
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PutMapping("/batch/update")
    ResponseEntity<?> updateDebts(
            @Valid @RequestBody List<DebtDTO> dto,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Realizar pago de deuda",
            description =
                    "Registra un pago hacia una deuda específica, actualiza el saldo pendiente y genera registro de transacción",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Pago realizado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Pago realizado correctamente",
                          "data": {
                            "debtId": 2,
                            "paymentAmount": 500.00,
                            "description": "Pago mensual de enero",
                            "paymentDate": "2024-01-30T14:30:00Z",
                            "newPendingAmount": 2300.00,
                            "paymentProgress": 28.57,
                            "remainingPayments": 5,
                            "nextPaymentDue": "2024-02-28T23:59:59Z"
                          },
                          "timestamp": "2024-01-30T14:30:00Z",
                          "path": "/v1/debt/payment"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de pago incorrectos",
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
                                                    name = "Monto de pago inválido",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El monto del pago debe ser un valor monetario válido",
                          "timestamp": "2024-01-30T14:30:00Z",
                          "path": "/v1/debt/payment"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Pago mayor que deuda",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El monto del pago no puede ser mayor que el monto pendiente de la deuda",
                          "timestamp": "2024-01-30T14:30:00Z",
                          "path": "/v1/debt/payment"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Deuda ya pagada",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "No se puede realizar pagos a una deuda con estado PAID",
                          "timestamp": "2024-01-30T14:30:00Z",
                          "path": "/v1/debt/payment"
                        }
                    """)
                                        })),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-30T14:30:00Z",
                          "path": "/v1/debt/payment"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Deuda no encontrada",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Deuda no encontrada con ID: 2",
                          "timestamp": "2024-01-30T14:30:00Z",
                          "path": "/v1/debt/payment"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-30T14:30:00Z",
                          "path": "/v1/debt/payment"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = DebtPaymentDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Pago de deuda",
                                                            value =
                                                                    """
                        {
                          "debtId": 2,
                          "paymentAmount": 500.00,
                          "description": "Pago mensual de enero",
                          "paymentDate": "2024-01-30T14:30:00"
                        }
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/payment")
    ResponseEntity<?> makePayment(
            @Valid @RequestBody DebtPaymentDTO dto,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Actualizar estado de deuda",
            description =
                    "Cambia el estado de una deuda específica (ACTIVE, PAID, OVERDUE, CANCELLED) con validaciones de transición",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Estado de la deuda actualizado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Estado de la deuda actualizado correctamente",
                          "data": {
                            "debtId": 1,
                            "previousState": "ACTIVE",
                            "newState": "PAID",
                            "stateChangedAt": "2024-01-30T15:45:00Z",
                            "finalPendingAmount": 0.00
                          },
                          "timestamp": "2024-01-30T15:45:00Z",
                          "path": "/v1/debt/1/state/PAID"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Transición de estado inválida",
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
                                                    name = "Estado inválido",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "Estado de deuda inválido: INVALID. Estados válidos: ACTIVE, PAID, OVERDUE, CANCELLED",
                          "timestamp": "2024-01-30T15:45:00Z",
                          "path": "/v1/debt/1/state/INVALID"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Transición no permitida",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "No se puede cambiar una deuda de estado PAID a ACTIVE",
                          "timestamp": "2024-01-30T15:45:00Z",
                          "path": "/v1/debt/1/state/ACTIVE"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Deuda con saldo pendiente",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "No se puede marcar como PAID una deuda con saldo pendiente de 2500.00",
                          "timestamp": "2024-01-30T15:45:00Z",
                          "path": "/v1/debt/1/state/PAID"
                        }
                    """)
                                        })),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-30T15:45:00Z",
                          "path": "/v1/debt/1/state/PAID"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Deuda no encontrada",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Deuda no encontrada con ID: 1",
                          "timestamp": "2024-01-30T15:45:00Z",
                          "path": "/v1/debt/1/state/PAID"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-30T15:45:00Z",
                          "path": "/v1/debt/1/state/PAID"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID de la deuda a actualizar",
                        required = true,
                        schema = @Schema(type = "integer", example = "1")),
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "state",
                        description = "Nuevo estado para la deuda",
                        required = true,
                        schema =
                                @Schema(
                                        type = "string",
                                        allowableValues = {
                                            "ACTIVE",
                                            "PAID",
                                            "OVERDUE",
                                            "CANCELLED"
                                        },
                                        example = "PAID"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PatchMapping("/{id}/state/{state}")
    ResponseEntity<?> updateDebtState(
            @PathVariable Integer id,
            @PathVariable StateDebt state,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar deuda",
            description =
                    "Elimina una deuda específica del sistema por su ID, incluyendo todos sus registros de pago",
            responses = {
                @ApiResponse(
                        responseCode = "204",
                        description = "Deuda eliminada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Deuda eliminada correctamente",
                          "data": null,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Deuda no encontrada",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Deuda no encontrada con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "409",
                        description = "Deuda con pagos activos, no se puede eliminar",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "No se puede eliminar la deuda porque tiene pagos registrados. Considere cancelarla en su lugar.",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/1"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/1"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID de la deuda a eliminar",
                        required = true,
                        schema = @Schema(type = "integer", example = "1"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @DeleteMapping("/{id}")
    ResponseEntity<?> deleteDebt(
            @PathVariable Integer id, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar múltiples deudas",
            description =
                    "Elimina múltiples deudas del sistema usando una lista de IDs con validaciones de integridad",
            responses = {
                @ApiResponse(
                        responseCode = "204",
                        description = "Deudas eliminadas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "2 deudas eliminadas correctamente",
                          "data": {
                            "deletedCount": 2,
                            "deletedIds": [1, 2],
                            "totalAmountRemoved": 13500.00
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Lista de IDs inválida o vacía",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Debe proporcionar al menos un ID de deuda para eliminar",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Una o más deudas no encontradas",
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Deudas no encontradas con IDs: [15, 20, 25]",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch"
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
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/debt/batch"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "id",
                        description = "Lista de IDs de deudas a eliminar",
                        required = true,
                        schema = @Schema(type = "array", example = "[1, 2]"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @DeleteMapping("/batch")
    ResponseEntity<?> deleteDebts(
            @RequestParam List<Integer> id, @Parameter(hidden = true) HttpServletRequest request);
}
