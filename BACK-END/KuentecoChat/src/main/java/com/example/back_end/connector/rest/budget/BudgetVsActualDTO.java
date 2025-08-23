package com.example.back_end.connector.rest.budget;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BudgetVsActualDTO {
    private String ownerUserId;
    private Integer categoryId;
    private Integer budgetId;
    private String categoryName;
    private String budgetName;
    private BigDecimal assignedAmount;
    private BigDecimal remainingBudget;
    private BigDecimal actualSpent;
    private BigDecimal calculatedRemaining;
    private BigDecimal percentageUsed;
    private String budgetStatus;
}
