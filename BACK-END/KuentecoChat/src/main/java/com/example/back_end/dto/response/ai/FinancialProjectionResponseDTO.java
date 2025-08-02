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
public class FinancialProjectionResponseDTO extends BaseDynamicResponseDTO {
    private FinancialProjectionDTO projection;

    public FinancialProjectionResponseDTO(
            String summary, String analysis, FinancialProjectionDTO projection) {
        super();
        this.setType(ResponseType.FINANCIAL_PROJECTION);
        this.setSummary(summary);
        this.setAnalysis(analysis);
        this.projection = projection;
    }
}
