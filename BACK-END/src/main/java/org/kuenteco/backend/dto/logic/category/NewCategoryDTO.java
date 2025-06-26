package org.kuenteco.backend.dto.logic.category;

import jakarta.validation.constraints.NotBlank;
import java.sql.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.logic.budget.BudgetDTO;
import org.kuenteco.backend.entity.extra.DescriptionCategory;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NewCategoryDTO {
    @NotBlank private BudgetDTO budget;
    @NotBlank private DescriptionCategory description;
    @NotBlank private Timestamp startDate;
    @NotBlank private Timestamp finishDate;
}
