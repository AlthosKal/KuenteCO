package org.kuenteco.backend.dto.logic.transaction;

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
    @NotNull private Integer categoryId;
    @NotNull private Integer budgetId;
    @NotNull private DescriptionTransaction description;
    @NotNull private BigDecimal amount;
}
