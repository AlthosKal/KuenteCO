package org.kuenteco.backend.entity.slave.extra;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SlaveDescriptionCategory implements Serializable {
    private String name;
    private BigDecimal assignedBudget;
    private String startDate;
    private String finishDate;
    private String state;
}

