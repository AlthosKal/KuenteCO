package org.kuenteco.backend.dto.logic.transaction;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.logic.budget.BudgetDetailDTO;
import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateTransactionDTO {
    private Integer id;
    private CategoryDTO category;
    private BudgetDetailDTO budget;
    private DescriptionTransaction description;
    private BigDecimal amount;
}
