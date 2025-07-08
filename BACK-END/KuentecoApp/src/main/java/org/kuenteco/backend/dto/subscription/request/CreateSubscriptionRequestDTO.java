package org.kuenteco.backend.dto.subscription.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CreateSubscriptionRequestDTO {
    @NotNull(message = "El tipo de suscripción es requerido")
    private SubscriptionType subscriptionType;

    private String backUrl; // URL de retorno después del pago (opcional)
}
