package com.example.back_end.connector.rest.category;

import com.example.back_end.enums.State;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DescriptionCategory {
    private BigDecimal assignedBudget;

    private State state;
}
