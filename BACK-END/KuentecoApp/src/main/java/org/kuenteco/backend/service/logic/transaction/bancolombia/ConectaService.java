package org.kuenteco.backend.service.logic.transaction.bancolombia;

import org.kuenteco.backend.dto.logic.transaction.bancolombia.AccountDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.TransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.TransactionsResponseDTO;

import java.time.LocalDate;
import java.util.List;

public interface ConectaService {

    /**
     * Obtiene todas las cuentas disponibles para el usuario autenticado.
     */
    List<AccountDTO> getAccounts();

    /**
     * Obtiene una cuenta específica por su ID.
     */
    AccountDTO getAccount(String accountId);

    /**
     * Obtiene transacciones para una cuenta entre dos fechas.
     */
    List<TransactionDTO> getTransactions(String accountId, LocalDate fromDate, LocalDate toDate);

    /**
     * Obtiene las transacciones del último mes para una cuenta.
     */
    List<TransactionDTO> getRecentTransactions(String accountId);

    /**
     * Obtiene las transacciones de los últimos N días para una cuenta.
     */
    List<TransactionDTO> getTransactionsForPeriod(String accountId, int days);

    /**
     * Obtiene la respuesta completa con resumen de transacciones para una cuenta.
     */
    TransactionsResponseDTO getTransactionsSummary(String accountId, LocalDate fromDate, LocalDate toDate);
}
