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
