package org.kuenteco.backend.controller.logic.transaction;

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
import org.kuenteco.backend.dto.logic.transaction.bancolombia.BancolombiaTransactionRequestDTO;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.NewTransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.UpdateTransactionDTO;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Transactions", description = "API para la gestión completa de transacciones financieras")
public interface TransactionResource {

    @Operation(
            summary = "Obtener transacciones",
            description = "Recupera una lista de transacciones con filtros opcionales por fechas y tipo",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Transacciones obtenidas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Transacciones obtenidas correctamente",
                          "data": [
                            {
                              "id": 1,
                              "name": "Compra Supermercado",
                              "description": {
                                "description": "Compra semanal de alimentos",
                                "type": "EXPENSE"
                              },
                              "amount": 25000.00,
                              "date": "2024-01-15T10:30:00Z",
                              "categoryId": 1,
                              "budgetId": 1,
                              "debtId": null
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para filtrar transacciones (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para filtrar transacciones (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de transacción a filtrar",
                        schema = @Schema(type = "string", allowableValues = {"INCOME", "EXPENSE"}, example = "EXPENSE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping
    ResponseEntity<?> getTransactions(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener resumen de transacciones",
            description = "Recupera un resumen estadístico de las transacciones con totales por tipo y período",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Resumen de transacciones obtenido correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Resumen de transacciones obtenida correctamente",
                          "data": {
                            "totalIncome": 5000.00,
                            "totalExpense": 3200.50,
                            "netBalance": 1799.50,
                            "transactionCount": 25,
                            "period": {
                              "from": "2024-01-01T00:00:00Z",
                              "to": "2024-01-31T23:59:59Z"
                            }
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/report/summary"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/report/summary"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/report/summary"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para el resumen (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para el resumen (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de transacción para incluir en el resumen",
                        schema = @Schema(type = "string", allowableValues = {"INCOME", "EXPENSE"}, example = "EXPENSE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/report/summary")
    ResponseEntity<?> getTransactionSummary(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Verificar estado del servicio Bancolombia",
            description = "Comprueba el estado de salud del servicio de integración con Bancolombia",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Servicio Bancolombia operativo",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "status": "UP",
                          "service": "bancolombia-transactional-info",
                          "timestamp": "2024-01-15T10:30:00"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "503",
                        description = "Servicio Bancolombia no disponible",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "status": "DOWN",
                          "service": "bancolombia-transactional-info",
                          "timestamp": "2024-01-15T10:30:00"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class)))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/bancolombia/health")
    ResponseEntity<?> checkHealth();

    @Operation(
            summary = "Obtener transacciones de Bancolombia",
            description = "Genera una URL de archivo con transacciones filtradas desde el sistema Bancolombia",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "URL de archivo de transacciones generada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "URL de archivo de transacciones obtenida",
                          "data": "https://bancolombia-api.com/files/transactions_2024_01.xlsx",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/bancolombia"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Parámetros de solicitud inválidos",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Los parámetros de fecha son requeridos",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/bancolombia"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/bancolombia"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "503",
                        description = "Servicio Bancolombia no disponible",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Servicio de Bancolombia no disponible temporalmente",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/bancolombia"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/bancolombia"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = BancolombiaTransactionRequestDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Solicitud Bancolombia",
                                                            value =
                                                                    """
                        {
                          "startDate": "2024-01-01T00:00:00Z",
                          "endDate": "2024-01-31T23:59:59Z",
                          "accountNumber": "1234567890"
                        }
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/bancolombia")
    ResponseEntity<?> getBancolombiaTransactions(
            @Valid @RequestBody BancolombiaTransactionRequestDTO request,
            @Parameter(hidden = true) HttpServletRequest servletRequest);

    @Operation(
            summary = "Agregar nueva transacción",
            description = "Registra una nueva transacción en el sistema con validaciones completas",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Transacción registrada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Transacción registrada correctamente",
                          "data": {
                            "categoryId": null,
                            "budgetId": null,
                            "debtId": null,
                            "name": "Compra Supermercado",
                            "description": {
                              "description": "Compra semanal de alimentos",
                              "type": "EXPENSE"
                            },
                            "amount": 25000.00
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "Campos requeridos",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El nombre de la transacción es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Monto inválido",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El monto debe ser un valor monetario válido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Categoría no encontrada",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "La categoría especificada no existe",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/add"
                        }
                    """)
                                        })),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/add"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = NewTransactionDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Nueva transacción",
                                                            value =
                                                                    """
                        {
                          "categoryId": null,
                          "budgetId": null,
                          "debtId": null,
                          "name": "Compra Supermercado",
                          "description": {
                            "description": "Compra semanal de alimentos",
                            "type": "EXPENSE"
                          },
                          "amount": 25000.00
                        }
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/add")
    ResponseEntity<?> addTransaction(
            @Valid @RequestBody NewTransactionDTO dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Agregar múltiples transacciones",
            description = "Registra múltiples transacciones en el sistema de forma eficiente",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Transacciones registradas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "30 transacciones creadas exitosamente",
                          "data": null,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos en una o más transacciones",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error en transacción índice 5: El nombre de la transacción es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch/add"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = NewTransactionDTO.class, type = "array"),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Múltiples transacciones",
                                                            value =
                                                                    """
                        [
                          {
                            "categoryId": null,
                            "budgetId": null,
                            "debtId": null,
                            "name": "Gasolina",
                            "description": {
                              "description": "Tanqueada semanal",
                              "type": "EXPENSE"
                            },
                            "amount": 80.0
                          },
                          {
                            "categoryId": null,
                            "budgetId": null,
                            "debtId": null,
                            "name": "Salario",
                            "description": {
                              "description": "Pago mensual salario",
                              "type": "INCOME"
                            },
                            "amount": 3000.0
                          }
                        ]
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/batch/add")
    ResponseEntity<?> registerTransactions(
            @Valid @RequestBody List<NewTransactionDTO> dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Actualizar transacción existente",
            description = "Actualiza los datos de una transacción existente con validaciones completas",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Transacción actualizada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Transacción actualizada correctamente",
                          "data": {
                            "id": 1,
                            "categoryId": 1,
                            "budgetId": 1,
                            "debtId": 1,
                            "description": {
                              "name": "Compra Supermercado Actualizada",
                              "description": "Compra quincenal de alimentos y productos de limpieza",
                              "type": "EXPENSE"
                            },
                            "amount": 280.00
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "ID requerido",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El ID de la transacción es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/update"
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
                          "path": "/v1/transaction/update"
                        }
                    """)
                                        })),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Transacción no encontrada",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Transacción no encontrada con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/update"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = UpdateTransactionDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Actualizar transacción",
                                                            value =
                                                                    """
                        {
                          "id": 1,
                          "categoryId": 1,
                          "budgetId": 1,
                          "debtId": 1,
                          "description": {
                            "name": "Compra Supermercado Actualizada",
                            "description": "Compra quincenal de alimentos y productos de limpieza",
                            "type": "EXPENSE"
                          },
                          "amount": 280.00
                        }
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PatchMapping("/update")
    ResponseEntity<?> updateTransaction(
            @Valid @RequestBody UpdateTransactionDTO dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Actualizar múltiples transacciones",
            description = "Actualiza múltiples transacciones existentes de forma eficiente",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Transacciones actualizadas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Transacciones actualizadas correctamente",
                          "data": [
                            {
                              "id": 1,
                              "categoryId": 1,
                              "budgetId": 1,
                              "debtId": 1,
                              "description": {
                                "name": "Compra de supermercado actualizada",
                                "description": "Compra semanal actualizada",
                                "type": "EXPENSE"
                              },
                              "amount": 175.25
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos en una o más transacciones",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error en transacción índice 2: El ID de la transacción es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Una o más transacciones no encontradas",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Transacciones no encontradas con IDs: [5, 8, 12]",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch/update"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = UpdateTransactionDTO.class, type = "array"),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Múltiples actualizaciones",
                                                            value =
                                                                    """
                        [
                          {
                            "id": 1,
                            "categoryId": 1,
                            "budgetId": 1,
                            "debtId": 1,
                            "description": {
                              "name": "Compra de supermercado actualizada",
                              "description": "Compra semanal actualizada",
                              "type": "EXPENSE"
                            },
                            "amount": 175.25
                          },
                          {
                            "id": 2,
                            "categoryId": 2,
                            "budgetId": 1,
                            "debtId": 2,
                            "description": {
                              "name": "Pago de servicios actualizado",
                              "description": "Pago de electricidad actualizado",
                              "type": "EXPENSE"
                            },
                            "amount": 95.75
                          }
                        ]
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PutMapping("/batch/update")
    ResponseEntity<?> updateTransactions(
            @Valid @RequestBody List<UpdateTransactionDTO> dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar transacción",
            description = "Elimina una transacción específica del sistema por su ID",
            responses = {
                @ApiResponse(
                        responseCode = "204",
                        description = "Transacción eliminada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Transacción eliminada correctamente",
                          "data": null,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Transacción no encontrada",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Transacción no encontrada con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/1"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID de la transacción a eliminar",
                        required = true,
                        schema = @Schema(type = "integer", example = "1"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @DeleteMapping("/{id}")
    ResponseEntity<?> deleteTransaction(
            @PathVariable Integer id, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar múltiples transacciones",
            description = "Elimina múltiples transacciones del sistema usando una lista de IDs",
            responses = {
                @ApiResponse(
                        responseCode = "204",
                        description = "Transacciones eliminadas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "3 transacciones eliminadas correctamente",
                          "data": null,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Lista de IDs inválida o vacía",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Debe proporcionar al menos un ID de transacción",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Una o más transacciones no encontradas",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Transacciones no encontradas con IDs: [15, 20, 25]",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/transaction/batch"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "id",
                        description = "Lista de IDs de transacciones a eliminar",
                        required = true,
                        schema = @Schema(type = "array", example = "[1, 2, 3]"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @DeleteMapping("/batch")
    ResponseEntity<?> deleteTransactions(
            @RequestParam List<Integer> id, @Parameter(hidden = true) HttpServletRequest request);
}