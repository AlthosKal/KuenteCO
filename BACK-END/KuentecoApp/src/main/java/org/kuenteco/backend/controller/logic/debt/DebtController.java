package org.kuenteco.backend.controller.logic.debt;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.math.BigDecimal;
import java.util.List;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.logic.debt.DebtDTO;
import org.kuenteco.backend.dto.logic.debt.DebtPaymentDTO;
import org.kuenteco.backend.dto.logic.debt.NewDebtDTO;
import org.kuenteco.backend.enums.StateDebt;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.logic.debt.DebtService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/debt")
@AllArgsConstructor
public class DebtController implements DebtResource {

    private DebtService debtService;

    @GetMapping
    public ResponseEntity<?> getAllDebts(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        Object debts = debtService.getDebts();
        return new ResponseEntity<>(
                ApiResponse.ok("Deudas obtenidas correctamente", debts, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/state/{state}")
    public ResponseEntity<?> getDebtsByState(
            @PathVariable StateDebt state,
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        Object debts = debtService.getDebtsByState(state);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Deudas filtradas por estado obtenidas correctamente",
                        debts,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/overdue")
    public ResponseEntity<?> getOverdueDebts(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        Object debts = debtService.getOverdueDebts();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Deudas vencidas obtenidas correctamente", debts, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/expiring-soon")
    public ResponseEntity<?> getDebtsExpiringInDays(
            @RequestParam("days") Integer days,
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        Object debts = debtService.getDebtsExpiringInDays(days);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Deudas próximas a vencer obtenidas correctamente",
                        debts,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/total-pending")
    public ResponseEntity<?> getTotalPendingAmount(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        BigDecimal totalPending = debtService.getTotalPendingAmount();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Total pendiente del usuario obtenido correctamente",
                        totalPending,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/report/summary")
    public ResponseEntity<?> getDebtSummaryReport(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind) {
        Object result = debtService.getDebtSummaryReport();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Resumen de deudas generado correctamente",
                        result,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/add")
    public ResponseEntity<?> addDebt(
            @Valid @RequestBody NewDebtDTO dto, HttpServletRequest request) {
        debtService.addDebt(dto);
        return new ResponseEntity<>(
                ApiResponse.ok("Deuda creada correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/batch/add")
    public ResponseEntity<?> addDebts(
            @Valid @RequestBody List<NewDebtDTO> dto, HttpServletRequest request) {
        dto.forEach(debtService::addDebt);
        return new ResponseEntity<>(
                ApiResponse.ok("Deudas creadas correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PatchMapping("/update")
    public ResponseEntity<?> updateDebt(
            @Valid @RequestBody DebtDTO dto, HttpServletRequest request) {
        debtService.updateDebt(dto);
        return new ResponseEntity<>(
                ApiResponse.ok("Deuda actualizada correctamente", dto, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PutMapping("/batch/update")
    public ResponseEntity<?> updateDebts(
            @Valid @RequestBody List<DebtDTO> dto, HttpServletRequest request) {
        dto.forEach(debtService::updateDebt);
        return new ResponseEntity<>(
                ApiResponse.ok("Deudas actualizadas correctamente", dto, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/payment")
    public ResponseEntity<?> makePayment(
            @Valid @RequestBody DebtPaymentDTO dto, HttpServletRequest request) {
        debtService.makePayment(dto);
        return new ResponseEntity<>(
                ApiResponse.ok("Pago realizado correctamente", dto, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PatchMapping("/{id}/state/{state}")
    public ResponseEntity<?> updateDebtState(
            @PathVariable Integer id, @PathVariable StateDebt state, HttpServletRequest request) {
        debtService.updateDebtState(id, state);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Estado de la deuda actualizado correctamente",
                        null,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteDebt(@PathVariable Integer id, HttpServletRequest request) {
        debtService.deleteDebt(id);
        return new ResponseEntity<>(
                ApiResponse.ok("Deuda eliminada correctamente", null, request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/batch")
    public ResponseEntity<?> deleteDebts(
            @RequestParam List<Integer> id, HttpServletRequest request) {
        id.forEach(debtService::deleteDebt);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        String.format("%d deudas eliminadas correctamente", id.size()),
                        null,
                        request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }
}
