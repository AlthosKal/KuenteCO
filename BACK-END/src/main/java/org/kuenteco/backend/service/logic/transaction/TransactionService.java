package org.kuenteco.backend.service.logic.transaction;

import org.kuenteco.backend.dto.logic.transaction.NewTransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.UpdateTransactionDTO;

public interface TransactionService {
    Object getTransactions();

    void registerTransaction(NewTransactionDTO dto);

    void updateTransaction(UpdateTransactionDTO dto);

    void deleteTransaction(Integer id);
}
