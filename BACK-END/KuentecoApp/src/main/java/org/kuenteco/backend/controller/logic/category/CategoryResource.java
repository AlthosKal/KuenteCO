package org.kuenteco.backend.controller.logic.category;

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
import org.kuenteco.backend.dto.logic.category.*;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Categories", description = "API para la gestión completa de categorías de gastos e ingresos")
public interface CategoryResource {

    @Operation(
            summary = "Obtener todas las categorías",
            description = "Recupera una lista de todas las categorías con filtros opcionales por fechas y tipo",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Categorías obtenidas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Categorías obtenidas correctamente",
                          "data": [
                            {
                              "id": 1,
                              "budgetId": 5,
                              "name": "Alimentación",
                              "description": {
                                "assignedBudget": 1500.00,
                                "state": "ACTIVE"
                              }
                            },
                            {
                              "id": 2,
                              "budgetId": 6,
                              "name": "Transporte",
                              "description": {
                                "assignedBudget": 800.00,
                                "state": "INACTIVE"
                              }
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category"
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
                          "path": "/v1/category"
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
                          "path": "/v1/category"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "from",
                        description = "Fecha de inicio para filtrar categorías (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-01T00:00:00Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "to",
                        description = "Fecha de fin para filtrar categorías (formato ISO 8601)",
                        schema = @Schema(type = "string", format = "date-time", example = "2024-01-31T23:59:59Z")),
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "kind",
                        description = "Tipo de categoría para filtrar",
                        schema = @Schema(type = "string", allowableValues = {"INCOME", "EXPENSE"}, example = "EXPENSE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping
    ResponseEntity<?> getCategories(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener asignaciones de categorías",
            description = "Recupera todas las asignaciones de categorías a perfiles con filtros opcionales",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Asignaciones de categorías obtenidas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Categorías obtenidas correctamente",
                          "data": [
                            {
                              "id": 1,
                              "profileId": 1,
                              "categoryId": 5,
                              "enrollmentDate": "2024-01-15T10:30:00Z",
                              "status": "ACTIVE"
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/enroll"
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
                          "path": "/v1/category/enroll"
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
                          "path": "/v1/category/enroll"
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
    ResponseEntity<?> getAllCategoryEnrollments(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener reporte de categoría específica",
            description = "Genera un reporte detallado de una categoría específica con estadísticas y transacciones",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Reporte de categoría generado exitosamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = CategoryReportDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Reporte de categoría generado exitosamente",
                          "data": {
                            "categoryId": 1,
                            "categoryName": "Alimentación",
                            "assignedBudget": 1500.00,
                            "usedBudget": 875.50,
                            "remainingBudget": 624.50,
                            "transactionCount": 12,
                            "period": {
                              "from": "2024-01-01T00:00:00Z",
                              "to": "2024-01-31T23:59:59Z"
                            }
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/report/1"
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
                          "path": "/v1/category/report/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Categoría no encontrada",
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
                          "message": "Categoría no encontrada con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/report/1"
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
                          "path": "/v1/category/report/1"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "categoryId",
                        description = "ID de la categoría para generar el reporte",
                        required = true,
                        schema = @Schema(type = "integer", example = "1")),
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
                        description = "Tipo de transacciones para incluir en el reporte",
                        schema = @Schema(type = "string", allowableValues = {"INCOME", "EXPENSE"}, example = "EXPENSE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/report/{categoryId}")
    ResponseEntity<?> getCategoryReport(
            @PathVariable Integer categoryId,
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener resumen de transacciones por categoría",
            description = "Recupera un resumen estadístico de todas las transacciones agrupadas por categorías",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Resumen de transacciones por categoría obtenido correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Resumen de transacciones por categoría obtenido correctamente",
                          "data": {
                            "categories": [
                              {
                                "categoryId": 1,
                                "categoryName": "Alimentación",
                                "totalAmount": 1250.75,
                                "transactionCount": 8,
                                "percentage": 35.2
                              },
                              {
                                "categoryId": 2,
                                "categoryName": "Transporte",
                                "totalAmount": 680.30,
                                "transactionCount": 5,
                                "percentage": 19.1
                              }
                            ],
                            "totalAmount": 3550.45,
                            "totalCategories": 12
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/report/summary"
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
                          "path": "/v1/category/report/summary"
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
                          "path": "/v1/category/report/summary"
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
                        description = "Tipo de transacciones para incluir en el resumen",
                        schema = @Schema(type = "string", allowableValues = {"INCOME", "EXPENSE"}, example = "EXPENSE"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/report/summary")
    ResponseEntity<?> getTransactionsByCategory(
            @Parameter(hidden = true) HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener asignaciones de categorías del usuario",
            description = "Recupera las asignaciones de categorías específicas del usuario autenticado",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Asignaciones de categorías del usuario obtenidas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Resumen de transacciones por categoría obtenido correctamente",
                          "data": [
                            {
                              "enrollmentId": 1,
                              "categoryId": 5,
                              "categoryName": "Alimentación",
                              "assignedBudget": 1500.00,
                              "usedAmount": 875.50,
                              "enrollmentDate": "2024-01-15T10:30:00Z"
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/enroll/user"
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
                          "path": "/v1/category/enroll/user"
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
                          "path": "/v1/category/enroll/user"
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
            summary = "Crear nueva categoría",
            description = "Registra una nueva categoría en el sistema con validaciones completas",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Categoría creada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Categoría creada correctamente",
                          "data": {
                            "budgetId": 5,
                            "name": "Alimentación",
                            "description": {
                              "assignedBudget": 1500.00,
                              "state": "ACTIVE"
                            }
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/add"
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
                          "message": "El nombre de la categoría es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Categoría duplicada",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "Ya existe una categoría con el nombre 'Alimentación'",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Presupuesto no encontrado",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El presupuesto especificado no existe",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/add"
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
                          "path": "/v1/category/add"
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
                          "path": "/v1/category/add"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = NewCategoryDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Nueva categoría",
                                                            value =
                                                                    """
                        {
                          "budgetId": 5,
                          "name": "Alimentación",
                          "description": {
                            "assignedBudget": 1500.00,
                            "state": "ACTIVE"
                          }
                        }
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/add")
    ResponseEntity<?> addCategory(
            @Valid @RequestBody NewCategoryDTO dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Crear múltiples categorías",
            description = "Registra múltiples categorías en el sistema de forma eficiente",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Categorías creadas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Categorías creadas correctamente",
                          "data": [
                            {
                              "budgetId": 1,
                              "name": "Alimentación",
                              "description": {
                                "assignedBudget": 1500.00,
                                "state": "ACTIVE"
                              }
                            },
                            {
                              "budgetId": 2,
                              "name": "Transporte",
                              "description": {
                                "assignedBudget": 800.00,
                                "state": "INACTIVE"
                              }
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/batch/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos en una o más categorías",
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
                          "message": "Error en categoría índice 3: El nombre de la categoría es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/batch/add"
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
                          "path": "/v1/category/batch/add"
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
                          "path": "/v1/category/batch/add"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = NewCategoryDTO.class, type = "array"),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Múltiples categorías",
                                                            value =
                                                                    """
                        [
                          {
                            "budgetId": 1,
                            "name": "Alimentación",
                            "description": {
                              "assignedBudget": 1500.00,
                              "state": "ACTIVE"
                            }
                          },
                          {
                            "budgetId": 2,
                            "name": "Transporte",
                            "description": {
                              "assignedBudget": 800.00,
                              "state": "INACTIVE"
                            }
                          }
                        ]
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/batch/add")
    ResponseEntity<?> addCategories(
            @Valid @RequestBody List<NewCategoryDTO> dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Actualizar categoría existente",
            description = "Actualiza los datos de una categoría existente con validaciones completas",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Categoría actualizada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Categoría actualizada correctamente",
                          "data": {
                            "id": 2,
                            "budgetId": null,
                            "name": "Alimentación y Comestibles",
                            "description": {
                              "assignedBudget": 123456789.00,
                              "state": "ACTIVE"
                            }
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/update"
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
                          "message": "El ID de la categoría es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/update"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Categoría no encontrada",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "No se encontró la categoría con ID: 999",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/update"
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
                          "path": "/v1/category/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Categoría no encontrada",
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
                          "message": "Categoría no encontrada con ID: 2",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/update"
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
                          "path": "/v1/category/update"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = UpdateCategoryDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Actualizar categoría",
                                                            value =
                                                                    """
                        {
                          "id": 2,
                          "budgetId": null,
                          "name": "Alimentación y Comestibles",
                          "description": {
                            "assignedBudget": 123456789.00,
                            "state": "ACTIVE"
                          }
                        }
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PatchMapping("/update")
    ResponseEntity<?> updateCategory(
            @Valid @RequestBody UpdateCategoryDTO dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Actualizar múltiples categorías",
            description = "Actualiza múltiples categorías existentes de forma eficiente",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Categorías actualizadas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Categorías actualizadas correctamente",
                          "data": [
                            {
                              "id": 3,
                              "budgetId": 3,
                              "name": "Alimentación Actualizada",
                              "description": {
                                "assignedBudget": 1800.00,
                                "state": "ACTIVE"
                              }
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos en una o más categorías",
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
                          "message": "Error en categoría índice 2: El ID de la categoría es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/batch/update"
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
                          "path": "/v1/category/batch/update"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Una o más categorías no encontradas",
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
                          "message": "Categorías no encontradas con IDs: [15, 20, 25]",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/batch/update"
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
                          "path": "/v1/category/batch/update"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = UpdateCategoryDTO.class, type = "array"),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Múltiples actualizaciones",
                                                            value =
                                                                    """
                        [
                          {
                            "id": 3,
                            "budgetId": 3,
                            "name": "Alimentación Actualizada",
                            "description": {
                              "assignedBudget": 1800.00,
                              "state": "ACTIVE"
                            }
                          },
                          {
                            "id": 4,
                            "budgetId": 4,
                            "name": "Transporte Actualizado",
                            "description": {
                              "assignedBudget": 950.00,
                              "state": "ACTIVE"
                            }
                          }
                        ]
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PutMapping("/batch/update")
    ResponseEntity<?> updateCategories(
            @Valid @RequestBody List<UpdateCategoryDTO> dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Asignar perfil a categoría",
            description = "Asigna un perfil específico a una categoría para seguimiento de gastos",
            responses = {
                @ApiResponse(
                        responseCode = "201",
                        description = "Categoría asignada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = CategoryEnrollmentDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Categoría asignada correctamente",
                          "data": {
                            "id": 1,
                            "profileId": 1,
                            "categoryId": 1,
                            "enrollmentDate": "2024-01-15T10:30:00Z",
                            "status": "ACTIVE"
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/enroll/add"
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
                          "message": "El perfil ya está asignado a esta categoría",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/enroll/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Perfil no encontrado",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "No se encontró el perfil con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/enroll/add"
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
                          "path": "/v1/category/enroll/add"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Perfil o categoría no encontrados",
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
                          "message": "Categoría no encontrada con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/enroll/add"
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
                          "path": "/v1/category/enroll/add"
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
                        name = "categoryId",
                        description = "ID de la categoría a asignar",
                        required = true,
                        schema = @Schema(type = "integer", example = "1"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/enroll/add")
    ResponseEntity<?> enrollProfileToCategory(
            @RequestParam Integer profileId,
            @RequestParam Integer categoryId,
            @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Asignar múltiples perfiles a categorías",
            description = "Realiza asignaciones masivas de perfiles a categorías de forma eficiente",
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
                          "message": "Categoría asignada correctamente",
                          "data": [
                            {
                              "id": 1,
                              "profileId": 1,
                              "categoryId": 10,
                              "enrollmentDate": "2024-01-15T10:30:00Z",
                              "status": "ACTIVE"
                            },
                            {
                              "id": 2,
                              "profileId": 2,
                              "categoryId": 10,
                              "enrollmentDate": "2024-01-15T10:30:00Z",
                              "status": "ACTIVE"
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/enroll/add/batch"
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
                          "message": "Error en asignación índice 2: El perfil ya está asignado a esta categoría",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/enroll/add/batch"
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
                          "path": "/v1/category/enroll/add/batch"
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
                          "path": "/v1/category/enroll/add/batch"
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
                          { "profileId": 1, "categoryId": 10 },
                          { "profileId": 2, "categoryId": 10 },
                          { "profileId": 3, "categoryId": 11 }
                        ]
                    """))),
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/enroll/add/batch")
    ResponseEntity<?> enrollProfilesToCategories(
            @RequestBody List<BatchEnrollmentRequestDTO> dto, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar categoría",
            description = "Elimina una categoría específica del sistema por su ID",
            responses = {
                @ApiResponse(
                        responseCode = "204",
                        description = "Categoría eliminada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Categoría eliminada correctamente",
                          "data": null,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/1"
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
                          "path": "/v1/category/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Categoría no encontrada",
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
                          "message": "Categoría no encontrada con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/1"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "409",
                        description = "Categoría en uso, no se puede eliminar",
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
                          "message": "No se puede eliminar la categoría porque tiene transacciones asociadas",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/1"
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
                          "path": "/v1/category/1"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID de la categoría a eliminar",
                        required = true,
                        schema = @Schema(type = "integer", example = "1"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @DeleteMapping("/{id}")
    ResponseEntity<?> deleteCategory(@PathVariable Integer id, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar múltiples categorías",
            description = "Elimina múltiples categorías del sistema usando una lista de IDs",
            responses = {
                @ApiResponse(
                        responseCode = "204",
                        description = "Categorías eliminadas correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "3 Categorías eliminadas correctamente",
                          "data": null,
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/batch"
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
                          "message": "Debe proporcionar al menos un ID de categoría",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/batch"
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
                          "path": "/v1/category/batch"
                        }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Una o más categorías no encontradas",
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
                          "message": "Categorías no encontradas con IDs: [15, 20, 25]",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/category/batch"
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
                          "path": "/v1/category/batch"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "id",
                        description = "Lista de IDs de categorías a eliminar",
                        required = true,
                        schema = @Schema(type = "array", example = "[1, 2, 3]"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @DeleteMapping("/batch")
    ResponseEntity<?> deleteCategories(
            @RequestParam List<Integer> id, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar asignación de categoría",
            description = "Elimina una asignación específica de categoría por su ID",
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
                          "path": "/v1/category/enroll/1"
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
                          "path": "/v1/category/enroll/1"
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
                          "path": "/v1/category/enroll/1"
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
                          "path": "/v1/category/enroll/1"
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
    ResponseEntity<?> removeCategoryEnrollment(
            @PathVariable Integer id, @Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Eliminar múltiples asignaciones de categorías",
            description = "Elimina múltiples asignaciones de categorías usando una lista de IDs",
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
                          "path": "/v1/category/enroll/batch"
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
                          "path": "/v1/category/enroll/batch"
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
                          "path": "/v1/category/enroll/batch"
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
                          "path": "/v1/category/enroll/batch"
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
                          "path": "/v1/category/enroll/batch"
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
    ResponseEntity<?> removeCategoryEnrollments(
            @RequestParam List<Integer> id, @Parameter(hidden = true) HttpServletRequest request);
}