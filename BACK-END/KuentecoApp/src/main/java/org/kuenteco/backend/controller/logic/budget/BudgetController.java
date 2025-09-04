package org.kuenteco.backend.controller.logic.budget;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.logic.budget.BatchEnrollmentRequestDTO;
import org.kuenteco.backend.dto.logic.budget.BudgetDTO;
import org.kuenteco.backend.dto.logic.budget.BudgetEnrollmentDTO;
import org.kuenteco.backend.dto.logic.budget.NewBudgetDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.logic.budget.BudgetEnrollmentService;
import org.kuenteco.backend.service.logic.budget.BudgetService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador para la gestión de presupuestos.
 *
 * <p>Proporciona endpoints para: - Obtener presupuestos y comparaciones - Manejar asignaciones a
 * perfiles - Crear, actualizar, y eliminar presupuestos
 */
@RestController
@RequestMapping("/v1/budget")
@AllArgsConstructor
public class BudgetController implements BudgetResource {
    private BudgetService budgetService;
    private BudgetEnrollmentService budgetEnrollmentService;

    @GetMapping
    public ResponseEntity<?> getBudgets(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        Object result = budgetService.getBudgets();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Presupuestos obtenidas correctamente", result, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/enroll")
    public ResponseEntity<?> getAllBudgetEnrollments(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        Object result = budgetEnrollmentService.getAllBudgetEnrollments();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Presupuestos obtenidos correctamente", result, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/enroll/user")
    public ResponseEntity<?> getBusinessUserBudgetEnrollments(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        Object result = budgetEnrollmentService.getBusinessUserBudgetEnrollments();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Resumen de transacciones por presupuesto obtenido correctamente",
                        result,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/report/comparison")
    public ResponseEntity<?> getBudgetComparison(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        Object result = budgetService.getBudgetVsActualReport();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Reporte de presupuestos vs gastos generado correctamente",
                        result,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/report/summary")
    public ResponseEntity<?> getBudgetSummary(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        Object result = budgetService.getBudgetSummary();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Resumen de presupuestos generado correctamente",
                        result,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/add")
    public ResponseEntity<?> addBudget(
            @Valid @RequestBody NewBudgetDTO dto, HttpServletRequest request) {
        budgetService.addBudget(dto);
        return new ResponseEntity<>(
                ApiResponse.ok("Presupuesto creado correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/batch/add")
    public ResponseEntity<?> addBudgets(
            @Valid @RequestBody List<NewBudgetDTO> dto, HttpServletRequest request) {
        dto.forEach(budgetService::addBudget);
        return new ResponseEntity<>(
                ApiResponse.ok("Presupuestos creados correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PatchMapping("/update")
    public ResponseEntity<?> updateBudget(
            @Valid @RequestBody BudgetDTO dto, HttpServletRequest request) {
        budgetService.updateBudget(dto);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Presupuesto actualizado correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PutMapping("/batch/update")
    public ResponseEntity<?> updateBudgets(
            @Valid @RequestBody List<BudgetDTO> dto, HttpServletRequest request) {
        dto.forEach(budgetService::updateBudget);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Presupuestos actualizados correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/enroll/add")
    public ResponseEntity<?> enrollProfileToBudget(
            @RequestParam Integer profileId,
            @RequestParam Integer budgetId,
            HttpServletRequest request) {
        BudgetEnrollmentDTO dto =
                budgetEnrollmentService.enrollProfileToBudget(profileId, budgetId);
        return new ResponseEntity<>(
                ApiResponse.ok("Presupuesto asignado correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/enroll/add/batch")
    public ResponseEntity<?> enrollProfileToBudgets(
            @RequestBody List<BatchEnrollmentRequestDTO> dto, HttpServletRequest request) {
        List<BudgetEnrollmentDTO> results =
                dto.stream()
                        .map(
                                e ->
                                        budgetEnrollmentService.enrollProfileToBudget(
                                                e.profileId(), e.budgetId()))
                        .toList();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Presupuesto asignado correctamente", results, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteBudget(@PathVariable Integer id, HttpServletRequest request) {
        budgetService.deleteBudget(id);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Presupuesto eliminado correctamente", null, request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/batch")
    public ResponseEntity<?> deleteBudgets(
            @RequestParam List<Integer> id, HttpServletRequest request) {
        id.forEach(budgetService::deleteBudget);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        String.format("%d Presupuestos eliminados correctamente", id.size()),
                        null,
                        request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/enroll/{id}")
    public ResponseEntity<?> removeBudgetEnrollment(
            @PathVariable Integer id, HttpServletRequest request) {
        budgetEnrollmentService.removeBudgetEnrollment(id);
        return new ResponseEntity<>(
                ApiResponse.ok("Asignación eliminada correctamente", null, request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/enroll/batch")
    public ResponseEntity<?> removeBudgetEnrollments(
            @RequestParam List<Integer> id, HttpServletRequest request) {
        id.forEach(budgetEnrollmentService::removeBudgetEnrollment);
        return new ResponseEntity<>(
                ApiResponse.ok("Asignación eliminada correctamente", null, request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }
}
