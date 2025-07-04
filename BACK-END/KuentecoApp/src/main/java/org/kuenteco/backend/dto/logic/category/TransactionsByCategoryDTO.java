package org.kuenteco.backend.dto.logic.category;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

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
