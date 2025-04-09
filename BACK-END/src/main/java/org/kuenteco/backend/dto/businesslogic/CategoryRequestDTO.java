package org.kuenteco.backend.dto.businesslogic;

import org.kuenteco.backend.entity.extra.DescriptionCategory;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class CategoryRequestDTO {
    private Integer accountId;
    private Integer assetId;
    private String name;
    private DescriptionCategory description;
    private BigDecimal assignedBudget;
    private Timestamp startDate;
    private Timestamp finishDate;
}
