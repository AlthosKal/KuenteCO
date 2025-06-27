package org.kuenteco.backend.dto.logic.debt;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.StateDebt;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DebtDTO {

    @NotNull(message = "El ID de la deuda es obligatorio")
    private Integer id;

    private String userId;

    private Integer transactionId;

    @NotBlank(message = "El nombre de la deuda es obligatorio")
    private String name;

    @NotNull(message = "El monto total es obligatorio")
    @Positive(message = "El monto total debe ser positivo")
    private BigDecimal totalAmount;

    @NotNull(message = "El monto pendiente es obligatorio")
    private BigDecimal pendingAmount;

    @NotNull(message = "La fecha de inicio es obligatoria")
    private Timestamp startDate;

    @NotNull(message = "La fecha de vencimiento es obligatoria")
    private Timestamp expirationDate;

    @NotNull(message = "El estado de la deuda es obligatorio")
    private StateDebt state;
}
