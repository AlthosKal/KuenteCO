package com.example.back_end.dto.response.ai;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExpenseReductionSuggestionDTO {
    private String category;
    private double current;
    private double suggested;
    private String recommendation;
}
