package com.example.back_end.dto.response.ai;

import com.example.back_end.enums.ResponseType;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, property = "type")
@JsonSubTypes({
    @JsonSubTypes.Type(value = SimpleTextResponseDTO.class, name = "SIMPLE_TEXT"),
    @JsonSubTypes.Type(value = ChartDataResponseDTO.class, name = "CHART_DATA"),
    @JsonSubTypes.Type(value = DebtAnalysisResponseDTO.class, name = "DEBT_ANALYSIS"),
    @JsonSubTypes.Type(value = SpendingPatternResponseDTO.class, name = "SPENDING_PATTERNS"),
    @JsonSubTypes.Type(value = FinancialHealthResponseDTO.class, name = "FINANCIAL_HEALTH"),
    @JsonSubTypes.Type(value = ExpenseReductionResponseDTO.class, name = "EXPENSE_SUGGESTIONS"),
    @JsonSubTypes.Type(value = FinancialProjectionResponseDTO.class, name = "FINANCIAL_PROJECTION"),
    @JsonSubTypes.Type(value = ReportDownloadResponseDTO.class, name = "REPORT_DOWNLOAD")
})
public abstract class BaseDynamicResponseDTO {
    private ResponseType type;
    private String summary;
    private String analysis;
}
