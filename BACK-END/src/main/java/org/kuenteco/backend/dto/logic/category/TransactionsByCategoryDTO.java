package org.kuenteco.backend.dto.logic.category;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionsByCategoryDTO {
    private Integer categoryId;
    private String categoryName;
    private Integer ownerUserId;
    private BigDecimal totalIncome;
    private BigDecimal totalExpenses;
    private BigDecimal netAmount;
    private Long transactionCount;
    private Long incomeCount;
    private Long expenseCount;
}
