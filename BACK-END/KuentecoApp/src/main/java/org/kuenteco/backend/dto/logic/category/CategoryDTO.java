package org.kuenteco.backend.dto.logic.category;

import jakarta.validation.constraints.Positive;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionCategory;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoryDTO {
    @Positive private Integer id;
    @Positive private Integer budgetId;
    private String name;
    private DescriptionCategory description;
    private LocalDateTime startDate;
    private LocalDateTime finishDate;
}
