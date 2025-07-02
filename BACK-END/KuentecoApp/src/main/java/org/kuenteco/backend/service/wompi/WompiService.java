package org.kuenteco.backend.service.wompi;

import org.kuenteco.backend.dto.subscription.request.WompiTokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.request.WompiTransactionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.WompiTokenResponseDTO;
import org.kuenteco.backend.dto.subscription.response.WompiTransactionResponseDTO;

import java.math.BigDecimal;

public interface WompiService {
    WompiTokenResponseDTO tokenizeCard(WompiTokenizeCardRequestDTO request);

    WompiTransactionResponseDTO createTransaction(WompiTransactionRequestDTO request);

    WompiTransactionResponseDTO getTransaction(String transactionId);

    String generateSignature(String reference, BigDecimal amount, String currency, String integritySecret);
}
