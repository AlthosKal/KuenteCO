package org.kuenteco.backend.dto.logic.budget;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BudgetDTO {
    private Integer id;
    private BigDecimal totalBudget;
    private BigDecimal remainingBudget;
}
