package org.kuenteco.backend.dto.logic.transaction;

import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.logic.budget.BudgetDetailDTO;
import org.kuenteco.backend.dto.logic.category.CategoryDetailDTO;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;
import org.kuenteco.backend.enums.TransactionType;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransactionDetailDTO {
    private CategoryDetailDTO category;
    private BudgetDetailDTO budget;
    private TransactionType type;
    private BigDecimal amount;
    private Timestamp timestamp;
    private DescriptionTransaction description;
}
