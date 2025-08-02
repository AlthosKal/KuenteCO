package com.example.back_end.dto.response.ai;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FinancialProjectionDTO {
    private double projectedBalanceIn3Months;
    private boolean riskOfDeficit;
    private String monthWithNegativeBalance;
    private String recommendation;
}
