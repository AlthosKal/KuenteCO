package org.kuenteco.backend.service.subscription.wompi;

import java.security.NoSuchAlgorithmException;
import org.kuenteco.backend.dto.subscription.wompi.request.api.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.wompi.response.api.SubscriptionPaymentResponseDTO;

public interface SubscriptionPaymentService {
    SubscriptionPaymentResponseDTO createSubscriptionPayment(CreateSubscriptionRequestDTO request)
            throws NoSuchAlgorithmException;

    SubscriptionPaymentResponseDTO getSubscriptionStatus(Integer subscriptionId);
}
