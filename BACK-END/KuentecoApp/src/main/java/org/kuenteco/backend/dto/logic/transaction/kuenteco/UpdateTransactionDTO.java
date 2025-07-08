package org.kuenteco.backend.dto.logic.transaction.kuenteco;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateTransactionDTO {
    @NotNull private Integer id;
    @NotNull private Integer categoryId;
    @NotNull private Integer budgetId;
    @NotNull private Integer debtId;
    @NotNull private DescriptionTransaction description;
    @NotNull private BigDecimal amount;
}
