package com.example.back_end.dto.response.ai;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FinancialHealthScoreDTO {
    private int score; // 0 - 100
    private String grade; // Ej: "Bueno", "Aceptable", "Crítico"
    private List<String> suggestions;
}
