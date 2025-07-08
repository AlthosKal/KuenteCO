package org.kuenteco.backend.service.subscription;

import org.kuenteco.backend.dto.subscription.request.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.CreateSubscriptionResponseDTO;
import org.kuenteco.backend.dto.subscription.response.SubscriptionResponseDTO;

public interface MercadoPagoService {

    /** Crea una suscripción en MercadoPago con los datos del usuario y el plan deseado. */
    CreateSubscriptionResponseDTO createSubscription(
            CreateSubscriptionRequestDTO request, String userEmail);

    /** Obtiene el estado de una suscripción específica por su preapprovalId. */
    SubscriptionResponseDTO getSubscription(String preapprovalId, String userEmail);
}
