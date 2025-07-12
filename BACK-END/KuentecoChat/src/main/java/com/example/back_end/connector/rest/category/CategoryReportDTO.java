package com.example.back_end.connector.rest.category;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import com.example.back_end.connector.rest.budget.BudgetDTO;
import com.example.back_end.connector.rest.transaction.TransactionDetailDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

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

