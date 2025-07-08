package org.kuenteco.backend.dto.logic.transaction.kuenteco;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewTransactionDTO {
    private Integer categoryId;
    private Integer budgetId;
    private Integer debtId;
    @Valid @NotNull private DescriptionTransaction description;
    @NotNull private BigDecimal amount;
}
