package org.kuenteco.backend.service.logic.transaction.kuenteco;

import org.kuenteco.backend.dto.logic.transaction.kuenteco.NewTransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.UpdateTransactionDTO;

public interface TransactionService {
    Object getTransactions();

    Object getTransactionSummary();

    void addTransaction(NewTransactionDTO dto);

    void updateTransaction(UpdateTransactionDTO dto);

    void deleteTransaction(Integer id);
}
