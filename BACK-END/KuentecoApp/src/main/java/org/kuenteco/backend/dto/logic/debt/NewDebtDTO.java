package org.kuenteco.backend.dto.logic.debt;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.StateDebt;
import org.kuenteco.backend.validation.FutureDate;
import org.kuenteco.backend.validation.ValidCurrency;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NewDebtDTO {

    private Integer transactionId;

    @NotBlank(message = "El nombre de la deuda es obligatorio")
    private String name;

    @NotNull(message = "El monto total es obligatorio")
    @ValidCurrency(
            min = 0.01,
            max = 999999999.99,
            message = "El monto total debe ser un valor monetario válido")
    private BigDecimal totalAmount;

    @NotNull(message = "El monto pendiente es obligatorio")
    @ValidCurrency(
            min = 0.01,
            max = 999999999.99,
            message = "El monto pendiente debe ser un valor monetario válido")
    private BigDecimal pendingAmount;

    @NotNull(message = "La fecha de inicio es obligatoria")
    private LocalDateTime startDate;

    @NotNull(message = "La fecha de vencimiento es obligatoria")
    @FutureDate(
            minDaysInFuture = 1,
            maxDaysInFuture = 7300,
            message = "La fecha de vencimiento debe ser futura (entre 1 día y 20 años)")
    private LocalDateTime expirationDate;

    private StateDebt state;
}
