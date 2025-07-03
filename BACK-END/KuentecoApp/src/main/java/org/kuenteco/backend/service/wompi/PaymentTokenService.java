package org.kuenteco.backend.service.wompi;

import java.util.List;
import org.kuenteco.backend.dto.subscription.request.api.TokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.response.api.PaymentTokenResponseDTO;

public interface PaymentTokenService {
    PaymentTokenResponseDTO tokenizeAndSaveCard(TokenizeCardRequestDTO request);

    List<PaymentTokenResponseDTO> getUserActiveTokens();
}
