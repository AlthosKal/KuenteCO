package org.kuenteco.backend.dto.logic.transaction;

import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.logic.budget.BudgetDTO;
import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewTransactionDTO {
    @NotBlank private CategoryDTO category;
    @NotBlank private BudgetDTO budget;
    @NotBlank private DescriptionTransaction description;
    @NotBlank private BigDecimal amount;
}
