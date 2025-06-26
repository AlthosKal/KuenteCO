package org.kuenteco.backend.dto.logic.category;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.logic.budget.BudgetDetailDTO;
import org.kuenteco.backend.entity.extra.DescriptionCategory;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NewCategoryDTO {
    private BudgetDetailDTO budget;
    private DescriptionCategory description;
    private Timestamp startDate;
    private Timestamp finishDate;
}
