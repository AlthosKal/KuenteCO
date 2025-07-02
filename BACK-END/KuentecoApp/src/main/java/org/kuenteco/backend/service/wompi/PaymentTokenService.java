package org.kuenteco.backend.service.wompi;

import org.kuenteco.backend.dto.subscription.request.api.TokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.response.api.PaymentTokenResponseDTO;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.UserPaymentToken;

import java.util.List;

public interface PaymentTokenService {
    PaymentTokenResponseDTO tokenizeAndSaveCard(User user, TokenizeCardRequestDTO request);

    void deactivatePreviousTokens(User user);

    List<PaymentTokenResponseDTO> getUserActiveTokens(User user);

    UserPaymentToken getActiveTokenById(Integer tokenId, User user);
}
