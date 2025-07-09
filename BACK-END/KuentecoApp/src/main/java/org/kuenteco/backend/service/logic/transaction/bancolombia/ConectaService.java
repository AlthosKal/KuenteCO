package org.kuenteco.backend.service.logic.transaction.bancolombia;

import org.kuenteco.backend.dto.logic.transaction.bancolombia.BancolombiaTransactionRequestDTO;

public interface ConectaService {

    String getTransactionsFromRequest(BancolombiaTransactionRequestDTO requestDto);
}
