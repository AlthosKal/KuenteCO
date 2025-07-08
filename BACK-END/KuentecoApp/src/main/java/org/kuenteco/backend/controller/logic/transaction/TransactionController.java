package org.kuenteco.backend.controller.logic.transaction;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

import java.time.LocalDate;
import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.AccountDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.TransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.TransactionsResponseDTO;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.NewTransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.UpdateTransactionDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.logic.transaction.bancolombia.ConectaService;
import org.kuenteco.backend.service.logic.transaction.kuenteco.TransactionService;
import org.springframework.format.annotation.DateTimeFormat;
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

    @GetMapping("/accounts")
    public ResponseEntity<?> getAccountsToBancolombia(HttpServletRequest request) {
       /* AuthCredentials credentials = AuthUtil.getCredentials();
        log.info("Usuario {} solicitando cuentas de Bancolombia", credentials.getEmail());*/

        List<AccountDTO> accounts = conectaService.getAccounts();

        return ResponseEntity.ok(ApiResponse.ok(
                "Cuentas obtenidas exitosamente",
                accounts,
                request.getRequestURI()
        ));
    }

    @GetMapping("/accounts/{accountId}")
    public ResponseEntity<?> getAccountToBancolombia(@PathVariable @NotBlank String accountId, HttpServletRequest request) {
/*
        AuthCredentials credentials = AuthUtil.getCredentials();
        log.info("Usuario {} solicitando cuenta {} de Bancolombia", credentials.getEmail(), accountId);
*/
        AccountDTO account = conectaService.getAccount(accountId);

        return ResponseEntity.ok(ApiResponse.ok(
                "Cuenta obtenida exitosamente",
                account,
                request.getRequestURI()
        ));
    }

    @GetMapping("/accounts/{accountId}/transactions")
    public ResponseEntity<?> getTransactionsToBancolombia(
            @PathVariable @NotBlank String accountId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,

            HttpServletRequest request) {
/*
        log.info("Solicitando transacciones para cuenta {} desde {} hasta {}", accountId, from, to);

        AuthCredentials credentials = AuthUtil.getCredentials();
        log.info("Usuario {} solicitando transacciones para cuenta {}", credentials.getEmail(), accountId);
*/
        List<TransactionDTO> transactions = conectaService.getTransactions(accountId, from, to);

        return ResponseEntity.ok(ApiResponse.ok(
                "Transacciones obtenidas exitosamente",
                transactions,
                request.getRequestURI()
        ));
    }

    @GetMapping("/accounts/{accountId}/transactions/recent")
    public ResponseEntity<?> getRecentTransactions(
            @PathVariable @NotBlank String accountId,
            HttpServletRequest request) {
/*
        log.info("Solicitando transacciones recientes para cuenta {}", accountId);

        AuthCredentials credentials = AuthUtil.getCredentials();
        log.info("Usuario {} solicitando transacciones recientes para cuenta {}", credentials.getEmail(), accountId);
*/
        List<TransactionDTO> transactions = conectaService.getRecentTransactions(accountId);

        return ResponseEntity.ok(ApiResponse.ok(
                "Transacciones recientes obtenidas exitosamente",
                transactions,
                request.getRequestURI()
        ));
    }

    @GetMapping("/accounts/{accountId}/transactions/period")
    public ResponseEntity<?> getTransactionsForPeriod(
            @PathVariable @NotBlank String accountId,
            @RequestParam @Positive int days,

            HttpServletRequest request) {
/*
        log.info("Solicitando transacciones de {} días para cuenta {}", days, accountId);

        AuthCredentials credentials = AuthUtil.getCredentials();
        log.info("Usuario {} solicitando transacciones de {} días para cuenta {}",
                credentials.getEmail(), days, accountId);
*/
        List<TransactionDTO> transactions = conectaService.getTransactionsForPeriod(accountId, days);

        return ResponseEntity.ok(ApiResponse.ok(
                "Transacciones del período obtenidas exitosamente",
                transactions,
                request.getRequestURI()
        ));
    }

    @GetMapping("/accounts/{accountId}/transactions/summary")
    public ResponseEntity<?> getTransactionsSummary(
            @PathVariable @NotBlank String accountId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,

            HttpServletRequest request) {
/*
        log.info("Solicitando resumen de transacciones para cuenta {} desde {} hasta {}", accountId, from, to);

        AuthCredentials credentials = AuthUtil.getCredentials();
        log.info("Usuario {} solicitando resumen de transacciones para cuenta {}",
                credentials.getEmail(), accountId);
*/
        TransactionsResponseDTO summary = conectaService.getTransactionsSummary(accountId, from, to);

        return ResponseEntity.ok(ApiResponse.ok(
                "Resumen de transacciones obtenido exitosamente",
                summary,
                request.getRequestURI()
        ));
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
