package org.kuenteco.backend.dto.logic.debt;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.StateDebt;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NewDebtDTO {

    private Integer transactionId;

    @NotBlank(message = "El nombre de la deuda es obligatorio")
    private String name;

    @NotNull(message = "El monto total es obligatorio")
    @Positive(message = "El monto total debe ser positivo")
    private BigDecimal totalAmount;

    @NotNull(message = "El monto pendiente es obligatorio")
    @Positive(message = "El monto pendiente debe ser positivo")
    private BigDecimal pendingAmount;

    @NotNull private LocalDateTime startDate;

    @NotNull(message = "La fecha de vencimiento es obligatoria")
    private LocalDateTime expirationDate;

    private StateDebt state;
}
