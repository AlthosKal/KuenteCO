package org.kuenteco.backend.dto.businesslogic;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BalanceDTO {
    private BigDecimal totalAssets;
    private BigDecimal totalDebts;
    private BigDecimal equity;
    private BigDecimal totalBudget;
    private BigDecimal remainingBudget;
}
