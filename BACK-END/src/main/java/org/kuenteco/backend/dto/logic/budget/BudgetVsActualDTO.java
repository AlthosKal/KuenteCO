package org.kuenteco.backend.dto.logic.budget;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BudgetVsActualDTO {
    private Integer categoryId;
    private String categoryName;
    private Integer budgetId;
    private String budgetName;
    private BigDecimal assignedAmount;
    private BigDecimal remainingBudget;
    private Integer ownerUserId;
    private BigDecimal actualSpent;
    private BigDecimal calculatedRemaining;
    private BigDecimal percentageUsed;
    private String budgetStatus;
}

