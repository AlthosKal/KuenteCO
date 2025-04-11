package org.kuenteco.backend.dto.businesslogic;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.kuenteco.backend.enums.State;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CategoryRequestDTO {
    private Integer accountId;
    private Integer assetId;
    private String name;
    private String description;
    private BigDecimal assignedBudget;
    private Timestamp startDate;
    private Timestamp finishDate;
    private State state;
}
