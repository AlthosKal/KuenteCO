package org.kuenteco.backend.dto.logic.budget;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewBudgetDTO {
    private String name;
    private BigDecimal totalBudget;
    private BigDecimal remainingBudget;
}
