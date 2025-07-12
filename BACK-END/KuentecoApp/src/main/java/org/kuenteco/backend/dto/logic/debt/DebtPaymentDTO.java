package org.kuenteco.backend.dto.logic.debt;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.validation.ValidCurrency;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DebtPaymentDTO {

    @NotNull(message = "El ID de la deuda es obligatorio")
    private Integer debtId;

    @NotNull(message = "El monto del pago es obligatorio")
    @ValidCurrency(
            min = 0.01,
            max = 999999999.99,
            message = "El monto del pago debe ser un valor monetario válido")
    private BigDecimal paymentAmount;

    private String description;

    private LocalDateTime paymentDate;
}
