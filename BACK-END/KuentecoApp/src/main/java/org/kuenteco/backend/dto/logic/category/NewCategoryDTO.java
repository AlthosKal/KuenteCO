package org.kuenteco.backend.dto.logic.category;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionCategory;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NewCategoryDTO {
    private Integer budgetId;
    @Valid private DescriptionCategory description;
    @NotNull private LocalDateTime startDate;
    @NotNull private LocalDateTime finishDate;
}
