package com.example.back_end.dto.response;

import com.example.back_end.dto.response.ai.ChartDataResponseDTO;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class StringChatResponseDTO {
    private String conversationId;
    private String response;
    private ChartDataResponseDTO chartData;
}
