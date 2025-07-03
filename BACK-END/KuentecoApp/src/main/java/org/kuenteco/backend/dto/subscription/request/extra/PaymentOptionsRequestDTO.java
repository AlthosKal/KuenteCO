package org.kuenteco.backend.dto.subscription.request.extra;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentOptionsRequestDTO {

    @Min(value = 1, message = "El número de cuotas debe ser mínimo 1")
    @Max(value = 36, message = "El número de cuotas no puede exceder 36")
    private Integer installments = 1; // Valor por defecto
}
