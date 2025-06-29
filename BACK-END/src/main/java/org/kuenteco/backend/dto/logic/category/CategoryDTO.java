package org.kuenteco.backend.dto.logic.category;

import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionCategory;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoryDTO {
    @NotBlank private Integer id;
    @NotBlank private Integer budgetId;
    @NotBlank private DescriptionCategory description;
    private LocalDateTime startDate;
    private LocalDateTime finishDate;
}
