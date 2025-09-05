package org.kuenteco.backend.dto.logic.debt;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DebtEnrollmentDTO {
    @NotBlank private String userEmail;
    @NotBlank private String profileEmail;
    private Integer debtId;
    @NotBlank private String debtName;
}
