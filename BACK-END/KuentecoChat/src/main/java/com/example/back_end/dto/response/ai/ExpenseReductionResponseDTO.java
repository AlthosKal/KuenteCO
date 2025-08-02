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
public class ExpenseReductionResponseDTO extends BaseDynamicResponseDTO {
    private List<ExpenseReductionSuggestionDTO> suggestions;
    private double totalPotentialSavings;

    public ExpenseReductionResponseDTO(
            String summary,
            String analysis,
            List<ExpenseReductionSuggestionDTO> suggestions,
            double totalPotentialSavings) {
        super();
        this.setType(ResponseType.EXPENSE_SUGGESTIONS);
        this.setSummary(summary);
        this.setAnalysis(analysis);
        this.suggestions = suggestions;
        this.totalPotentialSavings = totalPotentialSavings;
    }
}
