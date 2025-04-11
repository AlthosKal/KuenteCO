package org.kuenteco.backend.dto.businesslogic;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BudgetResponseDTO {
    private Integer id;
    private Integer accountId;
    private String accountName;
    private BigDecimal totalBudget;
    private BigDecimal remainingBudget;
    private BigDecimal usedPercentage;

    // Se puede agregar un método para calcular el porcentaje usado
    public void calculateUsedPercentage() {
        if (totalBudget != null && totalBudget.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal used = totalBudget.subtract(remainingBudget);
            usedPercentage = used.multiply(new BigDecimal("100")).divide(totalBudget, 2, BigDecimal.ROUND_HALF_UP);
        } else {
            usedPercentage = BigDecimal.ZERO;
        }
    }
}