package org.kuenteco.backend.dto.subscription.request.api;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateSubscriptionRequestDTO {
    @NotNull(message = "El tipo de suscripción es obligatorio")
    private SubscriptionType subscriptionType;

    private Integer paymentTokenId; // Si ya tiene un token guardado
    private TokenizeCardRequestDTO cardInfo; // Si necesita tokenizar una nueva tarjeta
}
