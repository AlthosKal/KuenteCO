package com.example.back_end.dto.response.ai;

import com.example.back_end.enums.ResponseType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class FinancialHealthResponseDTO extends BaseDynamicResponseDTO {
    private FinancialHealthScoreDTO healthScore;

    public FinancialHealthResponseDTO(
            String summary, String analysis, FinancialHealthScoreDTO healthScore) {
        super();
        this.setType(ResponseType.FINANCIAL_HEALTH);
        this.setSummary(summary);
        this.setAnalysis(analysis);
        this.healthScore = healthScore;
    }
}
