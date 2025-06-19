package org.kuenteco.backend.entity.extra;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DescriptionCategory {
    private String name;
    private BigDecimal assignedBudget;
    private String startDate;
    private String finishDate;
    private String state;
}
