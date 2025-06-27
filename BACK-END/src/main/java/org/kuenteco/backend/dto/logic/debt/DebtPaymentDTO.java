package org.kuenteco.backend.dto.logic.debt;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DebtPaymentDTO {

    @NotNull(message = "El ID de la deuda es obligatorio")
    private Integer debtId;

    @NotNull(message = "El monto del pago es obligatorio")
    @Positive(message = "El monto del pago debe ser positivo")
    private BigDecimal paymentAmount;

    private String description;

    private Timestamp paymentDate = new Timestamp(System.currentTimeMillis());
}
