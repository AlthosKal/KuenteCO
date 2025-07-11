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
public class SpendingPatternResponseDTO extends BaseDynamicResponseDTO {
    private List<String> categoriesWithHighestSpending;
    private double monthlyAverageIncome;
    private double monthlyAverageSpending;
    private List<String> spendingTrends;

    public SpendingPatternResponseDTO(
            String summary,
            String analysis,
            List<String> categoriesWithHighestSpending,
            double monthlyAverageIncome,
            double monthlyAverageSpending,
            List<String> spendingTrends) {
        super();
        this.setType(ResponseType.SPENDING_PATTERNS);
        this.setSummary(summary);
        this.setAnalysis(analysis);
        this.categoriesWithHighestSpending = categoriesWithHighestSpending;
        this.monthlyAverageIncome = monthlyAverageIncome;
        this.monthlyAverageSpending = monthlyAverageSpending;
        this.spendingTrends = spendingTrends;
    }
}
