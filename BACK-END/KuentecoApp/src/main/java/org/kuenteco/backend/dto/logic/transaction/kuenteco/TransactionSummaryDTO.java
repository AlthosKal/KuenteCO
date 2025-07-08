package org.kuenteco.backend.dto.logic.transaction.kuenteco;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionSummaryDTO {
    private Integer ownerUserId;
    private String transactionOwnerType;
    private Integer profileId;
    private String categoryName;
    private String budgetName;
    private String debtName;
    private Long transactionCount;
    private Long incomeCount;
    private Long expenseCount;
    private BigDecimal totalIncome;
    private BigDecimal totalExpenses;
    private BigDecimal netAmount;
    private LocalDateTime firstTransactionDate;
    private LocalDateTime lastTransactionDate;
}
