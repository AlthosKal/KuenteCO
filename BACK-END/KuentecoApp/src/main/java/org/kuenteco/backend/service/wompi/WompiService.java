package org.kuenteco.backend.service.wompi;

import java.math.BigDecimal;
import java.security.NoSuchAlgorithmException;
import org.kuenteco.backend.dto.subscription.request.WompiTokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.request.WompiTransactionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.WompiTokenResponseDTO;
import org.kuenteco.backend.dto.subscription.response.WompiTransactionResponseDTO;
import org.kuenteco.backend.enums.CurrencyType;

public interface WompiService {
    WompiTokenResponseDTO tokenizeCard(WompiTokenizeCardRequestDTO request);

    WompiTransactionResponseDTO createTransaction(WompiTransactionRequestDTO request);

    WompiTransactionResponseDTO getTransaction(String transactionId);

    String generateSignature(
            String reference, BigDecimal amount, CurrencyType currency, String integritySecret)
            throws NoSuchAlgorithmException;
}
