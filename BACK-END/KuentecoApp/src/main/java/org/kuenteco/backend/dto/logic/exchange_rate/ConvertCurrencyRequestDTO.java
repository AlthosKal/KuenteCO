package org.kuenteco.backend.dto.logic.exchange_rate;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.validation.ValidCurrency;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ConvertCurrencyRequestDTO {
    @NotNull(message = "El monto es requerido")
    @ValidCurrency(
            min = 0.01,
            max = 999999999.99,
            message = "El monto debe ser un valor monetario válido para conversión")
    private BigDecimal amount;

    @NotBlank(message = "La moneda base es requerida")
    @Size(
            min = 3,
            max = 3,
            message = "La moneda base debe tener exactamente 3 caracteres (código ISO)")
    private String baseCurrency;

    @NotBlank(message = "La moneda objetivo es requerida")
    @Size(
            min = 3,
            max = 3,
            message = "La moneda objetivo debe tener exactamente 3 caracteres (código ISO)")
    private String targetCurrency;
}
