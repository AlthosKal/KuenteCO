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
public class BudgetSummaryDTO {
    private String userId;
    private String ownerUserId; // Para consistencia con las vistas
    private String username;
    private Long totalBudgets;
    private BigDecimal totalBudgetAmount;
    private BigDecimal totalRemainingAmount;
    private BigDecimal totalSpentAmount;
    private BigDecimal overallPercentageUsed;
}
