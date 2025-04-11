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
public class CategoryResponseDTO {
    private Integer id;
    private Integer accountId;
    private Integer assetId;
    private String name;
    private String description;
    private BigDecimal assignedBudget;
    private BigDecimal usedBudget;
    private BigDecimal remainingBudget;
    private BigDecimal usedPercentage;
    private Timestamp startDate;
    private Timestamp finishDate;
    private State state;

    // Método para calcular el porcentaje usado
    public void calculateUsedPercentage() {
        if (assignedBudget != null && assignedBudget.compareTo(BigDecimal.ZERO) > 0) {
            usedPercentage = usedBudget.multiply(new BigDecimal("100")).divide(assignedBudget, 2,
                    BigDecimal.ROUND_HALF_UP);
        } else {
            usedPercentage = BigDecimal.ZERO;
        }
    }
}
