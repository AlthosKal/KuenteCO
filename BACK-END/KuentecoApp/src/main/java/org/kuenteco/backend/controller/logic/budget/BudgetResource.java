package org.kuenteco.backend.controller.logic.budget;

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
import org.kuenteco.backend.dto.logic.budget.*;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Budgets", description = "API para la gestión completa de presupuestos y control financiero")
public interface BudgetResource {

    @Operation(
            summary = "Obtener todos los presupuestos",
            description = "Recupera una lista de todos los presupuestos con filtros opcionales por fechas y tipo",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Presupuestos obtenidos correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Presupuestos obtenidos correctamente",
                          "data": [
                            {
                              "id": 1,
                              "name": "Presupuesto Anual 2024",
                              "totalBudget": 120000.00,
                              "remainingBudget": 85500.00,
                              "usedBudget": 34500.00,
                              "categories": [
                                {"categoryId": 1, "categoryName": "Alimentación", "assignedBudget": 15000.00},
                                {"categoryId": 2, "categoryName": "Transporte", "assignedBudget": 8000.00}
                              ]
                            },
                            {
                              "id": 2,
                              "name": "Presupuesto Mensual",
                              "totalBudget": 10000.00,
                              "remainingBudget": 3500.75,
                              "usedBudget": 6499.25,
                              "categories": []
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget"
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
                          "path": "/v1/budget"
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
                          "path": "/v1/budget"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para filtrar presupuestos (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para filtrar presupuestos (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de presupuesto para filtrar",
                        schema = @Schema(type = "string", allowableValues = {"MONTHLY", "YEARLY", "CUSTOM"}, example = "MONTHLY"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping
    ResponseEntity<?> getBudgets(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener asignaciones de presupuestos",
            description = "Recupera todas las asignaciones de presupuestos a perfiles con filtros opcionales",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Asignaciones de presupuestos obtenidas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Presupuestos obtenidos correctamente",
                          "data": [
                            {
                              "id": 1,
                              "profileId": 1,
                              "budgetId": 1,
                              "enrollmentDate": "2024-01-15T10:30:00Z",
                              "status": "ACTIVE",
                              "budgetName": "Presupuesto Anual 2024"
                            },
                            {
                              "id": 2,
                              "profileId": 1,
                              "budgetId": 2,
                              "enrollmentDate": "2024-01-10T08:20:00Z",
                              "status": "ACTIVE",
                              "budgetName": "Presupuesto Mensual"
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll"
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
                          "path": "/v1/budget/enroll"
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
                          "path": "/v1/budget/enroll"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para filtrar asignaciones (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para filtrar asignaciones (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de asignación para filtrar",
                        schema = @Schema(type = "string", allowableValues = {"ACTIVE", "INACTIVE"}, example = "ACTIVE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/enroll")
    ResponseEntity<?> getAllBudgetEnrollments(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener asignaciones de presupuestos del usuario",
            description = "Recupera las asignaciones de presupuestos específicas del usuario autenticado",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Asignaciones de presupuestos del usuario obtenidas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Resumen de transacciones por presupuesto obtenido correctamente",
                          "data": [
                            {
                              "enrollmentId": 1,
                              "budgetId": 1,
                              "budgetName": "Presupuesto Anual 2024",
                              "totalBudget": 120000.00,
                              "usedAmount": 34500.00,
                              "remainingAmount": 85500.00,
                              "enrollmentDate": "2024-01-15T10:30:00Z",
                              "utilizationPercentage": 28.75
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/user"
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
                          "path": "/v1/budget/enroll/user"
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
                          "path": "/v1/budget/enroll/user"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para filtrar asignaciones (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para filtrar asignaciones (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de asignación para filtrar",
                        schema = @Schema(type = "string", allowableValues = {"ACTIVE", "INACTIVE"}, example = "ACTIVE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/enroll/user")
    ResponseEntity<?> getBusinessUserCategoryEnrollments(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener comparación presupuesto vs gasto real",
            description = "Genera un reporte detallado comparando el presupuesto asignado contra los gastos reales con análisis de desviaciones",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Reporte de comparación generado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = BudgetVsActualDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Reporte de presupuestos vs gastos generado correctamente",
                          "data": {
                            "totalBudget": 120000.00,
                            "totalSpent": 34500.00,
                            "totalRemaining": 85500.00,
                            "utilizationPercentage": 28.75,
                            "categories": [
                              {
                                "categoryName": "Alimentación",
                                "budgetedAmount": 15000.00,
                                "actualAmount": 12750.50,
                                "variance": 2249.50,
                                "variancePercentage": 15.0
                              },
                              {
                                "categoryName": "Transporte",
                                "budgetedAmount": 8000.00,
                                "actualAmount": 9200.00,
                                "variance": -1200.00,
                                "variancePercentage": -15.0
                              }
                            ],
                            "period": {
                              "from": "2024-01-01T00:00:00Z",
                              "to": "2024-01-31T23:59:59Z"
                            }
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/report/comparison"
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
                          "path": "/v1/budget/report/comparison"
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
                          "path": "/v1/budget/report/comparison"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para el reporte (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para el reporte (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de análisis para incluir en el reporte",
                        schema = @Schema(type = "string", allowableValues = {"VARIANCE", "TREND", "DETAILED"}, example = "VARIANCE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/report/comparison")
    ResponseEntity<?> getBudgetComparison(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener resumen ejecutivo de presupuestos",
            description = "Genera un resumen consolidado de todos los presupuestos con estadísticas clave y métricas de rendimiento",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Resumen de presupuestos generado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = BudgetSummaryDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Resumen de presupuestos generado correctamente",
                          "data": {
                            "totalBudgets": 3,
                            "totalBudgetAmount": 180000.00,
                            "totalSpentAmount": 52750.75,
                            "totalRemainingAmount": 127249.25,
                            "overallUtilization": 29.31,
                            "budgetsByStatus": {
                              "onTrack": 2,
                              "overBudget": 0,
                              "underUtilized": 1
                            },
                            "topCategories": [
                              {"categoryName": "Alimentación", "totalSpent": 18500.00, "budgetUtilization": 85.5},
                              {"categoryName": "Transporte", "totalSpent": 12200.00, "budgetUtilization": 76.25}
                            ],
                            "alerts": [
                              {
                                "type": "WARNING",
                                "message": "Presupuesto de transporte está cerca del límite (90% utilizado)",
                                "budgetId": 2
                              }
                            ]
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/report/summary"
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
                          "path": "/v1/budget/report/summary"
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
                          "path": "/v1/budget/report/summary"
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
                        description = "Tipo de resumen para generar",
                        schema = @Schema(type = "string", allowableValues = {"EXECUTIVE", "DETAILED", "ALERTS_ONLY"}, example = "EXECUTIVE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/report/summary")
    ResponseEntity<?> getBudgetSummary(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Crear nuevo presupuesto",
            description = "Registra un nuevo presupuesto en el sistema con validaciones completas y cálculo automático de métricas",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Presupuesto creado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Presupuesto creado correctamente",
                          "data": {
                            "name": "Presupuesto Trimestral Q1",
                            "totalBudget": 30000.00,
                            "remainingBudget": 30000.00
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/add"
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
                          "message": "El nombre del presupuesto es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Presupuesto duplicado",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "Ya existe un presupuesto con el nombre 'Presupuesto Trimestral Q1'",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Monto inválido",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El presupuesto total debe ser un valor monetario válido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/add"
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
                          "path": "/v1/budget/add"
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
                          "path": "/v1/budget/add"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = NewBudgetDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Nuevo presupuesto",
                                                            value =
                                                                    """
                        {
                          "name": "Presupuesto Trimestral Q1",
                          "totalBudget": 30000.00,
                          "remainingBudget": 30000.00
                        }
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/add")
    ResponseEntity<?> addBudget(@Valid @RequestBody NewBudgetDTO dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Crear múltiples presupuestos",
            description = "Registra múltiples presupuestos en el sistema de forma eficiente con validación individual",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Presupuestos creados correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Presupuestos creados correctamente",
                          "data": [
                            {
                              "name": "Presupuesto Trimestral Q1",
                              "totalBudget": 30000.00,
                              "remainingBudget": 30000.00
                            },
                            {
                              "name": "Presupuesto Emergencias",
                              "totalBudget": 5000.00,
                              "remainingBudget": 5000.00
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/batch/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos en uno o más presupuestos",
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
                          "message": "Error en presupuesto índice 2: El nombre del presupuesto es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/batch/add"
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
                          "path": "/v1/budget/batch/add"
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
                          "path": "/v1/budget/batch/add"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = NewBudgetDTO.class, type = "array"),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Múltiples presupuestos",
                                                            value =
                                                                    """
                        [
                          {
                            "name": "Presupuesto Trimestral Q1",
                            "totalBudget": 30000.00,
                            "remainingBudget": 30000.00
                          },
                          {
                            "name": "Presupuesto Emergencias",
                            "totalBudget": 5000.00,
                            "remainingBudget": 5000.00
                          }
                        ]
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/batch/add")
    ResponseEntity<?> addBudgets(@Valid @RequestBody List<NewBudgetDTO> dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Actualizar presupuesto existente",
            description = "Actualiza los datos de un presupuesto existente con recalculo automático de métricas y validaciones",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Presupuesto actualizado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Presupuesto actualizado correctamente",
                          "data": {
                            "id": 1,
                            "name": "Presupuesto Anual 2024 - Actualizado",
                            "totalBudget": 150000.00,
                            "remainingBudget": 115500.00
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/update"
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
                          "message": "El ID del presupuesto es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/update"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Presupuesto no encontrado",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "No se encontró el presupuesto con ID: 999",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/update"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Presupuesto insuficiente",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El presupuesto restante no puede ser menor que el gasto actual",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/update"
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
                          "path": "/v1/budget/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Presupuesto no encontrado",
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
                          "message": "Presupuesto no encontrado con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/update"
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
                          "path": "/v1/budget/update"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = BudgetDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Actualizar presupuesto",
                                                            value =
                                                                    """
                        {
                          "id": 1,
                          "name": "Presupuesto Anual 2024 - Actualizado",
                          "totalBudget": 150000.00,
                          "remainingBudget": 115500.00
                        }
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PatchMapping("/update")
    ResponseEntity<?> updateBudget(@Valid @RequestBody BudgetDTO dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Actualizar múltiples presupuestos",
            description = "Actualiza múltiples presupuestos existentes de forma eficiente con validación individual",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Presupuestos actualizados correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Presupuestos actualizados correctamente",
                          "data": [
                            {
                              "id": 1,
                              "name": "Presupuesto Anual 2024 - Actualizado",
                              "totalBudget": 150000.00,
                              "remainingBudget": 115500.00
                            },
                            {
                              "id": 2,
                              "name": "Presupuesto Mensual - Actualizado",
                              "totalBudget": 12000.00,
                              "remainingBudget": 8500.75
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos en uno o más presupuestos",
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
                          "message": "Error en presupuesto índice 1: El ID del presupuesto es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/batch/update"
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
                          "path": "/v1/budget/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Uno o más presupuestos no encontrados",
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
                          "message": "Presupuestos no encontrados con IDs: [5, 8, 12]",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/batch/update"
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
                          "path": "/v1/budget/batch/update"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = BudgetDTO.class, type = "array"),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Múltiples actualizaciones",
                                                            value =
                                                                    """
                        [
                          {
                            "id": 1,
                            "name": "Presupuesto Anual 2024 - Actualizado",
                            "totalBudget": 150000.00,
                            "remainingBudget": 115500.00
                          },
                          {
                            "id": 2,
                            "name": "Presupuesto Mensual - Actualizado",
                            "totalBudget": 12000.00,
                            "remainingBudget": 8500.75
                          }
                        ]
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PutMapping("/batch/update")
    ResponseEntity<?> updateBudgets(@Valid @RequestBody List<BudgetDTO> dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Asignar perfil a presupuesto",
            description = "Asigna un perfil específico a un presupuesto para seguimiento y control de gastos personalizado",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Presupuesto asignado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = BudgetEnrollmentDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Presupuesto asignado correctamente",
                          "data": {
                            "id": 1,
                            "profileId": 1,
                            "budgetId": 1,
                            "enrollmentDate": "2024-01-15T10:30:00Z",
                            "status": "ACTIVE"
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Parámetros inválidos o asignación ya existente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = org.kuenteco.backend.exception.ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "Asignación duplicada",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El perfil ya está asignado a este presupuesto",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Presupuesto inactivo",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "No se puede asignar a un presupuesto inactivo",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/add"
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
                          "path": "/v1/budget/enroll/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Perfil o presupuesto no encontrados",
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
                          "message": "Presupuesto no encontrado con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/add"
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
                          "path": "/v1/budget/enroll/add"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "profileId",
                        description = "ID del perfil a asignar",
                        required = true,
                        schema = @Schema(type = "integer", example = "1")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "budgetId",
                        description = "ID del presupuesto a asignar",
                        required = true,
                        schema = @Schema(type = "integer", example = "1"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/enroll/add")
    ResponseEntity<?> enrollProfileToBudget(
            @RequestParam Integer profileId,
            @RequestParam Integer budgetId,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Asignar múltiples perfiles a presupuestos",
            description = "Realiza asignaciones masivas de perfiles a presupuestos de forma eficiente",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Asignaciones realizadas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Presupuesto asignado correctamente",
                          "data": [
                            {
                              "id": 1,
                              "profileId": 1,
                              "budgetId": 1,
                              "enrollmentDate": "2024-01-15T10:30:00Z",
                              "status": "ACTIVE"
                            },
                            {
                              "id": 2,
                              "profileId": 2,
                              "budgetId": 1,
                              "enrollmentDate": "2024-01-15T10:30:00Z",
                              "status": "ACTIVE"
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/add/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos en una o más asignaciones",
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
                          "message": "Error en asignación índice 3: El perfil ya está asignado a este presupuesto",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/add/batch"
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
                          "path": "/v1/budget/enroll/add/batch"
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
                          "path": "/v1/budget/enroll/add/batch"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = BatchEnrollmentRequestDTO.class, type = "array"),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Asignaciones múltiples",
                                                            value =
                                                                    """
                        [
                          { "profileId": 1, "budgetId": 1 },
                          { "profileId": 2, "budgetId": 1 },
                          { "profileId": 3, "budgetId": 2 }
                        ]
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/enroll/add/batch")
    ResponseEntity<?> enrollProfileToBudgets(
            @RequestBody List<BatchEnrollmentRequestDTO> dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar presupuesto",
            description = "Elimina un presupuesto específico del sistema por su ID, incluyendo todas sus asignaciones",
            responses = {
                @ApiResponse(
                        responseCode = "204",
                        description = "Presupuesto eliminado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Presupuesto eliminado correctamente",
                          "data": null,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/1"
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
                          "path": "/v1/budget/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Presupuesto no encontrado",
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
                          "message": "Presupuesto no encontrado con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "409",
                        description = "Presupuesto en uso, no se puede eliminar",
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
                          "message": "No se puede eliminar el presupuesto porque tiene transacciones asociadas",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/1"
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
                          "path": "/v1/budget/1"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID del presupuesto a eliminar",
                        required = true,
                        schema = @Schema(type = "integer", example = "1"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @DeleteMapping("/{id}")
    ResponseEntity<?> deleteBudget(@PathVariable Integer id, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar múltiples presupuestos",
            description = "Elimina múltiples presupuestos del sistema usando una lista de IDs",
            responses = {
                @ApiResponse(
                        responseCode = "204",
                        description = "Presupuestos eliminados correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "3 Presupuestos eliminados correctamente",
                          "data": null,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/batch"
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
                          "message": "Debe proporcionar al menos un ID de presupuesto",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/batch"
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
                          "path": "/v1/budget/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Uno o más presupuestos no encontrados",
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
                          "message": "Presupuestos no encontrados con IDs: [15, 20, 25]",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/batch"
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
                          "path": "/v1/budget/batch"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "id",
                        description = "Lista de IDs de presupuestos a eliminar",
                        required = true,
                        schema = @Schema(type = "array", example = "[1, 2, 3]"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @DeleteMapping("/batch")
    ResponseEntity<?> deleteBudgets(
            @RequestParam List<Integer> id, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar asignación de presupuesto",
            description = "Elimina una asignación específica de presupuesto por su ID",
            responses = {
                @ApiResponse(
                        responseCode = "204",
                        description = "Asignación eliminada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Asignación eliminada correctamente",
                          "data": null,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/1"
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
                          "path": "/v1/budget/enroll/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Asignación no encontrada",
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
                          "message": "Asignación no encontrada con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/1"
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
                          "path": "/v1/budget/enroll/1"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID de la asignación a eliminar",
                        required = true,
                        schema = @Schema(type = "integer", example = "1"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @DeleteMapping("/enroll/{id}")
    ResponseEntity<?> removeBudgetEnrollment(
            @PathVariable Integer id, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar múltiples asignaciones de presupuestos",
            description = "Elimina múltiples asignaciones de presupuestos usando una lista de IDs",
            responses = {
                @ApiResponse(
                        responseCode = "204",
                        description = "Asignaciones eliminadas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Asignación eliminada correctamente",
                          "data": null,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/batch"
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
                          "message": "Debe proporcionar al menos un ID de asignación",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/batch"
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
                          "path": "/v1/budget/enroll/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Una o más asignaciones no encontradas",
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
                          "message": "Asignaciones no encontradas con IDs: [15, 20, 25]",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/budget/enroll/batch"
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
                          "path": "/v1/budget/enroll/batch"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "id",
                        description = "Lista de IDs de asignaciones a eliminar",
                        required = true,
                        schema = @Schema(type = "array", example = "[1, 2, 3]"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @DeleteMapping("/enroll/batch")
    ResponseEntity<?> removeBudgetEnrollments(
            @RequestParam List<Integer> id, @Parameter(hidden = true) HttpServletRequest request);
}