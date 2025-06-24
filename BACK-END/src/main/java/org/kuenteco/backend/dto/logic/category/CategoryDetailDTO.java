package org.kuenteco.backend.dto.logic.category;

import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.logic.budget.BudgetDetailDTO;
import org.kuenteco.backend.entity.extra.DescriptionCategory;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoryDetailDTO {
    private Integer id;
    private BudgetDetailDTO budget;
    private DescriptionCategory description;
    private BigDecimal assignedBudget;
    private Timestamp startDate;
    private Timestamp finishDate;
}
