package org.kuenteco.backend.dto.subscription.request.api;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.subscription.request.extra.PaymentOptionsRequestDTO;
import org.kuenteco.backend.dto.subscription.request.extra.WompiCustomerDataDTO;
import org.kuenteco.backend.dto.subscription.request.extra.WompiShippingAddressDTO;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateSubscriptionRequestDTO {
    @NotNull(message = "El tipo de suscripción es obligatorio")
    private SubscriptionType subscriptionType;

    // Para usar Token existente
    private Integer paymentTokenId;
    // Para tokenizar nueva tarjeta
    @Valid private TokenizeCardRequestDTO cardInfo;

    // Nuevos campos obligatorios para evitar hardcodeo
    @NotNull(message = "La dirección de envío es obligatoria")
    @Valid
    private WompiShippingAddressDTO shippingAddress;

    @NotNull(message = "Los datos del cliente son obligatorios")
    @Valid
    private WompiCustomerDataDTO customerData;

    // Campo opcional para opciones de pago
    @Valid private PaymentOptionsRequestDTO paymentOptions;

    // Método para obtener installments con valor por defecto
    public Integer getInstallments() {
        return paymentOptions != null && paymentOptions.getInstallments() != null
                ? paymentOptions.getInstallments()
                : 1;
    }
}
