package org.kuenteco.backend.service.subscription.wompi;

import java.util.List;
import org.kuenteco.backend.dto.subscription.wompi.request.api.TokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.wompi.response.api.PaymentTokenResponseDTO;

public interface PaymentTokenService {
    PaymentTokenResponseDTO tokenizeAndSaveCard(TokenizeCardRequestDTO request);

    List<PaymentTokenResponseDTO> getUserActiveTokens();
}
