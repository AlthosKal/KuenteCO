package com.example.back_end.dto.response.ai;

import com.example.back_end.enums.ResponseType;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class DebtAnalysisResponseDTO extends BaseDynamicResponseDTO {
    private DebtRiskAnalysisDTO debtAnalysis;
    private List<String> recommendations;

    public DebtAnalysisResponseDTO(
            String summary,
            String analysis,
            DebtRiskAnalysisDTO debtAnalysis,
            List<String> recommendations) {
        super();
        this.setType(ResponseType.DEBT_ANALYSIS);
        this.setSummary(summary);
        this.setAnalysis(analysis);
        this.debtAnalysis = debtAnalysis;
        this.recommendations = recommendations;
    }
}
