package org.kuenteco.backend.dto.logic.budget;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.validation.ValidCurrency;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewBudgetDTO {
    @NotBlank(message = "El nombre del presupuesto es requerido")
    @Size(min = 3, max = 100, message = "El nombre debe tener entre 3 y 100 caracteres")
    private String name;

    @NotNull(message = "El presupuesto total es requerido")
    @ValidCurrency(
            min = 0.01,
            max = 999999999.99,
            message = "El presupuesto total debe ser un valor monetario válido")
    private BigDecimal totalBudget;

    @NotNull(message = "El presupuesto restante es requerido")
    @ValidCurrency(
            min = 0.00,
            max = 999999999.99,
            allowNegative = false,
            message = "El presupuesto restante debe ser un valor monetario válido")
    private BigDecimal remainingBudget;
}
