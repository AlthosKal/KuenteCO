package org.kuenteco.backend.controller.logic.transaction;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.logic.transaction.NewTransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.UpdateTransactionDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.logic.transaction.TransactionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/transaction")
@AllArgsConstructor
public class TransactionController {
    private final TransactionService transactionService;

    @GetMapping
    public ResponseEntity<?> getTransactions(HttpServletRequest request) {
        Object result = transactionService.getTransactions();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Transacciones obtenidas correctamente", result, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/add")
    public ResponseEntity<?> registerTransaction(
            @Valid @RequestBody NewTransactionDTO dto, HttpServletRequest request) {
        transactionService.addTransaction(dto);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Transacción registrada correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/add/batch")
    public ResponseEntity<?> registerTransactions(
            @Valid @RequestBody List<NewTransactionDTO> dto, HttpServletRequest request) {
        dto.forEach(transactionService::addTransaction);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        String.format("%d transacciones creadas exitosamente", dto.size()),
                        null,
                        request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PatchMapping("/update")
    public ResponseEntity<?> updateTransaction(
            @Valid @RequestBody UpdateTransactionDTO dto, HttpServletRequest request) {
        transactionService.updateTransaction(dto);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Transacción actualizada correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PutMapping("/update/batch")
    public ResponseEntity<?> updateTransactions(
            @Valid @RequestBody List<UpdateTransactionDTO> dto, HttpServletRequest request) {
        dto.forEach(transactionService::updateTransaction);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Transacciones actualizadas correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTransaction(
            @PathVariable Integer id, HttpServletRequest request) {
        transactionService.deleteTransaction(id);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Transacción eliminada correctamente", null, request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    // Usando RequestParam para la lista
    @DeleteMapping("/batch")
    public ResponseEntity<?> deleteTransactions(
            @RequestParam List<Integer> ids, HttpServletRequest request) {
        ids.forEach(transactionService::deleteTransaction);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        String.format("%d transacciones eliminadas correctamente", ids.size()),
                        null,
                        request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }
}
