package org.kuenteco.backend.controller.logic.budget;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.kuenteco.backend.dto.logic.budget.*;
import org.kuenteco.backend.exception.ApiResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Budget", description = "API para la gestión de presupuestos")
public interface BudgetResource {

    @Operation(
            summary = "Obtener todos los presupuestos",
            description = "Recupera una lista de todos los presupuestos",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Lista de presupuestos",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = BudgetDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "[ { \"id\": 1, \"name\": \"Presupuesto Anual\", \"totalBudget\": 10000.00, \"remainingBudget\": 8000.00 } ]")))
            })
    @GetMapping
    ResponseEntity<?> getBudgets(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener asignaciones de presupuestos",
            description = "Retorna todas las asignaciones de presupuesto existentes",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Lista de asignaciones de presupuestos",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(implementation = BudgetEnrollmentDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "[ { \"budgetId\": 1, \"profileId\": 1 } ]")))
            })
    @GetMapping("/enroll")
    ResponseEntity<?> getAllBudgetEnrollments(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener comparación de presupuesto vs gasto",
            description = "Genera un reporte comparando el presupuesto asignado vs el gasto real",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Reporte de comparación",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = BudgetVsActualDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"assignedBudget\": 10000, \"actualSpent\": 9500 }")))
            })
    @GetMapping("/report/comparison")
    ResponseEntity<?> getBudgetComparison(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Obtener resumen de presupuesto",
            description = "Genera un resumen del presupuesto del usuario",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Resumen del presupuesto",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = BudgetSummaryDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"totalBudget\": 10000, \"usedBudget\": 3000, \"remainingBudget\": 7000 }")))
            })
    @GetMapping("/summary")
    ResponseEntity<?> getBudgetSummary(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Agregar nuevo presupuesto",
            description = "Crea un nuevo presupuesto en el sistema",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "201",
                        description = "Presupuesto creado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Presupuesto creado correctamente\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = NewBudgetDTO.class))))
    @PostMapping("/add")
    ResponseEntity<?> addBudget(@Valid @RequestBody NewBudgetDTO dto, HttpServletRequest request);

    @Operation(
            summary = "Actualizar presupuesto",
            description = "Actualiza un presupuesto existente",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Presupuesto actualizado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Presupuesto actualizado correctamente\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = BudgetDTO.class))))
    @PatchMapping("/update")
    ResponseEntity<?> updateBudget(@Valid @RequestBody BudgetDTO dto, HttpServletRequest request);

    @Operation(
            summary = "Eliminar presupuesto",
            description = "Elimina un presupuesto por su ID",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "204",
                        description = "Presupuesto eliminado")
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID del presupuesto a eliminar",
                        required = true)
            })
    @DeleteMapping("/{id}")
    ResponseEntity<?> deleteBudget(@PathVariable Integer id, HttpServletRequest request);

    @Operation(
            summary = "Desinscribir usuario de presupuesto",
            description = "Desinscribe un usuario de un presupuesto específico",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "204",
                        description = "Usuario desinscrito del presupuesto")
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID del presupuesto",
                        required = true)
            })
    @DeleteMapping("/enroll/{id}")
    ResponseEntity<?> removeBudgetEnrollment(@PathVariable Integer id, HttpServletRequest request);
}
