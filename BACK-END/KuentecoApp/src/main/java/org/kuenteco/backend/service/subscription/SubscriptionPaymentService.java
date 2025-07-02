package org.kuenteco.backend.service.subscription;

import org.kuenteco.backend.dto.subscription.request.api.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.api.SubscriptionPaymentResponseDTO;
import org.kuenteco.backend.entity.User;

public interface SubscriptionPaymentService {
    SubscriptionPaymentResponseDTO createSubscriptionPayment(User user, CreateSubscriptionRequestDTO request);

    SubscriptionPaymentResponseDTO getSubscriptionStatus(Integer subscriptionId, User user);
}
