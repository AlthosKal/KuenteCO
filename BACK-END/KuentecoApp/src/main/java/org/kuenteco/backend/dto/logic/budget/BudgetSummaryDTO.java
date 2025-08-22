package org.kuenteco.backend.dto.logic.budget;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BudgetSummaryDTO {
    private String ownerUserId;
    private String username;
    private Long totalBudgets;
    private BigDecimal totalBudgetAmount;
    private BigDecimal totalRemainingAmount;
    private BigDecimal totalSpentAmount;
    private BigDecimal overallPercentageUsed;
}
