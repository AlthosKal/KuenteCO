package org.kuenteco.backend.dto.logic.budget;

import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BudgetEnrollmentDTO {
    @NotBlank private String userEmail;
    @NotBlank private String profileEmail;
    @NotBlank private BigDecimal totalBudget;
    @NotBlank private BigDecimal remainingBudget;
}
