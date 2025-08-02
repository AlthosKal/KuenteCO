package com.example.back_end.dto.response.ai;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DebtRiskAnalysisDTO {
    private double totalDebt;
    private double monthlyDebtPayment;
    private String debtToIncomeRatio; // Ej: "37.5%"
    private String riskLevel; // Bajo / Medio / Alto
    private List<String> actionPlan;
}
