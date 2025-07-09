package org.kuenteco.backend.controller.logic.transaction;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.util.List;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.BancolombiaTransactionRequestDTO;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.NewTransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.UpdateTransactionDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.logic.transaction.bancolombia.ConectaService;
import org.kuenteco.backend.service.logic.transaction.kuenteco.TransactionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/transaction")
@AllArgsConstructor
public class TransactionController {
    private TransactionService transactionService;
    private ConectaService conectaService;

    @GetMapping
    public ResponseEntity<?> getTransactions(HttpServletRequest request) {
        Object result = transactionService.getTransactions();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Transacciones obtenidas correctamente", result, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/report/summary")
    public ResponseEntity<?> getTransactionSummary(HttpServletRequest request) {
        Object result = transactionService.getTransactionSummary();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Resumen de transacciones obtenida correctamente",
                        result,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/bancolombia")
    public ResponseEntity<?> getBancolombiaTransactions(
            @Valid @RequestBody BancolombiaTransactionRequestDTO request,
            HttpServletRequest servletRequest) {

        String fileUrl = conectaService.getTransactionsFromRequest(request);

        return ResponseEntity.ok(
                ApiResponse.ok(
                        "URL de archivo de transacciones obtenida",
                        fileUrl,
                        servletRequest.getRequestURI()));
    }

    @PostMapping("/add")
    public ResponseEntity<?> addTransaction(
            @Valid @RequestBody NewTransactionDTO dto, HttpServletRequest request) {
        transactionService.addTransaction(dto);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Transacción registrada correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/batch/add")
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

    @PutMapping("/batch/update")
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
            @RequestParam List<Integer> id, HttpServletRequest request) {
        id.forEach(transactionService::deleteTransaction);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        String.format("%d transacciones eliminadas correctamente", id.size()),
                        null,
                        request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }
}
