package org.kuenteco.backend.service.subscription.mercado_pago;

import org.kuenteco.backend.dto.subscription.mercado_pago.request.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.mercado_pago.response.CreateSubscriptionResponseDTO;
import org.kuenteco.backend.dto.subscription.mercado_pago.response.SubscriptionResponseDTO;

public interface MercadoPagoService {

    /** Crea una suscripción en MercadoPago con los datos del usuario y el plan deseado. */
    CreateSubscriptionResponseDTO createSubscription(
            CreateSubscriptionRequestDTO request, String userEmail);

    /** Obtiene el estado de una suscripción específica por su preapprovalId. */
    SubscriptionResponseDTO getSubscription(String preapprovalId, String userEmail);
}
