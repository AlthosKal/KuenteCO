package org.kuenteco.backend.service.subscription;

import java.security.NoSuchAlgorithmException;
import org.kuenteco.backend.dto.subscription.request.api.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.api.SubscriptionPaymentResponseDTO;

public interface SubscriptionPaymentService {
    SubscriptionPaymentResponseDTO createSubscriptionPayment(CreateSubscriptionRequestDTO request)
            throws NoSuchAlgorithmException;

    SubscriptionPaymentResponseDTO getSubscriptionStatus(Integer subscriptionId);
}
