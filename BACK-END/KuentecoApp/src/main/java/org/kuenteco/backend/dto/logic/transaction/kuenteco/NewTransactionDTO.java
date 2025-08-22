package org.kuenteco.backend.dto.logic.transaction.kuenteco;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;
import org.kuenteco.backend.validation.ValidCurrency;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class NewTransactionDTO {
    @Positive(message = "El ID de categoría debe ser un número positivo")
    private Integer categoryId;

    @Positive(message = "El ID de presupuesto debe ser un número positivo")
    private Integer budgetId;

    @Positive(message = "El ID de deuda debe ser un número positivo")
    private Integer debtId;

    @NotBlank(message = "El nombre de la transacción es requerido")
    @Size(min = 3, max = 255, message = "El nombre debe tener entre 3 y 255 caracteres")
    private String name;

    @Valid
    @NotNull(message = "La descripción de la transacción es requerida")
    private DescriptionTransaction description;

    @NotNull(message = "El monto es requerido")
    @ValidCurrency(
            min = 0.01,
            max = 999999999.99,
            message = "El monto debe ser un valor monetario válido")
    private BigDecimal amount;
}
