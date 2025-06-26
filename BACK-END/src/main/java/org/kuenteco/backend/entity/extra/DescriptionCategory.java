package org.kuenteco.backend.entity.extra;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.State;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DescriptionCategory {
    private String name;
    private BigDecimal assignedBudget;
    @Enumerated(EnumType.STRING)
    private State state;
}
