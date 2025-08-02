package org.kuenteco.backend.dto.logic.category;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.logic.budget.BudgetDTO;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.TransactionDetailDTO;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CategoryReportDTO {
    private CategoryDTO category;
    private BudgetDTO budget;
    private BigDecimal totalSpent;
    private BigDecimal totalIncome;
    private BigDecimal categoryRemainingBudget;
    private Integer transactionCount;
    private List<TransactionDetailDTO> transactions;
    private LocalDateTime reportGeneratedAt;
}
