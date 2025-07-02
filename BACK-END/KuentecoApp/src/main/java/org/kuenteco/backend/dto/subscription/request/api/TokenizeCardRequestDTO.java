package org.kuenteco.backend.dto.subscription.request.api;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.validations.PayMethodConstraint;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@PayMethodConstraint
public class TokenizeCardRequestDTO {
    @NotBlank(message = "El número de tarjeta es obligatorio")
    @Pattern(regexp = "^\\d{13,19}$", message = "Número de tarjeta inválido")
    private String cardNumber;

    @NotBlank(message = "El CVC es obligatorio")
    @Pattern(regexp = "^\\d{3,4}$", message = "CVC inválido")
    private String cvc;

    @NotBlank(message = "El mes de expiración es obligatorio")
    @Pattern(regexp = "^(0[1-9]|1[0-2])$", message = "Mes inválido")
    private String expiryMonth;

    @NotBlank(message = "El año de expiración es obligatorio")
    @Pattern(regexp = "^20\\d{2}$", message = "Año inválido")
    private String expiryYear;

    @NotBlank(message = "El nombre del titular es obligatorio")
    private String cardHolder;
}
