package org.kuenteco.backend.service.subscription.wompi;

import java.math.BigDecimal;
import java.security.NoSuchAlgorithmException;
import org.kuenteco.backend.dto.subscription.wompi.request.WompiTokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.wompi.request.WompiTransactionRequestDTO;
import org.kuenteco.backend.dto.subscription.wompi.response.WompiTokenResponseDTO;
import org.kuenteco.backend.dto.subscription.wompi.response.WompiTransactionResponseDTO;
import org.kuenteco.backend.enums.CurrencyType;

public interface WompiService {
    WompiTokenResponseDTO tokenizeCard(WompiTokenizeCardRequestDTO request);

    WompiTransactionResponseDTO createTransaction(WompiTransactionRequestDTO request);

    WompiTransactionResponseDTO getTransaction(String transactionId);

    String generateSignature(
            String reference, BigDecimal amount, CurrencyType currency, String integritySecret)
            throws NoSuchAlgorithmException;
}
